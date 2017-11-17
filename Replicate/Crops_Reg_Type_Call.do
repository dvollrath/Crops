/*
Baseline egressions by crops
- Basic spec is reg productivity on rural density
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

//////////////////////////////////////
// Crop regressions - wheat and rice families
//////////////////////////////////////	
	// Wheat family suitable
	est_ref if dry_suit==1 & wet_suit==0
	estimates store reg_crop_1

	// Rice family suitable
	est_reg if dry_suit==0 & wet_suit==1
	estimates store reg_crop_2
	
	// Wheat family is dominant in max calories
	est_ref if dry_max==1 & wet_cells==0
	estimates store reg_crop_3

	// Rice family is dominant in max calories
	est_reg if dry_cells==0 & wet_max==1
	estimates store reg_crop_4

	// Wheat family is dominant in actual crop area
	est_ref if dry_area==1 & wet_area==0
	estimates store reg_crop_5

	// Rice family is dominant in actual crop area
	est_reg if dry_area==0 & wet_area==1
	estimates store reg_crop_6
		
// Write wheat/rice panel data	
estout reg_crop_* using "$output/tab_beta_crop_$tag.tex", /// write the region results to Tex file
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) ///
	stats(p_zero p_diff N_country N_obs r2_a, fmt(%9.3f %9.3f %9.0g %9.0g %9.2f) labels("p-value $\beta=0$" "p-value $\beta=\beta_{Temp}$" "Countries" "Observations" "Adjusted R-square")) ///
	keep(rurd_reg) label mlabels(none) collabels(none) prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)
	
coefplot reg_crop_1 || reg_crop_2 || reg_crop_3 || reg_crop_4 || reg_crop_5 || reg_crop_6, ///
	keep(rurd_reg) bycoefs graphregion(color(white)) xtitle("{&beta} estimate") xlabel(,format(%9.2f)) ///
	mlabel format(%9.3f) mlabposition(12) ///
	bylabels("Temperate (suitability)" "Tropical (suitability)" "Temperate (calories)" "Tropical (calories)" "Tempreate (harvested)" "Tropical (harvested)")
graph export "$output/fig_coef_crop_$tag.png", replace as(png)
graph export "$output/fig_coef_crop_$tag.eps", replace as(eps)

/*
scatter ln_csi_yield ln_rurd_2000 if suit_whe>0 & suit_rcw==0 & ln_csi_yield>0, msymbol(p) mcolor(black) ///
	|| lfit ln_csi_yield ln_rurd_2000 if suit_whe>0 & suit_rcw==0 & ln_csi_yield>0, clcolor(black) ///
	|| scatter ln_csi_yield ln_rurd_2000 if suit_whe==0 & suit_rcw>0, msymbol(p) mcolor(green) ///
	|| lfit ln_csi_yield ln_rurd_2000 if suit_whe==0 & suit_rcw>0, clcolor(green) ///
	xtitle("Log rural density, 2000CE") ytitle("Log caloric yield") ///
	ylabel(6(1)11, angle(0) nogrid) graphregion(color(white)) xlabel(-5(1)2) ///
	legend(ring(0) pos(10) label(1 "Temperate (Black)") label(2 "Fitted") label(3 "Tropical (Green)") label(4 "Fitted"))
graph export "$output/fig_beta_crop.png", replace as(png)
graph export "$output/fig_beta_crop.eps", replace as(eps)
*/

//////////////////////////////////////
// Crop regressions - alternatives
//////////////////////////////////////
	// Only districts without big citites
	// Wheat family 
	est_ref if dry_suit==1 & wet_suit==0 & urbc_2000<25000
	estimates store reg_sub_1

	// Rice rice family
	est_reg if dry_suit==0 & wet_suit==1 & urbc_2000<25000
	estimates store reg_sub_2

	// Only "poor" regions - no NA or Europe
	// Wheat family  
	est_ref if dry_suit==1 & wet_suit==0 & inlist(jv_subregion,4,7,8,9)
	estimates store reg_sub_3

	// Rice family
	est_reg if dry_suit==0 & wet_suit==1 & inlist(jv_subregion,4,7,8,9)
	estimates store reg_sub_4

	// Only high density regions
	qui summ $rurdvar, det
	global rurdcut = r(p25)
	// Wheat family 
	est_ref if dry_suit==1 & wet_suit==0 & $rurdvar > $rurdcut
	estimates store reg_sub_5

	// Rice family
	est_reg if dry_suit==0 & wet_suit==1 & $rurdvar > $rurdcut
	estimates store reg_sub_6
	
	
