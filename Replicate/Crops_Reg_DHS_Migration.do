//////////////////////////////////////////////////////////////////////
// 
// Produce summary stats on migration from DHS 
//
//////////////////////////////////////////////////////////////////////
cd "/users/dietz/dropbox/project/crops/"

insheet using "./Work/DHS-summ-migration.csv", names clear

drop if count==.
drop if country=="."

bysort country: egen yearmax = max(year)

gen p_mover = c_movers/count
gen p_mover5 = c_mover5/count
gen p_mover_2550 = c_mover_2550/count
gen p_mover5_2550_all = c_mover5_2550/count
gen p_mover_2550_2550 = c_mover_2550/c_2550

label variable p_mover "All movers / all inds."
label variable p_mover5 "Movers in last 5 years / all inds."
label variable p_mover_2550 "Movers aged 25-50 / all inds."
label variable p_mover_2550_2550 "Movers aged 25-50 / all aged 25-50"

gen c_cross = c_urb_city + c_urb_town + c_urb_country + c_rur_city + c_rur_town + c_rur_country
gen p_country_urban = c_urb_country/c_cross
gen p_town_urban = c_urb_town/c_cross
gen p_city_urban = c_urb_city/c_cross

gen p_country_rural = c_rur_country/c_cross
gen p_town_rural = c_rur_town/c_cross
gen p_city_rural = c_rur_city/c_cross

gen s_country_urban = c_urb_country/(c_rur_country + c_urb_country)
gen s_town_urban = c_urb_town/(c_rur_town + c_urb_town)
gen s_city_urban = c_urb_city/(c_rur_city + c_urb_city)

label variable s_country_urban "Countryside"
label variable s_town_urban "Town"
label variable s_city_urban "City"

gen s_mover_diffreg = c_mover_diffreg/(c_mover_diffreg + c_mover_samereg)
gen s_mover_diffcheck = c_mover_diffreg/c_movers


capture file close f_result
file open f_result using "./Drafts/tab_summ_dhs_mig.tex", write replace

file write f_result "\multicolumn{8}{l}{Share moving measured by: } \\" _n
foreach v in p_mover p_mover5 p_mover_2550 p_mover_2550_2550  {
		local lab: variable label `v' 
		qui summ `v', det
		file write f_result "`lab' &" %9.2fc (r(mean)) "&" %9.2fc (r(sd)) "&" %9.2fc (r(p10)) "&" %9.2fc (r(p25)) "&" %9.2fc (r(p50)) "&" ///
			%9.2fc (r(p75)) "&" %9.2fc (r(p90)) "\\" _n
}

file write f_result "\\" _n

file write f_result "\multicolumn{8}{l}{Share moving to urban areas from self-reported: } \\" _n
foreach v in s_city_urban s_town_urban s_country_urban {
		local lab: variable label `v' 
		qui summ `v', det
		file write f_result "`lab' &" %9.2fc (r(mean)) "&" %9.2fc (r(sd)) "&" %9.2fc (r(p10)) "&" %9.2fc (r(p25)) "&" %9.2fc (r(p50)) "&" ///
			%9.2fc (r(p75)) "&" %9.2fc (r(p90)) "\\" _n
}


capture file close f_result
