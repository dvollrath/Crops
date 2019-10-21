////////////////////////////////////////////////////////////////////////////
// Robustness checks - By KG Climate Zones
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
local rurdvar ln_grump_rurd // rural density per unit of total land
local controls grump_urb_perc ln_light_mean ln_grump_popc /// main controls
	ln_road_total_dens perc_road_tp1 perc_road_tp2 perc_road_tp3 ///
	ln_agro_slpidx dist_bigcity // distance controls
local dist 500 // km cutoff for Conley SE

gen kgcompare = 0.66*kgtotal // set comparison level of total land area

//////////////////////////////////////
// Regressions KG climates
//////////////////////////////////////	

gen zone = .

replace zone = 1 if kg_A>kgcompare // Equatorial zone
replace zone = 0 if kg_B>kgcompare // Arid zone

hdreg `csivar' `rurdvar', fe(`fe') controls(`controls') dist(`dist') comp(zone) tag(kgB) // call program to do spatial OLS

replace zone = . if zone==0
replace zone = 0 if kg_C>kgcompare // Warm temperate zone
hdreg `csivar' `rurdvar', fe(`fe') controls(`controls') dist(`dist') comp(zone) tag(kgC) // call program to do spatial OLS

replace zone = . if zone==0
replace zone = 0 if kg_D>kgcompare // Snow zone
hdreg `csivar' `rurdvar', fe(`fe') controls(`controls') dist(`dist') comp(zone) tag(kgD) // call program to do spatial OLS

// Output table
estout kgB1 kgB2 kgC2 kgD2 using "./Drafts/tab_beta_kg_climate_base.tex", /// write the region results to Tex file
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) ///
	stats(p_zero p_diff N_country N_obs r2, fmt(%9.3f %9.3f %9.0g %9.0g %9.2f) labels("p-value $\beta=0$" "p-value $\beta=\beta_{Equa}$" "Countries" "Observations" "R-square (ex. FE)")) ///
	keep(res_rurd) label mlabels(none) collabels(none) prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)

//////////////////////////////////////
// Regressions KG precipitation
//////////////////////////////////////	

replace zone = .
replace zone = 1 if kg_zfz>kgcompare // Fully humid zone
replace zone = 0 if kg_zsz>kgcompare // Dry summer zone

hdreg `csivar' `rurdvar', fe(`fe') controls(`controls') dist(`dist') comp(zone) tag(kgs) // call program to do spatial OLS

replace zone = . if zone==0
replace zone = 0 if kg_zwz>kgcompare // Dry winter zone
hdreg `csivar' `rurdvar', fe(`fe') controls(`controls') dist(`dist') comp(zone) tag(kgw) // call program to do spatial OLS

replace zone = . if zone==0
replace zone = 0 if kg_zmz>kgcompare // Monsoon zone
hdreg `csivar' `rurdvar', fe(`fe') controls(`controls') dist(`dist') comp(zone) tag(kgm) // call program to do spatial OLS

replace zone = . if zone==0
replace zone = 0 if kg_zdz>kgcompare // Desert zone
hdreg `csivar' `rurdvar', fe(`fe') controls(`controls') dist(`dist') comp(zone) tag(kgd) // call program to do spatial OLS

replace zone = . if zone==0
replace zone = 0 if kg_zpz>kgcompare // Steppe zone
hdreg `csivar' `rurdvar', fe(`fe') controls(`controls') dist(`dist') comp(zone) tag(kgp) // call program to do spatial OLS

// Output table
estout kgs1 kgs2 kgw2 kgm2 kgd2 kgp2 using "./Drafts/tab_beta_kg_precip_base.tex", /// write the region results to Tex file
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) ///
	stats(p_zero p_diff N_country N_obs r2, fmt(%9.3f %9.3f %9.0g %9.0g %9.2f) labels("p-value $\beta=0$" "p-value $\beta=\beta_{Humid}$" "Countries" "Observations" "R-square (ex. FE)")) ///
	keep(res_rurd) label mlabels(none) collabels(none) prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)

//////////////////////////////////////
// Regressions KG temperature
//////////////////////////////////////	

replace zone = .
replace zone = 1 if kg_zza>kgcompare // Hot summer
replace zone = 0 if kg_zzb>kgcompare // Warm summer

hdreg `csivar' `rurdvar', fe(`fe') controls(`controls') dist(`dist') comp(zone) tag(kgb) // call program to do spatial OLS

replace zone = . if zone==0
replace zone = 0 if kg_zzc>kgcompare // Cool summer
hdreg `csivar' `rurdvar', fe(`fe') controls(`controls') dist(`dist') comp(zone) tag(kgc) // call program to do spatial OLS

replace zone = . if zone==0
replace zone = 0 if kg_zzh>kgcompare // Hot arid
hdreg `csivar' `rurdvar', fe(`fe') controls(`controls') dist(`dist') comp(zone) tag(kgh) // call program to do spatial OLS

replace zone = . if zone==0
replace zone = 0 if kg_zzk>kgcompare // Cold arid
hdreg `csivar' `rurdvar', fe(`fe') controls(`controls') dist(`dist') comp(zone) tag(kgk) // call program to do spatial OLS

// Output table
estout kgb1 kgb2 kgc2 kgh2 kgk2 using "./Drafts/tab_beta_kg_temp_base.tex", /// write the region results to Tex file
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) ///
	stats(p_zero p_diff N_country N_obs r2, fmt(%9.3f %9.3f %9.0g %9.0g %9.2f) labels("p-value $\beta=0$" "p-value $\beta=\beta_{Humid}$" "Countries" "Observations" "R-square (ex. FE)")) ///
	keep(res_rurd) label mlabels(none) collabels(none) prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)

coefplot kgB1 || kgB2 || kgC2 || kgD2 || kgs1 || kgs2 || kgw2 || kgm2 || kgd2 || kgp2 || kgb1 || kgb2 || kgc2 || kgh2 || kgk2, ///
	keep(res_rurd) bycoefs graphregion(color(white)) xtitle("{&beta} estimate") xlabel(,format(%9.1f)) ///
	mlabel format(%9.3f) mlabposition(12) ///
	bylabels("Equatorial" "Arid" "Warm Temperate" "Snow" "Fully Humid" "Dry Summer" "Dry Winter" "Monsoonal" "Desert" "Steppe" "Hot Summer" "Warm Summer" "Cool Summer" "Hot Arid" "Cold Arid") ///
	headings(1 = "{bf: Climate}" 5 = "{bf: Precipitation}" 11 = "{bf: Temperature}")
graph export "./Drafts/fig_coef_kg_base.png", replace as(png)
graph export "./Drafts/fig_coef_kg_base.eps", replace as(eps)
	
