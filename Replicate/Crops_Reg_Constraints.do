//////////////////////////////////////
// Results with GAEZ constraint controls
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
local gaez i.agro_sq1_dum i.agro_sq2_dum i.agro_sq7_dum i.agro_slpmed_dum i.agro_ric_dum i.agro_lgd_dum //
local dist 500 // km cutoff for Conley SE

///////////////////////////////////////////////////
// Regressions - including GAEZ controls - for Appendix
///////////////////////////////////////////////////	

hdreg `csivar' `rurdvar', fe(`fe' `gaez') controls(`controls') dist(`dist') comp(temp) tag(bgaez) // call program to do spatial OLS
hdreg `csivar' `rurdvar' if grump_urbc<50000, fe(`fe' `gaez') controls(`controls') dist(`dist') comp(temp) tag(ugaez) // call program to do spatial OLS
hdreg `csivar' `rurdvar' if inlist(jv_subregion,4,7,8,9), fe(`fe' `gaez') controls(`controls') dist(`dist') comp(temp) tag(hgaez) // call program to do spatial OLS

// Output table and coefficient plot
estout bgaez1 bgaez2 ugaez1 ugaez2 hgaez1 hgaez2 using "./Drafts/tab_beta_robust_input_controls.tex", /// write the region results to Tex file
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) ///
	stats(p_zero p_diff N_country N_obs r2, fmt(%9.3f %9.3f %9.0g %9.0g %9.2f) labels("p-value $\beta_g=0$" "p-value $\beta_g=\beta_{Temp}$" "Countries" "Observations" "R-square (ex. FE)")) ///
	keep(res_rurd) label mlabels(none) collabels(none) prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)
		
