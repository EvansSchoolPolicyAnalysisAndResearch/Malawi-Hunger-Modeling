//Assumes working directory folder structure is the same as it is in the EPAR LSMS-ISA code respository.

use "Malawi IHS Wave 1\Raw DTA files\Geovariables\HH_level\householdgeovariables.dta", clear
keep ea_id lat_modified lon_modified 
duplicates drop 
duplicates report ea_id
ren lat_modified lat 
ren lon_modified lon
tempfile w1_geovars
save `w1_geovars'

use "Malawi IHS Wave 1\Raw DTA files\Household\hh_mod_a_filt.dta", clear
ren reside rural 
ren hh_a01 district 
ren hh_a02 ta
keep ea_id rural district //ta 
duplicates drop 
tempfile w1_admin
save `w1_admin'

use "Malawi IHS Wave 2\Raw DTA files\HH_MOD_A_FILT_13.dta", clear
merge m:1 ea_id using `w1_geovars', nogen keep(3)
merge m:1 ea_id using `w1_admin', nogen keep(3)
preserve
keep ea_id region district rural //ta
duplicates drop 
tempfile w2_admin
save `w2_admin'
restore
keep ea_id lat lon 
duplicates drop
tempfile w2_geovars
save `w2_geovars'

use "Malawi IHS Wave 3\Raw DTA files\IHS\householdgeovariablesihs4.dta", clear 
merge 1:1 case_id using "Malawi IHS Wave 3\Raw DTA files\IHS\hh_mod_a_filt.dta", nogen keep(3)
keep ea_id lat_modified lon_modified 
duplicates drop 
duplicates report ea_id
ren lat_modified lat 
ren lon_modified lon 
drop if lat==0 | lon==0
collapse (mean) lat lon, by(ea_id)
tempfile w3_geovars
save `w3_geovars'
merge 1:m ea_id using "Malawi IHS Wave 3\Raw DTA files\IHS\hh_mod_a_filt.dta", nogen keep(3)
ren reside rural
ren hh_a02a ta
keep ea_id region district rural ta
duplicates drop
tempfile w3_admin 
save `w3_admin'



use "Malawi IHS Wave 4\Raw DTA Files\IHS\householdgeovariables_ihs5.dta", clear 
keep ea_id ea_lat_mod ea_lon_mod 
duplicates drop 
duplicates report ea_id 
ren ea_lat_mod lat 
ren ea_lon_mod lon
drop if lat==0 | lon==0
collapse (mean) lat lon, by(ea_id)
tempfile w4_geovars 
save `w4_geovars'

preserve 
merge 1:m ea_id using "Malawi IHS Wave 4/Raw DTA Files/IHS/hh_mod_a_filt.dta", nogen keep(3)
ren reside rural 
ren hh_a02a ta
keep ea_id region district rural ta
duplicates drop
tempfile w4_admin 
save `w4_admin'
restore

append using `w1_geovars'
append using `w3_geovars'
collapse (mean) lat lon, by(ea_id)
save "ea_geocoords.dta", replace 

use `w1_geovars'
gen wave=1
append using `w2_geovars'
replace wave=2 if wave==.
append using `w3_geovars'
replace wave=3 if wave==.
append using `w4_geovars'
replace wave=4 if wave==.
drop lat lon 
merge m:1 ea_id using "ea_geocoords.dta", nogen
save "ea_geocoords_by_wave.dta", replace
export delimited using "ea_geocoords_by_wave.csv", replace



