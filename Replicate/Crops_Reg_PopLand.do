////////////////////////////////////////////////////////////////////////////
// Robustness checks - Table 3 in paper
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
local controls urb_perc_2000 ln_light_mean ln_popc_2000 // urban percent and light mean
local dist 500 // km cutoff for Conley SE
local temperate temp // variable denoting temperate/tropical

//////////////////////////////////////
// Regressions - different productivity
//////////////////////////////////////	
capture drop temp
gen temp = .
replace temp = 1 if dry_suit==1 & wet_suit==0 // suitable for temp crops, not for trop
replace temp = 0 if dry_suit==0 & wet_suit==1 // suitable for trop crops, not for temp

// HYDE 1950 rural density
doreg `csivar' ln_rurd_1950 `controls', fe(`fe') dist(`dist') comp(temp) tag(hyde) // call program to do spatial OLS

// GRUMP rural density
doreg `csivar' ln_grump_rurd ln_light_mean grump_urb_perc ln_grump_popc, fe(`fe') dist(`dist') comp(temp) tag(grump) // call program to do spatial OLS

// IPUMS rural density
clear
use "./Work//all_crops_data_ipums.dta"
gen c = 1 // constant for use in spatial OLS
capture drop temp
gen temp=.
replace temp = 1 if dry_suit==1 & wet_suit==0
replace temp = 0 if dry_suit==0 & wet_suit==1

doreg ln_csi_yield ln_pag urb_perc ln_light_mean, fe(cntry_code) dist(`dist') comp(temp) tag(ipums) // call program to do spatial OLS

// Output table
estout hyde1 hyde2 grump1 grump2 ipums1 ipums2 using "./Drafts/tab_beta_robust_pop.tex", /// write the region results to Tex file
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) ///
	stats(p_zero p_diff N_country N_obs r2, fmt(%9.3f %9.3f %9.0g %9.0g %9.2f) labels("p-value $\beta_g=0$" "p-value $\beta_g=\beta_{Temp}$" "Countries" "Observations" "R-square (ex. FE)")) ///
	keep(res_rurd) label mlabels(none) collabels(none) prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)
	
//////////////////////////////////////
// Regressions - different land assumptions
//////////////////////////////////////	
clear
estimates clear
use "./Work/all_crops_data_gadm2.dta" // 

capture drop temp
gen temp = .
replace temp = 1 if dry_suit==1 & wet_suit==0 // suitable for temp crops, not for trop
replace temp = 0 if dry_suit==0 & wet_suit==1 // suitable for trop crops, not for temp

// Using cultivated area
doreg `csivar' ln_rurd_cult_2000 ln_cult_area_perc `controls', fe(`fe') dist(`dist') comp(temp) tag(cult) // call program to do spatial OLS

// For positive production of staple crops
doreg `csivar' `rurdvar' `controls' if popc_2000<50000, fe(`fe') dist(`dist') comp(temp) tag(pop) // call program to do spatial OLS

// Drop provinces with fewer than 50 districts
doreg `csivar' `rurdvar' `controls' if district_count>50, fe(`fe') dist(`dist') comp(temp) tag(number) // call program to do spatial OLS

// Output table and coefficient plot
estout cult1 cult2 pop1 pop2 number1 number2 using "./Drafts/tab_beta_robust_other.tex", /// write the region results to Tex file
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) ///
	stats(p_zero p_diff N_country N_obs r2, fmt(%9.3f %9.3f %9.0g %9.0g %9.2f) labels("p-value $\beta_g=0$" "p-value $\beta_g=\beta_{Temp}$" "Countries" "Observations" "R-square (ex. FE)")) ///
	keep(res_rurd) label mlabels(none) collabels(none) prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)
		
coefplot cult1 || cult2 || pop1 || pop2 || number1 ///
	|| number2, ///
	keep(res_rurd) bycoefs graphregion(color(white)) xtitle("{&beta} estimate") xlabel(0(.05).35,format(%9.2f)) ///
	mlabel format(%9.3f) mlabposition(12) ///
	headings(1 = "{bf:Cult. area for density}" 3 = "{bf:<50K population}" 5 = "{bf:Excl. prov. <50 dist.}") ///
	bylabels("Temperate" "Tropical" "Temperate" "Tropical" "Temperate" "Tropical" )
graph export "./Drafts/fig_coef_robust_other.eps", replace as(eps)
graph export "./Drafts/fig_coef_robust_other.png", replace as(png)	

		
