//////////////////////////////////////////////////////////////////////
// Data preparation
//
//////////////////////////////////////////////////////////////////////

local gadm = "gadm2" 

//////////////////////////////////////////////////////////////////////
// There should be no reason to edit below this point
//////////////////////////////////////////////////////////////////////

graph set eps fontface Times

use "./Work/all_crops_collapse_`gadm'.dta", clear

//////////////////////////////////////
// IDs
//////////////////////////////////////
gen country_id = id_0
egen state_id = group(id_0 id_1)
bysort state_id: egen district_count = count(id_2) // create count of districts in a state

gen c = 1 // a constant for use in spatial regression

//////////////////////////////////////
// Centroid data
//////////////////////////////////////
drop if x_cent==. // drop if no longitude data
drop if y_cent==. // drop if no latitude data
drop if objectid==. // drop if no GIS identifier

save "./Work/all_crops_predrop_`gadm'.dta", replace

//////////////////////////////////////
// HYDE Population Data Prep
//////////////////////////////////////
local years 1900 1950 2000

qui gen shape_ha = shape_area*1000000 // convert to hectares
qui gen ln_cult_area_perc = ln(cult_area_perc) // generate log cultivated percent

foreach year in `years' {
	qui gen ln_popd_`year' = ln(popc_`year'/shape_ha) // population density
	label variable ln_popd_`year' "Density `year'"
	qui gen urb_perc_`year' = urbc_`year'/popc_`year' // urbanization rate
	label variable urb_perc_`year' "Urban share of district pop."
	qui gen ln_urbd_`year' = ln(urbc_`year') // urban population
	label variable ln_urbd_`year' "Urb density `year'"
	qui gen ln_rurd_`year' = ln(rurc_`year'/shape_ha) // urban density
	label variable ln_rurd_`year' "Log rural density"
	qui gen ln_rur_perc_`year' = ln(rurc_`year'/popc_`year') // percent of all rural workers in district i
	qui gen ln_rurd_cult_`year' = ln(rurc_`year'/(shape_ha*cult_area_perc))
	label variable ln_rurd_cult_`year' "Log rural cult. density"
	qui gen ln_popc_`year' = ln(popc_`year')
	label variable ln_popc_`year' "Log population"
}

qui gen ln_grump_rurd = ln(grump_rur_2000/shape_ha)
label variable ln_grump_rurd "Log rural density"
qui gen ln_grump_popc = ln(grump_pop_2000)
qui gen grump_urb_perc = (grump_pop_2000-grump_rur_2000)/grump_pop_2000
label variable grump_urb_perc "Urban share of district pop."
qui gen grump_urbc = grump_pop_2000 - grump_rur_2000
qui gen ln_grump_rurd_cult = ln(grump_rur_2000/(shape_ha*cult_area_perc))

qui gen ln_grump_rurd_1990 = ln(grump_rur_1990/shape_ha)
label variable ln_grump_rurd_1990 "Log rural density"
qui gen ln_grump_popc_1990 = ln(grump_pop_1990)
qui gen grump_urb_perc_1990 = (grump_pop_1990-grump_rur_1990)/grump_pop_1990
qui gen grump_urbc_1990 = grump_pop_1990 - grump_rur_1990
qui gen ln_grump_rurd_cult_1990 = ln(grump_rur_1990/(shape_ha*cult_area_perc))

bysort state_id: egen state_popc_2000 = sum(grump_pop_2000)
gen popc_2000_perc = grump_pop_2000/state_popc_2000
bysort state_id: egen state_urbc_2000 = sum(grump_urbc)
gen state_urbc_2000_perc = grump_urbc/state_urbc_2000
label variable state_urbc_2000_perc "Share of state urban pop."

bysort state_id: egen state_rurc_2000 = sum(grump_rur_2000)
gen rurc_2000_perc = grump_rur_2000/state_rurc_2000
bysort state_id: egen state_shape_ha = sum(shape_ha)
gen state_rurd_2000 = state_rurc_2000/state_shape_ha // state level rural density
gen p_state_shape_ha = shape_ha/state_shape_ha
label variable p_state_shape_ha "Share of state area"

gen p_state_popc_2000 = grump_pop_2000/state_popc_2000
label variable p_state_popc_2000 "Share of state population"

//////////////////////////////////////
// Create CSI productivity variables
//////////////////////////////////////
gen ln_csi_cals = ln(cals) // log total calories, using max crop in each cell
label variable ln_csi_cals "Log max cal"
gen ln_csi_meanyld = ln(meanyld) // log mean yield, using max crop in each cell
label variable ln_csi_meanyld "Log mean yield of calories"
gen ln_area = ln(shape_ha) // log of zone area
gen ln_csi_yield = ln_csi_cals - ln_area // log yield per area
label variable ln_csi_yield "Log caloric yield"

foreach c in barley buckwheat rye oat whitepotato wheat cassava cowpea pearlmillet sweetpotato wetrice yams ///
			banana coffee cotton oilpalm sunflower tea tobacco sugarbeet sugarcane {
	gen ln_`c'_yield = ln(`c'_only_cals) - ln_area
}

