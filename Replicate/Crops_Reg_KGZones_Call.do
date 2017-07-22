
//////////////////////////////////////
// Load data and calculate addl variables
//////////////////////////////////////
clear
estimates clear
use "$data/all_crops_data_$level.dta"

gen cons = 1 // constant for use in spatial OLS
gen y = 1 // "time" variable for use in spatial OLS
gen kgcompare = 0.66*kgtotal

drop if $drop // drop based on passed condition

// Stata saves variables in all small letters, so KG caps (ABCDE) look small

//////////////////////////////////////
// Zone regressions
//////////////////////////////////////	

est_ref if kg_A>kgcompare // use equatorial as reference group
estimates store reg_kg_climate_A

est_reg if kg_B>kgcompare
estimates store reg_kg_climate_B

est_reg if kg_C>kgcompare
estimates store reg_kg_climate_C

est_reg if kg_D>kgcompare
estimates store reg_kg_climate_D

estout reg_kg_climate_A reg_kg_climate_B reg_kg_climate_C reg_kg_climate_D ///
	using "$output/tab_beta_kg_climate_$tag.tex", /// write the region results to Tex file
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) stats(p_zero p_diff N_country N_obs r2_a, fmt(%9.3f %9.3f %9.0g %9.0g %9.2f) labels("p-value $\beta=0$" "p-value $\beta=\beta^{Equa}$" "Countries" "Observations" "Adjusted R-square")) ///
	keep(rurd_reg) label mlabels(none) collabels(none) prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)

est_ref if kg_zfz>kgcompare // use fully humid as reference group
estimates store reg_kg_precip_f
	
est_reg if kg_zsz>kgcompare
estimates store reg_kg_precip_s
	
est_reg if kg_zwz>kgcompare
estimates store reg_kg_precip_w

est_reg if kg_zmz>kgcompare
estimates store reg_kg_precip_m
	
est_reg if kg_zdz>kgcompare
estimates store reg_kg_precip_d

est_reg if kg_zpz>kgcompare
estimates store reg_kg_precip_p

estout reg_kg_precip_f reg_kg_precip_s reg_kg_precip_w reg_kg_precip_m reg_kg_precip_d reg_kg_precip_p ///
	using "$output/tab_beta_kg_precip_$tag.tex", /// write the region results to Tex file
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) stats(p_zero p_diff N_country N_obs r2_a, fmt(%9.3f %9.3f %9.0g %9.0g %9.2f) labels("p-value $\beta=0$" "p-value $\beta=\beta^{Fully}$" "Countries" "Observations" "Adjusted R-square")) ///
	keep(rurd_reg) label mlabels(none) collabels(none) prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)

est_ref if kg_zza>kgcompare // use hot summer as reference group
estimates store reg_kg_temp_a

est_reg if kg_zzb>kgcompare
estimates store reg_kg_temp_b

est_reg if kg_zzc>kgcompare
estimates store reg_kg_temp_c

est_reg if kg_zzh>kgcompare
estimates store reg_kg_temp_h

est_reg if kg_zzk>kgcompare
estimates store reg_kg_temp_k

estout reg_kg_temp_a reg_kg_temp_b reg_kg_temp_c reg_kg_temp_h reg_kg_temp_k ///
	using "$output/tab_beta_kg_temp_$tag.tex", /// write the region results to Tex file
	replace style(tex) ///
	cells(b(fmt(3)) se(par fmt(3))) stats(p_zero p_diff N_country N_obs r2_a, fmt(%9.3f %9.3f %9.0g %9.0g %9.2f) labels("p-value $\beta=0$" "p-value $\beta=\beta^{Hot}$" "Countries" "Observations" "Adjusted R-square")) ///
	keep(rurd_reg) label mlabels(none) collabels(none) prefoot("\midrule") starlevels(* 0.10 ** 0.05 *** 0.01)
	
coefplot reg_kg_climate_A || reg_kg_climate_B || reg_kg_climate_C || reg_kg_climate_D || reg_kg_precip_f ///
	|| reg_kg_precip_s || reg_kg_precip_w || reg_kg_precip_m || reg_kg_precip_d || reg_kg_precip_p ///
	|| reg_kg_temp_a || reg_kg_temp_b || reg_kg_temp_c || reg_kg_temp_h || reg_kg_temp_k, ///
	keep(rurd_reg) bycoefs graphregion(color(white)) xtitle("{&beta} estimate") xlabel(,format(%9.1f)) ///
	mlabel format(%9.3f) mlabposition(12) ///
	bylabels("Equatorial" "Arid" "Warm Temperate" "Snow" "Fully Humid" "Dry Summer" "Dry Winter" "Monsoonal" "Desert" "Steppe" "Hot Summer" "Warm Summer" "Cool Summer" "Hot Arid" "Cold Arid") ///
	headings(1 = "{bf: Climate}" 5 = "{bf: Precipitation}" 11 = "{bf: Temperature}")
graph export "$output/fig_coef_kg_$tag.png", replace as(png)
graph export "$output/fig_coef_kg_$tag.eps", replace as(eps)
	
