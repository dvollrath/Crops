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
local rurdvar ln_rurd_2000 // rural density per unit of total land
local controls urb_perc_2000 ln_light_mean ln_popc_2000 // urban percent and light mean
local dhshead dhs_p50_head_ed_years dhs_p50_head_age dhs_p50_hh_mem_dejure dhs_p10_head_ed_years dhs_p10_head_age dhs_p10_hh_mem_dejure dhs_p90_head_ed_years dhs_p90_head_age dhs_p90_hh_mem_dejure
local dhsasset dhs_hh_flush dhs_hh_elec dhs_hh_tv dhs_hh_frig dhs_hh_floor dhs_hh_land dhs_hh_bank dhs_hh_cattle_dum dhs_hh_draft_dum dhs_hh_sheep_dum
local dist 500 // km cutoff for Conley SE

//////////////////////////////////////
// Regressions - temperate and tropical
//////////////////////////////////////	

capture drop temp
gen temp = .

replace temp = 1 if dry_suit==1 & wet_suit==0 // suitable for temp crops, not for trop
replace temp = 0 if dry_suit==0 & wet_suit==1 // suitable for trop crops, not for temp

// Run reg just to capture sample for inclusion with all controls
qui reg `csivar' `rurdvar' `controls' `dhshead' `dhsasset' if inlist(temp,0,1), absorb(`fe') cluster(`fe')
gen tag = e(sample)

doreg `csivar' `rurdvar' `controls' if tag==1, fe(`fe') dist(`dist') comp(temp) tag(comp) // call program to do spatial OLS

doreg `csivar' `rurdvar' `controls' `dhshead' if tag==1, fe(`fe') dist(`dist') comp(temp) tag(dhs) // call program to do spatial OLS

doreg `csivar' `rurdvar' `controls' `dhshead' `dhsasset' if tag==1, fe(`fe') dist(`dist') comp(temp) tag(asset) // call program to do spatial OLS

// Output tables and coefficient plot
estout comp1 comp2 dhs1 dhs2 asset1 asset2 using "./Drafts/tab_beta_crop_dhs.tex", /// write the region results to Tex file
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) ///
	indicate("Demog. controls = res_cntl_dhs_p50_head_ed_years" "Asset controls = res_cntl_dhs_hh_flush") ///
	stats(p_zero p_diff N_country N_obs r2, fmt(%9.3f %9.3f %9.0g %9.0g %9.2f) labels("p-value $\beta_g=0$" "p-value $\beta_g=\beta_{Temp}$" "Countries" "Observations" "R-square (ex. FE)")) ///
	keep(res_rurd) label mlabels(none) collabels(none) prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)
	
coefplot comp1 || comp2 || dhs1 || dhs2 || asset1 || asset2, ///
	keep(res_rurd) bycoefs graphregion(color(white)) xtitle("{&beta} estimate") xlabel(0(.05).35,format(%9.2f)) ///
	mlabel format(%9.3f) mlabposition(12) ///
	headings(1 = "{bf:DHS sample, no DHS controls}" 3 = "{bf:Control DHS demog}" 5 = "{bf:Control DHS assets}") ///
	bylabels("Temperate" "Tropical" "Temperate" "Tropical" "Temperate" "Tropical")
graph export "./Drafts/fig_coef_crop_dhs.png", replace as(png)
graph export "./Drafts/fig_coef_crop_dhs.eps", replace as(eps)

//////////////////////////////////////
// Write Country (Year) names
//////////////////////////////////////
preserve
	keep if tag==1
	collapse (first) name_0 year phase, by(ccode)
	capture file close f_result
	file open f_result using "~/Dropbox/project/crops/drafts/tab_dhs_countries.tex", write replace

	count
	local max = r(N)
	forvalues x = 1(1)`max' {
		if `x'==1 {
			file write f_result (name_0[`x']) " (" (year[`x']) ")"
		}
		else {
			file write f_result ", " (name_0[`x']) " (" (year[`x']) ")"
		}
	}
	capture file close f_result
restore