gen ln_csi_yield_lo_rain = ln(cals_lo_rain) - ln_area
gen ln_csi_yield_med_rain = ln(cals_med_rain) - ln_area
gen ln_csi_yield_med_irr = ln(cals_med_irr) - ln_area
gen ln_csi_yield_hi_rain = ln(cals_hi_rain) - ln_area
gen ln_csi_yield_hi_irr = ln(cals_hi_irr) - ln_area

//////////////////////////////////////
// Create flag for DHS data
//////////////////////////////////////
gen dhs_flag = (!missing(dhsid))

//////////////////////////////////////
// Create and adjust night lights data
//////////////////////////////////////
gen light_mean_adj = light_mean
summ light_mean_adj if light_mean_adj>0 // find minimum level of average lights
replace light_mean_adj = r(min) if light_mean_adj==0 // as per Henderson et al, replace zeros with minimum positive value
gen ln_light_mean = ln(light_mean_adj)
label variable ln_light_mean "Log light density"

bysort state_id: egen ln_light_state_max = max(ln_light_mean)
gen p_state_light_max = exp(ln_light_mean - ln_light_state_max)

//////////////////////////////////////
// Clip CSI yield and rural density data
//////////////////////////////////////
qui summ ln_csi_yield, det
drop if ln_csi_yield<r(p1) | ln_csi_yield>r(p99) // drop above 99th and below 1st percentile
keep if !missing(ln_csi_yield) // remove if missing yield data

// For main year - 2000 - drop extreme values of rural density
qui summ ln_grump_rurd, det
drop if ln_grump_rurd<r(p1) | ln_grump_rurd>r(p99) // drop above 99th and below 1st percentile
keep if !missing(ln_grump_rurd) // remove if missing density data
drop if grump_rur_2000 <100 // remove districts with very few rural workers

//////////////////////////////////////
// Create crop groups
//////////////////////////////////////
gen dry_suit = 0
replace dry_suit = 1 if suit_brl>0 | suit_bck>0 | suit_rye>0 | suit_oat>0 | suit_wpo>0 | suit_whe>0
gen wet_suit = 0
replace wet_suit = 1 if suit_csv>0 | suit_cow>0 | suit_pml>0 | suit_spo>0 | suit_rcw>0 | suit_yam>0

gen dry_max = 0
replace dry_max = 1 if (barley_cells + buckwheat_cells + oat_cells + rye_cells + whitepotato_cells + wheat_cells)>.33*count
gen dry_cells = barley_cells + buckwheat_cells + oat_cells + rye_cells + whitepotato_cells + wheat_cells
gen wet_max = 0
replace wet_max = 1 if (cassava_cells + cowpea_cells + pearlmillet_cells + sweetpotato_cells + wetrice_cells + yams_cells)>.33*count
gen wet_cells = cassava_cells + cowpea_cells + pearlmillet_cells + sweetpotato_cells + wetrice_cells + yams_cells

egen harvarea_sum = rowtotal(*_harvarea)
gen dry_area_perc = (barley_harvarea + buckwheat_harvarea + oats_harvarea + rye_harvarea + potato_harvarea + wheat_harvarea)/harvarea_sum
gen wet_area_perc = (cassava_harvarea + cowpea_harvarea + millet_harvarea + sweetpotato_harvarea + rice_harvarea + yam_harvarea)/harvarea_sum

//////////////////////////////////////
// Create crop production totals
//////////////////////////////////////
egen prod_sum = rowtotal(*_production) // get total tonnes of all crops produced

gen cash_area = banana_harvarea + cocoa_harvarea + coffee_harvarea + cotton_harvarea + jute_harvarea ///
					+ oilpalm_harvarea + rubber_harvarea + sunflower_harvarea + tea_harvarea + tobacco_harvarea ///
					+ sugarbeet_harvarea + sugarcane_harvarea