use `w2_admin', clear
append using `w3_admin'
append using `w4_admin'
keep region district 
duplicates drop 
duplicates report district 
merge 1:m district using `w1_admin', nogen keep(2 3)
append using `w2_admin'
append using `w3_admin'
append using `w4_admin'

save "ea_admin.dta", replace 
keep ea_id rural 
duplicates drop 
save "ea_rururb.dta", replace 


//// GIS VARIABLES ////
use "Malawi IHS Wave 1\Raw DTA files\Geovariables\HH_level\householdgeovariables.dta", clear
ren lat_modified lat 
ren lon_modified lon
ren dist_road lsms_distroad
ren dist_popcenter lsms_distpopctr
ren dist_admarc lsms_distadmarc
ren dist_auction lsms_distauc
ren dist_boma lsms_distboma
ren dist_borderpost lsms_distborder
ren fsrad3_agpct lsms_agpct
ren fsrad3_lcmaj lsms_lcvr
ren ssa_aez09 lsms_aez
ren srtm_eaf lsms_elev
ren h2009_area lsms_ndviarea2009
ren h2009_grn lsms_ndvigrn2009
ren h2009_sen lsms_ndvisen2009
ren h2010_area lsms_ndviarea2010
ren h2010_grn lsms_ndvigrn2010
ren h2010_sen lsms_ndvisen2010
collapse (mean) lsms*, by(ea_id lat lon)
preserve
keep ea_id lat lon
duplicates drop
tempfile w1locs 
save `w1locs'
restore 

preserve 
keep ea_id *2009 *2010
reshape long lsms_ndviarea lsms_ndvigrn lsms_ndvisen, i(ea_id) j(ag_year)
tempfile ndviw1
save `ndviw1'
restore 
drop *2009 *2010
merge 1:m ea_id using `ndviw1', nogen
gen wave=1
save "ea_geovars_w1.dta", replace

use "Malawi IHS Wave 2\Raw DTA files\HouseholdGeovariables_IHPS_13.dta", clear
merge 1:1 y2_hhid using "Malawi IHS Wave 2\Raw DTA files\HH_MOD_A_FILT_13.dta", nogen
ren LAT_DD_MOD lat 
ren LON_DD_MOD lon 
drop if distY1Y2 !=.
/*
ren LAT_DD_MOD latw2
ren LON_DD_MOD lonw2

merge m:1 ea_id using `w1locs', nogen keep(3)
gen euclidean_dist = sqrt((lat-latw2)^2 + (lon-lonw2)^2)
bys ea_id : egen min_dist = min(euclidean_dist)
keep if euclidean_dist==min_dist  
drop lat lon
ren latw2 lat 
ren lonw2 lon 
*/
ren dist_road lsms_distroad
ren dist_popcenter lsms_distpopctr
ren dist_admarc lsms_distadmarc
ren dist_auction lsms_distauc
ren dist_boma lsms_distboma
ren dist_borderpost lsms_distborder
ren fsrad3_agpct lsms_agpct
ren fsrad3_lcmaj lsms_lcvr
ren ssa_aez09 lsms_aez
ren srtm_1k lsms_elev
ren h2012_eviarea lsms_ndviarea2012
ren h2012_grn lsms_ndvigrn2012
ren h2012_sen lsms_ndvisen2012
ren h2013_eviarea lsms_ndviarea2013
ren h2013_grn lsms_ndvigrn2013
ren h2013_sen lsms_ndvisen2013
collapse (mean) lsms*, by(ea_id lat lon)

preserve 
keep ea_id *2012 *2013
reshape long lsms_ndviarea lsms_ndvigrn lsms_ndvisen, i(ea_id) j(ag_year)
tempfile ndviw2
save `ndviw2'
restore 
drop *2012 *2013
merge 1:m ea_id using `ndviw2', nogen
gen wave=2
save "ea_geovars_w2.dta", replace
keep ea_id 
save "panel_eas.dta", replace
export delimited using "panel_eas.csv", replace

