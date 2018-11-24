////////////////////////////////////////////////////////////////////////////
// Robustness checks - Using individual crop productivity
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

capture drop temp
gen temp = .
replace temp = 1 if dry_suit==1 & wet_suit==0 // Temperate
replace temp = 0 if dry_suit==0 & wet_suit==1 // Tropical

/////////////////////////////////////////
// Regressions for temperate crops
/////////////////////////////////////////	
 
onereg ln_csi_yield `rurdvar' `controls' if temp==1, fe(`fe') dist(`dist') tag(csi)
onereg ln_barley_yield `rurdvar' `controls' if temp==1, fe(`fe') dist(`dist') tag(bar)
onereg ln_buckwheat_yield `rurdvar' `controls' if temp==1, fe(`fe') dist(`dist') tag(buck)
onereg ln_rye_yield `rurdvar' `controls' if temp==1, fe(`fe') dist(`dist') tag(rye)
onereg ln_oat_yield `rurdvar' `controls' if temp==1, fe(`fe') dist(`dist') tag(oat)
onereg ln_whitepotato_yield `rurdvar' `controls' if temp==1, fe(`fe') dist(`dist') tag(wpo)
onereg ln_wheat_yield `rurdvar' `controls' if temp==1, fe(`fe') dist(`dist') tag(wheat)

// Output table
estout csi1 bar1 buck1 rye1 oat1 wpo1 wheat1 using "./Drafts/tab_beta_tempcrop_base.tex", /// write the region results to Tex file
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) ///
	stats(p_zero N_country N_obs r2, fmt(%9.3f %9.0g %9.0g %9.2f) labels("p-value $\beta=0$" "Countries" "Observations" "R-square (ex. FE)")) ///
	keep(res_rurd) label mlabels(none) collabels(none) prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)
	
/////////////////////////////////////////
// Regressions for tropical crops
/////////////////////////////////////////
 
onereg ln_csi_yield `rurdvar' `controls' if temp==0, fe(`fe') dist(`dist') tag(csi)
onereg ln_cassava_yield `rurdvar' `controls' if temp==0, fe(`fe') dist(`dist') tag(cas)
onereg ln_cowpea_yield `rurdvar' `controls' if temp==0, fe(`fe') dist(`dist') tag(cow)
onereg ln_pearlmillet_yield `rurdvar' `controls' if temp==0, fe(`fe') dist(`dist') tag(pearl)
onereg ln_sweetpotato_yield `rurdvar' `controls' if temp==0, fe(`fe') dist(`dist') tag(sweet)
onereg ln_wetrice_yield `rurdvar' `controls' if temp==0, fe(`fe') dist(`dist') tag(rice)
onereg ln_yams_yield `rurdvar' `controls' if temp==0, fe(`fe') dist(`dist') tag(yam)

// Output table
estout csi1 cas1 cow1 pearl1 sweet1 rice1 yam1 using "./Drafts/tab_beta_tropcrop_base.tex", /// write the region results to Tex file
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) ///
	stats(p_zero N_country N_obs r2, fmt(%9.3f %9.0g %9.0g %9.2f) labels("p-value $\beta=0$" "Countries" "Observations" "R-square (ex. FE)")) ///
	keep(res_rurd) label mlabels(none) collabels(none) prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)
	