gen cash_area_perc = cash_area/harvarea_sum

//////////////////////////////////////
// Create soil quality variables
//////////////////////////////////////
gen agro_soil_perc = .
replace agro_soil_perc = 100 if agro_sq1==0
replace agro_soil_perc = (agro_sq1-0)*90 + (1-agro_sq1)*100 if agro_sq1>0 & agro_sq1<=1
replace agro_soil_perc = (agro_sq1-1)*70 + (2-agro_sq1)*90 if agro_sq1>1 & agro_sq1<=2
replace agro_soil_perc = (agro_sq1-2)*50 + (3-agro_sq1)*70 if agro_sq1>2 & agro_sq1<=3
replace agro_soil_perc = (agro_sq1-2)*30 + (3-agro_sq1)*50 if agro_sq1>3 & agro_sq1<=4

//////////////////////////////////////
// Basic climate zone sums
//////////////////////////////////////
egen kgtotal = rowtotal(kgfreq*)
egen kg_A = rowtotal(kgfreqa??)
label variable kg_A "Equatorial"
egen kg_B = rowtotal(kgfreqb??)
label variable kg_B "Arid"
egen kg_C = rowtotal(kgfreqc??)
label variable kg_C "Warm temperate"
egen kg_D = rowtotal(kgfreqd??)
label variable kg_D "Snow"
egen kg_zfz = rowtotal(kgfreq?f?)
label variable kg_zfz "Fully humid"
egen kg_zsz = rowtotal(kgfreq?s?)
label variable kg_zsz "Dry summer"
egen kg_zwz = rowtotal(kgfreq?w?)
label variable kg_zwz "Dry winter"
egen kg_zmz = rowtotal(kgfreq?m?)
label variable kg_zmz "Monsoonal"
egen kg_zdz = rowtotal(kgfreq?d?)
label variable kg_zdz "Desert"
egen kg_zpz = rowtotal(kgfreq?p?)
label variable kg_zpz "Steppe"
egen kg_zza = rowtotal(kgfreq??a)
label variable kg_zza "Hot summer"
egen kg_zzb = rowtotal(kgfreq??b)
label variable kg_zzb "Warm summer"
egen kg_zzc = rowtotal(kgfreq??c)
label variable kg_zzc "Cool summer"
egen kg_zzh = rowtotal(kgfreq??h)
label variable kg_zzh "Hot arid"
egen kg_zzk = rowtotal(kgfreq??k)
label variable kg_zzk "Cold arid"


//////////////////////////////////////
// Recode Russian provinces to Eur/Asia
//////////////////////////////////////
replace regioncode=142 if id_0==188 & inlist(id_1,11,30,36,66,73,80) // recoding Ural region to Asia
replace regioncode=142 if id_0==188 & inlist(id_1,3,12,24,28,40,56,60,61,82) // recoding Far East to Asia
replace regioncode=142 if id_0==188 & inlist(id_1,2,9,16,18,27,29,35,50,51,69,71,83) // recoding Siberia to Asia

replace subregioncode=999 if id_0==188 & inlist(id_1,11,30,36,66,73,80) // recoding Ural region to Russian Asia
replace subregioncode=999 if id_0==188 & inlist(id_1,3,12,24,28,40,56,60,61,82) // recoding Far East to Russian Asia
replace subregioncode=999 if id_0==188 & inlist(id_1,2,9,16,18,27,29,35,50,51,69,71,83) // recoding Siberia to Russian Asia
replace name_0 = "Russia (Europe)" if id_0==188 & subregioncode==151
replace name_0 = "Russia (Asia)" if id_0==188 & subregioncode==999

//////////////////////////////////////
// Create regional codes
//////////////////////////////////////
gen jv_region = . // create identifier
gen jv_region_text = ""
replace jv_region = 1 if inlist(subregioncode,154,39,155,151) // Europe
replace jv_region_text = "Europe" if jv_region==1
replace jv_region = 2 if inlist(subregioncode,34,35,30,999) // Asia
replace jv_region_text = "South and East Asia" if jv_region==2
replace jv_region = 3 if inlist(subregioncode,11,17,14,18) // Sub-Saharan Africa
replace jv_region_text = "Sub-Saharan Africa" if jv_region==3
replace jv_region = 4 if inlist(subregioncode,15,145,143) // Nafrica/W Asia
replace jv_region_text = "North Africa and West Asia" if jv_region==4
replace jv_region = 5 if inlist(subregioncode,29,13,5) // S. and C. America
replace jv_region_text = "South and Central America" if jv_region==5
replace jv_region = 6 if inlist(subregioncode,21) // N. America
replace jv_region_text = "North America" if jv_region==6

