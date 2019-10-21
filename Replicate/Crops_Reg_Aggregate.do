//////////////////////////////////////
// Aggregate beta values
//////////////////////////////////////

//////////////////////////////////////
// Load data and estimate baseline elasticities
//////////////////////////////////////
clear
estimates clear
use "./Work/all_crops_data_gadm2.dta" // 

local beta_temp = .285
local beta_trop = .126
local beta_mixed = .167

//////////////////////////////////////
// By pixel
//////////////////////////////////////
insheet using "./Work/gadm_pixel_crop_cal.csv", clear comma names // from R, pixel data
   // See Crops_Map_Country_Beta.r for processing that yields this file
rename gadm_raster_adm0_category iso // rename to useful names
rename layer maxcals
rename map_crop_type crop_type

drop if iso=="NA" // drop empty cells (ocean, etc.)
drop if maxcals=="NA"
drop if crop_type=="NA"

destring maxcals, replace // destring to numeric
destring crop_type, replace

drop if crop_type==0 // eliminate unsuitable cells

bysort iso: egen iso_maxcals = sum(maxcals) // sum calories by country (iso)
gen beta = 0 // generate a beta variable to hold value for each pixel
replace beta = `beta_temp' if crop_type==1 // assign beta values to pixel
replace beta = `beta_trop' if crop_type==2
replace beta = `beta_mixed' if crop_type==3
gen wtd_maxcals = beta*maxcals/iso_maxcals // generate weighted beta value for each pixel

collapse (rawsum) wtd_maxcals , by(iso) // collapse pixels to country (iso) level
rename wtd_maxcals beta_pixel // this is pixel-level beta aggregation
save "./Work/gadm_pixel_crop_beta.dta", replace

insheet using "./Work/gadm36_0_data.csv", clear names
rename gid_0 iso
save "./Work/gadm36_0_data.dta", replace
merge 1:1 iso using "./Work/gadm_pixel_crop_beta.dta"
drop if beta_pixel==.
sort name_0
gen name_short = substr(name_0,1,15)

capture file close f_result
file open f_result using "./Drafts/tab_aggregate_pixel_beta.tex", write replace
local countries = _N

forvalues i = 1(1)54 {
	file write f_result (name_short[`i']) " & " %9.3f (beta_pixel[`i']) " & " ///
		(name_short[`i'+54]) " & " %9.3f (beta_pixel[`i'+54]) " & " ///
		(name_short[`i'+108]) " & " %9.3f (beta_pixel[`i'+108]) " & " ///
		(name_short[`i'+162]) " & " %9.3f (beta_pixel[`i'+162]) " \\" _n
}
capture file close f_result

//////////////////////////////////////
// By district
//////////////////////////////////////
// Set values of three zones elasticity
use "./Work/all_crops_predrop_gadm2.dta", clear // load up ALL districts, even those dropped for estimation
gen dry_suit = 0
replace dry_suit = 1 if suit_brl>0 | suit_bck>0 | suit_rye>0 | suit_oat>0 | suit_wpo>0 | suit_whe>0
gen wet_suit = 0
replace wet_suit = 1 if suit_csv>0 | suit_cow>0 | suit_pml>0 | suit_spo | suit_rcw>0 | suit_yam>0

capture drop temp // drop and generate the temp variable to identify crop type
gen temp = .
replace temp = 1 if dry_suit==1 & wet_suit==0 // suitable for temp crops, not for trop
replace temp = 0 if dry_suit==0 & wet_suit==1 // suitable for trop crops, not for temp
replace temp = 2 if dry_suit==1 & wet_suit==1 // suitable for BOTH types of crops
replace temp = 4 if dry_suit==0 & wet_suit==0 // suitable for NEITHER type of crop
replace temp = 4 if temp==. // catching any other leftover category

gen district_beta = .  // create a district-level beta value
replace district_beta = `beta_trop' if temp==0
replace district_beta = `beta_temp' if temp==1
replace district_beta = `beta_mixed' if temp==2

bysort name_0: egen country_cals = sum(cals) // get country level calories
gen district_cals_perc = cals/country_cals // get district calorie weight
gen wtd_district_beta = district_cals_perc*district_beta // calorie weighted beta for district

//export delimited id_0 id_1 id_2 iso name_0 name_1 objectid district_beta temp using "./Work/district-beta-map.csv", ///
//	delimiter(",") nolabel replace
	
collapse (first) iso id_0 (rawsum) wtd_district_beta , by(name_0) // collapse to country level

merge 1:1 iso using "./Work/gadm_pixel_crop_beta.dta" // merge in the pixel-level beta for comparison

drop if wtd_district_beta==0
rename iso shortnam // for matching with mortality data later
save "./Work/district-beta-map.dta", replace

replace name_0 = "Bosnia" if name_0=="Bosnia and Herzegovina"
replace name_0 = "D.R. Congo" if name_0=="Democratic Republic of the Congo"
replace name_0 = "C. African Rep." if name_0=="Central African Republic"
replace name_0 = "Sao Tome" if name_0=="São Tomé and Príncipe"
replace name_0 = "Dominican Rep." if name_0=="Dominican Republic"
replace name_0 = "Eq. Guinea" if name_0=="Equatorial Guinea"
replace name_0 = "Papau N.G." if name_0=="Papua New Guinea"
replace name_0 = "Rep. of Congo" if name_0=="Republic of Congo"
replace name_0 = "Cote d'Ivoire" if name_0=="Côte d'Ivoire"

drop if name_0==""
sort name_0

capture file close f_result
file open f_result using "./Drafts/tab_aggregate_beta.tex", write replace

forvalues i = 1(1)39 {
	file write f_result (name_0[`i']) " & " %9.3f (wtd_district_beta[`i']) " & " ///
		(name_0[`i'+40]) " & " %9.3f (wtd_district_beta[`i'+40]) " & " ///
		(name_0[`i'+80]) " & " %9.3f (wtd_district_beta[`i'+80]) " & " ///
		(name_0[`i'+119]) " & " %9.3f (wtd_district_beta[`i'+119]) " \\" _n
}
file write f_result (name_0[40]) " & " %9.3f (wtd_district_beta[40]) "&" (name_0[80]) " & " %9.3f (wtd_district_beta[80]) ///
		" & & & & \\" _n
capture file close f_result
