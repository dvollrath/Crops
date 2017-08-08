//////////////////////////////////////////////////////////////////////
// Date: 2016-11-08
// Author: Dietz Vollrath
// 
// Run province level regressions
// 1. Run reg for each province with >6 observations
// 2. Create summary table and figures of beta values
// 3. Create figures of beta related to density
//
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////
// Set working parameters
//////////////////////////////////////
local year=2000
local cntl urb_perc_`year' ln_light_mean // control variables to include in all regressions

global data "/users/dietz/dropbox/project/crops/work"
global output "/users/dietz/dropbox/project/crops/drafts"

//////////////////////////////////////
// Load data and calculate addl variables
//////////////////////////////////////
clear
estimates clear
use "$data/all_crops_data_gadm2.dta"

gen cons = 1 // constant for use in spatial OLS
gen y = 1 // "time" variable for use in spatial OLS

gen beta = . // holder variable for estiamted beta
gen se = . // holder variable for SE of estimated beta

//////////////////////////////////////
// Run regressions for each province
//////////////////////////////////////
levelsof state_id, local(levels) // get identifiers for provinces
foreach x of local levels { // for each province
	di "Processing province id " (`x')
	count if state_id == `x'
	if r(N) > 5 {
		qui reg ln_csi_yield ln_rurd_`year' `cntl' if state_id==`x'
		qui replace beta = _b[ln_rurd_`year'] if state_id==`x'
		qui replace se = _se[ln_rurd_`year'] if state_id==`x'
	}
}
// Variables for rolling up light and CSI
gen light_total = exp(ln_light_mean)*shape_ha
gen csi_total = exp(ln_csi_yield)*shape_ha

// Collapse dataset to province level
collapse (first) iso id_0 id_1 name_0 name_1 beta se jv_region jv_subregion jv_subregion_text ///
	(rawsum) *_cells *_harvarea count rurc_`year' urbc_`year' shape_ha light_total csi_total (sd) ln_csi_yield (mean) suit_??? ///
	, by(state_id)
drop if beta==. // no beta calculated
drop if jv_subregion==. // not in our standard regions

rename ln_csi_yield ln_csi_yield_sd
gen ln_light_mean = ln(light_total/shape_ha)
gen ln_csi_yield = ln(csi_total/shape_ha)

// Generate crop suitability/cal/harv flags, similar to main analysis
gen dry_suit = 0
replace dry_suit = 1 if suit_brl>0 & suit_bck>0 & suit_rye>0 & suit_oat>0 & suit_wpo>0 & suit_whe>0
gen wet_suit = 0
replace wet_suit = 1 if suit_csv>0 & suit_cow>0 & suit_pml>0 & suit_spo & suit_rcw>0 & suit_yam>0

gen dry_max = 0
replace dry_max = 1 if (barley_cells + buckwheat_cells + oat_cells + rye_cells + whitepotato_cells + wheat_cells)>.33*count
gen wet_max = 0
replace wet_max = 1 if (cassava_cells + cowpea_cells + pearlmillet_cells + sweetpotato_cells + wetrice_cells + yams_cells)>.33*count

egen harvarea_sum = rowtotal(*_harvarea)
gen dry_area = 0
replace dry_area = 1 if (barley_harvarea + buckwheat_harvarea + oats_harvarea + rye_harvarea + potato_harvarea + wheat_harvarea)>.5*harvarea_sum
gen wet_area = 0
replace wet_area = 1 if (cassava_harvarea + cowpea_harvarea + millet_harvarea + sweetpotato_harvarea + rice_harvarea + yam_harvarea)>.5*harvarea_sum

// Write table of summary statistics for province-level results
capture file close f_result
file open f_result using "$output/tab_summ_province.tex", write replace

qui summ beta, det
file write f_result "All provinces &" %9.0fc (r(N)) "&" %9.2fc (r(mean)) "&" %9.2fc (r(sd)) "&" %9.2fc (r(p10)) "&" %9.2fc (r(p25)) "&" %9.2fc (r(p50)) "&" ///
			%9.2fc (r(p75)) "&" %9.2fc (r(p90)) "\\" _n
qui summ beta if dry_suit==1 & wet_suit==0, det
file write f_result "Wheat Suitable &" %9.0fc (r(N)) "&" %9.2fc (r(mean)) "&" %9.2fc (r(sd)) "&" %9.2fc (r(p10)) "&" %9.2fc (r(p25)) "&" %9.2fc (r(p50)) "&" ///
			%9.2fc (r(p75)) "&" %9.2fc (r(p90)) "\\" _n
