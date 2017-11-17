//////////////////////////////////////////////////////////////////////
// Date: 2016-11-08
// Author: Dietz Vollrath
// 
// Control the flow of work for regressions
// 1. Create program to reset globals controlling code
// 2. Call data merge and prep routines
// 3. Call regression routines under various assumptions
//
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////
// Program to reset control variables
// YOU SHOULD EDIT THE PATHS TO POINT TO YOUR DIRECTORIES
//////////////////////////////////////
capture program drop reset
program reset // reset all globals to the baseline values
	macro drop _all // get rid of all macros
	global data "/users/dietz/dropbox/project/crops/work"
	global output "/users/dietz/dropbox/project/crops/drafts"
	global code "/users/dietz/dropbox/project/crops/replicate"
	global year 2000 // year of data to use
	global level gadm2 // level of data to use (gadm1 = province, gadm2 = district)
	global fe state_id // fixed effect to include
	global csivar ln_csi_yield // our max calories per hectare
	global rurdvar ln_rurd_2000 // rural density per unit of total land in 2000
	global cntl urb_perc_2000 ln_light_mean // urban percent and light mean
	global cutoff 500 // km cutoff for Conley SE
	global drop = "urbc_2000<-99999" // drop from sample - baseline is to drop noone
end

//////////////////////////////////////
// Set initial controls - load programs
//////////////////////////////////////
reset
do "$code/ols_spatial_HAC.ado" // set up program to do spatial standard errors
do "$code/Crops_Reg_Program.do" // set up program to do spatial regressions

//////////////////////////////////////
// Call programs given controls
//////////////////////////////////////
// Base results
reset // reset all globals to baseline
global tag = "base" // name the set of results (files, figures)
do "$code/Crops_Reg_Type_Call.do" // call the temperate/tropical regressions
do "$code/Crops_Reg_Region_Call.do" // call the regional regressions
do "$code/Crops_Reg_KGZones_Call.do" // call the regional regressions

// Change cutoff for SE
//reset
//global cutoff 1000
//global tag = "cut1000"
//do "$code/Crops_Reg_Type_Call.do" // call the temperate/tropical regressions

// Province level results
//reset
//global level gadm1
//global tag = "province"
//global fe country_id
//do "$code/Crops_Reg_Type_Call.do" // call the temperate/tropical regressions

// Autarkic districts
//reset
//global cntl urb_perc_2000 ln_light_mean ln_rur_perc_2000
//global tag = "autarky"
//do "$code/Crops_Reg_Type_Call.do" // call the temperate/tropical regressions

// Cultivated area
//reset
//global rurdvar ln_rurd_cult_2000
//global cntl urb_perc_2000 ln_light_mean ln_cult_area_perc
//global tag = "cult"
//do "$code/Crops_Reg_Type_Call.do" // call the temperate/tropical regressions

// 1900 population results
//reset
//global year 1900
//global rurdvar ln_rurd_1900 // rural density per unit of total land in 2000
//global cntl urb_perc_1900 ln_light_mean // urban percent and light mean
//global tag = "pop1900"
//do "$code/Crops_Reg_Type_Call.do" // call the temperate/tropical regressions

// 1950 population results
//reset
//global year 1950
//global rurdvar ln_rurd_1950 // rural density per unit of total land in 2000
//global cntl urb_perc_1950 ln_light_mean // urban percent and light mean
//global tag = "pop1950"
//do "$code/Crops_Reg_Type_Call.do" // call the temperate/tropical regressions

// Remove provinces with few districts
//reset
//global drop = "district_count<10" // drop if fewer than 8 districts
//global tag = "district"
//do "$code/Crops_Reg_Type_Call.do" // call the temperate/tropical regressions

// Remove districts either very large or very small
//reset
//global drop = "ln_area>13.1086" // drop if outside 10th/90th pctile in size
//global tag = "size"
//do "$code/Crops_Reg_Type_Call.do" // call the temperate/tropical regressions

// Remove districts with few harvest hectares
//reset
//global drop = "prod_sum<2792" // drop if below 25th percentile in total production
//global tag = "prodsum25th"
//do "$code/Crops_Reg_Type_Call.do" // call the temperate/tropical regressions

// HYDE Data, using IPUMS countries for comparison
//reset // reset all globals to baseline
//global drop "ipums_flag~=1" // exclude countries without IPUMS data
//global tag = "ipumsflag" // name the set of results (files, figures)
//do "$code/Crops_Reg_Type_Call.do" // call the temperate/tropical regressions

// GRUMP population data
//reset
//global rurdvar ln_grump_rurd
//global tag = "grump"
//do "$code/Crops_Reg_Type_Call.do" // call the temperate/tropical regressions

////////////////////////////////////////////////////////////////////////////
// Call separate program to run using separate crop productivity data 
// - This should stay last as it has to manipulate globals directly
////////////////////////////////////////////////////////////////////////////
reset
global tag = "base"
di "$tag"
do "$code/Crops_Reg_ByCrop_Call.do"
