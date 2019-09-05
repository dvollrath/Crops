//////////////////////////////////////////////////////////////////////
// Date: 2016-11-08
// Author: Dietz Vollrath
// 
// Control the flow of work for regressions
// 1. Create program to reset globals controlling code
// 2. Call data merge and prep routines
// 3. Call regression routines under various assumptions
//
//////////////////////////////////////////////////////////////////////
/*
local limit=10 // minimum number of districts in a country
local fe state_id // fixed effect to include
local csivar ln_csi_yield // measure of productivity
local rurdvar ln_grump_rurd //ln_rurd_2000 // rural density per unit of total land
local controls grump_urb_perc ln_light_mean ln_grump_popc // urban percent and light mean and total population
local dist 500 // km cutoff for Conley SE

//////////////////////////////////////
// Load data and calculate addl variables
//////////////////////////////////////
clear
estimates clear
use "./Work/all_crops_data_gadm2.dta" // 

// Generate holding variables for estimated beta values
generate beta = .
generate se = .
generate beta_raw = .
generate se_raw = .

levelsof country_id, local(levels) // get identifiers for countries
foreach x of local levels { // for each country
	di "Processing country id " (`x')
	count if country_id==`x'
	if r(N)>`limit' {
		// Regress using province FE
		qui reg ln_csi_yield `rurdvar' `cntl' if country_id==`x', absorb(state_id) cluster(state_id)
		qui replace beta = _b[`rurdvar'] if country_id==`x'
		qui replace se = _se[`rurdvar'] if country_id==`x'
		// Regress withou any province FE
		qui reg ln_csi_yield `rurdvar' `cntl' if country_id==`x', cluster(state_id)
		qui replace beta_raw = _b[`rurdvar'] if country_id==`x'
		qui replace se_raw = _se[`rurdvar'] if country_id==`x'

	}
}

// Generate spatial total light and CSI, for aggregation
gen light_total = exp(ln_light_mean)*shape_ha
gen csi_total = exp(ln_csi_yield)*shape_ha

// Collapse to country-level 
collapse (first) iso id_0 name_0 beta se beta_raw se_raw jv_region jv_subregion jv_subregion_text ///
	(rawsum) *_cells *_harvarea count shape_ha light_total csi_total (mean) suit_??? ///
	, by(country_id)

rename iso shortnam
save "./Work/crops_country_beta.dta", replace
*/
clear
use "./Data/disease.dta" // load AJ data
capture drop _merge
merge m:1 shortnam using "./Work/district-beta-map.dta"
//capture drop _merge
//merge m:1 shortnam using "./Work/crops_country_beta.dta"

//gen dry_suit = 0
//replace dry_suit = 1 if suit_brl>0 & suit_bck>0 & suit_rye>0 & suit_oat>0 & suit_wpo>0 & suit_whe>0
//gen wet_suit = 0
//replace wet_suit = 1 if suit_csv>0 & suit_cow>0 & suit_pml>0 & suit_spo & suit_rcw>0 & suit_yam>0

keep if sjbasesamplenoncomm==1 & startrich!=1 & !missing(logGDPperpopworkingage)

drop if wtd_district_beta<0

summ wtd_district_beta, det
capture drop beta_low
gen beta_low = .
replace beta_low = 1 if wtd_district_beta<.2 & !missing(wtd_district_beta)
replace beta_low = 0 if wtd_district_beta>=.2 & !missing(wtd_district_beta)

// Pull out country and year FE from each major variable
qui reg logtotalmaddgdp i.ctry yr????
capture drop tot_res
predict tot_res, res
qui reg logmaddpop i.ctry yr????
capture drop pop_res
predict pop_res, res
label variable pop_res "Log population"
qui reg loglifeexpect i.ctry yr????
capture drop life_res
predict life_res, res
label variable life_res "Log life expectancy"
qui reg loggdppcmadd i.ctry yr????
capture drop gdppc_res
predict gdppc_res, res
qui reg logGDPperpopworkingage i.ctry yr????
capture drop gdppw_res
predict gdppw_res, res
qui reg compsjmhatit i.ctry yr????
capture drop comps_res
predict comps_res, res
label variable comps_res "Mortality rate"

// Regressions using the de-meaned data from above
// Using mortality as the independent variable
qui reg pop_res life_res if beta_low==1, robust
qui count if e(sample)==1 & beta_low==1
qui estadd scalar N_obs = r(N)
qui tabulate ctry if e(sample)==1 & beta_low==1
qui estadd scalar N_ctry = r(r)
qui estadd scalar p_diff = .
qui estadd scalar p_zero = 2*(1-t(e(df_r),abs(_b[life_res])/_se[life_res])) // add p-value from interaction		
estimates store reg_aj_5

