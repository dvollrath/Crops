//////////////////////////////////////
// Baseline results - Table 3 in paper
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

//////////////////////////////////////
// Regressions - temperate and tropical
//////////////////////////////////////	

// Create dummy to distinguish temperate from tropical on crops
capture drop temp
gen temp = .
replace temp = 1 if dry_suit==1 & wet_suit==0 // suitable for temp crops, not for trop
replace temp = 0 if dry_suit==0 & wet_suit==1 // suitable for trop crops, not for temp

hdreg `csivar' `rurdvar', fe(`fe') controls(`controls') dist(`dist') comp(temp) tag(base) // call program to do spatial OLS

// Create dummy to distinguish temperate from tropical on frost-free days
replace temp = .
replace temp = 1 if agro_lt3<365 // any average frost days
replace temp = 0 if agro_lt3==365 // no average frost days

hdreg `csivar' `rurdvar', fe(`fe') controls(`controls') dist(`dist') comp(temp) tag(harv) // call program to do spatial OLS

// Create dummy to distinguish temperate from tropical on Koeppen-Geiger zones
replace temp = .
replace temp = 1 if (kg_C+kg_D>0) & (kg_zzb+kg_zzc>0) // KG warm temperate, snow and cool/warm summers
replace temp = 0 if (kg_A>0) // KG equatorial zone

//doreg `csivar' `rurdvar' `controls', fe(`fe') dist(`dist') comp(temp) tag(kg) // call program to do spatial OLS
hdreg `csivar' `rurdvar', fe(`fe') controls(`controls') dist(`dist') comp(temp) tag(kg) // call program to do spatial OLS

// Output tables and coefficient plot
estout base1 base2 harv1 harv2 kg1 kg2 using "./Drafts/tab_beta_crop_base.tex", /// write the region results to Tex file
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) ///
	stats(p_zero p_diff N_country N_obs r2, fmt(%9.3f %9.3f %9.0g %9.0g %9.2f) labels("p-value $\beta_g=0$" "p-value $\beta_g=\beta_{Temp}$" "Countries" "Observations" "R-square (ex. FE)")) ///
	keep(res_rurd) label mlabels(none) collabels(none) prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)
	
coefplot base1 || base2 || harv1 || harv2 || kg1 || kg2, ///
	keep(res_rurd) bycoefs graphregion(color(white)) xtitle("{&beta} estimate") xlabel(0(.05).35,format(%9.2f)) ///
	mlabel format(%9.3f) mlabposition(12) ///
	headings(1 = "{bf:By GAEZ suitability}" 3 = "{bf:By frost-free days}" 5 = "{bf:By Koeppen-Geiger}") ///
	bylabels("Temperate" "Tropical" "Temperate" "Tropical" "Temperate" "Tropical")
graph export "./Drafts/fig_coef_crop_base.png", replace as(png)
graph export "./Drafts/fig_coef_crop_base.eps", replace as(eps)

// Produce figure showing residual plots
qui estimates restore base1
local tempbeta = round(_b[res_rurd],0.01)
qui estimates restore base2
local tropbeta = round(_b[res_rurd],0.01)

binscatter ln_csi_yield ln_grump_rurd, ///
	nquantiles(50) by(temp) mcolors(black gray) msymbol(oh dh) lcolors(black gray) ///
	xtitle("(Log) labor/land ratio") ytitle("(Log) caloric yield")  ylabel(,nogrid angle(0) format(%9.1f)) ///
	absorb(state_id) controls(`controls') noaddmean ///
	legend(pos(3) ring(0) cols(1) label(1 "Tropical {&beta}{sub:g} = 0`tropbeta'") label(2 "Temperate {&beta}{sub:g} = 0`tempbeta'") region(lwidth(none))) ///
	savegraph("./Drafts/fig_beta_crop.eps") replace reportreg
	
//////////////////////////////////////
// Regressions - baseline but changing samples
//////////////////////////////////////

// Create dummy to distinguish temperate from tropical on crops
replace temp = .
replace temp = 1 if dry_suit==1 & wet_suit==0 // suitable for temp crops, not for trop
replace temp = 0 if dry_suit==0 & wet_suit==1 // suitable for trop crops, not for temp

// For only with under certain urban total
hdreg `csivar' `rurdvar' if grump_urbc<50000, fe(`fe') controls(`controls') dist(`dist') comp(temp) tag(urbc) // call program to do spatial OLS

// For only with under certain urban total
hdreg `csivar' `rurdvar' if p_state_popc_2000<.05, fe(`fe') controls(`controls') dist(`dist') comp(temp) tag(perc) // call program to do spatial OLS

// For only in "poor" regions
hdreg `csivar' `rurdvar' if inlist(jv_subregion,4,7,8,9), fe(`fe') controls(`controls') dist(`dist') comp(temp) tag(poor) // call program to do spatial OLS

// Output table and coefficient plot
estout urbc1 urbc2 perc1 perc2 poor1 poor2 using "./Drafts/tab_beta_crop_sub_base.tex", /// write the region results to Tex file
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) ///
	stats(p_zero p_diff N_country N_obs r2, fmt(%9.3f %9.3f %9.0g %9.0g %9.2f) labels("p-value $\beta_g=0$" "p-value $\beta_g=\beta_{Temp}$" "Countries" "Observations" "R-square (ex. FE)")) ///
	keep(res_rurd) label mlabels(none) collabels(none) prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)
	
coefplot urbc1 || urbc2 || perc1 || perc2 || poor1 || poor2, ///
	keep(res_rurd) bycoefs graphregion(color(white)) xtitle("{&beta} estimate") xlabel(0(.05).40,format(%9.2f)) ///
	mlabel format(%9.3f) mlabposition(12) ///
	headings(1 = "{bf:<50K urban pop}" 3 = "{bf:<5% state pop}" 5 = "{bf:Excl. rich countries}") ///
	bylabels("Temperate" "Tropical" "Temperate" "Tropical" "Temperate" "Tropical")
graph export "./Drafts/fig_coef_crop_sub_base.png", replace as(png)
graph export "./Drafts/fig_coef_crop_sub_base.eps", replace as(eps)

