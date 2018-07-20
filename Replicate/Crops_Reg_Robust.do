/*
Robust regressions
- Uses suitability data exclusively to divide sample
- Much of this is hard-coded, as the specific robustness checks are specific to tables
*/

//////////////////////////////////////
// Set working parameters
//////////////////////////////////////
local limit = 0

//////////////////////////////////////
// Productivity basis robustness
//////////////////////////////////////
clear
estimates clear
use "$data/all_crops_data_$level.dta"

gen cons = 1 // constant for use in spatial OLS
gen y = 1 // "time" variable for use in spatial OLS

// Medium rainfall
reset
global csivar ln_csi_yield_med_irr

	// Wheat family suitable
	est_ref if dry_suit==1 & wet_suit==0
	estimates store reg_med_1

	// Rice family suitable
	est_reg if dry_suit==0 & wet_suit==1
	estimates store reg_med_2

// High input rainfall
reset
global csivar ln_csi_yield_hi_rain

	// Wheat family suitable
	est_ref if dry_suit==1 & wet_suit==0
	estimates store reg_hirain_1

	// Rice family suitable
	est_reg if dry_suit==0 & wet_suit==1
	estimates store reg_hirain_2

// High input irrigated
reset
global csivar ln_csi_yield_hi_irr

	// Wheat family suitable
	est_ref if dry_suit==1 & wet_suit==0
	estimates store reg_hiirr_1

	// Rice family suitable
	est_reg if dry_suit==0 & wet_suit==1
	estimates store reg_hiirr_2
	
// Write population robustness
estout reg_med_1 reg_med_2 reg_hirain_1 reg_hirain_2 reg_hiirr_1 reg_hiirr_2 using "$output/tab_beta_robust_input.tex", /// write the region results to Tex file
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) ///
	stats(p_zero p_diff N_country N_obs r2_a, fmt(%9.3f %9.3f %9.0g %9.0g %9.2f) labels("p-value $\beta=0$" "p-value $\beta=\beta_{Temp}$" "Countries" "Observations" "Adjusted R-square")) ///
	keep(rurd_reg) label mlabels(none) collabels(none) prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)

//////////////////////////////////////
// Productivity basis - only poor countries
//////////////////////////////////////
clear
estimates clear
use "$data/all_crops_data_$level.dta"

gen cons = 1 // constant for use in spatial OLS
gen y = 1 // "time" variable for use in spatial OLS

// Medium rainfall
reset
global csivar ln_csi_yield_med_irr

	// Wheat family suitable
	est_ref if dry_suit==1 & wet_suit==0 & inlist(jv_subregion,4,7,8,9)
	estimates store reg_med_1

	// Rice family suitable
	est_reg if dry_suit==0 & wet_suit==1 & inlist(jv_subregion,4,7,8,9)
	estimates store reg_med_2

// High input rainfall
reset
global csivar ln_csi_yield_hi_rain

	// Wheat family suitable
	est_ref if dry_suit==1 & wet_suit==0 & inlist(jv_subregion,4,7,8,9)
	estimates store reg_hirain_1

	// Rice family suitable
	est_reg if dry_suit==0 & wet_suit==1 & inlist(jv_subregion,4,7,8,9)
	estimates store reg_hirain_2

// High input irrigated
reset
global csivar ln_csi_yield_hi_irr

	// Wheat family suitable
	est_ref if dry_suit==1 & wet_suit==0 & inlist(jv_subregion,4,7,8,9)
	estimates store reg_hiirr_1

	// Rice family suitable
	est_reg if dry_suit==0 & wet_suit==1 & inlist(jv_subregion,4,7,8,9)
	estimates store reg_hiirr_2
	
// Write population robustness
estout reg_med_1 reg_med_2 reg_hirain_1 reg_hirain_2 reg_hiirr_1 reg_hiirr_2 using "$output/tab_beta_robust_input_poor.tex", /// write the region results to Tex file
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) ///
	stats(p_zero p_diff N_country N_obs r2_a, fmt(%9.3f %9.3f %9.0g %9.0g %9.2f) labels("p-value $\beta=0$" "p-value $\beta=\beta_{Temp}$" "Countries" "Observations" "Adjusted R-square")) ///
	keep(rurd_reg) label mlabels(none) collabels(none) prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)

	
