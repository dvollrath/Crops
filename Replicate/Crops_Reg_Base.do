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
local controls urb_perc_2000 ln_light_mean // urban percent and light mean
local dist 500 // km cutoff for Conley SE

//////////////////////////////////////
// Regressions - temperate and tropical
//////////////////////////////////////	

// Create dummy to distinguish temperate from tropical on crops
capture drop temp
gen temp = .
replace temp = 1 if dry_suit==1 & wet_suit==0 // suitable for temp crops, not for trop
replace temp = 0 if dry_suit==0 & wet_suit==1 // suitable for trop crops, not for temp

doreg `csivar' `rurdvar' `controls', fe(`fe') dist(`dist') comp(temp) tag(base) // call program to do spatial OLS

// Create dummy to distinguish temperate from tropical on frost-free days
replace temp = .
replace temp = 1 if agro_lt3<365 // any average frost days
replace temp = 0 if agro_lt3==365 // no average frost days

doreg `csivar' `rurdvar' `controls', fe(`fe') dist(`dist') comp(temp) tag(harv) // call program to do spatial OLS

// Create dummy to distinguish temperate from tropical on Koeppen-Geiger zones
replace temp = .
replace temp = 1 if (kg_C+kg_D>0) & (kg_zzb+kg_zzc>0) // KG warm temperate, snow and cool/warm summers
replace temp = 0 if (kg_A>0) // KG equatorial zone

doreg `csivar' `rurdvar' `controls', fe(`fe') dist(`dist') comp(temp) tag(kg) // call program to do spatial OLS

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


//////////////////////////////////////
// Regressions - baseline but changing samples
//////////////////////////////////////

// Create dummy to distinguish temperate from tropical on crops
replace temp = .
replace temp = 1 if dry_suit==1 & wet_suit==0 // suitable for temp crops, not for trop
replace temp = 0 if dry_suit==0 & wet_suit==1 // suitable for trop crops, not for temp

// For only with under certain urban total
doreg `csivar' `rurdvar' `controls' if urbc_2000<25000, fe(`fe') dist(`dist') comp(temp) tag(urbc) // call program to do spatial OLS

// For only in "poor" regions
doreg `csivar' `rurdvar' `controls' if inlist(jv_subregion,4,7,8,9), fe(`fe') dist(`dist') comp(temp) tag(poor) // call program to do spatial OLS

qui summ prod_sum, det // use raw tonnage of production
local prodcut = r(p25) // cut off above 25th percentile

// For only those above 25th percentile in raw production
doreg `csivar' `rurdvar' `controls' if prod_sum>`prodcut', fe(`fe') dist(`dist') comp(temp) tag(prod) // call program to do spatial OLS
	
// Output table and coefficient plot
estout urbc1 urbc2 poor1 poor2 prod1 prod2 using "./Drafts/tab_beta_crop_sub_base.tex", /// write the region results to Tex file
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) ///
	stats(p_zero p_diff N_country N_obs r2, fmt(%9.3f %9.3f %9.0g %9.0g %9.2f) labels("p-value $\beta_g=0$" "p-value $\beta_g=\beta_{Temp}$" "Countries" "Observations" "R-square (ex. FE)")) ///
	keep(res_rurd) label mlabels(none) collabels(none) prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)
	
coefplot urbc1 || urbc2 || poor1 || poor2 || prod1 || prod2, ///
	keep(res_rurd) bycoefs graphregion(color(white)) xtitle("{&beta} estimate") xlabel(0(.05).35,format(%9.2f)) ///
	mlabel format(%9.3f) mlabposition(12) ///
	headings(1 = "{bf:<25K urban pop}" 3 = "{bf:Excl. rich countries}" 5 = "{bf:Excl. low production}") ///
	bylabels("Temperate" "Tropical" "Temperate" "Tropical" "Temperate" "Tropical")
graph export "./Drafts/fig_coef_crop_sub_base.png", replace as(png)
graph export "./Drafts/fig_coef_crop_sub_base.eps", replace as(eps)

