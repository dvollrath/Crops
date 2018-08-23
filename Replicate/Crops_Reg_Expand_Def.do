/*
Baseline egressions by crops
*/

//////////////////////////////////////
// Set working parameters
//////////////////////////////////////
local limit = 0

//////////////////////////////////////
// Load data and calculate addl variables
//////////////////////////////////////
clear
estimates clear
use "$data/all_crops_data_$level.dta"

gen cons = 1 // constant for use in spatial OLS
gen y = 1 // "time" variable for use in spatial OLS

drop if $drop // drop based on passed condition
di "$tag"
//////////////////////////////////////
// Temperate zone regressions
//////////////////////////////////////	
	global csivar ln_csi_yield 
	est_ref if dry_suit==1 & wet_suit==1
	estimates store reg_crop_1

	global csivar ln_csi_yield
	est_ref if dry_suit==1
	estimates store reg_crop_2

	global csivar ln_csi_yield 
	est_ref if wet_suit==1
	estimates store reg_crop_3

	global csivar ln_csi_yield 
	est_ref if dry_suit==1 & wet_suit==1 & urbc_2000<25000
	estimates store reg_crop_4
	
	global csivar ln_csi_yield 
	est_ref if dry_suit==1 & urbc_2000<25000
	estimates store reg_crop_5

	global csivar ln_csi_yield 
	est_ref if wet_suit==1 & urbc_2000<25000
	estimates store reg_crop_6
	
// Write wheat/rice panel data	
di "$tag"
estout reg_crop_? using "$output/tab_beta_expand_$tag.tex", /// write the region results to Tex file
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) ///
	stats(p_zero N_country N_obs r2_a, fmt(%9.3f %9.0g %9.0g %9.2f) labels("p-value $\beta=0$" "Countries" "Observations" "Adjusted R-square")) ///
	keep(rurd_reg) label mlabels(none) collabels(none) prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)
	
