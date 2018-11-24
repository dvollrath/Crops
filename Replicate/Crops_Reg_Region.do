////////////////////////////////////////////////////////////////////////////
// Robustness checks - By Region
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

//////////////////////////////////////
// Regressions for main regions
//////////////////////////////////////	
gen sub = .
replace sub = 1 if jv_subregion==1 // NW Europe

qui summ jv_subregion
local max = r(max)
forvalues x = 2(1)`max' { // for all the subregions
	replace sub = . if sub==0
	replace sub = 0 if jv_subregion==`x' // for next zone
	if `x'==10 { // for North Africa - a one-off change b/c of small number of districts
		local dist 300 // set to this cutoff
	}
	doreg `csivar' `rurdvar' `controls', fe(`fe') dist(`dist') comp(sub) tag(reg`x')
	local dist 500 // reset distance
}

// China, Japan, Korea
replace sub = . if sub==0
replace sub = 0 if inlist(jv_china,1,2) // all of China	
doreg `csivar' `rurdvar' `controls', fe(`fe') dist(`dist') comp(sub) tag(chall)

replace sub = . if sub==0
replace sub = 0 if inlist(jv_china,1) // north China	
doreg `csivar' `rurdvar' `controls', fe(`fe') dist(`dist') comp(sub) tag(chn)

replace sub = . if sub==0
replace sub = 0 if inlist(jv_china,2) // south China	
doreg `csivar' `rurdvar' `controls', fe(`fe') dist(`dist') comp(sub) tag(chs)

replace sub = . if sub==0
replace sub = 0 if name_0=="Japan" // Japan	
doreg `csivar' `rurdvar' `controls', fe(`fe') dist(`dist') comp(sub) tag(jap)

replace sub = . if sub==0
replace sub = 0 if name_0=="North Korea" | name_0=="South Korea" // Korea	
doreg `csivar' `rurdvar' `controls', fe(`fe') dist(`dist') comp(sub) tag(kor)
	
// Output table
estout reg21 reg22 reg32 reg42 reg52 using "./Drafts/tab_beta_subregionA_base.tex", /// write the region results to Tex file
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) ///
	stats(p_zero p_diff N_country N_obs r2, fmt(%9.3f %9.3f %9.0g %9.0g %9.2f) labels("p-value $\beta=0$" "p-value $\beta=\beta_{NWEur}$" "Countries" "Observations" "R-square (ex. FE)")) ///
	keep(res_rurd) label mlabels(none) collabels(none) prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)

estout reg62 reg72 reg82 reg92 reg102 using "./Drafts/tab_beta_subregionB_base.tex", /// write the region results to Tex file
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) ///
	stats(p_zero p_diff N_country N_obs r2, fmt(%9.3f %9.3f %9.0g %9.0g %9.2f) labels("p-value $\beta=0$" "p-value $\beta=\beta_{NWEur}$" "Countries" "Observations" "R-square (ex. FE)")) ///
	keep(res_rurd) label mlabels(none) collabels(none) prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)

estout chall2 chn2 chs2 jap2 kor2 using "./Drafts/tab_beta_subregionC_base.tex", /// write the region results to Tex file
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) ///
	stats(p_zero p_diff N_country N_obs r2, fmt(%9.3f %9.3f %9.0g %9.0g %9.2f) labels("p-value $\beta=0$" "p-value $\beta=\beta_{NWEur}$" "Countries" "Observations" "R-square (ex. FE)")) ///
	keep(res_rurd) label mlabels(none) collabels(none) prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)
	
coefplot reg21 || reg22 || reg32 || reg42 || reg52 || reg62 || reg72 || reg82 || reg92 || reg102 || chall2 || chn2 || chs2 || jap2 || kor2, ///
	keep(res_rurd) bycoefs graphregion(color(white)) xtitle("{&beta} estimate") xlabel(,format(%9.1f)) ///
	mlabel format(%9.3f) mlabposition(12) ///
	bylabels("Northwest Europe" "East Europe" "South Europe" "South and Southeast Asia" "Central and West Asia" "Temperate Americas" "Tropical Americas" "Tropical Africa" "Southern Africa" "North Africa" "All China" "Temperate China" "Tropical China" "Japan" "N. and S. Korea")
graph export "./Drafts/fig_coef_subregion_base.png", replace as(png)
graph export "./Drafts/fig_coef_subregion_base.eps", replace as(eps)