use "Malawi IHS Wave 3\Raw DTA files\IHPS\HouseholdGeovariablesIHPSY3.dta", clear 
merge 1:1 y3_hhid using "Malawi IHS Wave 3\Raw DTA files\IHPS\hh_mod_a_filt_16.dta", nogen keep(3)
ren lat_modified latw3 
ren lon_modified lonw3
merge m:1 ea_id using `w1locs', nogen keep(1 3)
gen euclidean_dist = sqrt((lat-latw3)^2 + (lon-lonw3)^2)
bys ea_id : egen min_dist = min(euclidean_dist)
keep if euclidean_dist==min_dist  


**************************************
* WAVE 1
**************************************
use "Malawi IHS Wave 3\Raw DTA files\IHS\householdgeovariablesihs4.dta", clear 
merge 1:1 case_id using "Malawi IHS Wave 3\Raw DTA files\IHS\hh_mod_a_filt.dta", nogen keep(3)
use "Malawi IHS Wave 1\Raw DTA files\Household\hh_mod_a_filt.dta", clear
merge 1:1 case_id using "Malawi IHS Wave 1\Raw DTA files\Household\hh_mod_h.dta", nogen
ren case_id hhid
gen int_month = hh_a23b_1 
replace int_month = hh_a23b_2 if qx_type=="Panel B"
gen int_year = hh_a23c_1
replace int_year=hh_a23c_2 if qx_type=="Panel B"
gen mar_2009 = hh_h05a_01 == "X" if int_month <  4 & int_year!=2011
gen apr_2009 = hh_h05a_02 == "X" if int_month <  5 & int_year!=2011
gen may_2009 = hh_h05a_03 == "X" if int_month <  6 & int_year!=2011
gen jun_2009 = hh_h05a_04 == "X" if int_month <  7 & int_year!=2011 
gen jul_2009 = hh_h05a_05 == "X" if int_month <  8 & int_year!=2011
gen aug_2009 = hh_h05a_06 == "X" if int_month <  9 & int_year!=2011
gen sep_2009 = hh_h05a_07 == "X" if int_month < 10 & int_year!=2011
gen oct_2009 = hh_h05a_08 == "X" if int_month < 11 & int_year!=2011
gen nov_2009 = hh_h05a_09 == "X" if int_month < 12 & int_year!=2011
gen dec_2009 = hh_h05a_10 == "X" if int_year!=2011
gen jan_2010 = hh_h05b_01 == "X" if (int_month > 1 & int_year==2010) | (int_month < 2 & int_year==2011)
gen feb_2010 = hh_h05b_02 == "X" if (int_month > 2 & int_year==2010) | (int_month < 3 & int_year==2011)
gen mar_2010 = hh_h05b_03 == "X" if (int_month > 3 & int_year==2010) | (int_month < 4 & int_year==2011)
gen apr_2010 = hh_h05b_04 == "X" if (int_month > 4 & int_year==2010) | (int_month < 5 & int_year==2011)
gen may_2010 = hh_h05b_05 == "X" if int_month >  5 | int_year==2011
gen jun_2010 = hh_h05b_06 == "X" if int_month >  6 | int_year==2011
gen jul_2010 = hh_h05b_07 == "X" if int_month >  7 | int_year==2011
gen aug_2010 = hh_h05b_08 == "X" if int_month >  8 | int_year==2011
gen sep_2010 = hh_h05b_09 == "X" if int_month >  9 | int_year==2011
gen oct_2010 = hh_h05b_10 == "X" if int_month > 10 | int_year==2011
gen nov_2010 = hh_h05b_11 == "X" if int_month > 11 | int_year==2011
gen dec_2010 = hh_h05b_12 == "X" if int_year == 2011
gen jan_2011 = hh_h05b_13 == "X" if int_year == 2011 & int_month > 1
gen feb_2011 = hh_h05b_14 == "X" if int_year == 2011 & int_month > 2
gen mar_2011 = hh_h05b_15 == "X" if int_year == 2011 & int_month > 3

ren *_2009 hunger2009*
ren *_2010 hunger2010*
ren *_2011 hunger2011*
keep hhid ea_id hunger*
reshape long hunger2009 hunger2010 hunger2011, i(ea_id hhid) j(month) string
reshape long hunger, i(ea_id hhid month) j(year)
tostring hhid, replace
tempfile hh_hunger_y1
save `hh_hunger_y1'

la def months 1 "jan" 2 "feb" 3 "mar" 4 "apr" 5 "may" 6 "jun" 7 "jul" 8 "aug" 9 "sep" 10 "oct" 11 "nov" 12 "dec"
encode month, l(months) gen(labmonth)
drop month
ren labmonth month
export delimited using "hunger_month_y1_hh.csv", nolabel replace

