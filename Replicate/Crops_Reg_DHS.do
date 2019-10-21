//////////////////////////////////////
// Results with DHS controls
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
local rurdvar c.ln_grump_rurd //ln_rurd_2000 // rural density per unit of total land
local controls c.grump_urb_perc c.ln_light_mean c.ln_grump_popc /// urban percent and light mean and total population
	c.ln_road_total_dens c.perc_road_tp1 c.perc_road_tp2 c.perc_road_tp3 ///
	c.ln_agro_slpidx // distance controls
local dhshead c.dhs_p50_head_ed_years c.dhs_p50_head_age c.dhs_p50_hh_mem_dejure // dhs_p10_head_ed_years dhs_p10_head_age dhs_p10_hh_mem_dejure dhs_p90_head_ed_years dhs_p90_head_age dhs_p90_hh_mem_dejure
local dhsasset c.dhs_hh_land c.dhs_hh_cattle_dum c.dhs_hh_draft_dum c.dhs_hh_sheep_dum c.dhs_hh_bank c.dhs_hh_flush c.dhs_hh_elec
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

reg `csivar' `rurdvar' `controls' if tag==1 & temp==1, absorb(`fe') cluster(`fe')
qui estadd scalar p_zero = 2*(1-t(e(df_r),abs(_b[ `rurdvar'])/_se[ `rurdvar']))
qui tabulate name_0 if e(sample)==1 & temp==1
qui estadd scalar N_country = r(r)
qui estadd scalar N_obs = r(N)
estimates store comp1

reg `csivar' (`rurdvar' `controls')##i.temp if tag==1, absorb(`fe') cluster(`fe')
qui estadd scalar p_zero = 2*(1-t(e(df_r),abs(_b[ `rurdvar'])/_se[ `rurdvar']))
qui estadd scalar p_diff = 2*(1-t(e(df_r),abs(_b[1.temp#c.`rurdvar'])/_se[1.temp#c.`rurdvar']))
qui tabulate name_0 if e(sample)==1 & temp==0
qui estadd scalar N_country = r(r)
qui estadd scalar N_obs = r(N)
estimates store comp2

reg `csivar' `rurdvar' `controls' `dhshead' if tag==1 & temp==1, absorb(`fe') cluster(`fe')
qui estadd scalar p_zero = 2*(1-t(e(df_r),abs(_b[ `rurdvar'])/_se[ `rurdvar']))
qui tabulate name_0 if e(sample)==1 & temp==1
qui estadd scalar N_country = r(r)
qui estadd scalar N_obs = r(N)
estimates store dhs1

reg `csivar' (`rurdvar' `controls' `dhshead')##i.temp if tag==1, absorb(`fe') cluster(`fe')
qui estadd scalar p_zero = 2*(1-t(e(df_r),abs(_b[ `rurdvar'])/_se[ `rurdvar']))
qui estadd scalar p_diff = 2*(1-t(e(df_r),abs(_b[1.temp#c.`rurdvar'])/_se[1.temp#c.`rurdvar']))
qui tabulate name_0 if e(sample)==1 & temp==0
qui estadd scalar N_country = r(r)
qui estadd scalar N_obs = r(N)
estimates store dhs2

reg `csivar' `rurdvar' `controls' `dhshead' `dhsasset' if tag==1 & temp==1, absorb(`fe') cluster(`fe')
qui estadd scalar p_zero = 2*(1-t(e(df_r),abs(_b[ `rurdvar'])/_se[ `rurdvar']))
qui tabulate name_0 if e(sample)==1 & temp==1
qui estadd scalar N_country = r(r)
qui estadd scalar N_obs = r(N)
estimates store asset1

reg `csivar' (`rurdvar' `controls' `dhshead' `dhsasset')##i.temp if tag==1, absorb(`fe') cluster(`fe')
qui estadd scalar p_zero = 2*(1-t(e(df_r),abs(_b[ `rurdvar'])/_se[ `rurdvar']))
qui estadd scalar p_diff = 2*(1-t(e(df_r),abs(_b[1.temp#c.`rurdvar'])/_se[1.temp#c.`rurdvar']))
qui tabulate name_0 if e(sample)==1 & temp==0
qui estadd scalar N_country = r(r)
qui estadd scalar N_obs = r(N)
estimates store asset2

// Output tables and coefficient plot
estout comp1 comp2 dhs1 dhs2 asset1 asset2 using "./Drafts/tab_beta_crop_dhs.tex", /// write the region results to Tex file
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) ///
	indicate("Demog. controls = dhs_p50_head_ed_years" "Asset controls = dhs_hh_land") ///
	stats(p_zero p_diff N_country N_obs r2, fmt(%9.3f %9.3f %9.0g %9.0g %9.2f) labels("p-value $\beta_g=0$" "p-value $\beta_g=\beta_{Temp}$" "Countries" "Observations" "R-square")) ///
	keep(ln_grump_rurd) label mlabels(none) collabels(none) prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)
	
coefplot comp1 || comp2 || dhs1 || dhs2 || asset1 || asset2, ///
	keep(ln_grump_rurd) bycoefs graphregion(color(white)) xtitle("{&beta} estimate") xlabel(0(.05).50,format(%9.2f)) ///
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
