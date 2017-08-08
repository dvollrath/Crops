//////////////////////////////////////////////////////////////////////
// Date: 2016-11-08
// Author: Dietz Vollrath
// 
// Collapse IPUMS data
// 1. Create variables to count worker types
// 2. Collapse on GEOLEV2
// 3. Save collapsed file to working folder
//
//////////////////////////////////////////////////////////////////////

// Set these to working directories you use
global input "/users/dietz/dropbox/project/crops/data/ipums" // raw IPUMS dta file
global output "/users/dietz/dropbox/project/crops/work" // write collapsed data

// Set census code local
local start 32200101 // first census in set, not important which one
local codes 40200101	50200101  68200101	76200001	854199601	116199801 ///
	120200501	152200201	156200001	170200501	188200001	192200201	218200101 ///
	818199601	222200701	231199401	242199601	288200001	300200101	324199601 ///
	332200301	356199941	364200601	368199701	400200401	404199901	417199901 ///
	454199801	484200001	504200401	508199701	586199801	591200001	604200701 ///
	608200001	686200201	694200401	710200101	728200801	724200101	729200801 ///
	834200201	792200001	800200201	804200101	840200001	862200101	704199901 ///
	894200001 // all other census codes
	
// Cycle through, creating separate files for each census included
foreach census in `start' `codes' {
	use "$input/ipumsi_00044.dta" if sample==`census', clear
	
	di "Processing census code: " (`census')
	
	quietly {
		gen purban = 0
		replace purban = perwt if empstat==1 & urban==2 // urban residents, employed
		
		gen purbanany = 0
		replace purbanany = perwt if urban==2 // urban residents, any employment

		gen pworker = 0
		replace pworker = perwt if empstat==1 // employed, any location/industry

		gen pag = 0
		replace pag = perwt if empstat==1 & indgen==10 // employed, agric industry

		gen prural = 0
		replace prural = perwt if empstat==1 & urban==1 // employed, rural

		gen pagany = 0
		replace pagany = perwt if indgen==10 // any reported agric industry

		gen pruralany = 0
		replace pruralany = perwt if urban==1 // any rural resident
	}
	collapse (sum) perwt purban purbanany pworker pag prural pagany pruralany ///
		(first) country year sample, by(geolev2)
	qui count
	display "-- Collapsed to " (r(N)) " districts"
	
	save "$input/ipums`census'.dta", replace
}

// Append all the collapsed datasets together into one output file for regressions
use "$input/ipums`start'.dta", clear
save "$output/ipumsgeo.dta", replace
foreach x in `codes' {
	append using "$input/ipums`x'.dta"
	save "$output/ipumsgeo.dta", replace
}

quietly count
display "Total district records: " (r(N))
save "$output/ipumsgeo.dta", replace	