preserve
gen n_hunger = hunger!=.
collapse (sum) n_hunger (mean) hunger, by(ea_id month year)
gen month2 = ""

replace month2 = "01 - Jan" if month==1
replace month2 = "02 - Feb" if month==2
replace month2 = "03 - Mar" if month==3
replace month2 = "04 - Apr" if month==4
replace month2 = "05 - May" if month==5
replace month2 = "06 - Jun" if month==6
replace month2 = "07 - Jul" if month==7
replace month2 = "08 - Aug" if month==8
replace month2 = "09 - Sep" if month==9 
replace month2 = "10 - Oct" if month==10
replace month2 = "11 - Nov" if month==11
replace month2 = "12 - Dec" if month==12
drop month
ren month2 month
drop if n_hunger < 8
export delimited using "hunger_month_y1_ea.csv", nolabel replace
restore

**************************************
** WAVE 2 
**************************************

use "Malawi IHS Wave 2/Raw DTA Files/HouseholdGeovariables_IHPS_13.dta", clear //615 obs dropped
keep y2_hhid LAT_DD_MOD LON_DD_MOD distY1Y2
recode distY1Y2 (.=0)
keep if distY1Y2 <= 10 
keep y2_hhid
tempfile y2_panel_filt
save `y2_panel_filt'

use "Malawi IHS Wave 2\Raw DTA files\HH_MOD_A_FILT_13.dta", clear
merge 1:1 y2_hhid using "Malawi IHS Wave 2\Raw DTA files\HH_MOD_H_13.dta", nogen
merge 1:1 y2_hhid using `y2_panel_filt', nogen keep(3)
ren y2_hhid hhid
gen int_month = hh_a23a_2 
replace int_month = hh_a37a_2 if qx_type==2
gen int_year = 2013 //For all relevant interviews

gen apr_2012 = hh_h05a == "X" if int_month < 5
gen may_2012 = hh_h05b == "X" if int_month < 6
gen jun_2012 = hh_h05c == "X" if int_month < 7
gen jul_2012 = hh_h05d == "X" if int_month < 8
gen aug_2012 = hh_h05e == "X" if int_month < 9
gen sep_2012 = hh_h05f == "X" if int_month < 10
gen oct_2012 = hh_h05g == "X" if int_month < 11
gen nov_2012 = hh_h05h == "X" 
gen dec_2012 = hh_h05i == "X"
gen jan_2013 = hh_h05j == "X"
gen feb_2013 = hh_h05k == "X"
gen mar_2013 = hh_h05l == "X"
gen apr_2013 = hh_h05m == "X" if int_month > 4
gen may_2013 = hh_h05n == "X" if int_month > 5
gen jun_2013 = hh_h05o == "X" if int_month > 6
gen jul_2013 = hh_h05p == "X" if int_month > 7
gen aug_2013 = hh_h05q == "X" if int_month > 8
gen sep_2013 = hh_h05r == "X" if int_month > 9
gen oct_2013 = hh_h05s == "X" if int_month > 10

ren *_2012 hunger2012*
ren *_2013 hunger2013*
 
