//////////////////////////////////////////////////////////////////////////////////////////////////////////
// Main programs to run spatial interaction regression
/////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////
// Run reg with correction for spatial SE
// - Allows for 0/1 variable distinguishing groups (e.g. temp and trop) to compare estimates
/////////////////////////////////////////////////////////////////////////////////////////////////////////
capture program drop hdreg
program hdreg, eclass
	syntax varlist(min=2 fv) [if] [in] [,controls(varlist) fe(varlist fv) dist(real 500) comp(varlist) tag(string)] 
	token `varlist' // tokenize list of passed variables for use
	marksample touse // mark observations to use in regression
	
	capture drop c // must include own constant for spatial OLS
	gen c = 1
	capture drop res_csi // these hold residuals from initial FE regressions
	capture drop res_rurd // all three use actual variables so that post-estimation we can work with results
	capture drop int_rurd
	
	// Remove FE and apply controls to both yield and labor/land ratios to speed up spatial regression
	qui reghdfe `1' `controls' if inlist(`comp',0,1) & `touse', absorb(`fe') residuals(res_csi) // for yield variable
	local df_fe = e(df_a) // this is for adjusting DF of SEs in spatial regression
	qui reghdfe `2' `controls' if inlist(`comp',0,1) & `touse', absorb(`fe') residuals(res_rurd) // for labor/land variable
	qui gen int_rurd = res_rurd*`comp' // interaction to distinguish elasticity based on comp variable

	qui ols_spatial_JV res_csi res_rurd int_rurd `comp' c if `touse', /// this actually does OLS with spatial corrected SE
			lat(y_cent) lon(x_cent) timevar(c) panelvar(c) distcutoff(`dist') lagcutoff(1)
	qui tabulate name_0 if e(sample)==1 & `comp'==0 // count countries in group=0
	qui estadd scalar N_country = r(r) // store country count for group=0
	qui count if e(sample)==1 & `comp'==0 // count observations in group=0
	qui estadd scalar N_obs = r(N) // store obs count for group=0
	local df_adj = e(df_r)/(e(df_r)-`df_fe') // Df adjustment for estimated FE
	mat NV = `df_adj'*e(V) // adjust all C/V matrix
	ereturn repost V = NV // repost adjust C/V matrix as the C/V matrix
	
	qui estadd scalar p_zero = 2*(1-t(e(df_r),abs(_b[res_rurd])/_se[res_rurd])) // add p-value for H0: beta=0 for group==0		
	qui estadd scalar p_diff = 2*(1-t(e(df_r),abs(_b[int_rurd])/_se[int_rurd])) // add p-value for H0: beta(group=0) = beta(group=1)
	estimates store `tag'2 // store results

	qui lincom res_rurd + int_rurd // get linear combination of base and interaction to get estimated elasticity, SE for group==1	
	local comp_se = r(se) // save off the SE of this estimate
	
	// Run separate OLS for reference group, for reporting use
	// To avoid running spatial OLS again, pull the appropriate SE from the prior spatial OLS
	// Done solely to avoid re-running spatial OLS again to save time
	reg res_csi res_rurd if `touse' & `comp'==1 // run regression on just the comparison group ==1, the reference
	mat NV = e(V) // save OLS Var/Covar matrix
	mat NV[1,1] = `comp_se'^2 // overwrite Var/Covar for density with the variance from spatial OLS above
	ereturn repost V = NV // repost the overwritten Var/Covar to estimates for reporting
	qui tabulate name_0 if e(sample)==1 & `comp'==1 // count countries in group=1
	qui estadd scalar N_country = r(r) // store country count for group=1
	qui count if e(sample)==1 & `comp'==1 // count observations in group=1	
	qui estadd scalar N_obs = r(N) // store obs count for group=1
	qui estadd scalar p_zero = 2*(1-t(e(df_r),abs(_b[res_rurd])/`comp_se'))
	estimates store `tag'1 // store results
	
	label variable res_rurd "Log labor/land ratio ($\beta_g$)"
end 

//////////////////////////////////////////////////////////////////////////////////////////////////////////
// Run reg with correction for spatial SE
// - Allows for 0/1/2 variable distinguishing groups (e.g. temp, trop, mixed) to compare estimates
/////////////////////////////////////////////////////////////////////////////////////////////////////////
capture program drop hdreg3
program hdreg3, eclass
	syntax varlist(min=2 fv) [if] [in] [,controls(varlist) fe(varlist fv) dist(real 500) comp(varlist) tag(string)] 
	token `varlist' // tokenize list of passed variables for use
	marksample touse
	
	capture drop c // must include own constant for spatial OLS
	gen c = 1
	capture drop res_csi // these hold residuals from initial FE regressions
	capture drop res_rurd
	capture drop int1_rurd
	capture drop int2_rurd
	
	capture drop comp1
	capture drop comp2
	qui gen comp1 = (`comp'==1) // create separate dummy for 1st comp category
	qui gen comp2 = (`comp'==2) // create separate dummy for 2nd comp category

	// Remove FE and apply controls to both yield and labor/land ratios to speed up spatial regression
	qui reghdfe `1' `controls' if inlist(`comp',0,1,2) & `touse', absorb(`fe') residuals(res_csi)
	local df_fe = e(df_a)
	qui reghdfe `2' `controls' if inlist(`comp',0,1,2) & `touse', absorb(`fe') residuals(res_rurd)
	qui gen int1_rurd = res_rurd*comp1
	qui gen int2_rurd = res_rurd*comp2

	qui ols_spatial_JV res_csi res_rurd int1_rurd int2_rurd comp1 comp2 c if `touse', /// actual spatial OLS with SE correction
			lat(y_cent) lon(x_cent) timevar(c) panelvar(c) distcutoff(`dist') lagcutoff(1)
	qui tabulate name_0 if e(sample)==1 & `comp'==0 // count countries in group=0
	qui estadd scalar N_country = r(r) // store country count for group=0
	qui count if e(sample)==1 & `comp'==0 // count observations in group=0
	qui estadd scalar N_obs = r(N) // store obs count for group=0
	local df_adj = e(df_r)/(e(df_r)-`df_fe') // Df adjustment for estimated FE
	mat NV = `df_adj'*e(V) // adjust all C/V matrix
	ereturn repost V = NV
	qui estadd scalar p_zero = 2*(1-t(e(df_r),abs(_b[res_rurd])/_se[res_rurd])) // add p-value for H0: beta=0 for group==0		
	qui estadd scalar p_diff1 = 2*(1-t(e(df_r),abs(_b[int1_rurd])/_se[int1_rurd])) // add p-value for H0: beta(group=0) = beta(group=1)
	qui estadd scalar p_diff2 = 2*(1-t(e(df_r),abs(_b[int2_rurd])/_se[int2_rurd])) // add p-value for H0: beta(group=0) = beta(group=2)
	estimates store `tag'1 // store results
	
	label variable res_rurd "Log labor/land ratio ($\beta_g$)"
end 