//////////////////////////////////////
// Population robustness
//////////////////////////////////////
clear
estimates clear
use "$data/all_crops_data_$level.dta"

gen cons = 1 // constant for use in spatial OLS
gen y = 1 // "time" variable for use in spatial OLS

// HYDE 1950 results
global year 1950
global rurdvar ln_rurd_1950

	// Wheat family suitable
	est_ref if dry_suit==1 & wet_suit==0
	estimates store reg_hyde_1

	// Rice family suitable
	est_reg if dry_suit==0 & wet_suit==1
	estimates store reg_hyde_2

// GRUMP population data
reset
global year 2000
global rurdvar ln_grump_rurd

	// Wheat family suitable
	est_ref if dry_suit==1 & wet_suit==0
	estimates store reg_grump_1

	// Rice family suitable
	est_reg if dry_suit==0 & wet_suit==1
	estimates store reg_grump_2

// IPUMS population data
clear
use "$data/all_crops_data_ipums.dta"
gen cons = 1 // constant for use in spatial OLS
gen y = 1 // "time" variable for use in spatial OLS
reset
global fe cntry_code // fixed effect to include
global rurdvar ln_pag
global cntl urb_perc ln_light_mean

	// Wheat family suitable
	est_ref if dry_suit==1 & wet_suit==0
	estimates store reg_ipums_1

	// Rice family suitable
	est_reg if dry_suit==0 & wet_suit==1
	estimates store reg_ipums_2
	
// Write population robustness
estout reg_hyde_1 reg_hyde_2 reg_grump_1 reg_grump_2 reg_ipums_1 reg_ipums_2 using "$output/tab_beta_robust_pop.tex", /// write the region results to Tex file
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) ///
	stats(p_zero p_diff N_country N_obs r2_a, fmt(%9.3f %9.3f %9.0g %9.0g %9.2f) labels("p-value $\beta=0$" "p-value $\beta=\beta_{Temp}$" "Countries" "Observations" "Adjusted R-square")) ///
	keep(rurd_reg) label mlabels(none) collabels(none) prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)
	
//////////////////////////////////////
// Area and size robustness
//////////////////////////////////////
// Use cultivated area
reset
global rurdvar ln_rurd_cult_2000
global cntl urb_perc_2000 ln_light_mean ln_cult_area_perc

clear
use "$data/all_crops_data_$level.dta"

gen cons = 1 // constant for use in spatial OLS
gen y = 1 // "time" variable for use in spatial OLS

	// Wheat family suitable
	est_ref if dry_suit==1 & wet_suit==0
	estimates store reg_cult_1

	// Rice family suitable
	est_reg if dry_suit==0 & wet_suit==1
	estimates store reg_cult_2

// Drop large districts (over 90th)
reset
	
clear
use "$data/all_crops_data_$level.dta"

gen cons = 1 // constant for use in spatial OLS
gen y = 1 // "time" variable for use in spatial OLS
drop if ln_area>13.1086

	// Wheat family suitable
	est_ref if dry_suit==1 & wet_suit==0
	estimates store reg_size_1

	// Rice family suitable
	est_reg if dry_suit==0 & wet_suit==1
	estimates store reg_size_2

// Drop districts less than 25th ptile in total production
reset

clear
use "$data/all_crops_data_$level.dta"

gen cons = 1 // constant for use in spatial OLS
gen y = 1 // "time" variable for use in spatial OLS
drop if prod_sum<2792
	
	// Wheat family suitable
	est_ref if dry_suit==1 & wet_suit==0
	estimates store reg_prod_1

	// Rice family suitable
	est_reg if dry_suit==0 & wet_suit==1
	estimates store reg_prod_2

// Write population robustness
estout reg_cult_1 reg_cult_2 reg_size_1 reg_size_2 reg_prod_1 reg_prod_2 using "$output/tab_beta_robust_other.tex", /// write the region results to Tex file
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) ///
	stats(p_zero p_diff N_country N_obs r2_a, fmt(%9.3f %9.3f %9.0g %9.0g %9.2f) labels("p-value $\beta=0$" "p-value $\beta=\beta_{Temp}$" "Countries" "Observations" "Adjusted R-square")) ///
	keep(rurd_reg) label mlabels(none) collabels(none) prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)
	
