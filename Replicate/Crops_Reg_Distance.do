//////////////////////////////////////
// Calculate distances to large cities
//////////////////////////////////////

//////////////////////////////////////
// Load data
//////////////////////////////////////
clear
estimates clear
use "./Work/all_crops_collapse_gadm2.dta" // use collapsed raw dataset

///////////////////////////////////////////
// Create reference variables for distances
///////////////////////////////////////////
gen lonrad = x_cent*_pi/180 // longitude in radians
gen latrad = y_cent*_pi/180 // latitude in radians
gen bigcity = ((grump_pop_2000 - grump_rur_2000)>99999) // 0/1 for wether district contains "big city" or not
gen dist_bigcity = 0  // variable to contain distance to big city - normalize to 0 for all
gen dist_bigcity_same_state = 0 // dummy for whether big city is in same state

local N = _N
forvalues i = 1/`N' { // for every district
	if bigcity[`i']==0 { // if the district does NOT have a big city itself
		di name_0[`i'] ", " name_2[`i'] // show name of district to keep track
		capture drop dlon
		capture drop dlat
		qui gen dlon = lonrad - lonrad[`i'] // diff in longitude
		qui gen dlat = latrad - latrad[`i'] // diff in latitude
		capture drop a
		qui gen a = (sin(dlat/2))^2 + cos(latrad[`i'])*cos(latrad)*(sin(dlon/2))^2 // Haversine formula
		capture drop c
		qui gen c = 2*atan2(sqrt(a),sqrt(1-a)) // Haversine formula
		capture drop d
		qui gen d = 6373*c // in KM, distance of each district to district 'i'
		qui replace d = . if bigcity==0 // replace with missing if district does not have big city
		qui summ d, det // summarize distances remaining (which should be dist of districts with big city to district 'i'
		local min = r(min)
		qui replace dist_bigcity = `min' if _n==`i' // set dist to big city to be minimum
		qui summ id_0 if d==`min' // find state_id of district with city at min distance
		local minid0 = r(min)
		qui summ id_1 if d==`min' 
		local minid1 = r(min)
		qui replace dist_bigcity_same_state = 1 if id_0[`i'] == `minid0' & id_1[`i'] == `minid1' // if state_id of i is same as state_id of min distance city district
	} // end if
} // end forvalues

capture drop dlon
capture drop dlat
capture drop a
capture drop c
capture drop d
save "./Work/all_crops_collapse_gadm2_dist.dta", replace
