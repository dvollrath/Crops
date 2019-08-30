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
local rurdvar ln_grump_rurd //ln_rurd_2000 // rural density per unit of total land
local controls grump_urb_perc ln_light_mean ln_grump_popc // urban percent and light mean and total population

//////////////////////////////////////
// Regressions - temperate and tropical
//////////////////////////////////////	

// Create dummy to distinguish temperate from tropical on crops
capture drop temp
gen temp = .
replace temp = 1 if dry_suit==1 & wet_suit==0 // suitable for temp crops, not for trop
replace temp = 0 if dry_suit==0 & wet_suit==1 // suitable for trop crops, not for temp
replace temp = 2 if dry_suit==1 & wet_suit==1 // suitable for BOTH types of crops


areg `csivar' if inlist(temp,0,1), absorb(`fe')
qui predict res_csi, res
areg `rurdvar' if inlist(temp,0,1), absorb(`fe')
qui predict res_rurd, res
areg grump_urb_perc if inlist(temp,0,1), absorb(`fe')
qui predict res_urb_perc, res
areg ln_grump_popc if inlist(temp,0,1), absorb(`fe')
qui predict res_popc, res
areg ln_light_mean if inlist(temp,0,1), absorb(`fe')
qui predict res_light_mean, res

reg res_csi res_rurd res_urb_per res_popc res_light_mean  if temp==0
local beta_tropical = _b[res_rurd]
reg res_csi res_rurd res_urb_per res_popc res_light_mean if temp==1
local beta_temperate = _b[res_rurd]
areg `csivar' `rurdvar' `controls' if temp==2, absorb(`fe')
local beta_both = _b[`rurdvar']

use "./Work/all_crops_predrop_gadm2.dta", clear // load up ALL districts, even those dropped for estimation
gen dry_suit = 0
replace dry_suit = 1 if suit_brl>0 | suit_bck>0 | suit_rye>0 | suit_oat>0 | suit_wpo>0 | suit_whe>0
gen wet_suit = 0
replace wet_suit = 1 if suit_csv>0 | suit_cow>0 | suit_pml>0 | suit_spo | suit_rcw>0 | suit_yam>0

capture drop temp
gen temp = .
replace temp = 1 if dry_suit==1 & wet_suit==0 // suitable for temp crops, not for trop
replace temp = 0 if dry_suit==0 & wet_suit==1 // suitable for trop crops, not for temp
replace temp = 2 if dry_suit==1 & wet_suit==1 // suitable for BOTH types of crops
replace temp = 4 if dry_suit==0 & wet_suit==0 // suitable for NEITHER type of crop
replace temp = 4 if temp==. // catching any other leftover category

gen district_beta = .
replace district_beta = `beta_tropical' if temp==0
replace district_beta = `beta_temperate' if temp==1
replace district_beta = `beta_both' if temp==2

bysort name_0: egen country_cals = sum(cals)
gen district_cals_perc = cals/country_cals
gen wtd_district_beta = district_cals_perc*district_beta

export delimited id_0 id_1 id_2 iso name_0 name_1 objectid district_beta temp using "./Work/district-beta-map.csv", ///
	delimiter(",") nolabel replace

collapse (rawsum) wtd_district_beta , by(name_0)

drop if wtd_district_beta==0

replace name_0 = "Bosnia" if name_0=="Bosnia and Herzegovina"
replace name_0 = "D.R. Congo" if name_0=="Democratic Republic of the Congo"
replace name_0 = "C. African Rep." if name_0=="Central African Republic"
replace name_0 = "Sao Tome" if name_0=="São Tomé and Príncipe"
replace name_0 = "Dominican Rep." if name_0=="Dominican Republic"
replace name_0 = "Eq. Guinea" if name_0=="Equatorial Guinea"
replace name_0 = "Papau N.G." if name_0=="Papua New Guinea"
replace name_0 = "Rep. of Congo" if name_0=="Republic of Congo"
replace name_0 = "Cote d'Ivoire" if name_0=="Côte d'Ivoire"
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
