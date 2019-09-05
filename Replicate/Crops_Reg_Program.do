//////////////////////////////////////////////////////////////////////////////////////////////////////////
// Main program to run spatial interaction regression
// - Variables are all demeaned first to save time
// - Spatial OLS doesn't like ## notation, so create interaction terms ourselves
// - Report both the results for main group, and the comparison group
/////////////////////////////////////////////////////////////////////////////////////////////////////////
capture program drop spatreg
program spatreg, eclass
	syntax varlist(min=2) [if] [in] [, fe(varlist) dist(real 500) comp(varlist) tag(string)] 
	token `varlist' // tokenize list of passed variables for use
	
	local and = "&" // default is to add extra condition to passed if statement
	if "`if'"=="" { // if the "if" passed is blank, then
		local and = "if" // include the "if" explicitly
	}
	
	qui areg `1' `if' `and' inlist(`comp',0,1), absorb(`fe') // demean the productivity variable over passed FE variable
		// do this only if it matches passed "if" statement
		// do this only if it has a valid 0/1 value in the group variable
	local df_fe = e(df_a) // save off degrees of freedom from absorbing FE for use in adjusting SE later
	capture drop res_`1'
	qui predict res_`1', res // create residuals of productivity variable
	
	qui areg `2' `if' `and' inlist(`comp',0,1), absorb(`fe') // demean the rural density variable over passed FE variable
	capture drop res_rurd
	qui predict res_rurd, res // create residual of density variable
	capture drop int_rurd
	qui gen int_rurd = res_rurd*`comp' // create interaction of residual density and comparison group variable
	
	local i = 3 
	while "``i''" != "" { // for all the remaining controls
		qui areg ``i'' `if' `and' inlist(`comp',0,1), absorb(`fe') // demean the control over passed FE variable
		capture drop res_cntl_``i''
		qui predict res_cntl_``i'', res // create residual of control variable
		capture drop int_cntl_``i''
		qui gen int_cntl_``i'' = res_cntl_``i''*`comp' // create interaction of residual control with comparison group variable
		local ++i
	}

	// Main results
	// Regress productivity on density, include all controls, include all interaction terms, and a constant(c), 
	reg res_`1' res_rurd int_rurd res_cntl_* int_cntl_* `comp' `if' `and' inlist(`comp',0,1) // OLS version for testing, leave commented out
	local df = e(df_r) - `df_fe' // adjust DF for estimation of the FE
	capture drop ols_res
	predict ols_res, res
	capture drop touse
	gen touse = e(sample)
	
	unab rhs : res_rurd int_rurd res_cntl_* int_cntl_* `comp'
	
	mata{
		u = st_data(.,"touse") // get vector of 0/1 for obs in sample
		W = select(X,u) // get rows from X matching sample
		W = select(W,u') // get columns from W matching sample

		df = st_local("df")
		dfreal = strtoreal(df)

		rhs_vars = st_local("rhs")
		Z = st_data(.,tokens(rhs_vars),"touse") // get matrix of RHS variables for sample
		e = st_data(.,"ols_res","touse") // get vector of OLS residuals for sample
		
		invZZ = luinv(Z'*Z)*dfreal
		E = e*e'
		weighted = E:*W
		sandwich = Z'*weighted*Z / dfreal
		V = invZZ*sandwich*invZZ / dfreal
		V = (V+V')/2 
		st_matrix("V_spatial", V)
	}
	ereturn repost V = V_spatial
end 



capture program drop doreg
program doreg, eclass
	syntax varlist(min=2) [if] [in] [, fe(varlist) dist(real 500) comp(varlist) tag(string)] 
	token `varlist' // tokenize list of passed variables for use
	
	local and = "&" // default is to add extra condition to passed if statement
	if "`if'"=="" { // if the "if" passed is blank, then
		local and = "if" // include the "if" explicitly
	}

	capture drop res_*
	capture drop int_*

	qui areg `1' `if' `and' inlist(`comp',0,1), absorb(`fe') // demean the productivity variable over passed FE variable
		// do this only if it matches passed "if" statement
		// do this only if it has a valid 0/1 value in the group variable
	local df_fe = e(df_a) // save off degrees of freedom from absorbing FE for use in adjusting SE later
	capture drop res_`1'
	qui predict res_`1', res // create residuals of productivity variable
	
	qui areg `2' `if' `and' inlist(`comp',0,1), absorb(`fe') // demean the rural density variable over passed FE variable
	capture drop res_rurd
	qui predict res_rurd, res // create residual of density variable
	capture drop int_rurd
	qui gen int_rurd = res_rurd*`comp' // create interaction of residual density and comparison group variable
		
	local i = 3 
	while "``i''" != "" { // for all the remaining controls
		qui areg ``i'' `if' `and' inlist(`comp',0,1), absorb(`fe') // demean the control over passed FE variable
		capture drop res_cntl_``i''
		qui predict res_cntl_``i'', res // create residual of control variable
		capture drop int_cntl_``i''
		qui gen int_cntl_``i'' = res_cntl_``i''*`comp' // create interaction of residual control with comparison group variable
		local ++i
	}

	// Main results
	// Regress productivity on density, include all controls, include all interaction terms, and a constant(c), 
	qui ols_spatial_HAC res_`1' res_rurd int_rurd res_cntl_* int_cntl_* `comp' c `if' `and' inlist(`comp',0,1), ///
			lat(y_cent) lon(x_cent) timevar(c) panelvar(c) distcutoff(`dist') lagcutoff(1)	// options for spatial errors
	//reg res_`1' res_rurd int_rurd res_cntl_* int_cntl_* `comp' `if' `and' inlist(`comp',0,1) // OLS version for testing, leave commented out
	qui tabulate name_0 `if' `and' e(sample)==1 & `comp'==0 // count countries in group=0
	qui estadd scalar N_country = r(r) // store country count for group=0
	qui count `if' `and' e(sample)==1 & `comp'==0 // count observations in group=0
	qui estadd scalar N_obs = r(N) // store obs count for group=0
	local df_adj = e(df_r)/(e(df_r)-`df_fe') // Df adjustment for estimated FE
	mat NV = `df_adj'*e(V) // adjust all C/V matrix
	ereturn repost V = NV
	qui estadd scalar p_zero = 2*(1-t(e(df_r),abs(_b[res_rurd])/_se[res_rurd])) // add p-value for H0: beta=0 for group==0		
	qui estadd scalar p_diff = 2*(1-t(e(df_r),abs(_b[int_rurd])/_se[int_rurd])) // add p-value for H0: beta(group=0) = beta(group=1)
	estimates store `tag'2 // store results

	qui lincom res_rurd + int_rurd // get linear combination of base and interaction to get estimated elasticity, SE for group==1	
	local comp_se = r(se) // save off the SE of this estimate
	
	// Run separate OLS for reference group, for reporting use
	// To avoid running spatial OLS again, pull the appropriate SE from the prior spatial OLS
	// Done solely to avoid re-running spatial OLS again to save time
	qui reg res_`1' res_rurd res_cntl_* `if' `and' `comp'==1 // run regression on just the comparison group ==1, the reference
	mat NV = e(V) // save OLS Var/Covar matrix
	mat NV[1,1] = `comp_se'^2 // overwrite Var/Covar for density with the variance from spatial OLS above
	ereturn repost V = NV // repost the overwritten Var/Covar to estimates for reporting
	qui tabulate name_0 `if' `and' e(sample)==1 & `comp'==1 // count countries in group=1
	qui estadd scalar N_country = r(r) // store country count for group=1
	qui count `if' `and' e(sample)==1 & `comp'==1 // count observations in group=1	
	qui estadd scalar N_obs = r(N) // store obs count for group=1
	qui estadd scalar p_zero = 2*(1-t(e(df_r),abs(_b[res_rurd])/`comp_se'))
	estimates store `tag'1 // store results
	
	label variable res_rurd "Log labor/land ratio ($\beta_g$)"


end 

//////////////////////////////////////////////////////////////////////////////////////////////////////////
// Supplemental program to run spatial interaction regression
// - Variables are all demeaned first to save time
// - Spatial OLS for a single group based on if statement (MUST have if statement)
/////////////////////////////////////////////////////////////////////////////////////////////////////////
capture program drop onereg
program onereg, eclass
	syntax varlist(min=2) [if] [in] [, fe(varlist) dist(real 500) tag(string)] 
	token `varlist' // tokenize list of passed variables for use
		
	qui areg `1' `if', absorb(`fe') // demean the productivity variable over passed FE variable
	capture drop res_`1'
	qui predict res_`1', res // create residuals of productivity variable
	
	qui areg `2' `if', absorb(`fe') // demean the rural density variable over passed FE variable
	capture drop res_rurd
	qui predict res_rurd, res // create residual of density variable
	
	local i = 3 
	while "``i''" != "" { // for all the remaining controls
		qui areg ``i'' `if', absorb(`fe') // demean the control over passed FE variable
		capture drop res_cntl_``i''
		qui predict res_cntl_``i'', res // create residual of control variable
		local ++i
	}

	// Regress productivity on density, include all controls, and a constant(c), 
	qui ols_spatial_HAC res_`1' res_rurd res_cntl_*  c `if', ///
			lat(y_cent) lon(x_cent) timevar(c) panelvar(c) distcutoff(`dist') lagcutoff(1)	// options for spatial errors
	qui tabulate name_0 `if' & e(sample)==1 // count countries in group=0
	qui estadd scalar N_country = r(r) // store country count for group=0
	qui count `if' & e(sample)==1 // count observations in group=0
	qui estadd scalar N_obs = r(N) // store obs count for group=0
	qui estadd scalar p_zero = 2*(1-t(e(df_r),abs(_b[res_rurd])/_se[res_rurd])) // add p-value for H0: beta=0 for group==0		
	estimates store `tag'1 // store results
	
	label variable res_rurd "Log labor/land ratio ($\beta_g$)"

end 


capture program drop threereg
program threereg, eclass
	syntax varlist(min=2) [if] [in] [, fe(varlist) dist(real 500) comp(varlist) tag(string)] 
	token `varlist' // tokenize list of passed variables for use
	
	local and = "&" // default is to add extra condition to passed if statement
	if "`if'"=="" { // if the "if" passed is blank, then
		local and = "if" // include the "if" explicitly
	}

	capture drop res_*
	capture drop int_*

	qui areg `1' `if' `and' inlist(`comp',0,1,2), absorb(`fe') // demean the productivity variable over passed FE variable
		// do this only if it matches passed "if" statement
		// do this only if it has a valid 0/1 value in the group variable
	local df_fe = e(df_a) // save off degrees of freedom from absorbing FE for use in adjusting SE later
	capture drop res_`1'
	qui predict res_`1', res // create residuals of productivity variable
	
	capture drop comp1
	capture drop comp2
	qui gen comp1 = (`comp'==1) // create separate dummy for 1st comp category
	qui gen comp2 = (`comp'==2) // create separate dummy for 2nd comp category
	
	qui areg `2' `if' `and' inlist(`comp',0,1,2), absorb(`fe') // demean the rural density variable over passed FE variable
	capture drop res_rurd
	qui predict res_rurd, res // create residual of density variable
	capture drop int_rurd_1
	capture drop int_rurd_2
	qui gen int_rurd_1 = res_rurd*comp1 // create interaction of residual density and comparison group variable
	qui gen int_rurd_2 = res_rurd*comp2 // create interaction of residual density and comparison group variable
		
	local i = 3 
	while "``i''" != "" { // for all the remaining controls
		qui areg ``i'' `if' `and' inlist(`comp',0,1,2), absorb(`fe') // demean the control over passed FE variable
		capture drop res_cntl_``i''
		qui predict res_cntl_``i'', res // create residual of control variable
		capture drop int_cntl_``i''_1
		capture drop int_cntl_``i''_2
		qui gen int_cntl_``i''_1 = res_cntl_``i''*comp1 // create interaction of residual control with comparison group variable
		qui gen int_cntl_``i''_2 = res_cntl_``i''*comp2 // create interaction of residual control with comparison group variable
		local ++i
	}

	// Main results
	// Regress productivity on density, include all controls, include all interaction terms, and a constant(c), 
	qui ols_spatial_HAC res_`1' res_rurd int_rurd_* res_cntl_* int_cntl_* comp1 comp2 c `if' `and' inlist(`comp',0,1,2), ///
			lat(y_cent) lon(x_cent) timevar(c) panelvar(c) distcutoff(`dist') lagcutoff(1)	// options for spatial errors
	//reg res_`1' res_rurd int_rurd_* res_cntl_* int_cntl_* comp1 comp2 `if' `and' inlist(`comp',0,1,2) // OLS version for testing, leave commented out
	qui tabulate name_0 `if' `and' e(sample)==1 & `comp'==0 // count countries in group=0
	qui estadd scalar N_country = r(r) // store country count for group=0
	qui count `if' `and' e(sample)==1 & `comp'==0 // count observations in group=0
	qui estadd scalar N_obs = r(N) // store obs count for group=0
	local df_adj = e(df_r)/(e(df_r)-`df_fe') // Df adjustment for estimated FE
	mat NV = `df_adj'*e(V) // adjust all C/V matrix
	ereturn repost V = NV
	qui estadd scalar p_zero = 2*(1-t(e(df_r),abs(_b[res_rurd])/_se[res_rurd])) // add p-value for H0: beta=0 for group==0		
	qui estadd scalar p_diff1 = 2*(1-t(e(df_r),abs(_b[int_rurd_1])/_se[int_rurd_1])) // add p-value for H0: beta(group=0) = beta(group=1)
	qui estadd scalar p_diff2 = 2*(1-t(e(df_r),abs(_b[int_rurd_2])/_se[int_rurd_2])) // add p-value for H0: beta(group=0) = beta(group=1)
	estimates store `tag'1 // store results
	
	label variable res_rurd "Log labor/land ratio ($\beta_g$)"


end 

