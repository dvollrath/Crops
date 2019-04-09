//////////////////////////////////////////////////////////////////////
// 
// Merge the various CSV files of GIS data together
// 1. Set the level of aggregation (country, province, district)
// 2. Pull in each CSV file, remove dupes, aggregate to set level
// 3. Merge all files together
//
//////////////////////////////////////////////////////////////////////

local gadm = "gadm2" // sets the file name "gadm2" is 2nd-level
local levels = "id_0 id_1 id_2" // collapse over these ID's (0 - nation, 1 - state, 2 - district)

// Create DTA file for regional identifier data
insheet using "./Replicate/iso_codes.csv", clear comma
rename alpha3 iso
save "./Work/iso_codes.dta", replace

// Create DTA files for each input source
// Identify duplicates on the ID variables - all files should have identical dupes
// Remove *all* instances of duplicated rows - mainly Nepal

insheet using "./Work/all_gaez_cult.csv", clear comma
duplicates report `levels'
duplicates tag `levels', generate(dupe)
drop if dupe~=0
collapse (first) iso name_0 name_1 (rawsum) shape_area cult_area_perc, by(`levels')
save "./Work/all_gaez_cult_`gadm'.dta", replace

insheet using "./Work/all_kg_data.csv", clear comma
duplicates report `levels'
duplicates tag `levels', generate(dupe)
drop if dupe~=0
collapse (first) iso name_0 name_1 (rawsum) kgfreq*, by(`levels')
save "./Work/all_kg_data_`gadm'.dta", replace

insheet using "./Work/all_cent_data_`gadm'.csv", clear comma
duplicates report `levels'
duplicates tag `levels', generate(dupe)
drop if dupe~=0

save "./Work/all_cent_data_`gadm'.dta", replace

insheet using "./Work/all_hyde_data.csv", clear comma
duplicates report id_0 id_1 id_2
duplicates tag id_0 id_1 id_2, generate(dupe)
drop if dupe~=0
collapse (first) iso name_0 name_1 (rawsum) shape_area popc* rurc* urbc*, by(`levels')
save "./Work/all_hyde_data_`gadm'.dta", replace

insheet using "./Work/all_gaez_suit_data.csv", clear comma
duplicates report id_0 id_1 id_2
duplicates tag id_0 id_1 id_2, generate(dupe)
drop if dupe~=0
collapse (first) iso name_0 name_1 (rawsum) shape_area (sum) suit* [iw = shape_area], by(`levels')
foreach var of varlist suit* {
	replace `var' = `var'/shape_area
}
save "./Work/all_gaez_suit_data_`gadm'.dta", replace

insheet using "./Work/all_gaez_agro_data.csv", clear comma
duplicates report id_0 id_1 id_2
duplicates tag id_0 id_1 id_2, generate(dupe)
drop if dupe~=0
collapse (first) iso name_0 name_1 (rawsum) shape_area (sum) agro* [iw = shape_area], by(`levels')
foreach var of varlist agro* {
	replace `var' = `var'/shape_area
}
save "./Work/all_gaez_agro_data_`gadm'.dta", replace

insheet using "./Work/all_csi_data.csv", clear comma
duplicates report id_0 id_1 id_2
duplicates tag id_0 id_1 id_2, generate(dupe)
drop if dupe~=0
collapse (first) iso name_0 name_1 (rawsum) shape_area count cals calsperc *_cells *_cals ///
	(mean) meanyld [iw = shape_area], by(`levels')
save "./Work/all_csi_data_`gadm'.dta", replace

insheet using "./Work/all_csi_only_data.csv", clear comma
duplicates report id_0 id_1 id_2
duplicates tag id_0 id_1 id_2, generate(dupe)
drop if dupe~=0
collapse (first) iso name_0 name_1 (rawsum) shape_area *_only_cals, by(`levels')
save "./Work/all_csi_only_data_`gadm'.dta", replace

insheet using "./Work/all_dmsp_light_data.csv", clear comma
duplicates report id_0 id_1 id_2
duplicates tag id_0 id_1 id_2, generate(dupe)
drop if dupe~=0
collapse (first) iso name_0 name_1 (sum) light_mean [iw = shape_area], by(`levels')
save "./Work/all_dmsp_light_data_`gadm'.dta", replace

insheet using "./Work/all_earthstat_data.csv", clear comma
duplicates report id_0 id_1 id_2
duplicates tag id_0 id_1 id_2, generate(dupe)
drop if dupe~=0
collapse (first) iso name_0 name_1 (sum) *_harvarea *_production es_*, by(`levels')
save "./Work/all_earthstat_data_`gadm'.dta", replace

insheet using "./Work/all_grump_pop_data.csv", clear comma
duplicates report id_0 id_1 id_2
duplicates tag id_0 id_1 id_2, generate(dupe)
drop if dupe~=0
collapse (first) iso name_0 name_1 (sum) grump_rur grump_pop, by(`levels')
save "./Work/all_grump_data_`gadm'.dta", replace

insheet using "./Work/all_csi_data_input_water.csv", clear comma
duplicates report id_0 id_1 id_2
duplicates tag id_0 id_1 id_2, generate(dupe)
drop if dupe~=0
collapse (first) iso name_0 name_1 (rawsum) shape_area count_* cals_* (mean) meanyld_* [iw = shape_area], by(`levels')
save "./Work/all_csi_data_input_water_`gadm'.dta", replace


// Merge all input sources together
// All _merge results should be identical in numbers of observations
clear
use "./Work/all_hyde_data_`gadm'.dta" // start with HYDE data, merge others to it
save "./Work/all_crops_collapse_`gadm'.dta", replace

merge 1:1 `levels' using "./Work/all_gaez_agro_data_`gadm'.dta"
drop _merge
merge 1:1 `levels' using "./Work/all_gaez_suit_data_`gadm'.dta"
drop _merge
merge 1:1 `levels' using "./Work/all_csi_data_`gadm'.dta"
drop _merge
merge 1:1 `levels' using "./Work/all_csi_only_data_`gadm'.dta"
drop _merge
merge 1:1 `levels' using "./Work/all_dmsp_light_data_`gadm'.dta"
drop _merge
merge 1:1 `levels' using "./Work/all_cent_data_`gadm'.dta"
drop _merge
merge 1:1 `levels' using "./Work/all_kg_data_`gadm'.dta"
drop _merge
merge 1:1 `levels' using "./Work/all_gaez_cult_`gadm'.dta"
drop _merge
merge 1:1 `levels' using "./Work/all_earthstat_data_`gadm'.dta"
drop _merge
merge 1:1 `levels' using "./Work/all_grump_data_`gadm'.dta"
drop _merge
merge 1:1 `levels' using "./Work/all_csi_data_input_water_`gadm'.dta"
drop _merge
merge m:1 iso using "./Work/iso_codes.dta"
drop _merge

drop if id_0==.
drop if id_1==.
drop if id_2==.

merge 1:1 `levels' using "./Data/DHS/DHS-all-gadm-hh.dta"
drop _merge

save "./Work/all_crops_collapse_`gadm'.dta", replace