capture label drop region
label define region 1 "Europe"
label define region 2 "South and East Asia", add
label define region 3 "Sub-Saharan Africa", add
label define region 4 "N. Africa and West Asia", add
label define region 5 "S. and Central America", add
label define region 6 "U.S. and Canada", add
label values jv_region region

//////////////////////////////////////
// Create sub-regional codes
//////////////////////////////////////
gen jv_subregion = . // create identifier
gen jv_subregion_text = ""
replace jv_subregion = 1 if inlist(subregioncode,154,155) // North western Europe
replace jv_subregion_text = "Northwest Europe" if jv_subregion==1
replace jv_subregion = 2 if inlist(subregioncode,151) // Eastern Europe
replace jv_subregion_text = "Eastern Europe" if jv_subregion==2
replace jv_subregion = 3 if inlist(subregioncode,39) // South Europe
replace jv_subregion_text = "Southern Europe" if jv_subregion==3
replace jv_subregion = 4 if inlist(subregioncode,35) | name_0=="India" | name_0=="Bangladesh" | name_0=="Sri Lanka" // South-east Asia
replace jv_subregion_text = "South and Southeast Asia" if jv_subregion==4
replace jv_subregion = 5 if inlist(subregioncode,143,34,145,999) & jv_subregion~=4 // Continental Asia
replace jv_subregion_text = "Central and West Asia" if jv_subregion==5
replace jv_subregion = 6 if  inlist(subregioncode,21) | name_0=="Argentina" | name_0=="Uruguay" | name_0=="Chile" // Temperate Americas
replace jv_subregion_text = "Temperate Americas" if jv_subregion==6
replace jv_subregion = 7 if inlist(subregioncode,13,5,29) & jv_subregion~=6 // Tropical Americas
replace jv_subregion_text = "Tropical Americas" if jv_subregion==7
replace jv_subregion = 8 if inlist(subregioncode,11,17,14) // East, West and Mid Africa
replace jv_subregion_text = "Tropical Africa" if jv_subregion==8
replace jv_subregion = 9 if inlist(subregioncode,18) // South Africa
replace jv_subregion_text = "South Africa" if jv_subregion==9
replace jv_subregion = 10 if inlist(subregioncode,15) // North Africa
replace jv_subregion_text = "North Africa" if jv_subregion==10

capture label drop long
label define long 1 "Northwest Europe"
label define long 2 "Eastern Europe", add
label define long 3 "Southern Europe", add
label define long 4 "South and S. East Asia", add
label define long 5 "Central and West. Asia", add
label define long 6 "Temperate Americas", add
label define long 7 "Tropical Americas", add
label define long 8 "Tropical Africa", add
label define long 9 "Southern Africa", add
label define long 10 "Northern Africa", add
label values jv_subregion long	

//////////////////////////////////////
// Create china indicator for North/South
//////////////////////////////////////
gen jv_china = . // create identifier for north/south
replace jv_china = 1 if name_0=="China" & inlist(name_1,"Hebei","Heilongjiang","Jilin") // North
replace jv_china = 1 if name_0=="China" & inlist(name_1,"Liaoning","Nei Mongol","Ningxia Hui","Shaanxi","Shanxi") // North
replace jv_china = 1 if name_0=="China" & inlist(name_1,"Tianjin","Sichuan","Shandong","Yunnan") // North
replace jv_china = 2 if name_0=="China" & inlist(name_1,"Guangxi","Guangdong","Fujian","Jiangxi","Hunan") // South
replace jv_china = 2 if name_0=="China" & inlist(name_1,"Guizhou","Chongqing","Hubei","Anhui","Zhejiang") // South
replace jv_china = 2 if name_0=="China" & inlist(name_1,"Henan","Jiangsu","Hainan") // South
// "Xizang", "Xinjiang Uygur" "Gansu", "Qinghai", - remove Tibet and Xinjiang from "North" ,"Yunnan"

