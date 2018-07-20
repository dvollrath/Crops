//////////////////////////////////////////////////////////////////////
// Date: 2018-07-16
// Author: Dietz Vollrath
// 
// Merge pixel level dataset with GADM data
// Create variables for use in regressions
//
//////////////////////////////////////////////////////////////////////

// SET THESE TO POINT TO YOUR WORK AND DATA FOLDERS
global data "/users/dietz/dropbox/project/crops/work"

// Pull in GADM dataset and save to DTA for merging
insheet using "$data/gadm28_adm2_data.csv", clear names

save "$data/gadm28_adm2_data.dta", replace

// Pull in pixel-level dataset and merge in GADM
insheet using "$data/gadm28_pixel_data.csv", clear names

merge m:1 objectid using "$data/gadm28_adm2_data.dta"
// 4776 districts that do not have matching pixels?
// These are districts that are so small they are contained w/in pixels?

// Generate variables for regressions
egen district_id = group(id_0 id_1 id_2)

gen ln_csi_yield = ln(csi_maxyld)
gen ln_rurd_2000 = ln(rurc_2000) - ln(shape_area)
gen urb_perc_2000 = urbc_2000/(urbc_2000+rurc_2000)

gen dmsp_mean_light_adj = dmsp_mean_light
summ dmsp_mean_light_adj if dmsp_mean_light_adj>0
replace dmsp_mean_light_adj = r(min) if dmsp_mean_light_adj==0
gen ln_light_mean = ln(dmsp_mean_light_adj)

gen dry_suit = 0
replace dry_suit = 1 if suit_brl>0 | suit_bck>0 | suit_rye>0 | suit_oat>0 | suit_wpo>0 | suit_whe>0
gen wet_suit = 0
replace wet_suit = 1 if suit_csv>0 | suit_cow>0 | suit_pml>0 | suit_spo | suit_rcw>0 | suit_yam>0
