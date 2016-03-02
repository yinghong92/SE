use new, replace
gen oc=1
//managerial, and professional

//TECHNICAL, SALES, AND ADMINISTRATIVE SUPPORT OCCUPATIONS
replace oc=2 if occ1990>=203

//SERVICE OCCUPATIONS
replace oc=3 if occ1990>=405

//FARMING, FORESTRY, AND FISHING OCCUPATIONS
replace oc=4 if occ1990>=473
//OPERATORS, FABRICATORS, AND LABORERS	
replace oc=5 if occ1990>=703
//military
replace oc=6 if occ1990>=905
//unemp
replace oc=0 if occ1990>=991
label define oc 1 "managerial, and prof" 2 "Tech, sales and admin." 3 "service" ///
4 "farming, forestry, fishing"  5 "operators,laborers"  6 "military", replace
label values oc oc

save new, replace
use new, replace
collapse (mean) SENI  [pweight=wtsupp], by(year oc edu_att)
label var SENI "ratio of SENI"
save SENI, replace

use new, replace
collapse (mean) SEI  [pweight=wtsupp], by(year oc edu_att)
label var SEI "ratio of SEI"
save SEI, replace
mer 1:1 _n using SENI
  drop _merge
//graph
save SEI_SENI, replace


local i =1
while `i'<=6{
 twoway (lfitci SEI year) (lfitci SENI year) (scatter SEI year)(scatter SENI year)  if oc==`i', by(edu_att oc) 
 graph  export  oc_sei`i'.png, replace
 local i=`i'+1
}
/*--======================================by occ======================================*/

/*--------------------------------physician----------------------------------------------*/
mean SEI if occ1990==84
mean SENI if occ1990==84
  twoway  (scatter SEI year)(scatter SENI year)  if occ1990==84, by(edu_att year) 
 //edu==3 97.95%
use SEI_physician, replace
 twoway (lfitci SEI year) (line SEI year) if edu_att==3
 graph  export  SEI_physician.png, replace
/*-----------------------------Laywer-------------------------------------------------*/


/*--===================by ind1990-===================-*/

/*-----------------------------------insurance-----------------------------------------*/
use retail_2014.dta, replace
ren SENI SENI_2014
merge 1:m ind1990 edu_att using retail_1994
drop _merge
gen D_NI=SENI_2014-SENI
la var D_NI "Retail_SENI ratio change"
save ...
reg D_NI i.ind i.edu_a
/*------=================== which occ/ind change more in SE ===================---------*/
use new, replace
drop if lab==1
keep if year ==1994
collapse (mean) SENI  [pweight=wtsupp], by(occ1990 ind1990 edu_att)
label var SENI "ratio of SENI"
drop if SENI==0
save SENI_1994, replace

use new, replace
drop if lab==1
keep if year ==2014
collapse (mean) SENI  [pweight=wtsupp], by(occ1990 ind1990 edu_att)
label var SENI "ratio of SENI"
ren SENI SENI_2014
drop if SENI==0
save SENI_2014, replace
merge 1:m occ1990 ind1990 edu_a using SENI_1994
drop if SENI==.
drop _merge
gen D=SENI_2014-SENI

gen oc=1
//managerial, and professional

//TECHNICAL, SALES, AND ADMINISTRATIVE SUPPORT OCCUPATIONS
replace oc=2 if occ1990>=203

//SERVICE OCCUPATIONS
replace oc=3 if occ1990>=405

//FARMING, FORESTRY, AND FISHING OCCUPATIONS
replace oc=4 if occ1990>=473
//OPERATORS, FABRICATORS, AND LABORERS	
replace oc=5 if occ1990>=703
//military
replace oc=6 if occ1990>=905
//unemp
replace oc=0 if occ1990>=991
label define oc 1 "managerial, and prof" 2 "Tech, sales and admin." 3 "service" ///
4 "farming, forestry, fishing"  5 "operators,laborers"  6 "military", replace
label values oc oc
/*------------------------------------------------------------------------------*/

//agriculture
gen ind=0  if ind1990<=032  
//mining
replace ind=1 if ind1990>032  
 //construction
replace ind=2 if ind1990>050 
//manufacturing
replace ind=3 if ind1990>060
//transportation, communications and other public utilities
replace ind=4 if ind1990>392
//wholesale trade
replace ind=5 if ind1990>472
//retail trade
replace ind=6 if ind1990>571 
//FINANCE, INSURANCE, AND REAL ESTATE
replace ind=7 if ind1990>691 
//BUSINESS AND  service
replace ind=8 if ind1990>712 
//PROFESSIONAL AND RELATED SERVICES	
replace ind=9 if ind1990>810
//PUBLIC ADMINISTRATION	
replace ind=10 if ind1990>893
//ACTIVE DUTY MILITARY	
replace ind=11  if ind1990>932

label define industry 0 "agriculture" 1 "mining" 2 "construction" 3 "manufacturing" ///
4 "TCP"  5 "wholesale trade"  6 "retail trade" ///
7 "FIRE" 8"Business, Services" 9 "professional and related" 10 "public administration" 11 "military", replace
label values ind industry
//4. transportation, communications, public utilities
drop if ind==1 | ind==0
gen D_abs=abs(D)
save SENI_mer, replace
drop if D_abs<0.01

/*------------------------------------------------------------------------------*/
use new, replace
drop if lab==1
keep if year ==1994
collapse (count) SENI  [pweight=wtsupp], by(occ1990 ind1990 edu_att)
label var SENI "no. of SENI"
drop if SENI==0
save SENI_count, replace
drop if SENI<5000

mer 1:m occ1990 ind1990 edu_a  using SENI_mer
drop if D==.
drop if SENI_2014==1
drop if ind==2  //construction


save mer, replace


//






