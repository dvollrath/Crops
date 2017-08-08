//////////////////////////////////////////////////////////////////////
// Date: 2016-11-08
// Author: Dietz Vollrath
// 
// Merge the various CSV files of IPUMS data together
// 1. All files comes in at the GEOLEV2 (district) level
// 2. Pull in each CSV file, remove dupes, remove missing GEOLEV2
// 3. Merge all files together
//
//////////////////////////////////////////////////////////////////////

// SET THESE TO POINT TO YOUR WORK AND DATA FOLDERS
global data "/users/dietz/dropbox/project/crops/work"
global text "/users/dietz/dropbox/project/crops/drafts"

//////////////////////////////////////////////////////////////////////
// There should be no reason to edit below this point
//////////////////////////////////////////////////////////////////////

graph set eps fontface Times

//////////////////////////////////////
// Prep GIS datasets
//////////////////////////////////////
insheet using "$data/all_csi_data_ipums.csv", clear names
drop if geolevel2==. // get rid of non-district data
drop if geolevel2==888888888 // also non-district data
drop zone x1 x // useless fields
save "$data/all_csi_data_ipums.dta", replace

insheet using "$data/all_earthstat_data_ipums.csv", clear names
drop if geolevel2==. // get rid of non-district data
drop if geolevel2==888888888 // also non-district data
drop zone x1 x // useless fields
save "$data/all_earthstat_data_ipums.dta", replace

insheet using "$data/all_dmsp_light_data_ipums.csv", clear names
drop if geolevel2==. // get rid of non-district data
drop if geolevel2==888888888 // also non-district data
drop zone x1 x // useless fields
save "$data/all_dmsp_light_data_ipums.dta", replace

insheet using "$data/all_gaez_suit_data_ipums.csv", clear names
drop if geolevel2==. // get rid of non-district data
drop if geolevel2==888888888 // also non-district data
drop zone x1 x // useless fields
save "$data/all_gaez_suit_data_ipums.dta", replace

//////////////////////////////////////
// Open IPUMS data, clean, and merge
//////////////////////////////////////
use "$data/ipumsgeo.dta", clear
drop if geolev2==. // this is holding a roll-up of national level data, drop
drop if geolev2==888888888 // also non-district data
rename geolev2 geolevel2 // to match GIS files
save "$data/all_crops_data_ipums.dta", replace

merge 1:1 geolevel2 using "$data/all_csi_data_ipums.dta"
drop _merge
merge 1:1 geolevel2 using "$data/all_earthstat_data_ipums.dta"
drop _merge
merge 1:1 geolevel2 using "$data/all_dmsp_light_data_ipums.dta"
drop _merge
merge 1:1 geolevel2 using "$data/all_gaez_suit_data_ipums.dta"
drop _merge

//////////////////////////////////////
// Create state ID's from GEOLEV2
//////////////////////////////////////
// GEOLEVEL2 is CCCSSSDDD - country, state, district
gen state_id = int(geolevel2/1000)

//////////////////////////////////////
// Population Data Prep
//////////////////////////////////////
// perwt is total person weights from IPUMS, so is equiv to "population" size
// all other counts are totals of perwts for categories, so equiv to count of that category

qui gen urb_perc = purbanany/perwt // urbanization rate
label variable urb_perc "Urbanization rate"
qui gen ln_prural = ln(prural/area_ha) // rural density
label variable ln_prural "Log rural density"
qui gen ln_pag = ln(pag/area_ha) // ag worker density
label variable ln_pag "Log ag. worker density"
qui gen ln_pagany = ln(pagany/area_ha) // any ag person density
label variable ln_pagany "Log ag. pop density"