//////////////////////////////////////
// Create indicator for inclusion in IPUMS data
//////////////////////////////////////
gen ipums_flag = .
replace ipums_flag = 1 if inlist(name_0,"Argentina","Austria","Bolivia","Brazil","Burkina Faso")
replace ipums_flag = 1 if inlist(name_0,"Cambodia","Cameroon","Chile","Colombia","Costa Rica")
replace ipums_flag = 1 if inlist(name_0,"Ecuador","Egypt","El Salvador","Fiji","Ghana")
replace ipums_flag = 1 if inlist(name_0,"Greece","Haiti","India","Iran","Iraq")
replace ipums_flag = 1 if inlist(name_0,"Jordan","Kyrgyzstan","Malawi","Mexico","Morocco")
replace ipums_flag = 1 if inlist(name_0,"Mozambique","Panama","Peru","Sierra Leone","South Africa")
replace ipums_flag = 1 if inlist(name_0,"South Sudan","Spain","Sudan","Tanzania","Turkey")
replace ipums_flag = 1 if inlist(name_0,"Uganda","United States","Venezuela","Zambia")

save "./Work/all_crops_data_`gadm'.dta", replace


//////////////////////////////////////
// Write table of regional membership
//////////////////////////////////////
capture file close f_result
file open f_result using "./Drafts/tab_region_id.tex", write replace

qui levelsof jv_subregion_text, local(levels)
foreach x of local levels {
	preserve 
		keep if jv_subregion_text == "`x'"
		file write f_result "\item \textbf{`x'}: "
		qui levelsof name_0, local(countries)
		local i = 1
		foreach c of local countries {
			if `i'==1 {
				file write f_result "`c'"
			}
			else {
				file write f_result ", `c'"
			}
			local i = `i' + 1
		}
		file write f_result _n
	restore
}
capture file close f_result

capture file close f_result
file open f_result using "./Drafts/tab_russia_id.tex", write replace

qui levelsof name_1 if id_0==188 & subregioncode==999, local(provinces)
file write f_result "\item \textbf{Russia(Asia)}: "
local i = 1
foreach c of local provinces {
		if `i'==1 {
			file write f_result "`c'"
		}
		else {
			file write f_result ", `c'"
		}
		local i = `i' + 1
	}
file write f_result _n

qui levelsof name_1 if id_0==188 & subregioncode==151, local(provinces)
file write f_result "\item \textbf{Russia(Europe)}: "
local i = 1
foreach c of local provinces {
		if `i'==1 {
			file write f_result "`c'"
		}
		else {
			file write f_result ", `c'"
		}
		local i = `i' + 1
	}
file write f_result _n
file close f_result

//////////////////////////////////////
// Write summary stats table
//////////////////////////////////////

gen csi_yield = (cals/1000)/shape_ha
label variable csi_yield "Caloric yield (mil cals/ha)"
gen rurd_2000 = grump_rur_2000/shape_ha
label variable rurd_2000 "Labor/land (persons/ha)"
gen popc_report = grump_pop_2000/1000
label variable popc_report "Total population (000s)"
gen rurc_report = grump_rur_2000/1000
label variable rurc_report "Rural population (000s)"
gen shape_ha_report = shape_ha/1000
label variable shape_ha_report "Total area (000s ha)"
gen urbc_report = grump_urbc/1000
label variable urbc_report "Urban population (000s)"



capture file close f_result
file open f_result using "./Drafts/tab_summ_levels.tex", write replace

foreach v in rurd_2000 csi_yield ln_light_mean {
		local lab: variable label `v' 
		qui summ `v', det
		file write f_result "`lab' &" %9.2fc (r(mean)) "&" %9.2fc (r(sd)) "&" %9.2fc (r(p10)) "&" %9.2fc (r(p25)) "&" %9.2fc (r(p50)) "&" ///
			%9.2fc (r(p75)) "&" %9.2fc (r(p90)) "\\" _n
}
file close f_result

capture file close f_result
file open f_result using "./Drafts/tab_summ_counts.tex", write replace
qui count
file write f_result "{\newcommand{\districts}{" %8.0fc (r(N)) "}" _n
qui tabulate state_id
file write f_result "{\newcommand{\provinces}{" %8.0fc (r(r)) "}" _n
qui tabulate country_id
file write f_result "{\newcommand{\countries}{" %8.0fc (r(r)) "}" _n
file close f_result

capture file close f_result
file open f_result using "./Drafts/tab_summ_districts.tex", write replace