keep ea_id hhid hunger*
reshape long hunger2012 hunger2013, i(hhid) j(month) string
reshape long hunger, i(hhid month) j(year)
tempfile hh_hunger_y2
save `hh_hunger_y2'
//la def months 1 "may" 2 "jun" 3 "jul" 4 "aug" 5 "sep" 6 "oct" 7 "nov" 8 "dec" 9 "jan" 10 "feb" 11 "mar" 12 "apr"
la def months 1 "jan" 2 "feb" 3 "mar" 4 "apr" 5 "may" 6 "jun" 7 "jul" 8 "aug" 9 "sep" 10 "oct" 11 "nov" 12 "dec"
encode month, l(months) gen(labmonth)
drop month
ren labmonth month

export delimited using "hunger_month_y2_hh.csv", nolabel replace
gen n_hunger = hunger!=.
collapse (sum) n_hunger (mean) hunger, by(ea_id month year)
gen month2 = ""

replace month2 = "01 - Jan" if month==1
replace month2 = "02 - Feb" if month==2
replace month2 = "03 - Mar" if month==3
replace month2 = "04 - Apr" if month==4
replace month2 = "05 - May" if month==5
replace month2 = "06 - Jun" if month==6
replace month2 = "07 - Jul" if month==7
replace month2 = "08 - Aug" if month==8
replace month2 = "09 - Sep" if month==9 
replace month2 = "10 - Oct" if month==10
replace month2 = "11 - Nov" if month==11
replace month2 = "12 - Dec" if month==12
drop month
ren month2 month
drop if n_hunger < 8
export delimited using "hunger_month_y2_ea.csv", nolabel replace


***********************************
*** WAVE 3
**********************************

use "Malawi IHS Wave 3/Raw DTA Files/IHPS/HouseholdGeovariablesIHPSY3.dta", clear //540 obs dropped
keep y3_hhid distY1Y3 
recode distY1Y3 (.=0)
keep if distY1Y3 <= 10 
keep y3_hhid 
tempfile y3_panel_filt
save `y3_panel_filt'

use  "Malawi IHS Wave 3\Raw DTA files\IHPS\hh_meta_16.dta", clear 
drop if moduleH_start_date==""
duplicates tag y3_hhid, g(dupes)
drop if dupes > 0
merge 1:1 y3_hhid using "Malawi IHS Wave 3\Raw DTA files\IHPS\hh_mod_h_16.dta", nogen keep(3)
merge 1:1 y3_hhid using "Malawi IHS Wave 3\Raw DTA files\IHPS\hh_mod_a_filt_16.dta", nogen keep(3)
merge 1:1 y3_hhid using `y3_panel_filt', nogen keep(3)
ren y3_hhid hhid 
tempfile y3_panel
save `y3_panel'

use  "Malawi IHS Wave 3\Raw DTA files\IHS\hh_metadata.dta", clear 
drop if moduleH_start_date==""
merge 1:1 case_id using  "Malawi IHS Wave 3\Raw DTA files\IHS\HH_MOD_H.dta", nogen keep(3)
merge 1:1 case_id using "Malawi IHS Wave 3\Raw DTA files\IHS\hh_mod_a_filt.dta", nogen keep(3)
//ren HHID hhid
drop hhid
ren case_id hhid
append using `y3_panel'

gen int_month_s = substr(moduleH_start_date, 6, 2)
gen int_month = real(int_month_s)
gen int_year_s = substr(moduleH_start_date, 1, 4)
gen int_year = real(int_year)

foreach let in a b c d e f g h i j k l m n o p q r s t u v w x y {
 replace hh_h05`let' = "" if hh_h04 == 2
}


gen apr_2015 = hh_h05a == "X" if int_month < 5 & int_year < 2017
gen may_2015 = hh_h05b == "X" if int_month < 6 & int_year < 2017
gen jun_2015 = hh_h05c == "X" if int_month < 7 & int_year < 2017
gen jul_2015 = hh_h05d == "X" if int_month < 8 & int_year < 2017
gen aug_2015 = hh_h05e == "X" if int_month < 9 & int_year < 2017
gen sep_2015 = hh_h05f == "X" if int_month < 10 & int_year < 2017
gen oct_2015 = hh_h05g == "X" if int_month < 11 & int_year < 2017
gen nov_2015 = hh_h05h == "X" if int_month < 12 & int_year < 2017
gen dec_2015 = hh_h05i == "X" if int_year < 2017
gen jan_2016 = hh_h05j == "X" if int_year < 2017 | int_month < 2
gen feb_2016 = hh_h05k == "X" if int_year < 2017 | int_month < 3
gen mar_2016 = hh_h05l == "X" if (int_month >  3 & int_year==2016) | (int_month < 4 & int_year==2017)
gen apr_2016 = hh_h05m == "X" if (int_month >  4 & int_year==2016) | (int_month < 5 & int_year==2017)
gen may_2016 = hh_h05n == "X" if int_month >  5 | int_year == 2017
gen jun_2016 = hh_h05o == "X" if int_month >  6 | int_year == 2017
gen jul_2016 = hh_h05p == "X" if int_month >  7 | int_year == 2017
gen aug_2016 = hh_h05q == "X" if int_month >  8 | int_year == 2017
gen sep_2016 = hh_h05r == "X" if int_month >  9 | int_year == 2017
gen oct_2016 = hh_h05s == "X" if int_month >  10 | int_year == 2017
gen nov_2016 = hh_h05t == "X" if int_month > 11 | int_year == 2017
gen dec_2016 = hh_h05u == "X" if int_year == 2017
gen jan_2017 = hh_h05v == "X" if int_month > 1 & int_year == 2017
gen feb_2017 = hh_h05w == "X" if int_month > 2 & int_year == 2017
gen mar_2017 = hh_h05x == "X" if int_month > 3 & int_year == 2017
gen apr_2017 = hh_h05y == "X" if int_month > 4 & int_year == 2017

