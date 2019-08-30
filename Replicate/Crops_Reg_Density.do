//////////////////////////////////////
// Result after grouping provinces by density
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
local rurdvar ln_grump_rurd //ln_rurd_2000 // rural density per unit of total land
local controls grump_urb_perc ln_light_mean ln_grump_popc // urban percent and light mean and total population
local dist 500 // km cutoff for Conley SE

//////////////////////////////////////
// Regressions - temperate and tropical
//////////////////////////////////////	

// Create dummy to distinguish temperate from tropical on crops

gen beta = .
gen se = .
gen n = 1

levelsof state_id, local(levels) // get identifiers for provinces
foreach x of local levels { // for each province
	di "Processing province id " (`x')
	count if state_id == `x'
	if r(N) >= 10 {
		qui reg ln_csi_yield ln_grump_rurd `controls' if state_id==`x'
		qui replace beta = _b[ln_grump_rurd] if state_id==`x'
		qui replace se = _se[ln_grump_rurd] if state_id==`x'
	}
}

collapse (first) iso id_0 id_1 name_0 name_1 beta se jv_region jv_subregion jv_subregion_text ///
	(rawsum) grump_rur grump_urbc shape_ha n (mean) suit_??? ///
	, by(state_id)
drop if beta==.

gen dry_suit = 0
replace dry_suit = 1 if suit_brl>0 & suit_bck>0 & suit_rye>0 & suit_oat>0 & suit_wpo>0 & suit_whe>0
gen wet_suit = 0
replace wet_suit = 1 if suit_csv>0 & suit_cow>0 & suit_pml>0 & suit_spo & suit_rcw>0 & suit_yam>0

capture drop temp
gen temp = .
replace temp = 1 if dry_suit==1 & wet_suit==0 // suitable for temp crops, not for trop
replace temp = 0 if dry_suit==0 & wet_suit==1 // suitable for trop crops, not for temp

gen rurd_2000 = grump_rur/shape_ha
gen ln_rurd_2000 = ln(rurd_2000)

drop if beta>1.5
twoway (scatter beta ln_rurd_2000, mcolor(gray)) (lfit beta ln_rurd_2000, clcolor(black)) ///
	, legend(off) ytitle("Estimated {&beta} for province") xtitle("(Log) rural density for province") ///
	ylabel(, nogrid)
graph export "./Drafts/fig_beta_province.png", replace as(png)
graph export "./Drafts/fig_beta_province.eps", replace as(eps)	
/*

xtile state_rurd_xtile = state_rurd_2000, nquantiles(5)

forvalues i = 1(1)5 {
	doreg `csivar' `rurdvar' `controls' if state_rurd_xtile==`i', fe(`fe') dist(`dist') comp(temp) tag(dens`i') // call program to do spatial OLS
}

//coefplot base11 || base12 || base21 || base22 || base31 || base32 || base41 || base42 ///
//	, keep(res_rurd) bycoefs graphregion(color(white)) xtitle("{&beta} estimate")

estout dens11 dens12 dens21 dens22 dens31 dens32 dens41 dens42 dens51 dens52 using "./Drafts/tab_beta_crop_density.tex", /// write the region results to Tex file
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) ///
	stats(p_zero p_diff N_country N_obs r2, fmt(%9.3f %9.3f %9.0g %9.0g %9.2f) labels("p-value $\beta_g=0$" "p-value $\beta_g=\beta_{Temp}$" "Countries" "Observations" "R-square (ex. FE)")) ///
	keep(res_rurd) label mlabels(none) collabels(none) prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)
