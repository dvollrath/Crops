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
	est_ref if dry_suit==1 & wet_suit==0
	estimates store reg_crop_1

	global csivar ln_barley_yield 
	est_ref if dry_suit==1 & wet_suit==0
	estimates store reg_crop_2

	global csivar ln_buckwheat_yield 
	est_ref if dry_suit==1 & wet_suit==0
	estimates store reg_crop_3
	
	global csivar ln_rye_yield 
	est_ref if dry_suit==1 & wet_suit==0
	estimates store reg_crop_4
	
	global csivar ln_oat_yield 
	est_ref if dry_suit==1 & wet_suit==0
	estimates store reg_crop_5

	global csivar ln_whitepotato_yield 
	est_ref if dry_suit==1 & wet_suit==0
	estimates store reg_crop_6

	global csivar ln_wheat_yield 
	est_ref if dry_suit==1 & wet_suit==0
	estimates store reg_crop_7
		
// Write wheat/rice panel data	
di "$tag"
estout reg_crop_* using "$output/tab_beta_tempcrop_$tag.tex", /// write the region results to Tex file
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) ///
	stats(p_zero N_country N_obs r2_a, fmt(%9.3f %9.0g %9.0g %9.2f) labels("p-value $\beta=0$" "Countries" "Observations" "Adjusted R-square")) ///
	keep(rurd_reg) label mlabels(none) collabels(none) prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)
	
coefplot reg_crop_1 || reg_crop_2 || reg_crop_3 || reg_crop_4 || reg_crop_5 || reg_crop_6 || reg_crop_7, ///
	keep(rurd_reg) bycoefs graphregion(color(white)) xtitle("{&beta} estimate") xlabel(,format(%9.2f)) ///
	mlabel format(%9.3f) mlabposition(12) ///
	bylabels("Using CSI yield" "Using barley yield" "Using buckwheat yield" "Using rye yield" "Using oat yield" "Using white potato yield" "Using wheat yield")
graph export "$output/fig_coef_tempcrop_$tag.png", replace as(png)
graph export "$output/fig_coef_tempcrop_$tag.eps", replace as(eps)

//////////////////////////////////////
// Tropical zone regressions
//////////////////////////////////////	
	global csivar ln_csi_yield
	est_ref if dry_suit==0 & wet_suit==1
	estimates store reg_crop_1

	global csivar ln_cassava_yield 
	est_ref if dry_suit==0 & wet_suit==1
	estimates store reg_crop_2

	global csivar ln_cowpea_yield 
	est_ref if dry_suit==0 & wet_suit==1
	estimates store reg_crop_3
	
	global csivar ln_pearlmillet_yield 
	est_ref if dry_suit==0 & wet_suit==1
	estimates store reg_crop_4
	
	global csivar ln_sweetpotato_yield 
	est_ref if dry_suit==0 & wet_suit==1
	estimates store reg_crop_5

	global csivar ln_wetrice_yield 
	est_ref if dry_suit==0 & wet_suit==1
	estimates store reg_crop_6

	global csivar ln_yams_yield 
	est_ref if dry_suit==0 & wet_suit==1
	estimates store reg_crop_7
		
// Write wheat/rice panel data	
estout reg_crop_* using "$output/tab_beta_tropcrop_$tag.tex", /// write the region results to Tex file
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) ///
	stats(p_zero N_country N_obs r2_a, fmt(%9.3f %9.0g %9.0g %9.2f) labels("p-value $\beta=0$" "Countries" "Observations" "Adjusted R-square")) ///
	keep(rurd_reg) label mlabels(none) collabels(none) prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)
	
coefplot reg_crop_1 || reg_crop_2 || reg_crop_3 || reg_crop_4 || reg_crop_5 || reg_crop_6 || reg_crop_7, ///
	keep(rurd_reg) bycoefs graphregion(color(white)) xtitle("{&beta} estimate") xlabel(,format(%9.2f)) ///
	mlabel format(%9.3f) mlabposition(12) ///
	bylabels("Using CSI yield" "Using cassava yield" "Using cowpea yield" "Using pearlmillet yield" "Using sweet potato yield" "Using wet rice yield" "Using yam yield")
graph export "$output/fig_coef_tropcrop_$tag.png", replace as(png)
graph export "$output/fig_coef_tropcrop_$tag.eps", replace as(eps)
