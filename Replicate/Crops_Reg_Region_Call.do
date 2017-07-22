/*
Baseline egressions on regions and sub-regions
- Basic spec is reg productivity on rural density
*/

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
// Regional regressions
//////////////////////////////////////
est_ref if jv_region==1
estimates store reg_spatial_1

qui summ jv_region
local max = r(max)
forvalues x = 2(1)`max' {
	est_reg if jv_region==`x'
	estimates store reg_spatial_`x'
}

// Create coefficient plot for use in paper/presentations
coefplot reg_spatial_1 || reg_spatial_2 || reg_spatial_3 || reg_spatial_4 || reg_spatial_5 || reg_spatial_6, ///
	keep(rurd_reg) bycoefs graphregion(color(white)) xtitle("{&beta} estimate") xlabel(,format(%9.1f)) ///
	mlabel format(%9.3f) mlabposition(12) ///
	bylabels("Europe" "South and East Asia" "Sub-Saharan Africa" "N. Africa and West Asia" "S. and Central America" "U.S. and Canada")
graph export "$output/fig_coef_region_$tag.png", replace as(png)
graph export "$output/fig_coef_region_$tag.eps", replace as(eps)
	
// Write regression table data for use in paper
estout reg_spatial_* using "$output/tab_beta_region_spatial_$tag.tex", /// write the region results to Tex file
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) ///
	stats(p_zero p_diff N_country N_obs r2_a, fmt(%9.3f %9.3f %9.0g %9.0g %9.2f) labels("p-value $\beta=0$" "p-value $\beta=\beta^{Eur}$" "Countries" "Observations" "Adjusted R-square")) ///
	keep(rurd_reg) label mlabels(none) ///
	collabels(none) prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)


//////////////////////////////////////
// Sub-region regressions
//////////////////////////////////////
est_ref if jv_subregion==1
estimates store reg_subspatial_1

qui summ jv_subregion
local max = r(max)
forvalues x = 2(1)`max' {
	est_reg if jv_subregion==`x'
	estimates store reg_subspatial_`x'
}

//////////////////////////////////////
// China/Japan/Korea regressions
//////////////////////////////////////
est_reg if inlist(jv_china,1,2)
estimates store reg_china_all

est_reg if jv_china==1
estimates store reg_china_north

est_reg if jv_china==2
estimates store reg_china_south

est_reg if name_0=="Japan"
estimates store reg_china_japan

est_reg if name_0=="North Korea" | name_0=="South Korea"
estimates store reg_china_korea

coefplot reg_subspatial_1 || reg_subspatial_2 || reg_subspatial_3 || reg_subspatial_4 || reg_subspatial_5 ///
	|| reg_subspatial_6 || reg_subspatial_7 || reg_subspatial_8 || reg_subspatial_9 || reg_subspatial_10, ///
	|| reg_china_all || reg_china_north || reg_china_south || reg_china_japan || reg_china_korea, ///
	keep(rurd_reg) bycoefs graphregion(color(white)) xtitle("{&beta} estimate") xlabel(,format(%9.1f)) ///
	mlabel format(%9.3f) mlabposition(12) ///
	bylabels("Northwest Europe" "East Europe" "South Europe" "South and Southeast Asia" "Central and West Asia" "Temperate Americas" "Tropical Americas" "Tropical Africa" "Southern Africa" "North Africa" "All China" "Temperate China" "Tropical China" "Japan" "N. and S. Korea")
graph export "$output/fig_coef_subregion_$tag.png", replace as(png)
graph export "$output/fig_coef_subregion_$tag.eps", replace as(eps)

estout reg_subspatial_1 reg_subspatial_2 reg_subspatial_3 reg_subspatial_4 reg_subspatial_5 ///
	using "$output/tab_beta_subregionA_$tag.tex", ///
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) ///
	stats(p_zero p_diff N_country N_obs r2_a, fmt(%9.3f %9.3f %9.0g %9.0g %9.2f) labels("p-value $\beta=0$" "p-value $\beta=\beta^{NWEur}$" "Countries" "Observations" "Adjusted R-square")) ///
	keep(rurd_reg) label mlabels(none) collabels(none) ///
	prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)

estout reg_subspatial_6 reg_subspatial_7 reg_subspatial_8 reg_subspatial_9 reg_subspatial_10 ///
	using "$output/tab_beta_subregionB_$tag.tex", ///
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) ///
	stats(p_zero p_diff N_country N_obs r2_a, fmt(%9.3f %9.3f %9.0g %9.0g %9.2f) labels("p-value $\beta=0$" "p-value $\beta=\beta^{NWEur}$" "Countries" "Observations" "Adjusted R-square")) ///
	keep(rurd_reg) label mlabels(none) collabels(none) ///
	prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)	

estout reg_china_all reg_china_north reg_china_south reg_china_japan reg_china_korea ///
	using "$output/tab_beta_subregionC_$tag.tex", ///
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) ///
	stats(p_zero p_diff N_obs r2_a, fmt(%9.3f %9.3f %9.0g %9.2f) labels("p-value $\beta=0$" "p-value $\beta=\beta^{NWEur}$" "Observations" "Adjusted R-square")) ///
	keep(rurd_reg) label mlabels(none) collabels(none) ///
	prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)	