qui summ beta if dry_suit==0 & wet_suit==1, det
file write f_result "Rice Suitable &" %9.0fc (r(N)) "&" %9.2fc (r(mean)) "&" %9.2fc (r(sd)) "&" %9.2fc (r(p10)) "&" %9.2fc (r(p25)) "&" %9.2fc (r(p50)) "&" ///
			%9.2fc (r(p75)) "&" %9.2fc (r(p90)) "\\" _n
qui summ beta if dry_max==1 & wet_max==0, det
file write f_result "Wheat cals>33\% &" %9.0fc (r(N)) "&" %9.2fc (r(mean)) "&" %9.2fc (r(sd)) "&" %9.2fc (r(p10)) "&" %9.2fc (r(p25)) "&" %9.2fc (r(p50)) "&" ///
			%9.2fc (r(p75)) "&" %9.2fc (r(p90)) "\\" _n
qui summ beta if dry_max==0 & wet_max==1, det
file write f_result "Rice cals>33\% &" %9.0fc (r(N)) "&" %9.2fc (r(mean)) "&" %9.2fc (r(sd)) "&" %9.2fc (r(p10)) "&" %9.2fc (r(p25)) "&" %9.2fc (r(p50)) "&" ///
			%9.2fc (r(p75)) "&" %9.2fc (r(p90)) "\\" _n
qui summ beta if dry_area==1 & wet_area==0, det
file write f_result "Wheat area>50\% &" %9.0fc (r(N)) "&" %9.2fc (r(mean)) "&" %9.2fc (r(sd)) "&" %9.2fc (r(p10)) "&" %9.2fc (r(p25)) "&" %9.2fc (r(p50)) "&" ///
			%9.2fc (r(p75)) "&" %9.2fc (r(p90)) "\\" _n
qui summ beta if dry_area==0 & wet_area==1, det
file write f_result "Rice area>50\% &" %9.0fc (r(N)) "&" %9.2fc (r(mean)) "&" %9.2fc (r(sd)) "&" %9.2fc (r(p10)) "&" %9.2fc (r(p25)) "&" %9.2fc (r(p50)) "&" ///
			%9.2fc (r(p75)) "&" %9.2fc (r(p90)) "\\" _n

file close f_result		

// Generate betas by sub-sample for dot-plot
capture drop beta?
qui summ beta, det
gen beta0 = beta if beta<r(p99) & beta>r(p1)
label variable beta0 "All provinces"
gen beta1 = beta if dry_suit==1 & wet_suit==0 & beta<r(p99) & beta>r(p1)
label variable beta1 "Wheat suit"
gen beta2 = beta if dry_suit==0 & wet_suit==1 & beta<r(p99) & beta>r(p1)
label variable beta2 "Rice suit"
gen beta3 = beta if dry_max==1 & wet_max==0 & beta<r(p99) & beta>r(p1)
label variable beta3 "Wheat cals"
gen beta4 = beta if dry_max==0 & wet_max==1 & beta<r(p99) & beta>r(p1)
label variable beta4 "Rice cals"
gen beta5 = beta if dry_area==1 & wet_area==0 & beta<r(p99) & beta>r(p1)
label variable beta5 "Wheat area"
gen beta6 = beta if dry_area==0 & wet_area==1 & beta<r(p99) & beta>r(p1)
label variable beta6 "Rice area"

dotplot beta?, ///
	center msymbol(oh o) ny(50) mcolor(gray black) median ///
	graphregion(color(white))  ylabel(-.5(.25)1, angle(0) format(%9.1f)) ytitle("Estimated {&beta}") ///
	xtitle("") xlabel(, angle(45))
graph export "$output/fig_beta_province.png", replace as(png)
graph export "$output/fig_beta_province.eps", replace as(eps)
		
// Generate other figures of beta versus density, beta versus SD of CSI		
qui summ beta, det	
capture drop point
qui gen point = 1 if beta<r(p99) & beta>r(p1)
capture drop ln_rurd
qui gen ln_rurd = ln(rurc_`year'/shape_ha)
scatter beta ln_rurd if point==1, msymbol(oh) mcolor(black) ///
	graphregion(color(white)) xtitle("Log rural density (province level)") ytitle("Estimated {&beta}") ///
	ylabel(-.5(.25)1, nogrid angle(0) format(%9.2f))
graph export "$output/fig_beta_rurd.png", replace as(png)
graph export "$output/fig_beta_rurd.eps", replace as(eps)
		
scatter beta ln_csi_yield_sd if point==1, msymbol(oh) mcolor(black) ///
	graphregion(color(white)) xtitle("SD of Log CSI Yield x/districts") ytitle("Estimated {&beta}") ///
	ylabel(-.5(.25)1, nogrid angle(0) format(%9.2f))
graph export "$output/fig_beta_sd_csi.png", replace as(png)
graph export "$output/fig_beta_sd_csi.eps", replace as(eps)
		
		