//////////////////////////////////////
// Create CSI productivity variable
//////////////////////////////////////
gen ln_csi_cals = ln(cals) // log total calories, using max crop in each cell
label variable ln_csi_cals "Log max cal"
gen ln_csi_meanyld = ln(meanyld) // log mean yield, using max crop in each cell
label variable ln_csi_meanyld "Log mean yield of calories"
gen ln_area = ln(area_ha) // log of zone area
gen ln_csi_yield = ln_csi_cals - ln_area // log yield per area
label variable ln_csi_yield "Log caloric yield"

//////////////////////////////////////
// Create and adjust night lights data
//////////////////////////////////////
gen light_mean_adj = light_mean
summ light_mean_adj if light_mean_adj>0 // find minimum level of average lights
replace light_mean_adj = r(min) if light_mean_adj==0 // as per Henderson et al, replace zeros with minimum positive value
gen ln_light_mean = ln(light_mean_adj)
label variable ln_light_mean "Log light density"

//////////////////////////////////////
// Create crop groups
//////////////////////////////////////
gen dry_suit = 0
replace dry_suit = 1 if suit_brl>0 | suit_bck>0 | suit_rye>0 | suit_oat>0 | suit_wpo>0 | suit_whe>0
gen wet_suit = 0
replace wet_suit = 1 if suit_csv>0 | suit_cow>0 | suit_pml>0 | suit_spo | suit_rcw>0 | suit_yam>0

gen dry_max = 0
replace dry_max = 1 if (barley_cells + buckwheat_cells + oat_cells + rye_cells + whitepotato_cells + wheat_cells)>0
gen wet_max = 0
replace wet_max = 1 if (cassava_cells + cowpea_cells + pearlmillet_cells + sweetpotato_cells + wetrice_cells + yams_cells)>0

egen harvarea_sum = rowtotal(*_harvarea)
gen dry_area = 0
replace dry_area = 1 if (barley_harvarea + buckwheat_harvarea + oats_harvarea + rye_harvarea + potato_harvarea + wheat_harvarea)>.5*harvarea_sum
gen wet_area = 0
replace wet_area = 1 if (cassava_harvarea + cowpea_harvarea + millet_harvarea + sweetpotato_harvarea + rice_harvarea + yam_harvarea)>.5*harvarea_sum

//////////////////////////////////////
// Create crop production totals
//////////////////////////////////////
egen prod_sum = rowtotal(*_production) // get total tonnes of all crops produced

drop if ln_csi_yield==.
drop if ln_pag==.


save "$data/all_crops_data_ipums.dta", replace

