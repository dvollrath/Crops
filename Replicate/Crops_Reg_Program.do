//////////////////////////////////////
// Interaction regression
//////////////////////////////////////	
capture program drop est_reg
program est_reg // Perform set of regressions for given conditions in `0', create output
	di "Create residuals for selected sample"
	// Get residuals for the selected sample - removes cntl's and FE
	qui reg $csivar $cntl i.$fe `0'
	capture drop ln_csi_yield_res
	qui predict ln_csi_yield_res, res
	qui reg $rurdvar $cntl i.$fe `0'
	capture drop ln_rurd_res
	qui predict ln_rurd_res, res
	
	// Create the CSI variable using selected sample and reference group
	di "Create interaction variables"
	capture drop csi_reg
	qui gen csi_reg  = .
	qui replace csi_reg = ln_csi_yield_res `0'
	qui replace csi_reg = ln_csi_yield_ref if ref_ind==1
	// Create the rurd variable using selected sample and reference group
	capture drop rurd_reg 
	qui gen rurd_reg = .
	qui replace rurd_reg = ln_rurd_res `0'
	qui replace rurd_reg = ln_rurd_ref if ref_ind==1
	label variable rurd_reg "Log rural density"
	// Create the interaction term for sample (0) and reference group
	capture drop rurd_int
	qui gen rurd_int = .
	qui replace rurd_int = 0 `0'
	qui replace rurd_int = ln_rurd_ref if ref_ind==1
	// Mark the sample to use
	capture drop sample_ind
	gen sample_ind = 0
	replace sample_ind = 1 `0'
	replace sample_ind = 1 if ref_ind==1
	
	di "Perform spatial regression"
	qui ols_spatial_HAC csi_reg rurd_reg rurd_int if sample_ind==1, ///
			lat(y_cent) lon(x_cent) timevar(y) panelvar($fe) distcutoff($cutoff) lagcutoff(1)
	qui tabulate name_0 `0' & e(sample)==1
	qui estadd scalar N_country = r(r)
	qui count `0' & e(sample)==1 & ref_ind==.
	qui estadd scalar N_obs = r(N)
	qui estadd scalar p_zero = 2*(1-t(e(df_r),abs(_b[rurd_reg])/_se[rurd_reg])) // add p-value from interaction		
	qui estadd scalar p_diff = 2*(1-t(e(df_r),abs(_b[rurd_int])/_se[rurd_int])) // add p-value from interaction	
end

//////////////////////////////////////
// Reference program
// -- Set ref_ind==1 for sample to act as reference
// -- Usage: est_ref 
//////////////////////////////////////	
capture program drop est_ref
program est_ref 
	di "Process reference group"
	capture drop ref_ind
	qui gen ref_ind = .
	qui replace ref_ind = 1 `0'
	
	di "Reference residuals"
	qui reg $csivar $cntl i.$fe if ref_ind==1
	capture drop ln_csi_yield_ref
	qui predict ln_csi_yield_ref, res
	qui reg $rurdvar $cntl i.$fe if ref_ind==1
	capture drop ln_rurd_ref
	qui predict ln_rurd_ref, res
	
	capture drop csi_reg
	qui gen csi_reg  = .
	qui replace csi_reg = ln_csi_yield_ref
	capture drop rurd_reg 
	qui gen rurd_reg = .
	qui replace rurd_reg = ln_rurd_ref
	label variable rurd_reg "Log rural density"
	
	qui ols_spatial_HAC csi_reg rurd_reg if ref_ind==1, ///
				lat(y_cent) lon(x_cent) timevar(y) panelvar($fe) distcutoff($cutoff) lagcutoff(1)
	qui tabulate name_0 if ref_ind==1 & e(sample)==1
	qui estadd scalar N_country = r(r)
	qui count `0' & e(sample)==1 & ref_ind==1
	qui estadd scalar N_obs = r(N)
	qui estadd scalar p_zero = 2*(1-t(e(df_r),abs(_b[rurd_reg])/_se[rurd_reg])) // add p-value from interaction		
end

capture program drop est_quick
program est_quick
	qui reg $csivar $cntl i.$fe `0'
	capture drop ln_csi_yield_ref
	qui predict ln_csi_yield_ref, res
	qui reg $rurdvar $cntl i.$fe `0'
	capture drop ln_rurd_ref
	qui predict ln_rurd_ref, res
	
	capture drop csi_reg
	qui gen csi_reg  = .
	qui replace csi_reg = ln_csi_yield_ref
	capture drop rurd_reg 
	qui gen rurd_reg = .
	qui replace rurd_reg = ln_rurd_ref
	
	reg csi_reg rurd_reg `0', absorb($fe) cluster($fe)
	qui tabulate name_0 if ref_ind==1 & e(sample)==1
	qui estadd scalar N_country = r(r)
	qui count `0' & e(sample)==1 & ref_ind==1
	qui estadd scalar N_obs = r(N)
	qui estadd scalar p_zero = 2*(1-t(e(df_r),abs(_b[rurd_reg])/_se[rurd_reg])) // add p-value from interaction		
end
