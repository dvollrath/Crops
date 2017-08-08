//////////////////////////////////////////////////////////////////////
// Date: 2016-11-08
// Author: Dietz Vollrath
// 
// Merge the various CSV files together
// 1. Set the level of aggregation (country, province, district)
// 2. Pull in each CSV file, remove dupes, aggregate to set level
// 3. Merge all files together
//
//////////////////////////////////////////////////////////////////////

// SET THESE TO POINT TO YOUR WORK AND DATA FOLDERS
global data "/users/dietz/dropbox/project/crops/work" // where to find CSV files
global codes "/users/dietz/dropbox/project/crops/replicate" // where to find control files

// SET LEVEL OF AGGREGATION TO WORK WITH
// gadm0 - Countries
// gadm1 - States within countries
// gadm2 - Districts within states within countries
local gadm = "gadm2" 

//////////////////////////////////////////////////////////////////////
// There should be no reason to edit below this point
//////////////////////////////////////////////////////////////////////

// Assign correct levels to collapse over based on gadm level
if "`gadm'" == "gadm0" {
	local levels = "id_0"
}
else if "`gadm'" == "gadm1" {
	local levels = "id_0 id_1"
}
else if "`gadm'" == "gadm2" {
	local levels = "id_0 id_1 id_2"
}


// Create DTA file for regional identifier data
insheet using "$codes/iso_codes.csv", clear comma
rename alpha3 iso
save "$data/iso_codes.dta", replace

// Create DTA files for each input source
// Identify duplicates on the ID variables - all files should have identical dupes
// Remove *all* instances of duplicated rows - mainly Nepal

insheet using "$data/all_gaez_cult.csv", clear comma
duplicates report `levels'
duplicates tag `levels', generate(dupe)
drop if dupe~=0
collapse (first) iso name_0 name_1 (rawsum) shape_area cult_area_perc, by(`levels')
save "$data/all_gaez_cult_`gadm'.dta", replace

insheet using "$data/all_kg_data.csv", clear comma
duplicates report `levels'
duplicates tag `levels', generate(dupe)
drop if dupe~=0
collapse (first) iso name_0 name_1 (rawsum) kgfreq*, by(`levels')
save "$data/all_kg_data_`gadm'.dta", replace

insheet using "$data/all_cent_data_`gadm'.csv", clear comma
duplicates report `levels'
duplicates tag `levels', generate(dupe)
drop if dupe~=0

save "$data/all_cent_data_`gadm'.dta", replace

insheet using "$data/all_hyde_data.csv", clear comma
duplicates report id_0 id_1 id_2
duplicates tag id_0 id_1 id_2, generate(dupe)
drop if dupe~=0
collapse (first) iso name_0 name_1 (rawsum) shape_area popc* rurc* urbc*, by(`levels')
save "$data/all_hyde_data_`gadm'.dta", replace

insheet using "$data/all_gaez_suit_data.csv", clear comma
duplicates report id_0 id_1 id_2
duplicates tag id_0 id_1 id_2, generate(dupe)
drop if dupe~=0
collapse (first) iso name_0 name_1 (rawsum) shape_area (sum) suit* [iw = shape_area], by(`levels')
foreach var of varlist suit* {
	replace `var' = `var'/shape_area
}
save "$data/all_gaez_suit_data_`gadm'.dta", replace

insheet using "$data/all_gaez_agro_data.csv", clear comma
duplicates report id_0 id_1 id_2
duplicates tag id_0 id_1 id_2, generate(dupe)
drop if dupe~=0
collapse (first) iso name_0 name_1 (rawsum) shape_area (sum) agro* [iw = shape_area], by(`levels')
foreach var of varlist agro* {
	replace `var' = `var'/shape_area
}
save "$data/all_gaez_agro_data_`gadm'.dta", replace

insheet using "$data/all_csi_data.csv", clear comma
duplicates report id_0 id_1 id_2
duplicates tag id_0 id_1 id_2, generate(dupe)
drop if dupe~=0
collapse (first) iso name_0 name_1 (rawsum) shape_area count cals calsperc *_cells *_cals ///
	(mean) meanyld [iw = shape_area], by(`levels')
save "$data/all_csi_data_`gadm'.dta", replace

insheet using "$data/all_csi_only_data.csv", clear comma
duplicates report id_0 id_1 id_2
duplicates tag id_0 id_1 id_2, generate(dupe)
drop if dupe~=0
collapse (first) iso name_0 name_1 (rawsum) shape_area *_only_cals, by(`levels')
save "$data/all_csi_only_data_`gadm'.dta", replace

insheet using "$data/all_dmsp_light_data.csv", clear comma
duplicates report id_0 id_1 id_2
duplicates tag id_0 id_1 id_2, generate(dupe)
drop if dupe~=0
collapse (first) iso name_0 name_1 (sum) light_mean [iw = shape_area], by(`levels')
save "$data/all_dmsp_light_data_`gadm'.dta", replace

insheet using "$data/all_earthstat_data.csv", clear comma
duplicates report id_0 id_1 id_2
duplicates tag id_0 id_1 id_2, generate(dupe)
drop if dupe~=0
collapse (first) iso name_0 name_1 (sum) *_harvarea *_production, by(`levels')
save "$data/all_earthstat_data_`gadm'.dta", replace

insheet using "$data/all_grump_pop_data.csv", clear comma
duplicates report id_0 id_1 id_2
duplicates tag id_0 id_1 id_2, generate(dupe)
drop if dupe~=0
collapse (first) iso name_0 name_1 (sum) grump_rur, by(`levels')
save "$data/all_grump_data_`gadm'.dta", replace


// Merge all input sources together
// All _merge results should be identical in numbers of observations
clear
use "$data/all_hyde_data_`gadm'.dta" // start with HYDE data, merge others to it
save "$data/all_crops_collapse_`gadm'.dta", replace

merge 1:1 `levels' using "$data/all_gaez_agro_data_`gadm'.dta"
drop _merge
merge 1:1 `levels' using "$data/all_gaez_suit_data_`gadm'.dta"
drop _merge
merge 1:1 `levels' using "$data/all_csi_data_`gadm'.dta"
drop _merge
merge 1:1 `levels' using "$data/all_csi_only_data_`gadm'.dta"
drop _merge
merge 1:1 `levels' using "$data/all_dmsp_light_data_`gadm'.dta"
drop _merge
merge 1:1 `levels' using "$data/all_cent_data_`gadm'.dta"
drop _merge
merge 1:1 `levels' using "$data/all_kg_data_`gadm'.dta"
drop _merge
merge 1:1 `levels' using "$data/all_gaez_cult_`gadm'.dta"
drop _merge
merge 1:1 `levels' using "$data/all_earthstat_data_`gadm'.dta"
drop _merge
merge 1:1 `levels' using "$data/all_grump_data_`gadm'.dta"
drop _merge
merge m:1 iso using "$data/iso_codes.dta"
drop _merge

save "$data/all_crops_collapse_`gadm'.dta", replace