ren *_2015 hunger2015*
ren *_2016 hunger2016*
ren *_2017 hunger2017*

keep ea_id hhid hunger*
drop *panelweight
reshape long hunger2015 hunger2016 hunger2017, i(hhid) j(month) string
reshape long hunger, i(hhid month) j(year)
tempfile hh_hunger_y3
save `hh_hunger_y3'

la def months 1 "jan" 2 "feb" 3 "mar" 4 "apr" 5 "may" 6 "jun" 7 "jul" 8 "aug" 9 "sep" 10 "oct" 11 "nov" 12 "dec"
encode month, l(months) gen(labmonth)
drop month
ren labmonth month
export delimited using "hunger_month_y3_hh_2.csv", nolabel replace
preserve
gen n_hunger = hunger!=.
collapse (sum) n_hunger (mean) hunger, by(ea_id month year)
gen month2 = ""

replace month2 = "01 - Jan" if month==1
replace month2 = "02 - Feb" if month==2
replace month2 = "03 - Mar" if month==3
replace month2 = "04 - Apr" if month==4
replace month2 = "05 - May" if month==5
replace month2 = "06 - Jun" if month==6
replace month2 = "07 - Jul" if month==7
replace month2 = "08 - Aug" if month==8
replace month2 = "09 - Sep" if month==9 
replace month2 = "10 - Oct" if month==10
replace month2 = "11 - Nov" if month==11
replace month2 = "12 - Dec" if month==12
drop month
ren month2 month
drop if n_hunger == 0
export delimited using "hunger_month_y3_ea_2.csv", nolabel replace
restore

*******************************
* WAVE 4
*******************************


use "Malawi IHS Wave 4/Raw DTA Files/IHPS/householdgeovariables_y4.dta", clear //821 obs dropped
keep y4_hhid d_ihs3
recode d_ihs3 (.=0)
keep if d_ihs3 <= 10
keep y4_hhid 
tempfile y4_panel_filt
save `y4_panel_filt'


use "Malawi IHS Wave 4/Raw DTA Files/IHPS/HH_MOD_H_19.dta", clear
merge 1:1 y4_hhid using "Malawi IHS Wave 4/Raw DTA Files/IHPS/HH_meta_19.dta", nogen keep(3)
merge 1:1 y4_hhid using "Malawi IHS Wave 4/Raw DTA Files/IHPS/hh_mod_a_filt_19.dta", nogen keep(3)
merge 1:1 y4_hhid using `y4_panel_filt', nogen keep(3)
drop panelweight*
ren y4_hhid hhid
tempfile y4_panel 
save `y4_panel'

use "Malawi IHS Wave 4/Raw DTA Files/IHS/HH_MOD_H.dta", clear
merge 1:1 HHID using "Malawi IHS Wave 4/Raw DTA Files/IHS/HH_MOD_META.dta", nogen keep(3)
merge 1:1 HHID using "Malawi IHS Wave 4/Raw DTA Files/IHS/hh_mod_a_filt.dta", nogen keep(3)
ren HHID hhid
append using `y4_panel'


gen int_month_s = substr(moduleH_start_date, 6, 2)
gen int_month = real(int_month_s)
gen int_year_s = substr(moduleH_start_date, 1, 4)
gen int_year = real(int_year)

foreach let in a b c d e f g h i j k l m n o p q r s t u v w x y {
 replace hh_h05`let' = "" if hh_h04 == 2
}

