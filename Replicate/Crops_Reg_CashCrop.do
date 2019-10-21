////////////////////////////////////////////////////////////////////////////
// Cash crop only regressions
////////////////////////////////////////////////////////////////////////////
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
local rurdvar ln_grump_rurd //ln_rurd_2000 // rural density per unit of total land
local controls grump_urb_perc ln_light_mean ln_grump_popc /// main controls
	ln_road_total_dens perc_road_tp1 perc_road_tp2 perc_road_tp3 ///
	ln_agro_slpidx dist_bigcity // distance controls
local dist 500 // km cutoff for Conley SE
local fraction .10

//////////////////////////////////////
// Regressions - different population
//////////////////////////////////////
foreach c in banana coffee cotton sugarcane tea tobacco { // for each cash crop
	capture drop `c'_harvarea_perc
	gen `c'_harvarea_perc = `c'_harvarea/harvarea_sum 
	summ `c'_harvarea_perc, det
	local cut = r(p99) // get 99th percentile of harvested percent of that crop
	reg ln_`c'_yield `rurdvar' `controls' if `c'_harvarea_perc>=`cut', absorb(`fe') cluster(`fe') // cluster FE because very sparse
	qui tabulate name_0 if e(sample)==1 // count countries in group=0
	qui estadd scalar N_country = r(r) // store country count for group=0
	qui count if e(sample)==1 // count observations in group=0
	qui estadd scalar N_obs = r(N) // store obs count for group=0
	qui estadd scalar p_zero = 2*(1-t(e(df_r),abs(_b[`rurdvar'])/_se[`rurdvar'])) // add p-value for H0: beta=0 for group==0		
	qui estadd scalar cutoff = `cut'
	estimates store `c'_reg
}

// Output table and coefficient plot
estout *_reg using "./Drafts/tab_beta_cash_crop.tex", /// write the region results to Tex file
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) ///
	stats(p_zero N_country N_obs cutoff, fmt(%9.3f %9.0g %9.0g %9.2f) labels("p-value $\beta_g=0$" "Countries" "Observations" "Harv. perc. min")) ///
	keep(`rurdvar') label mlabels(none) collabels(none) prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)