// Write wheat/rice panel data	
estout reg_sub_* using "$output/tab_beta_crop_sub_$tag.tex", /// write the region results to Tex file
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) ///
	stats(p_zero p_diff N_country N_obs r2_a, fmt(%9.3f %9.3f %9.0g %9.0g %9.2f) labels("p-value $\beta=0$" "p-value $\beta=\beta_{Temp}$" "Countries" "Observations" "Adjusted R-square")) ///
	keep(rurd_reg) label mlabels(none) collabels(none) prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)
	
coefplot reg_sub_1 || reg_sub_2 || reg_sub_3 || reg_sub_4 || reg_sub_5 || reg_sub_6, ///
	keep(rurd_reg) bycoefs graphregion(color(white)) xtitle("{&beta} estimate") xlabel(,format(%9.2f)) ///
	mlabel format(%9.3f) mlabposition(12) ///
	bylabels("<25K Urban: Temperate" "<25K Urban: Tropical" "Poor Countries: Temperate" "Poor Countries: Tropical" "High density: Temperate" "High density: Tropical")
graph export "$output/fig_coef_crop_sub_$tag.png", replace as(png)
graph export "$output/fig_coef_crop_sub_$tag.eps", replace as(eps)


/*
//////////////////////////////////////
// Crop regressions - other crops
//////////////////////////////////////
	// either maize
	est_ref if suit_mze>0 & wet_suit==1 & dry_suit==1
	estimates store reg_alt_1

	// "wet" maize
	est_reg if suit_mze>0 & wet_suit==1 & dry_suit==0
	estimates store reg_alt_2

	// "dry" maize
	est_reg if suit_mze>0 & wet_suit==0 & dry_suit==1
	estimates store reg_alt_3

	// either soy
	est_ref if suit_soy>0 & wet_suit==1 & dry_suit==1
	estimates store reg_alt_4

	// "wet" soy
	est_reg if suit_soy>0 & wet_suit==1 & dry_suit==0
	estimates store reg_alt_5

	// "dry" soy
	est_reg if suit_soy>0 & wet_suit==0 & dry_suit==1
	estimates store reg_alt_6
	
// Write wheat/rice panel data	
estout reg_alt_* using "$output/tab_beta_crop_alt_$tag.tex", /// write the region results to Tex file
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) ///
	stats(p_zero p_diff N_country N_obs r2_a, fmt(%9.3f %9.3f %9.0g %9.0g %9.2f) labels("p-value $\beta=0$" "p-value $\beta=\beta^{All}$" "Countries" "Observations" "Adjusted R-square")) ///
	keep(rurd_reg) label mlabels(none) collabels(none) prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)
	
coefplot reg_alt_1 || reg_alt_2 || reg_alt_3 || reg_alt_4 || reg_alt_5 || reg_alt_6, ///
	keep(rurd_reg) bycoefs graphregion(color(white)) xtitle("{&beta} estimate") xlabel(,format(%9.2f)) ///
	mlabel format(%9.3f) mlabposition(12) ///
	bylabels("Maize and Wheat AND Rice" "Maize and Rice Only" "Maize and Wheat Only" "Soy and Wheat AND Rice" "Soy and Rice Only" "Soy and Wheat Only")
graph export "$output/fig_coef_crop_alt_$tag.png", replace as(png)
graph export "$output/fig_coef_crop_alt_$tag.eps", replace as(eps)
*/