qui reg pop_res i.beta_low##c.life_res, robust
qui count if e(sample)==1 & beta_low==0
qui estadd scalar N_obs = r(N)
qui tabulate ctry if e(sample)==1 & beta_low==0
qui estadd scalar N_ctry = r(r)
qui estadd scalar p_diff = 2*(1-t(e(df_r),abs(_b[1.beta_low#c.life_res])/_se[1.beta_low#c.life_res]))
qui estadd scalar p_zero = 2*(1-t(e(df_r),abs(_b[life_res])/_se[life_res])) // add p-value from interaction		
estimates store reg_aj_6

qui reg gdppc_res life_res if beta_low==1, robust
qui count if e(sample)==1 & beta_low==1
qui estadd scalar N_obs = r(N)
qui tabulate ctry if e(sample)==1 & beta_low==1
qui estadd scalar N_ctry = r(r)
qui estadd scalar p_diff = .
qui estadd scalar p_zero = 2*(1-t(e(df_r),abs(_b[life_res])/_se[life_res])) // add p-value from interaction		
estimates store reg_aj_1

qui reg gdppc_res i.beta_low##c.life_res, robust
qui count if e(sample)==1 & beta_low==0
qui estadd scalar N_obs = r(N)
qui tabulate ctry if e(sample)==1 & beta_low==0
qui estadd scalar N_ctry = r(r)
qui estadd scalar p_diff = 2*(1-t(e(df_r),abs(_b[1.beta_low#c.life_res])/_se[1.beta_low#c.life_res]))
qui estadd scalar p_zero = 2*(1-t(e(df_r),abs(_b[life_res])/_se[life_res])) // add p-value from interaction		
estimates store reg_aj_2

qui reg gdppw_res life_res if beta_low==1, robust
qui count if e(sample)==1 & beta_low==1
qui estadd scalar N_obs = r(N)
qui tabulate ctry if e(sample)==1 & beta_low==1
qui estadd scalar N_ctry = r(r)
qui estadd scalar p_diff = .
qui estadd scalar p_zero = 2*(1-t(e(df_r),abs(_b[life_res])/_se[life_res])) // add p-value from interaction		
estimates store reg_aj_3

qui reg gdppw_res i.beta_low##c.life_res, robust
qui count if e(sample)==1 & beta_low==0
qui estadd scalar N_obs = r(N)
qui tabulate ctry if e(sample)==1 & beta_low==0
qui estadd scalar N_ctry = r(r)
qui estadd scalar p_diff = 2*(1-t(e(df_r),abs(_b[1.beta_low#c.life_res])/_se[1.beta_low#c.life_res]))
qui estadd scalar p_zero = 2*(1-t(e(df_r),abs(_b[life_res])/_se[life_res])) // add p-value from interaction		
estimates store reg_aj_4

estout reg_aj_1 reg_aj_2 reg_aj_3 reg_aj_4 reg_aj_5 reg_aj_6 using "./Drafts/tab_aj.tex", /// write the region results to Tex file
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) ///
	stats(p_zero p_diff N_ctry N_obs, fmt(%9.3f %9.3f %9.0f %9.0f) labels("p-value $\theta=0$" "p-value $\theta=\theta^{Below}$" "Countries" "Observations")) ///
	keep(life_res) label mlabels(none) collabels(none) prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)

qui reg gdppc_res pop_res if beta_low==1, robust
qui count if e(sample)==1 & beta_low==1
qui estadd scalar N_obs = r(N)
qui tabulate ctry if e(sample)==1 & beta_low==1
qui estadd scalar N_ctry = r(r)
qui estadd scalar p_diff = .
qui estadd scalar p_zero = 2*(1-t(e(df_r),abs(_b[pop_res])/_se[pop_res])) 
estimates store reg_aj_1

qui reg gdppc_res i.beta_low##c.pop_res, robust
qui count if e(sample)==1 & beta_low==0
qui estadd scalar N_obs = r(N)
qui tabulate ctry if e(sample)==1 & beta_low==0
qui estadd scalar N_ctry = r(r)
qui estadd scalar p_diff = 2*(1-t(e(df_r),abs(_b[1.beta_low#c.pop_res])/_se[1.beta_low#c.pop_res]))
qui estadd scalar p_zero = 2*(1-t(e(df_r),abs(_b[pop_res])/_se[pop_res])) 
estimates store reg_aj_2

qui reg gdppw_res pop_res if beta_low==1, robust
qui count if e(sample)==1 & beta_low==1
qui estadd scalar N_obs = r(N)
qui tabulate ctry if e(sample)==1 & beta_low==1
qui estadd scalar N_ctry = r(r)
qui estadd scalar p_diff = .
qui estadd scalar p_zero = 2*(1-t(e(df_r),abs(_b[pop_res])/_se[pop_res])) 
estimates store reg_aj_3

qui reg gdppw_res i.beta_low##c.pop_res, robust
qui count if e(sample)==1 & beta_low==0
qui estadd scalar N_obs = r(N)
qui tabulate ctry if e(sample)==1 & beta_low==0
qui estadd scalar N_ctry = r(r)
qui estadd scalar p_diff = 2*(1-t(e(df_r),abs(_b[1.beta_low#c.pop_res])/_se[1.beta_low#c.pop_res]))
qui estadd scalar p_zero = 2*(1-t(e(df_r),abs(_b[pop_res])/_se[pop_res])) 
estimates store reg_aj_4

estout reg_aj_1 reg_aj_2 reg_aj_3 reg_aj_4 using "./Drafts/tab_aj_pop.tex", /// write the region results to Tex file
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) ///
	stats(p_zero p_diff N_ctry N_obs, fmt(%9.3f %9.3f %9.0f %9.0f) labels("p-value $\theta=0$" "p-value $\theta=\theta^{Below}$" "Countries" "Observations")) ///
	keep(pop_res) label mlabels(none) collabels(none) prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)

qui reg pop_res comps_res if beta_low==1, robust
qui count if e(sample)==1 & beta_low==1
qui estadd scalar N_obs = r(N)
qui tabulate ctry if e(sample)==1 & beta_low==1
qui estadd scalar N_ctry = r(r)
qui estadd scalar p_diff = .
qui estadd scalar p_zero = 2*(1-t(e(df_r),abs(_b[comps_res])/_se[comps_res])) 
estimates store reg_aj_5

qui reg pop_res i.beta_low##c.comps_res, robust
qui count if e(sample)==1 & beta_low==0
qui estadd scalar N_obs = r(N)
qui tabulate ctry if e(sample)==1 & beta_low==0
qui estadd scalar N_ctry = r(r)
qui estadd scalar p_diff = 2*(1-t(e(df_r),abs(_b[1.beta_low#c.comps_res])/_se[1.beta_low#c.comps_res]))
qui estadd scalar p_zero = 2*(1-t(e(df_r),abs(_b[comps_res])/_se[comps_res])) 
estimates store reg_aj_6

qui reg gdppc_res comps_res if beta_low==1, robust
qui count if e(sample)==1 & beta_low==1
qui estadd scalar N_obs = r(N)
qui tabulate ctry if e(sample)==1 & beta_low==1
qui estadd scalar N_ctry = r(r)
qui estadd scalar p_diff = .
qui estadd scalar p_zero = 2*(1-t(e(df_r),abs(_b[comps_res])/_se[comps_res])) 
estimates store reg_aj_1

qui reg gdppc_res i.beta_low##c.comps_res, robust
qui count if e(sample)==1 & beta_low==0
qui estadd scalar N_obs = r(N)
qui tabulate ctry if e(sample)==1 & beta_low==0
qui estadd scalar N_ctry = r(r)
qui estadd scalar p_diff = 2*(1-t(e(df_r),abs(_b[1.beta_low#c.comps_res])/_se[1.beta_low#c.comps_res]))
qui estadd scalar p_zero = 2*(1-t(e(df_r),abs(_b[comps_res])/_se[comps_res])) 
estimates store reg_aj_2

qui reg gdppw_res comps_res if beta_low==1, robust
qui count if e(sample)==1 & beta_low==1
qui estadd scalar N_obs = r(N)
qui tabulate ctry if e(sample)==1 & beta_low==1
qui estadd scalar N_ctry = r(r)
qui estadd scalar p_diff = .
qui estadd scalar p_zero = 2*(1-t(e(df_r),abs(_b[comps_res])/_se[comps_res])) 
estimates store reg_aj_3

qui reg gdppw_res i.beta_low##c.comps_res, robust
qui count if e(sample)==1 & beta_low==0
qui estadd scalar N_obs = r(N)
qui tabulate ctry if e(sample)==1 & beta_low==0
qui estadd scalar N_ctry = r(r)
qui estadd scalar p_diff = 2*(1-t(e(df_r),abs(_b[1.beta_low#c.comps_res])/_se[1.beta_low#c.comps_res]))
qui estadd scalar p_zero = 2*(1-t(e(df_r),abs(_b[comps_res])/_se[comps_res])) 
estimates store reg_aj_4

estout reg_aj_1 reg_aj_2 reg_aj_3 reg_aj_4 reg_aj_5 reg_aj_6 using "./Drafts/tab_aj_comp.tex", /// write the region results to Tex file
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) ///
	stats(p_zero p_diff N_ctry N_obs, fmt(%9.3f %9.3f %9.0f %9.0f) labels("p-value $\theta=0$" "p-value $\theta=\theta^{Trop}$" "Countries" "Observations")) ///
	keep(comps_res) label mlabels(none) collabels(none) prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)

