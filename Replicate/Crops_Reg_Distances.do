cd "/users/dietz/dropbox/project/crops/"

use "./Work/all_crops_data_gadm2.dta", clear

drop if x_cent==.
drop if y_cent==.

gen lat = y_cent
gen lon = x_cent + 180 // work on 0-360 degree scale

keep lat lon objectid

save "./Work/all_lat_lon_only.dta", replace

local cutoff 500

capture file close f
file open f using "./Work/all_sparse_dist_`cutoff'.csv", write replace
file write f "Home, Neighbor, Flag" _n

local Nobs = _N

gen londiff = .
gen latdiff = .
gen dist = .

forvalues i = 1(1)`Nobs' { // for every district	
	di `i' // for tracking progress while running
	local lonscale = cos(lat[`i']*_pi/180)*111 // calculate appropriate km/deg for given latitude
	qui replace latdiff = 111*(lat[`i']-lat) // get lat diff in KM
	qui replace londiff = `lonscale'*min(abs(lon[`i']-lon),abs(-lon[`i']-lon)) // get lon diff in KM
	qui replace dist = (latdiff^2 + londiff^2)^(.5) // given diffs, calculate distance
	
	qui levelsof objectid if _n==`i', local(home) // capture objectid for current district
	qui levelsof objectid if dist<`cutoff' & dist>0, local(neighbors) // capture object id for any neighbors (but not self)
	
	foreach d of local neighbors {
		file write f (`home') "," (`d') ", 1" _n
	}
}

capture file close f

insheet using "./Work/all_sparse_dist_`cutoff'.csv", clear comma names
count
keep if home < neighbor // this will eliminate duplicated entries
drop if home == neighbor // should not be any, but check for sure
count
save "./Work/all_sparse_dist_`cutoff'.dta", replace