foreach v in popc_report rurc_report urbc_report  {
		local lab: variable label `v' 
		qui summ `v', det
		file write f_result "`lab' &" %9.1fc (r(mean)) "&" %9.1fc (r(sd)) "&" %9.1fc (r(p10)) "&" %9.1fc (r(p25)) "&" %9.1fc (r(p50)) "&" ///
			%9.1fc (r(p75)) "&" %9.1fc (r(p90)) "\\" _n
}

local lab: variable label grump_urb_perc
qui summ grump_urb_perc, det
file write f_result "`lab' &" %9.2fc (r(mean)) "&" %9.2fc (r(sd)) "&" %9.2fc (r(p10)) "&" %9.2fc (r(p25)) "&" %9.2fc (r(p50)) "&" ///
			%9.2fc (r(p75)) "&" %9.2fc (r(p90)) "\\ \\" _n
			
foreach v in p_state_popc_2000 state_urbc_2000_perc  p_state_shape_ha  {
		local lab: variable label `v' 
		qui summ `v', det
		file write f_result "`lab' &" %9.2fc (r(mean)) "&" %9.2fc (r(sd)) "&" %9.2fc (r(p10)) "&" %9.2fc (r(p25)) "&" %9.2fc (r(p50)) "&" ///
			%9.2fc (r(p75)) "&" %9.2fc (r(p90)) "\\" _n
}

file write f_result "\\"
local lab: variable label shape_ha_report 
qui summ shape_ha_report, det
file write f_result "`lab' &" %9.1fc (r(mean)) "&" %9.1fc (r(sd)) "&" %9.1fc (r(p10)) "&" %9.1fc (r(p25)) "&" %9.1fc (r(p50)) "&" ///
	%9.1fc (r(p75)) "&" %9.1fc (r(p90)) "\\" _n


file close f_result

capture file close f_result


//////////////////////////////////////
// Create density figures for yield/rurd
//////////////////////////////////////

capture drop temp
gen temp = .
replace temp = 1 if dry_suit==1 & wet_suit==0 // suitable for temp crops, not for trop
replace temp = 0 if dry_suit==0 & wet_suit==1 // suitable for trop crops, not for temp

twoway kdensity csi_yield if temp==0, clcolor(black) ///
	|| kdensity csi_yield if temp==1, clcolor(gray) clpattern(dash) ///
	graphregion(color(white)) xtitle("Caloric yield (mil. per hectare)") ///
	legend(size(small) ring(0) pos(2) cols(1) label(1 "Tropical") label(2 "Temperate")) ///
	ylabel(, nogrid angle(0) format(%9.2f)) ytitle("Density") xlabel(0(5)35)
graph export "./Drafts/fig_dens_csi.png", replace as(png)
graph export "./Drafts/fig_dens_csi.eps", replace as(eps)

twoway kdensity ln_grump_rurd if temp==0, clcolor(black) ///
	|| kdensity ln_grump_rurd if temp==1, clcolor(gray) clpattern(dash) ///
	graphregion(color(white)) xtitle("Log labor/land ratio (persons/ha)") ///
	legend(size(small) ring(0) pos(2) cols(1) label(1 "Tropical") label(2 "Temperate")) ///
	ylabel(, nogrid angle(0) format(%9.2f)) ytitle("Density") //xlabel(-6(1)3)
graph export "./Drafts/fig_dens_rurd.png", replace as(png)
graph export "./Drafts/fig_dens_rurd.eps", replace as(eps)

binscatter ln_csi_yield ln_grump_rurd, ///
	nquantiles(50) by(temp) mcolors(black gray) msymbol(oh dh) lcolors(black gray) ///
	xtitle("(Log) labor/land ratio") ytitle("(Log) caloric yield")  ylabel(,nogrid angle(0) format(%9.1f)) ///
	absorb(state_id) controls(grump_urb_perc ln_light_mean ln_grump_popc) noaddmean ///
	legend(pos(3) ring(0) cols(1) label(1 "Tropical {&beta}{sub:g} = 0.088") label(2 "Temperate {&beta}{sub:g} = 0.239") region(lwidth(none))) ///
	savegraph("./Drafts/fig_beta_crop.eps") replace reportreg
	
//////////////////////////////////////
// Create residual variation in main variables
//////////////////////////////////////
quietly {
capture drop res_ln_csi_yield
areg ln_csi_yield, absorb(state_id)
predict res_ln_csi_yield, res
capture drop res_ln_grump_rurd
areg ln_grump_rurd, absorb(state_id)
predict res_ln_grump_rurd, res
}


// end
