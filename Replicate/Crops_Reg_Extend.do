////////////////////////////////////////////////////////////////////////////
// Robustness checks - Extended definitions of temperate/tropical
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
local csivar ln_csi_yield  // productivity
local rurdvar ln_rurd_2000 // rural density per unit of total land
local controls urb_perc_2000 ln_light_mean // urban percent and light mean
local dist 500 // km cutoff for Conley SE

/////////////////////////////////////////
// Regressions for wider crop definitions
/////////////////////////////////////////	
capture drop crop
gen crop = .
replace crop = 1 if dry_suit==0 & wet_suit==0 // NEITHER temperate or tropical suitable is baseline

replace crop = 0 if dry_suit==1 & wet_suit==1 // BOTH temperate and tropical
doreg `csivar' `rurdvar' `controls', fe(`fe') dist(`dist') comp(crop) tag(both)

replace crop = . if crop==0
replace crop = 0 if dry_suit==1 // ANY temperate
doreg `csivar' `rurdvar' `controls', fe(`fe') dist(`dist') comp(crop) tag(temp)

replace crop = . if crop==0
replace crop = 0 if wet_suit==1 // ANY tropical
doreg `csivar' `rurdvar' `controls', fe(`fe') dist(`dist') comp(crop) tag(trop)

replace crop = . if crop==0
replace crop = 0 if dry_suit==1 & wet_suit==1 // BOTH temperate and tropical
doreg `csivar' `rurdvar' `controls' if urbc_2000<25000, fe(`fe') dist(`dist') comp(crop) tag(bothurb)

replace crop = . if crop==0
replace crop = 0 if dry_suit==1 // ANY temperate
doreg `csivar' `rurdvar' `controls' if urbc_2000<25000, fe(`fe') dist(`dist') comp(crop) tag(tempurb)

replace crop = . if crop==0
replace crop = 0 if wet_suit==1 // ANY tropical
doreg `csivar' `rurdvar' `controls' if urbc_2000<25000, fe(`fe') dist(`dist') comp(crop) tag(tropurb)

// Output table
estout both2 temp2 trop2 bothurb2 tempurb2 tropurb2 using "./Drafts/tab_beta_extend_base.tex", /// write the region results to Tex file
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) ///
	stats(p_zero N_country N_obs r2, fmt(%9.3f %9.0g %9.0g %9.2f) labels("p-value $\beta=0$" "Countries" "Observations" "R-square (ex. FE)")) ///
	keep(res_rurd) label mlabels(none) collabels(none) prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)
	