gen apr_2018 = hh_h05a == "X" if int_month < 5 & int_year < 2020
gen may_2018 = hh_h05b == "X" if int_month < 6 & int_year < 2020
gen jun_2018 = hh_h05c == "X" if int_month < 7 & int_year < 2020
gen jul_2018 = hh_h05d == "X" if int_month < 8 & int_year < 2020
gen aug_2018 = hh_h05e == "X" if int_month < 9 & int_year < 2020
gen sep_2018 = hh_h05f == "X" if int_month < 10 & int_year < 2020
gen oct_2018 = hh_h05g == "X" if int_month < 11 & int_year < 2020
gen nov_2018 = hh_h05h == "X" if int_month < 12 & int_year < 2020 //A few in 2020 but those seem like mistakes.
gen dec_2018 = hh_h05i == "X" if int_year < 2020
gen jan_2019 = hh_h05j == "X" if int_year < 2020 | int_month < 2  //2019 interviews don't start until april.
gen feb_2019 = hh_h05k == "X" if int_year < 2020 | (int_month < 3 & int_year==2020)
gen mar_2019 = hh_h05l == "X" if int_year < 2020 | (int_month < 4 & int_year==2020)
gen apr_2019 = hh_h05m == "X" if int_month > 4 | int_year == 2020
gen may_2019 = hh_h05n == "X" if int_month > 5  | int_year == 2020
gen jun_2019 = hh_h05o == "X" if int_month > 6  | int_year == 2020
gen jul_2019 = hh_h05p == "X" if int_month > 7 | int_year == 2020
gen aug_2019 = hh_h05q == "X" if int_month > 8 | int_year == 2020
gen sep_2019 = hh_h05r == "X" if int_month > 9 | int_year == 2020
gen oct_2019 = hh_h05s == "X" if int_month > 10 | int_year == 2020
gen nov_2019 = hh_h05t == "X" if int_month > 11 | int_year == 2020
gen dec_2019 = hh_h05u == "X" if int_year == 2020
gen jan_2020 = hh_h05v == "X" if int_month > 1 & int_year==2020
gen feb_2020 = hh_h05w == "X" if int_month > 2 & int_year == 2020
gen mar_2020 = hh_h05x == "X" if int_month > 3 & int_year == 2020

