//////////////////////////////////////
// Baseline results - Table 2 in paper
//////////////////////////////////////

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
local csivar ln_csi_yield // measure of productivity
local rurdvar ln_grump_rurd //ln_rurd_2000 // rural density per unit of total land
local controls grump_urb_perc ln_light_mean ln_grump_popc // urban percent and light mean and total population
local dist 500 // km cutoff for Conley SE

//////////////////////////////////////
// Regressions - temperate and tropical
//////////////////////////////////////	

// Create dummy to distinguish temperate from tropical on crops
capture drop temp
gen temp = .
replace temp = 1 if dry_suit==1 & wet_suit==0 // suitable for temp crops, not for trop
replace temp = 0 if dry_suit==0 & wet_suit==1  // suitable for trop crops, not for temp
replace temp = 2 if dry_suit==1 & wet_suit==1  // suitable for BOTH kinds of crops

onereg `csivar' `rurdvar' `controls' if temp==2, fe(`fe') dist(`dist') tag(base) // call program to do spatial OLS

onereg `csivar' `rurdvar' `controls' if temp==2 & grump_urbc<25000, fe(`fe') dist(`dist') tag(urbc) // call program to do spatial OLS

onereg `csivar' `rurdvar' `controls' if temp==2 & inlist(jv_subregion,4,7,8,9), fe(`fe') dist(`dist') tag(poor)

onereg `csivar' ln_grump_rurd_cult ln_cult_area_perc `controls' if temp==2, fe(`fe') dist(`dist') tag(cult)

onereg `csivar' `rurdvar' `controls' if temp==2 & cash_area_perc<.05, fe(`fe') dist(`dist') tag(cash)

onereg ln_csi_yield_hi_rain `rurdvar' `controls' if temp==2, fe(`fe') dist(`dist') tag(hirain)

// Output tables and coefficient plot
estout base1 urbc1 poor1 cult1 cash1 hirain1 using "./Drafts/tab_beta_mixed_base.tex", /// write the region results to Tex file
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) ///
	stats(p_zero N_country N_obs r2, fmt(%9.3f %9.0g %9.0g %9.2f) labels("p-value $\beta_g=0$" "Countries" "Observations" "R-square (ex. FE)")) ///
	keep(res_rurd) label mlabels(none) collabels(none) prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)
	
coefplot base1 || urbc1 || poor1 || cult1 || cash1 ||hirain1, ///
	keep(res_rurd) bycoefs graphregion(color(white)) xtitle("{&beta} estimate") xlabel(0(.05).35,format(%9.2f)) ///
	mlabel format(%9.3f) mlabposition(12) ///
	bylabels("Baseline" "Urban Pop < 25K" "Ex. Eur. and NA" "Cultivated land" "Ex. Cash crop" "High input prod.")
graph export "./Drafts/fig_coef_mixed_base.png", replace as(png)
graph export "./Drafts/fig_coef_mixed_base.eps", replace as(eps)

