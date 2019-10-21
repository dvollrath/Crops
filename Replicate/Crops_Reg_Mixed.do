//////////////////////////////////////
// Mixed crop area results - Table 7
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
local controls grump_urb_perc ln_light_mean ln_grump_popc /// main controls
	ln_road_total_dens perc_road_tp1 perc_road_tp2 perc_road_tp3 ///
	ln_agro_slpidx dist_bigcity // distance controls
local dist 500 // km cutoff for Conley SE

//////////////////////////////////////
// Regressions mixed districts
//////////////////////////////////////	

// Create dummy to distinguish temperate from tropical on crops
capture drop mixed
gen mixed = .
replace mixed = 0 if dry_suit==1 & wet_suit==1  // suitable for BOTH, baseline
replace mixed = 1 if dry_suit==1 & wet_suit==0 // suitable for temp crops, not for trop
replace mixed = 2 if dry_suit==0 & wet_suit==1 // suitable for trop, not for temp

hdreg3 `csivar' `rurdvar', controls(`controls') fe(`fe') dist(`dist') comp(mixed) tag(base) // call program to do spatial OLS

hdreg3 `csivar' `rurdvar' if grump_urbc<50000, controls(`controls') fe(`fe') dist(`dist') comp(mixed) tag(urbc) // call program to do spatial OLS

hdreg3 `csivar' `rurdvar' if inlist(jv_subregion,4,7,8,9), controls(`controls') fe(`fe') dist(`dist') comp(mixed) tag(poor)

hdreg3 `csivar' ln_grump_rurd_cult, controls(ln_cult_area_perc `controls') fe(`fe') dist(`dist') comp(mixed) tag(cult)

hdreg3 `csivar' `rurdvar' if cash_area_perc<.10, controls(`controls') fe(`fe') dist(`dist') comp(mixed) tag(cash)

hdreg3 ln_csi_yield_hi_rain `rurdvar', controls(`controls') fe(`fe') dist(`dist') comp(mixed) tag(hirain)

// Output tables and coefficient plot
estout base1 urbc1 poor1 cult1 cash1 hirain1 using "./Drafts/tab_beta_mixed_base.tex", /// write the region results to Tex file
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) ///
	stats(p_zero p_diff1 p_diff2 N_country N_obs r2, fmt(%9.3f %9.3f %9.3f %9.0g %9.0g %9.2f) labels("p-value $\beta_g=0$" "p-value $\beta_g=\beta_g^{Temp}$" "p-value $\beta_g=\beta_g^{Trop}$" "Countries" "Observations" "R-square (ex. FE)")) ///
	keep(res_rurd) label mlabels(none) collabels(none) prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)
	
coefplot base1 || urbc1 || poor1 || cult1 || cash1 ||hirain1, ///
	keep(res_rurd) bycoefs graphregion(color(white)) xtitle("{&beta} estimate") xlabel(0(.05).35,format(%9.2f)) ///
	mlabel format(%9.3f) mlabposition(12) ///
	bylabels("Baseline" "Urban Pop < 50K" "Ex. Eur. and NA" "Cultivated land" "Ex. Cash crop" "High input prod.")
graph export "./Drafts/fig_coef_mixed_base.png", replace as(png)
graph export "./Drafts/fig_coef_mixed_base.eps", replace as(eps)

