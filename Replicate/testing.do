clear
estimates clear
//use "./Work/all_sparse_dist_500.dta" // 
use "./Work/all_crops_data_gadm2.dta"

local sparse "./Work/all_sparse_dist_500.dta"
local objectid objectid // name of the 


capture program drop spreg
program spreg, eclass
	syntax varlist(min=2 fv) [if] [in] [, objectid(varlist) sparse(string)] 
	token `varlist' // tokenize list of passed variables for use

	local e efgzzz // nonsense name for residual variable
	local c cdezzz // nonsense name for constant
	tempfile backup // file for backup
	tempfile results // file for temporary results

	save "`backup'", replace // create copy of dataset

	reg `varlist' `if', robust // run basic regression with robust SEs
	local dfadj = e(df_r)/e(N) // save the Df adjustment
	mat Vrobust = e(V) // save the V/Cov matrix

	local X ln_rurd_2000_res ln_light_mean_res urb_perc_2000_res
	local k : word count `X'
	
	// Save subset of actual data for use in SE calaculation
	capture drop `e' `c'
	predict `e', res
	keep if e(sample)==1 // keep if in sample from regression
	keep `e' `X' `objectid' // keep residuals and X variables and GIS id
	gen `c' = 1 // add a constant
	mkmat `X' `c', matrix(X) // create matrix of X variables and c
	save "`results'", replace // save this limited amount of information necessary

	// Merge data with sparse distance matrix for use in SE calculations
	use `sparse', clear // open the sparse matrix file
	rename home `objectid' // rename for merging
	merge m:1 `objectid' using "`results'" // merge the regression data to the "home" ID
	keep if _merge==3 // only keep data if it matched a row in sparse matrix
	capture drop _merge
		
	foreach v in `e' `X' `c' { // rename all that data to be unique
		rename `v' `v'_i
	}

	rename `objectid' home // put correct name back to home
	rename neighbor `objectid' // rename neighbor for merging
	merge m:1 `objectid' using "`results'" // merge the regression data to the "neighbor" ID
	keep if _merge==3 // only keep data if it matched a row in sparse matrix
	capture drop _merge
	foreach v in `e' `X' `c' { // rename all that data to be unique
		rename `v' `v'_j
	}

	sort `objectid' 
	matrix opaccum A = *_i, group(`objectid') opvar(`e'_j)
	
	// Calculate the off-diagonal terms in the V/Cov matrix due to spatial correlation
	mat Vspatial = J(`k'+1,`k'+1,0) // create matrix to store sums, plus one for constant

	local m = 1 // counter for position in matrix
	foreach v in `X' `c' { // for each X variable and the constant
		qui gen `v'_term = `e'_i*`e'_j*`v'_i*`v'_j // get cross-product term of residuals and X variable
		qui summ `v'_term // summ those cross-products
		mat Vspatial[`m',`m'] = r(sum) // store the summation of those cross-products in the matrix
		local m = `m' + 1 // up the index
	}

	mat invXX = invsym(X'*X) // matrix of inverted X'X
	mat Vadd = invXX*Vspatial*invXX/`dfadj' // create spatial V/C matrix to add to existing V/C matrix from regression

	mat Vtotal = Vrobust + Vadd // combined V/C matrix

	use "`backup'", clear // restore the original dataset
end

foreach v in ln_csi_yield ln_rurd_2000 ln_light_mean urb_perc_2000 {
qui areg `v' if name_0=="China", absorb(state_id)
capture drop `v'_res
predict `v'_res, res
}

spreg ln_csi_yield_res ln_rurd_2000_res ln_light_mean_res urb_perc_2000_res if name_0=="China", objectid(objectid) sparse("./Work/all_sparse_dist_500.dta")

ols_spatial_HAC ln_csi_yield_res ln_rurd_2000_res ln_light_mean_res urb_perc_2000_res if name_0=="China", ///
			lat(y_cent) lon(x_cent) timevar(c) panelvar(c) distcutoff(500) lagcutoff(1)