//////////////////////////////////////
// Perform IPUMS regressions
//////////////////////////////////////
	capture drop dummy
	gen dummy = .
	replace dummy = 1 if dry_suit==1 & wet_suit==0
	replace dummy = 0 if dry_suit==0 & wet_suit==1
	// Wheat family suitable
	qui reg ln_csi_yield ln_pag ln_light_mean urb_perc if dummy==1, absorb(cntry_code) cluster(cntry_code)
	estadd scalar p_zero = 2*(1-t(e(df_r),abs(_b[ln_pag]/_se[ln_pag])))
	qui tabulate cntry_code if e(sample)==1
	qui estadd scalar N_country = r(r)
	qui count if e(sample)==1
	qui estadd scalar N_obs = r(N)
	estimates store reg_crop_1

	// Rice family suitable
	reg ln_csi_yield c.ln_pag##i.dummy c.ln_light_mean#i.dummy c.urb_perc#i.dummy, absorb(cntry_code) cluster(cntry_code)
	estadd scalar p_zero = 2*(1-t(e(df_r),abs(_b[ln_pag]/_se[ln_pag])))
	estadd scalar p_diff = 2*(1-t(e(df_r),abs(_b[1.dummy#c.ln_pag])/_se[1.dummy#c.ln_pag]))
	qui tabulate cntry_code if e(sample)==1 & dummy==0
	qui estadd scalar N_country = r(r)
	qui count if e(sample)==1 & dummy==0
	qui estadd scalar N_obs = r(N)
	estimates store reg_crop_2

	capture drop dummy
	gen dummy = .
	replace dummy = 1 if dry_max==1 & wet_max==0
	replace dummy = 0 if dry_max==0 & wet_max==1	
	// Wheat family suitable
	qui reg ln_csi_yield ln_pag ln_light_mean urb_perc if dummy==1, absorb(cntry_code) cluster(cntry_code)
	estadd scalar p_zero = 2*(1-t(e(df_r),abs(_b[ln_pag]/_se[ln_pag])))
	qui tabulate cntry_code if e(sample)==1
	qui estadd scalar N_country = r(r)
	qui count if e(sample)==1
	qui estadd scalar N_obs = r(N)	
	estimates store reg_crop_3

	// Rice family suitable
	reg ln_csi_yield c.ln_pag##i.dummy c.ln_light_mean#i.dummy c.urb_perc#i.dummy, absorb(cntry_code) cluster(cntry_code)
	estadd scalar p_zero = 2*(1-t(e(df_r),abs(_b[ln_pag]/_se[ln_pag])))
	estadd scalar p_diff = 2*(1-t(e(df_r),abs(_b[1.dummy#c.ln_pag])/_se[1.dummy#c.ln_pag]))
	qui tabulate cntry_code if e(sample)==1 & dummy==0
	qui estadd scalar N_country = r(r)
	qui count if e(sample)==1 & dummy==0
	qui estadd scalar N_obs = r(N)
	estimates store reg_crop_4

	capture drop dummy
	gen dummy = .
	replace dummy = 1 if dry_area==1 & wet_area==0
	replace dummy = 0 if dry_area==0 & wet_area==1	
	// Wheat family suitable
	qui reg ln_csi_yield ln_pag ln_light_mean urb_perc if dummy==1, absorb(cntry_code) cluster(cntry_code)
	estadd scalar p_zero = 2*(1-t(e(df_r),abs(_b[ln_pag]/_se[ln_pag])))
	qui tabulate cntry_code if e(sample)==1
	qui estadd scalar N_country = r(r)
	qui count if e(sample)==1
	qui estadd scalar N_obs = r(N)	
	estimates store reg_crop_5

	// Rice family suitable
	reg ln_csi_yield c.ln_pag##i.dummy c.ln_light_mean#i.dummy c.urb_perc#i.dummy, absorb(cntry_code) cluster(cntry_code)
	estadd scalar p_zero = 2*(1-t(e(df_r),abs(_b[ln_pag]/_se[ln_pag])))
	estadd scalar p_diff = 2*(1-t(e(df_r),abs(_b[1.dummy#c.ln_pag])/_se[1.dummy#c.ln_pag]))
	qui tabulate cntry_code if e(sample)==1 & dummy==0
	qui estadd scalar N_country = r(r)
	qui count if e(sample)==1 & dummy==0
	qui estadd scalar N_obs = r(N)
	estimates store reg_crop_6
		
// Write wheat/rice panel data	
estout reg_crop_* using "$output/tab_beta_crop_ipums.tex", /// write the region results to Tex file
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) ///
	stats(p_zero p_diff N_country N_obs r2_a, fmt(%9.3f %9.3f %9.0g %9.0g %9.2f) labels("p-value $\beta=0$" "p-value $\beta=\beta^{Wheat}$" "Countries" "Observations" "Adjusted R-square")) ///
	keep(ln_pag) label mlabels(none) collabels(none) prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)

//////////////////////////////////////
// Write Country (Year) names
//////////////////////////////////////
preserve
	collapse (first) cntry_name year, by(cntry_code)
	capture file close f_result
	file open f_result using "$output/tab_ipums_countries.tex", write replace

	count
	local max = r(N)
	forvalues x = 1(1)`max' {
		if `x'==1 {
			file write f_result (cntry_name[`x']) " (" (year[`x']) ")"
		}
		else {
			file write f_result ", " (cntry_name[`x']) " (" (year[`x']) ")"
		}
	}
	capture file close f_result
restore
