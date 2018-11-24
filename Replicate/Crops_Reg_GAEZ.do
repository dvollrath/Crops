////////////////////////////////////////////////////////////////////////////
// Alternate Productivity Measures - Table 4 in paper
////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////
// Load data and calculate addl variables
//////////////////////////////////////
clear
estimates clear
use "./Work/all_crops_data_gadm2.dta" // 

//////////////////////////////////////
// Set locals for regressions
//////////////////////////////////////
local fe state_id // fixed effect to include
local rurdvar ln_rurd_2000 // rural density per unit of total land
local controls urb_perc_2000 ln_light_mean // urban percent and light mean
local dist 500 // km cutoff for Conley SE
local temperate temp // variable denoting temperate/tropical

//////////////////////////////////////
// Regressions - different productivity
//////////////////////////////////////	

doreg ln_csi_yield_med_irr `rurdvar' `controls', fe(`fe') dist(`dist') comp(`temperate') tag(mirr) // call program to do spatial OLS

doreg ln_csi_yield_hi_rain `rurdvar' `controls', fe(`fe') dist(`dist') comp(`temperate') tag(hrain) // call program to do spatial OLS

doreg ln_csi_yield_hi_irr `rurdvar' `controls', fe(`fe') dist(`dist') comp(`temperate') tag(hirr) // call program to do spatial OLS

// Output table
estout mirr1 mirr2 hrain1 hrain2 hirr1 hirr2 using "./Drafts/tab_beta_robust_input.tex", /// write the region results to Tex file
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) ///
	stats(p_zero p_diff N_country N_obs r2, fmt(%9.3f %9.3f %9.0g %9.0g %9.2f) labels("p-value $\beta=0$" "p-value $\beta=\beta_{Temp}$" "Countries" "Observations" "R-square (ex. FE)")) ///
	keep(res_rurd) label mlabels(none) collabels(none) prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)
	
//////////////////////////////////////
// Regressions - different productivity - poor only
//////////////////////////////////////	

doreg ln_csi_yield_med_irr `rurdvar' `controls' if inlist(jv_subregion,4,7,8,9), fe(`fe') dist(`dist') comp(temp) tag(pmirr) // call program to do spatial OLS

doreg ln_csi_yield_hi_rain `rurdvar' `controls' if inlist(jv_subregion,4,7,8,9), fe(`fe') dist(`dist') comp(temp) tag(phrain) // call program to do spatial OLS

doreg ln_csi_yield_hi_irr `rurdvar' `controls' if inlist(jv_subregion,4,7,8,9), fe(`fe') dist(`dist') comp(temp) tag(phirr) // call program to do spatial OLS

// Output table and coefficient plot
estout pmirr1 pmirr2 phrain1 phrain2 phirr1 phirr2 using "./Drafts/tab_beta_robust_input_poor.tex", /// write the region results to Tex file
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) ///
	stats(p_zero p_diff N_country N_obs r2, fmt(%9.3f %9.3f %9.0g %9.0g %9.2f) labels("p-value $\beta=0$" "p-value $\beta=\beta_{Temp}$" "Countries" "Observations" "R-square (ex. FE)")) ///
	keep(res_rurd) label mlabels(none) collabels(none) prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)
		
coefplot mirr1 || pmirr1 || mirr2 || pmirr2 || hrain1 ///
	|| phrain1 || hrain2 || phrain2 || hirr1 || phirr1, ///
	|| hirr2 || phirr2, ///
	keep(rurd_reg) bycoefs graphregion(color(white)) xtitle("{&beta} estimate") xlabel(0(.05).35,format(%9.2f)) ///
	mlabel format(%9.3f) mlabposition(12) ///
	headings(1 = "{bf:Medium input irrigated prod.}" 5 = "{bf:High input non-irrigated prod.}" 9 = "{bf:High input irrigated prod.}") ///
	bylabels("Temperate" "Temperate, excl. rich" "Tropical" "Tropical, excl. rich" "Temperate" "Temperate, excl. rich" "Tropical" "Tropical, excl. rich" "Temperate" "Temperate, excl. rich" "Tropical" "Tropical, excl. rich")
graph export "./Drafts/fig_coef_robust_input.eps", replace as(eps)
graph export "./Drafts/fig_coef_robust_input.png", replace as(png)	
		