ren *_2018 hunger2018*
ren *_2019 hunger2019*
ren *_2020 hunger2020*
keep ea_id hhid hunger*
reshape long hunger2018 hunger2019 hunger2020, i(hhid) j(month) string
reshape long hunger, i(hhid month) j(year)
tempfile hh_hunger_y4
save `hh_hunger_y4'
//la def months 1 "may" 2 "jun" 3 "jul" 4 "aug" 5 "sep" 6 "oct" 7 "nov" 8 "dec" 9 "jan" 10 "feb" 11 "mar" 12 "apr"
la def months 1 "jan" 2 "feb" 3 "mar" 4 "apr" 5 "may" 6 "jun" 7 "jul" 8 "aug" 9 "sep" 10 "oct" 11 "nov" 12 "dec"
encode month, l(months) gen(labmonth)
drop month
ren labmonth month
//replace year = year-1 if month > 8
export delimited using "hunger_month_y4_hh_2.csv", nolabel replace
preserve
gen n_hunger = hunger!=.
collapse (sum) n_hunger (mean) hunger, by(ea_id month year)
gen month2 = ""
replace month2 = "01 - Jan" if month==1
replace month2 = "02 - Feb" if month==2
replace month2 = "03 - Mar" if month==3
replace month2 = "04 - Apr" if month==4
replace month2 = "05 - May" if month==5
replace month2 = "06 - Jun" if month==6
replace month2 = "07 - Jul" if month==7
replace month2 = "08 - Aug" if month==8
replace month2 = "09 - Sep" if month==9 
replace month2 = "10 - Oct" if month==10
replace month2 = "11 - Nov" if month==11
replace month2 = "12 - Dec" if month==12
drop month
ren month2 month
drop if n_hunger < 8
export delimited using "hunger_month_y4_ea_2.csv", nolabel replace
restore

use `hh_hunger_y1'
gen wave = 1
append using `hh_hunger_y2'
replace wave = 2 if wave == .
append using `hh_hunger_y3'
replace wave = 3 if wave == .
append using `hh_hunger_y4'
replace wave = 4 if wave == .
drop if hunger == .
export delimited using  "hunger_for_sumstats.csv", nolabel replace

collapse (sum) n_hunger=hunger (count) n_obs=hunger, by(ea_id month year wave)
gen any_hunger = n_hunger > 1 
gen prop_hunger=n_hunger/n_obs
drop if n_obs < 8
tostring ea_id, replace force
merge m:1 ea_id using "ea_rururb.dta", nogen keep(3)
merge m:1 ea_id using "panel_eas.dta", nogen keep(3)
export delimited using  "ea_hunger_for_sumstats.csv", nolabel replace


gen cat = 0 if prop_hunger==0
replace cat=1 if prop_hunger > 0
replace cat=2 if prop_hunger >= 0.125
replace cat=3 if prop_hunger >= 0.25 
replace cat=4 if prop_hunger > 0.4375 
merge m:1 ea_id using "ea_geocoords.dta", nogen
drop if lat==0 | lon==0 | lat==. | lon==. | cat==.
export delimited using "hunger_long_extr.csv", replace


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*RCSI Weights
1. Less preferred - 1
2. Limit portions - 1
3. Reduce meals - 1
4. Restrict adult consumption - 3
5. Borrow or rely on help - 2

*/
//RCSI
//From EPAR LSMS-ISA Code
use "Malawi_IHS_W1_food_insecurity.dta", clear
gen wave=1
append using "Malawi_IHPS_W2_food_insecurity.dta"
replace wave=2 if wave==.
append using "Malawi_IHS_IHPS_W3_food_insecurity.dta"
replace wave=3 if wave==. 
append using "Malawi_IHS_IHPS_W4_food_insecurity.dta"
replace wave=4 if wave==.
drop if rcsi_Rasch > 12 
//gen rasch_norm = rcsi_Rasch/12
//gen fews_norm = rcsi_FEWS/89
//gen lentz_norm = rcsi_6ques/37
//keep ea_id hhid rasch_norm fews_norm lentz_norm rcsi_FEWS rcsi_6ques rcsi_Rasch months_food_insec int_month int_year
gen rcsi_Fbins = 0
replace rcsi_Fbins=1 if rcsi_FEWS > 3 & rcsi_FEWS < 19
replace rcsi_Fbins=2 if rcsi_FEWS > 18
gen rcsi_Bin0 = rcsi_Fbins==0
gen rcsi_Bin1 = rcsi_Fbins==1
gen rcsi_Bin2 = rcsi_Fbins==2
gen obs=1
collapse (mean) rcsi_Fbins rcsi_Bin* rcsi_FEWS (sum) obs, by(ea_id wave int_month int_year)
drop if obs < 8
gen rcsi_EAbin1 = 0
replace rcsi_EAbin1 = 1 if rcsi_FEWS > 3 & rcsi_FEWS < 19 //bin1 = based on EA average 
replace rcsi_EAbin1 = 2 if rcsi_FEWS > 18
gen rcsi_EAbin2 = rcsi_Bin1 >= 0.2
replace rcsi_EAbin2 = 2 if rcsi_Bin2 >= 0.2

ren rcsi_EAbin1 rcsi_EAlevel
ren rcsi_EAbin2 rcsi_HHlevel 
ren rcsi_FEWS rcsi_EAavgscore
keep ea_id wave rcsi_EAlevel rcsi_HHlevel rcsi_EAavgscore int_month int_year
export delimited using "rcsi.csv", replace
