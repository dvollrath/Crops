////////////////////////////////////////////////////////////////////////////
// Terrain limited samples
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
local csivar ln_csi_yield // measure of productivity
local rurdvar ln_grump_rurd //ln_rurd_2000 // rural density per unit of total land
local controls grump_urb_perc ln_light_mean ln_grump_popc /// main controls
	ln_road_total_dens perc_road_tp1 perc_road_tp2 perc_road_tp3 ///
	ln_agro_slpidx dist_bigcity // distance controls
local dist 500 // km cutoff for Conley SE

//////////////////////////////////////
// Regressions
//////////////////////////////////////

// Create dummy to distinguish temperate from tropical on crops
capture drop temp
qui gen temp = .
qui replace temp = 1 if dry_suit==1 & wet_suit==0 // suitable for temp crops, not for trop
qui replace temp = 0 if dry_suit==0 & wet_suit==1 // suitable for trop crops, not for temp

capture drop agro_slope_index
qui gen agro_slope_index = agro_slpidx/100
qui summ agro_slope_index, det
local p1 = r(p1)
local p5 = r(p5)
local p25 = r(p25)

hdreg `csivar' `rurdvar' if agro_slope_index>=`p1', fe(`fe') controls(`controls') dist(`dist') comp(temp) tag(first) // call program to do spatial OLS
hdreg `csivar' `rurdvar' if agro_slope_index>=`p5', fe(`fe') controls(`controls') dist(`dist') comp(temp) tag(second) // call program to do spatial OLS
hdreg `csivar' `rurdvar' if agro_slope_index>=`p25', fe(`fe') controls(`controls') dist(`dist') comp(temp) tag(third) // call program to do spatial OLS

// Output table and coefficient plot
estout first1 first2 second1 second2 third1 third2 using "./Drafts/tab_beta_terrain.tex", /// write the region results to Tex file
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) ///
	stats(p_zero p_diff N_country N_obs r2, fmt(%9.3f %9.3f %9.0g %9.0g %9.2f) labels("p-value $\beta_g=0$" "p-value $\beta_g=\beta_{Temp}$" "Countries" "Observations" "R-square (ex. FE)")) ///
	keep(res_rurd) label mlabels(none) collabels(none) prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)
		
