//////////////////////////////////////////////////////////////////////
// Date: 2016-11-08
// Author: Dietz Vollrath
// 
// Merge the FAOSTAT summary data
//
//////////////////////////////////////////////////////////////////////

// SET THESE TO POINT TO YOUR WORK AND DATA FOLDERS
global data "/users/dietz/dropbox/project/crops/data"
global work "/users/dietz/dropbox/project/crops/work"

insheet using "$data/FAOSTAT_output.csv", clear names
rename value FAO_output
label variable FAO_output "Output (1000 Intl $)"
save "$work/FAOSTAT_output.dta", replace

insheet using "$data/FAOSTAT_labor.csv", clear names
rename value FAO_agworker
label variable FAO_agworker "1000 ag employees"
rename countrycode areacode
duplicates drop areacode, force
save "$work/FAOSTAT_labor.dta", replace

insheet using "$data/FAOSTAT_land.csv", clear names
rename value FAO_agland
label variable FAO_agland "1000 hectares ag land"
save "$work/FAOSTAT_land.dta", replace

merge 1:1 areacode using "$work/FAOSTAT_labor.dta"

drop _merge

merge 1:1 areacode using "$work/FAOSTAT_output.dta"

drop _merge

gen yield = FAO_output/FAO_agland
gen prod = FAO_output/FAO_agworker
gen density = FAO_agworker/FAO_agland
