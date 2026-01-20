* Do file for the replication of the results in 
* "Attack When the World Is Not Watching? US News and the Israeli-Palestinian Conflict"
* by Ruben Durante and Ekaterina Zhuravskaya
* Accepted for Publication in the Journal of Political Economy (Chicago University Press)

* Replication main tables and figures, as well as online appendix tables and figures

* The do file refers to the following three directories:

* dta: includes data files
* tab: includes output tables
* fig: includes output figures

************************************************************************************************************
set more off

* Define main directory
global main="~/Dropbox/Master do file Isr_Pal/replication/"

* Define data directory
global dta="$main/dta/"

* Define tables directory
global tables="$main/tables/"

* Define figures directory
global figures="$main/figures/"

*********************************************************************************************************
												*** MAIN TABLES	***
*********************************************************************************************************

************************************************************************
** Table 1. News Pressure and the Length of Conflict-related News
************************************************************************

use "$dta/replication_file1.dta", clear

* Panel A: Full sample

cap drop sample_deriv
xi: ivreg daily_woi (length_conflict_news=high_intensity) i.month i.year i.dow, cluster (monthyear)
gen sample_deriv=1 if e(sample)

reg length_conflict_news high_intensity i.month i.year i.dow  if sample_deriv==1 , vce(cluster monthyear)
test  high_intensity
test  high_intensity
scalar F_cont=r(F)
outreg2 using "$tables/table_1a.xls", replace ctitle("Length conflict news, 1st stage") keep(high_intensity) nocons label bdec(3) addstat ("F excl. instr.", F_cont)

xi: ivreg daily_woi (length_conflict_news = high_intensity) i.month i.year i.dow  , cluster (monthyear)
outreg2 using "$tables/table_1a.xls", append ctitle("NP, 2SLS") keep(length_conflict_news) nocons label bdec(3) addstat ("F excl. instr.", F_cont)

xi: ivreg daily_woi_nc (length_conflict_news = high_intensity) i.month i.year i.dow , cluster (monthyear)
outreg2 using "$tables/table_1a.xls", append ctitle("Uncorr NP, 2SLS") keep(length_conflict_news) nocons label bdec(3) addstat ("F excl. instr.", F_cont)

* Panel A: Sample of days with an attack on the same day or the previous day

cap drop sample_deriv
xi: ivreg daily_woi (length_conflict_news=high_intensity) i.month i.year i.dow if  (occurrence_t_y==1 | occurrence_pal_t_y ==1), cluster (monthyear)
gen sample_deriv=1 if e(sample)

reg length_conflict_news high_intensity i.month i.year i.dow  if sample_deriv==1& (occurrence_t_y==1 | occurrence_pal_t_y ==1) , vce(cluster monthyear)
test  high_intensity
scalar F_cont=r(F)
outreg2 using "$tables/table_1b.xls", replace ctitle("Length conflict news, 1st stage") keep(high_intensity) nocons label bdec(3) addstat ("F excl. instr.", F_cont)

xi: ivreg daily_woi (length_conflict_news = high_intensity) i.month i.year i.dow if  (occurrence_t_y==1 | occurrence_pal_t_y ==1) , cluster (monthyear)
outreg2 using "$tables/table_1b.xls", append ctitle("NP, 2SLS") keep(length_conflict_news) nocons label bdec(5) addstat ("F excl. instr.", F_cont) dec(3)

xi: ivreg daily_woi_nc (length_conflict_news = high_intensity) i.month i.year i.dow if  (occurrence_t_y==1 | occurrence_pal_t_y ==1), cluster (monthyear)
outreg2 using "$tables/table_1b.xls", append ctitle("Uncorr NP, 2SLS") keep(length_conflict_news) nocons label bdec(3) addstat ("F excl. instr.", F_cont)

************************************************************************
** Table 2. Coverage of Conflict, News Pressure, and Google Searches
************************************************************************

use "$dta/replication_file1.dta", clear

eststo: xi: reg any_conflict_news occurrence_t_y occurrence_pal_t_y i.month i.year i.dow , cluster(monthyear)
outreg2 using "$tables/table_2.xls", replace ctitle("Isr-Pal on news") keep(occurrence_t_y occurrence_pal_t_y) nocons label bdec(3)

eststo: xi: nbreg length_conflict_news occurrence_t_y occurrence_pal_t_y i.month i.year i.dow , vce(cluster monthyear)
outreg2 using "$tables/table_2.xls", append ctitle("Time to Isr-Pal news") keep(occurrence_t_y occurrence_pal_t_y) nocons label bdec(3)

eststo: xi: reg any_conflict_news lnvic_t_y lnvic_pal_y daily_woi i.month i.year i.dow if  (occurrence_t_y==1 | occurrence_pal_t_y ==1), cluster(monthyear)
outreg2 using "$tables/table_2.xls", append ctitle("Isr-Pal on news") keep(lnvic_t_y lnvic_pal_y daily_woi) nocons label bdec(3)

eststo: xi: nbreg length_conflict_news lnvic_t_y lnvic_pal_y daily_woi i.month i.year i.dow if  (occurrence_t_y==1 | occurrence_pal_t_y ==1), vce(cluster monthyear)
outreg2 using "$tables/table_2.xls", append ctitle("Time to Isr-Pal news") keep(lnvic_t_y lnvic_pal_y daily_woi) nocons label bdec(3)

xi: newey conflict_searches lnvic_t_y lnvic_pal_y monthyear i.month i.year i.dow  if length_conflict_news_t_t_1!=., lag(7) force
outreg2 using "$tables/table_2.xls", append stats(coef se) keep(lnvic_t_y lnvic_pal_y) nocons label bdec(3)

xi: newey conflict_searches lnvic_t_y lnvic_pal_y length_conflict_news_t_t_1  monthyear i.month i.year i.dow  , lag(7) force
outreg2 using "$tables/table_2.xls", append stats(coef se) keep(lnvic_t_y lnvic_pal_y length_conflict_news_t_t_1) nocons label bdec(3) sdec(3)

* Corresponding OLS regressions estimated below to display R-squared
eststo: xi: reg conflict_searches lnvic_t_y lnvic_pal_y monthyear i.month i.year i.dow if length_conflict_news_t_t_1!=., vce(cluster monthyear)
eststo: xi: reg conflict_searches lnvic_t_y lnvic_pal_y length_conflict_news_t_t_1 monthyear i.month i.year i.dow , vce(cluster monthyear)
esttab, se pr2 r2 star(* 0.1 ** 0.05 *** 0.01)

*************************************************************************
** Table 3. Israeli Attacks and News Pressure
************************************************************************

use "$dta/replication_file1.dta", clear

* Panel A: News Pressure

sort date

xi: reg occurrence daily_woi i.month i.year i.dow if gaza_war==0, cluster(monthyear)
outreg2 using "$tables/table_3a.xls", replace ctitle("Occurrence") keep(daily_woi) nocons label bdec(3)

xi: newey occurrence daily_woi leaddaily_woi i.month i.year i.dow if gaza_war==0, lag(7) force
outreg2 using  "$tables/table_3a.xls", append ctitle("Occurrence") keep(daily_woi leaddaily_woi lagdaily_woi occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14) nocons label bdec(3)

xi: newey occurrence daily_woi leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, lag(7) force
outreg2 using  "$tables/table_3a.xls", append ctitle("Occurrence") keep(daily_woi leaddaily_woi lagdaily_woi occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14) nocons label bdec(3)
 
xi: reg lnvic daily_woi i.month i.year i.dow if gaza_war==0, cluster(monthyear)
outreg2 using  "$tables/table_3a.xls", append ctitle("Ln(victims)") keep(daily_woi) nocons label bdec(3)

xi: newey lnvic daily_woi leaddaily_woi  i.month i.year i.dow if gaza_war==0,lag(7) force 
outreg2 using  "$tables/table_3a.xls", append ctitle("Ln(victims)") keep(daily_woi leaddaily_woi) nocons label bdec(3)

xi: newey lnvic daily_woi leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, lag(7) force 
outreg2 using  "$tables/table_3a.xls", append ctitle("Ln(victims)") keep(daily_woi leaddaily_woi lagdaily_woi occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14) nocons label bdec(3)

xi: glm victims_isr daily_woi leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, family(nbinom ml) vce(hac nwest 7)
outreg2 using  "$tables/table_3a.xls", append ctitle("Num. victims") keep(daily_woi leaddaily_woi lagdaily_woi occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14) nocons label bdec(3)

* Corresponding OLS regressions estimated below to display (pseudo) R-squared
eststo clear
eststo: xi: reg occurrence daily_woi i.month i.year i.dow if gaza_war==0 , cluster(monthyear)
eststo: xi: reg occurrence daily_woi leaddaily_woi i.month i.year i.dow if gaza_war==0, cluster(monthyear)
eststo: xi: reg occurrence daily_woi leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, cluster(monthyear)
eststo: xi: reg lnvic daily_woi i.month i.year i.dow if gaza_war==0, cluster(monthyear)
eststo: xi: reg lnvic daily_woi leaddaily_woi i.month i.year i.dow if gaza_war==0, cluster(monthyear)
eststo: xi: reg lnvic daily_woi leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, cluster(monthyear) 
eststo: nbreg victims_isr daily_woi leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, vce(cluster monthyear)
esttab, se r2 pr2 star(* 0.10 ** 0.05 *** 0.01)

* Panel B: Uncorrected news pressure

sort date

xi: reg occurrence daily_woi_nc i.month i.year i.dow if gaza_war==0, cluster(monthyear)
outreg2 using  "$tables/table_3b.xls", replace ctitle("Occurrence") keep(daily_woi_nc) nocons label bdec(3)

xi: newey occurrence daily_woi_nc leaddaily_woi_nc  i.month i.year i.dow if gaza_war==0, lag(7) force
outreg2 using  "$tables/table_3b.xls", append ctitle("Occurrence") keep(daily_woi_nc leaddaily_woi_nc lagdaily_woi_nc occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14) nocons label bdec(3)

xi: newey occurrence daily_woi_nc leaddaily_woi_nc lagdaily_woi_nc-lagdaily_woi7_nc occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, lag(7) force
outreg2 using "$tables/table_3b.xls", append ctitle("Occurrence") keep(daily_woi_nc leaddaily_woi_nc lagdaily_woi_nc occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14) nocons label bdec(3)

xi: reg lnvic daily_woi_nc i.month i.year i.dow if gaza_war==0, cluster(monthyear)
outreg2 using "$tables/table_3b.xls", append ctitle("Ln(victims)") keep(daily_woi_nc) nocons label bdec(3)

xi: newey lnvic daily_woi_nc leaddaily_woi_nc i.month i.year i.dow if gaza_war==0,lag(7) force 
outreg2 using "$tables/table_3b.xls", append ctitle("Ln(victims)") keep(daily_woi_nc leaddaily_woi_nc lagdaily_woi_nc occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14) nocons label bdec(3)

xi: newey lnvic daily_woi_nc leaddaily_woi_nc lagdaily_woi_nc-lagdaily_woi7_nc occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, lag(7) force 
outreg2 using "$tables/table_3b.xls", append ctitle("Ln(victims)") keep(daily_woi_nc leaddaily_woi_nc lagdaily_woi_nc occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14) nocons label bdec(3)

xi: glm victims_isr daily_woi_nc leaddaily_woi_nc lagdaily_woi_nc-lagdaily_woi7_nc occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, family(nbinom ml) vce(hac nwest 7)
outreg2 using "$tables/table_3b.xls", append ctitle("Num. victims") keep(daily_woi_nc leaddaily_woi_nc lagdaily_woi_nc occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14) nocons label bdec(3)

* Corresponding OLS regressions estimated below to display (pseudo) R-squared
eststo clear
eststo: xi: reg occurrence daily_woi_nc i.month i.year i.dow if gaza_war==0, cluster(monthyear)
eststo: xi: reg occurrence daily_woi_nc leaddaily_woi_nc i.month i.year i.dow if gaza_war==0, cluster(monthyear)
eststo: xi: reg occurrence daily_woi_nc leaddaily_woi_nc lagdaily_woi_nc-lagdaily_woi7_nc occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, cluster(monthyear)
eststo: xi: reg lnvic daily_woi_nc i.month i.year i.dow if gaza_war==0, cluster(monthyear)
eststo: xi: reg lnvic daily_woi_nc leaddaily_woi_nc i.month i.year i.dow if gaza_war==0, cluster(monthyear)
eststo: xi: reg lnvic daily_woi_nc leaddaily_woi_nc lagdaily_woi_nc-lagdaily_woi7_nc occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, cluster(monthyear)
eststo: nbreg victims_isr daily_woi_nc leaddaily_woi_nc lagdaily_woi_nc-lagdaily_woi7_nc occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, cluster(monthyear)
esttab, se r2 pr2 star(* 0.10 ** 0.05 *** 0.01) compress

*************************************************************************
** Table 4. Palestinian Attacks and News Pressure
************************************************************************

use "$dta/replication_file1.dta", clear
sort date

xi: reg occurrence_pal daily_woi i.month i.year i.dow if gaza_war==0, cluster(monthyear)
outreg2 using "$tables/table_4.xls", replace ctitle("Occurrence") keep(daily_woi) nocons label bdec(3)

xi: newey occurrence_pal daily_woi leaddaily_woi  i.month i.year i.dow if gaza_war==0, lag(7) force
outreg2 using "$tables/table_4.xls", append ctitle("Occurrence") keep(daily_woi leaddaily_woi lagdaily_woi occurrence_1 occurrence_2_7 occurrence_8_14) nocons label bdec(3)

xi: newey occurrence_pal daily_woi leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_1 occurrence_2_7 occurrence_8_14 i.month i.year i.dow if gaza_war==0, lag(7) force
outreg2 using "$tables/table_4.xls", append ctitle("Occurrence") keep(daily_woi leaddaily_woi  lagdaily_woi occurrence_1 occurrence_2_7 occurrence_8_14) nocons label bdec(3)

xi: reg lnvic_pal daily_woi i.month i.year i.dow if gaza_war==0, cluster(monthyear)
outreg2 using "$tables/table_4.xls", append ctitle("Ln(victims)") keep(daily_woi) nocons label bdec(3)

xi: newey lnvic_pal daily_woi leaddaily_woi i.month i.year i.dow if gaza_war==0,lag(7) force 
outreg2 using "$tables/table_4.xls", append ctitle("Ln(victims)") keep(daily_woi leaddaily_woi  lagdaily_woi occurrence_1 occurrence_2_7 occurrence_8_14) nocons label bdec(3)

xi: newey lnvic_pal daily_woi leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_1 occurrence_2_7 occurrence_8_14 i.month i.year i.dow if gaza_war==0, lag(7) force 
outreg2 using "$tables/table_4.xls", append ctitle("Ln(victims)") keep(daily_woi leaddaily_woi  lagdaily_woi occurrence_1 occurrence_2_7 occurrence_8_14) nocons label bdec(3)

xi: glm victims_pal daily_woi leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_1 occurrence_2_7 occurrence_8_14 i.month i.year i.dow if gaza_war==0, family(nbinom ml) vce(hac nwest 7)
outreg2 using "$tables/table_4.xls", append ctitle("Num. victims") keep(daily_woi leaddaily_woi  lagdaily_woi occurrence_1 occurrence_2_7 occurrence_8_14) nocons label bdec(3)

* Corresponding OLS regressions estimated below to display (pseudo) R-squared
eststo clear
eststo: xi: reg occurrence_pal daily_woi i.month i.year i.dow if gaza_war==0, cluster(monthyear)
eststo: xi: reg occurrence_pal daily_woi leaddaily_woi i.month i.year i.dow if gaza_war==0, cluster(monthyear)
eststo: xi: reg occurrence_pal daily_woi leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_1 occurrence_2_7 occurrence_8_14 i.month i.year i.dow if gaza_war==0, cluster(monthyear)
eststo: xi: reg lnvic_pal daily_woi i.month i.year i.dow if gaza_war==0, cluster(monthyear)
eststo: xi: reg lnvic_pal daily_woi leaddaily_woi i.month i.year i.dow if gaza_war==0, cluster(monthyear)
eststo: xi: reg lnvic_pal daily_woi leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_1 occurrence_2_7 occurrence_8_14 i.month i.year i.dow if gaza_war==0, cluster(monthyear) 
eststo: xi: nbreg victims_pal daily_woi leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_1 occurrence_2_7 occurrence_8_14 i.month i.year i.dow if gaza_war==0, vce(cluster monthyear)
esttab, se r2 pr2 star(* 0.10 ** 0.05 *** 0.01)

* Seemingly unrelated regressions (SUR) to compare coefficients for Israel and Palestinian attacks

* Comparison between column 2 of table 3.A and column 2 of table 4
#delimit;
sureg 
(occurrence         daily_woi  leaddaily_woi  i.month i.year i.dow if gaza_war==0, cluster(monthyear))
(occurrence_pal daily_woi  leaddaily_woi  i.month i.year i.dow if gaza_war==0, cluster(monthyear));
#delimit cr
test [occurrence]leaddaily_woi=0
test [occurrence_pal]leaddaily_woi=0
lincom [occurrence]leaddaily_woi-[occurrence_pal]leaddaily_woi

* Comparison between column 3 of table 3.A and column 3 of table 4
#delimit;
sureg 
(occurrence         leaddaily_woi daily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, cluster(monthyear))
(occurrence_pal leaddaily_woi daily_woi lagdaily_woi-lagdaily_woi7 occurrence_1         occurrence_2_7         occurrence_8_14         i.month i.year i.dow if gaza_war==0, cluster(monthyear));
#delimit cr
test [occurrence]leaddaily_woi=0
test [occurrence_pal]leaddaily_woi=0
lincom [occurrence]leaddaily_woi-[occurrence_pal]leaddaily_woi

* Comparison between column 5 of table 3.A and column 5 of table 4
#delimit;
sureg 
(lnvic         daily_woi   leaddaily_woi   i.month i.year i.dow if gaza_war==0, cluster(monthyear))
(lnvic_pal daily_woi   leaddaily_woi   i.month i.year i.dow if gaza_war==0, cluster(monthyear));
#delimit cr
test [lnvic]leaddaily_woi=0
test [lnvic_pal]leaddaily_woi=0
lincom [lnvic]leaddaily_woi-[lnvic_pal]leaddaily_woi

* Comparison between column 6 of table 3.A and column 6 of table 4
set more off
#delimit;
sureg 
(lnvic         leaddaily_woi daily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, cluster(monthyear))
(lnvic_pal leaddaily_woi daily_woi lagdaily_woi-lagdaily_woi7 occurrence_1 occurrence_2_7 occurrence_8_14                         i.month i.year i.dow if gaza_war==0, cluster(monthyear));
#delimit cr
test [lnvic]leaddaily_woi=0
test [lnvic_pal]leaddaily_woi=0
lincom [lnvic]leaddaily_woi-[lnvic_pal]leaddaily_woi

****************************************************************************************************
** Table 5. Attacks and Next-day News Pressure Driven by Predictable Political and Sports Events
****************************************************************************************************

use "$dta/replication_file1.dta", clear
sort date

** Panel A: Israeli Attacks and Predictable Newsworthy Events

xi: reg leaddaily_woi lead_maj_events occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0 , first cluster(monthyear)
test lead_maj_events
scalar F_cont=r(F)
outreg2 using "$tables/table_5a.xls", replace ctitle("NP t+1, 1st stage") keep(lead_maj_events)  nocons label bdec(3)

xi: reg leaddaily_woi_nc lead_maj_events occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0 , first cluster(monthyear)
test lead_maj_events
scalar F_cont_unc=r(F)
outreg2 using "$tables/table_5a.xls", append ctitle("NP t+1 (uncorrected), 1st stage") keep(lead_maj_events)  nocons label bdec(3)

xi: ivreg occurrence (leaddaily_woi=lead_maj_events) occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14  i.month i.year i.dow if gaza_war==0 , first cluster(monthyear)
gen sample_iv=1 if e(sample)
outreg2 using "$tables/table_5a.xls", append ctitle("Occurrence, IV 2nd stage") keep(leaddaily_woi) addstat ("F excl. instr.", F_cont) nocons label bdec(3)

xi: ivreg occurrence (leaddaily_woi_nc=lead_maj_events) occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14  i.month i.year i.dow if gaza_war==0 , first cluster(monthyear)
outreg2 using "$tables/table_5a.xls", append ctitle("Occurrence, IV 2nd stage") keep(leaddaily_woi_nc) addstat ("F excl. instr.", F_cont_unc) nocons label bdec(3)

xi:  reg occurrence         lead_maj_events occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0 , first cluster(monthyear)
gen sample_rf=1 if e(sample)
outreg2 using "$tables/table_5a.xls", append ctitle("Occurrence, Reduced form") keep(lead_maj_events) nocons label bdec(3)

cap drop mon1-mon12 day1-day7 year1-year12
tab month, gen(mon)
tab dow, gen(day)
tab year, gen(year)

#delimit;
     qvf victims_isr
	 leaddaily_woi 
	 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14
	 mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12
	 day2 day3 day4 day5 day6 day7 
	 year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
	 (lead_maj_events 
	 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14
	 mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12
	 day2 day3 day4 day5 day6 day7 
	 year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12) 
	 if gaza_war==0, family(nbinom) robust cluster(monthyear);
#delimit cr
outreg2 using "$tables/table_5a.xls", append ctitle("Num. victims, IV 2nd stage") keep(leaddaily_woi) addstat ("F excl. instr.", F_cont) nocons label bdec(3)
	 
#delimit;
     qvf victims_isr 
	 leaddaily_woi_nc
	 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14
	 mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12
	 day2 day3 day4 day5 day6 day7 
	 year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
	 (lead_maj_events 
	 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14
	 mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12
	 day2 day3 day4 day5 day6 day7 
	 year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12) 
	 if gaza_war==0, family(nbinom) robust cluster(monthyear);
#delimit cr
outreg2 using "$tables/table_5a.xls", append ctitle("Num. victims, IV 2nd stage") keep(leaddaily_woi_nc) addstat ("F excl. instr.", F_cont_unc) nocons label bdec(3)
	 
#delimit;
     xi: glm victims_isr 
     lead_maj_events 
	 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14
	 i.month i.year i.dow if  gaza_war==0, family(nbinom ml)
	 vce(cluster monthyear);
#delimit cr
outreg2 using "$tables/table_5a.xls", append ctitle("Num. victims, Reduced form") keep(lead_maj_events) nocons label bdec(3)

* Corresponding OLS regressions estimated below to display pseudo R-squared
eststo clear
eststo: xi: nbreg victims_isr lead_maj_events occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if  gaza_war==0, vce(cluster monthyear)
esttab, se pr2 star(* 0.1 ** 0.05 *** 0.01)

** Panel B: Palestinian Attacks and Predictable Newsworthy Events

xi: reg leaddaily_woi lead_maj_events occurrence_1 occurrence_2_7 occurrence_8_14 i.year i.dow if gaza_war==0 , first cluster(monthyear)
test lead_maj_events
scalar F_cont=r(F)
outreg2 using "$tables/table_5b.xls", replace ctitle("NP t+1, 1st stage") keep(lead_maj_events) nocons label bdec(3)

xi: reg leaddaily_woi_nc lead_maj_events occurrence_1 occurrence_2_7 occurrence_8_14 i.year i.dow if gaza_war==0 , first cluster(monthyear)
test lead_maj_events
scalar F_cont_unc=r(F)
outreg2 using "$tables/table_5b.xls", append ctitle("NP t+1 (uncorrected), 1st stage") keep(lead_maj_events) nocons label bdec(3)

xi: ivreg occurrence_pal (leaddaily_woi=lead_maj_events) occurrence_1 occurrence_2_7 occurrence_8_14 i.year i.dow if gaza_war==0 , first cluster(monthyear)
outreg2 using "$tables/table_5b.xls", append ctitle("Occurrence, IV 2nd stage") keep(leaddaily_woi) addstat ("F excl. instr.", F_cont) nocons label bdec(3)

xi: ivreg occurrence_pal (leaddaily_woi_nc=lead_maj_events) occurrence_1 occurrence_2_7 occurrence_8_14 i.year i.dow if gaza_war==0 , first cluster(monthyear)
outreg2 using "$tables/table_5b.xls", append ctitle("Occurrence, IV 2nd stage") keep(leaddaily_woi_nc) addstat ("F excl. instr.", F_cont_unc) nocons label bdec(3)

xi: reg occurrence_pal lead_maj_events occurrence_1 occurrence_2_7 occurrence_8_14 i.year i.dow if gaza_war==0 , first cluster(monthyear)
outreg2 using "$tables/table_5b.xls", append ctitle("Occurrence, Reduced form") keep(lead_maj_events) nocons label bdec(3)

cap drop mon1-mon12 day1-day7 year1-year12
tab month, gen(mon)
tab dow, gen(day)
tab year, gen(year)

#delimit;
   qvf victims_pal
	 leaddaily_woi 
	 occurrence_1 occurrence_2_7 occurrence_8_14
	 day2 day3 day4 day5 day6 day7 
	 year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
	 (lead_maj_events 
	occurrence_1 occurrence_2_7 occurrence_8_14
	 day2 day3 day4 day5 day6 day7 
	 year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12) 
	 if gaza_war==0, family(nbinom) robust cluster(monthyear);
#delimit cr
outreg2 using "$tables/table_5b.xls", append ctitle("Num. victims, IV 2nd stage") keep(leaddaily_woi) addstat ("F excl. instr.", F_cont) nocons label bdec(3)
	 
#delimit;
   qvf victims_pal 
	 leaddaily_woi_nc
	 occurrence_1 occurrence_2_7 occurrence_8_14
	 day2 day3 day4 day5 day6 day7 
	 year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
	 (lead_maj_events 
	 occurrence_1 occurrence_2_7 occurrence_8_14
	 day2 day3 day4 day5 day6 day7 
	 year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12) 
	 if gaza_war==0, family(nbinom) robust cluster(monthyear);
#delimit cr
outreg2 using "$tables/table_5b.xls", append ctitle("Num. victims, IV 2nd stage") keep(leaddaily_woi_nc) addstat ("F excl. instr.", F_cont_unc) nocons label bdec(3)
	 
#delimit;
   xi: glm victims_pal 
   lead_maj_events 
	 occurrence_1 occurrence_2_7 occurrence_8_14
	 i.year i.dow if gaza_war==0, family(nbinom ml)
	 vce(cluster monthyear);
#delimit cr
outreg2 using "$tables/table_5b.xls", append ctitle("Num. victims, Reduced form") keep(lead_maj_events) nocons label bdec(3)

* Corresponding negative binomial regressions to display the pseudo R-squared
eststo clear
eststo: xi: nbreg victims_pal lead_maj_events occurrence_1 occurrence_2_7 occurrence_8_14 i.year i.dow if gaza_war==0, vce(cluster monthyear)
esttab, se pr2 star(* 0.1 ** 0.05 *** 0.01)	 
	 

* Compare relationship between main predictable events and Israeli attacks and main predictable events and Palestinian attacks

* Compare column 3 of panel a of table 5 with column 3 of panel b of table 5

cap drop mon1-mon12 day1-day7 year1-year12
tab month, gen(mon)
tab dow, gen(day)
tab year, gen(year)

preserve 
keep if sample_iv==1

#delimit;
gmm (eq1: occurrence     - {r1: leaddaily_woi occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 
									mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12 
									year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
									day2 day3 day4 day5 day6 day7} - {b0})
	(eq2: occurrence_pal - {r2: leaddaily_woi occurrence_1 occurrence_2_7 occurrence_8_14
									year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
									day2 day3 day4 day5 day6 day7} - {c0}), 
	instruments(eq1: lead_maj_events occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 
				     mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12 
					 year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
					 day2 day3 day4 day5 day6 day7) 
	instruments(eq2: lead_maj_events occurrence_1 occurrence_2_7 occurrence_8_14
					 year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
					 day2 day3 day4 day5 day6 day7) 
	onestep winitial(unadjusted, indep);
#delimit cr
test [r1]leaddaily_woi= [r2]leaddaily_woi
restore

* Compare column 4 of panel a of table 5 with column 4 of panel b of table 5

preserve 
keep if sample_iv==1

#delimit;
gmm (eq1: occurrence     - {r1: leaddaily_woi_nc occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 
									mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12 
									year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
									day2 day3 day4 day5 day6 day7} - {b0})
	(eq2: occurrence_pal - {r2: leaddaily_woi_nc occurrence_1 occurrence_2_7 occurrence_8_14
									year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
									day2 day3 day4 day5 day6 day7} - {c0}), 
	instruments(eq1: lead_maj_events occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 
				     mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12 
					 year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
					 day2 day3 day4 day5 day6 day7) 
	instruments(eq2: lead_maj_events occurrence_1 occurrence_2_7 occurrence_8_14
					 year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
					 day2 day3 day4 day5 day6 day7) 
	onestep winitial(unadjusted, indep);
#delimit cr
test [r1]leaddaily_woi_nc= [r2]leaddaily_woi_nc
restore

* Compare column 5 of panel a of table 5 with column 5 of panel b of table 5

preserve 
keep if sample_rf==1

set more off
#delimit;
sureg 
(occurrence         lead_maj_events occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0 , cluster(monthyear))
(occurrence_pal lead_maj_events occurrence_1         occurrence_2_7         occurrence_8_14                 i.year i.dow if gaza_war==0 , cluster(monthyear));
#delimit cr
test [occurrence]lead_maj_events=0
test [occurrence_pal]lead_maj_events=0
lincom [occurrence]lead_maj_events-[occurrence_pal]lead_maj_events
restore

* Compare column 6 of panel a of table 5 with column 6 of panel b of table 5

preserve 
keep if sample_iv==1

#delimit;
gmm (eq1: lnvic     - {r1:     leaddaily_woi occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 
							   mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12 
							   year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
							   day2 day3 day4 day5 day6 day7} - {b0})
	(eq2: lnvic_pal - {r2: leaddaily_woi occurrence_1 occurrence_2_7 occurrence_8_14
							   year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
							   day2 day3 day4 day5 day6 day7} - {c0}), 
	instruments(eq1: lead_maj_events occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 
				     mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12 
					 year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
					 day2 day3 day4 day5 day6 day7) 
	instruments(eq2: lead_maj_events occurrence_1 occurrence_2_7 occurrence_8_14
					 year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
					 day2 day3 day4 day5 day6 day7) 
	onestep winitial(unadjusted, indep) ;
#delimit cr
test [r1]leaddaily_woi= [r2]leaddaily_woi
restore

* Compare column 7 of panel a of table 5 with column 7 of panel b of table 5

preserve 
keep if sample_iv==1

#delimit;
gmm (eq1: lnvic     - {r1:     leaddaily_woi_nc occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 
							   mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12 
							   year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
							   day2 day3 day4 day5 day6 day7} - {b0})
	(eq2: lnvic_pal - {r2: leaddaily_woi_nc occurrence_1 occurrence_2_7 occurrence_8_14
							   year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
							   day2 day3 day4 day5 day6 day7} - {c0}), 
	instruments(eq1: lead_maj_events occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 
				     mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12 
					 year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
					 day2 day3 day4 day5 day6 day7) 
	instruments(eq2: lead_maj_events occurrence_1 occurrence_2_7 occurrence_8_14
					 year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
					 day2 day3 day4 day5 day6 day7) 
	onestep winitial(unadjusted, indep) ;
#delimit cr
test [r1]leaddaily_woi_nc= [r2]leaddaily_woi_nc
restore

* Compare column 8 of panel a of table 5 with column 8 of panel b of table 5

preserve 
keep if sample_rf==1

set more off
#delimit;
sureg 
(lnvic         lead_maj_events occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0 , cluster(monthyear))
(lnvic_pal lead_maj_events occurrence_1         occurrence_2_7         occurrence_8_14                 i.year i.dow if gaza_war==0 , cluster(monthyear));
#delimit cr
test [lnvic]lead_maj_events=0
test [lnvic_pal]lead_maj_events=0
lincom [lnvic]lead_maj_events-[lnvic_pal]lead_maj_events
restore

** Panel C (placebo) Israeli Attacks and Unpredictable Newsworthy Events

xi: reg leaddaily_woi lead_disaster occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.dow i.month i.year if gaza_war==0 , cluster(monthyear)
test  lead_disaster
scalar Fd_cont=r(F)
outreg2 using "$tables/table_5c.xls", replace ctitle("NP-Tomorrow, 1st stage") keep(lead_disaster lead_killed_1000)  nocons label bdec(3) addstat ("F excl. insrt", Fd_cont) 

xi: reg leaddaily_woi_nc lead_disaster occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.dow i.month i.year if gaza_war==0 , cluster(monthyear)
test  lead_disaster
scalar Fd_cont_nc=r(F)
outreg2 using "$tables/table_5c.xls", append ctitle("UncorNP-Tomorrow, 1st stage") keep(lead_disaster lead_killed_1000)  nocons label bdec(3) addstat ("F excl. insrt", Fd_cont_nc) 

xi: ivreg  occurrence (leaddaily_woi=lead_disaster) occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14  i.dow i.month i.year if gaza_war==0, first cluster(monthyear)
outreg2 using "$tables/table_5c.xls", append ctitle("Occurrence, IV 2nd stage") keep(leaddaily_woi ) addstat ("F excl. insrt", Fd_cont) nocons label bdec(3)

xi: ivreg  occurrence (leaddaily_woi_nc=lead_disaster) occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14  i.dow i.month i.year if gaza_war==0, first cluster(monthyear)
outreg2 using "$tables/table_5c.xls", append ctitle("Occurrence, IV 2nd stage") keep(leaddaily_woi_nc  ) addstat ("F excl. insrt", Fd_cont_nc) nocons label bdec(3)

xi: reg  occurrence lead_disaster occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14  i.dow i.month i.year if gaza_war==0 ,  cluster(monthyear)
outreg2 using "$tables/table_5c.xls", append ctitle("Occurrence, Reduced form") keep(lead_disaster  )  nocons label bdec(3)

cap drop mon1-mon12 day1-day7 year1-year12
tab month, gen(mon)
tab dow, gen(day)
tab year, gen(year)

#delimit;
     qvf victims_isr  
	 leaddaily_woi
	 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14
	 mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12
	 day2 day3 day4 day5 day6 day7 
	 year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
	 (lead_disaster
	 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14
	 mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12
	 day2 day3 day4 day5 day6 day7 
	 year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12) 
	 if gaza_war==0, family(nbinom) robust cluster(monthyear);
#delimit cr
outreg2 using "$tables/table_5c.xls", append ctitle("Num. victims, IV 2nd stage") keep(leaddaily_woi  ) addstat ("F excl. insrt", Fd_cont) nocons label bdec(3)

#delimit;
     qvf victims_isr  
	 leaddaily_woi_nc
	 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14
	 mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12
	 day2 day3 day4 day5 day6 day7 
	 year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
	 (lead_disaster
	 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14
	 mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12
	 day2 day3 day4 day5 day6 day7 
	 year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12) 
	 if gaza_war==0, family(nbinom) robust cluster(monthyear);
#delimit cr
outreg2 using "$tables/table_5c.xls", append ctitle("Num. victims, IV 2nd stage") keep(leaddaily_woi_nc  ) addstat ("F excl. insrt", Fd_cont_nc) nocons label bdec(3)

#delimit;
     xi: glm victims_isr 
     lead_disaster 
	 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14
     mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12
	 day2 day3 day4 day5 day6 day7 
	 year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
	 if  gaza_war==0, family(nbinom ml)
	 vce(cluster monthyear);
#delimit cr
outreg2 using "$tables/table_5c.xls", append ctitle("Num. victims, Reduced form") keep(lead_disaster lead_killed_1000) nocons label bdec(3)

* Corresponding negative binomial regressions to display the pseudo R-squared
eststo clear
#delimit;
eststo: xi: nbreg victims_isr lead_disaster 
							  mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12
							  day2 day3 day4 day5 day6 day7 
							  year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
							  occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14
							  if gaza_war==0, vce(cluster monthyear) ;
#delimit cr
esttab, se pr2 star(* 0.1 ** 0.05 *** 0.01)

* Compare relationship between main predictable events and Israeli attacks and disasters and Israeli attacks

* Compare column 3 of panel a of table 5 with column 3 of panel c of table 5

preserve 
keep if sample_iv==1

#delimit;
gmm (eq1: occurrence     - {r1: leaddaily_woi occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 
									mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12 
									year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
									day2 day3 day4 day5 day6 day7} - {b0})
	(eq2: occurrence     - {r2: leaddaily_woi occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14
	                                mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12 
									year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
									day2 day3 day4 day5 day6 day7} - {c0}), 
	instruments(eq1: lead_maj_events occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14  
				     mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12 
					 year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
					 day2 day3 day4 day5 day6 day7) 
	instruments(eq2: lead_disaster   occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14
					 mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12
					 year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
					 day2 day3 day4 day5 day6 day7) 
	onestep winitial(unadjusted, indep);
#delimit cr
test [r1]leaddaily_woi=[r2]leaddaily_woi
restore

* Compare column 4 of panel a of table 5 with column 4 of panel c of table 5

preserve 
keep if sample_iv==1

#delimit;
gmm (eq1: occurrence     - {r1: leaddaily_woi_nc occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 
									mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12 
									year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
									day2 day3 day4 day5 day6 day7} - {b0})
	(eq2: occurrence     - {r2: leaddaily_woi_nc occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14
	                                mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12 
									year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
									day2 day3 day4 day5 day6 day7} - {c0}), 
	instruments(eq1: lead_maj_events occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14  
				     mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12 
					 year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
					 day2 day3 day4 day5 day6 day7) 
	instruments(eq2: lead_disaster   occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14
					 mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12
					 year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
					 day2 day3 day4 day5 day6 day7) 
	onestep winitial(unadjusted, indep);
#delimit cr
test [r1]leaddaily_woi_nc=[r2]leaddaily_woi_nc
restore

* Compare column 5 of panel a of table 5 with column 5 of panel c of table 5

preserve 
keep if sample_rf==1

reg  occurrence lead_maj_events lead_disaster occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0 , cluster(monthyear)
test lead_maj_events=lead_disaster

restore

* Compare column 6 of panel a of table a with column 6 of panel c of table 5

preserve 
keep if sample_iv==1

#delimit;
gmm (eq1: lnvic     - {r1:     leaddaily_woi occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 
							   mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12 
							   year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
							   day2 day3 day4 day5 day6 day7} - {b0})
	(eq2: lnvic     - {r2:     leaddaily_woi occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 
							   mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12 
							   year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
							   day2 day3 day4 day5 day6 day7} - {c0}),
	instruments(eq1: lead_maj_events occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 
				     mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12 
					 year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
					 day2 day3 day4 day5 day6 day7) 
	instruments(eq2: lead_disaster occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 
				     mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12 
					 year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
					 day2 day3 day4 day5 day6 day7)
	onestep winitial(unadjusted, indep);
#delimit cr
test [r1]leaddaily_woi= [r2]leaddaily_woi
restore

* Compare column 7 of panel a of table 5 with column 7 of panel c of table 5

preserve 
keep if sample_iv==1

#delimit;
gmm (eq1: lnvic     - {r1:     leaddaily_woi_nc occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 
							   mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12 
							   year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
							   day2 day3 day4 day5 day6 day7} - {b0})
	(eq2: lnvic     - {r2:     leaddaily_woi_nc occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 
							   mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12 
							   year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
							   day2 day3 day4 day5 day6 day7} - {c0}),
	instruments(eq1: lead_maj_events occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 
				     mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12 
					 year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
					 day2 day3 day4 day5 day6 day7) 
	instruments(eq2: lead_disaster occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 
				     mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12 
					 year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
					 day2 day3 day4 day5 day6 day7)
	onestep winitial(unadjusted, indep);
#delimit cr
test [r1]leaddaily_woi_nc= [r2]leaddaily_woi_nc
restore

* Compare column 8 of panel a of table 5 with column 8 of panel c of table 5

preserve 
keep if sample_rf==1

reg lnvic lead_maj_events lead_disaster occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0 , cluster(monthyear)
test lead_maj_events=lead_disaster
restore

****************************************************************************************************
** Table 6. The Urgency of Attacks and the Likelihood of Civilian Casualties
****************************************************************************************************

use "$dta/replication_file1.dta", clear

* Multinomial logit: occurrence of different types of Israeli attacks

* Targeted vs. non-targeted killings

#delimit;
xi: dmlogit2 attacks_target 
	leaddaily_woi 
	occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 
	lagdaily_woi-lagdaily_woi7 
	i.month i.year i.dow 
	if gaza_war==0, cluster(monthyear) baseoutcome(1);
test [2]leaddaily_woi = [3]leaddaily_woi;
scalar P_v=r(p);
#delimit cr
outreg2 using "$tables/table_6_a.xls", replace ctitle("Non-targeted") keep(leaddaily_woi) nocons label bdec(3) addstat("p value", P_v)

* Fatal vs. non-fatal attacks
#delimit;
xi: dmlogit2 attacks_fatal
	leaddaily_woi 
	occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 
	lagdaily_woi-lagdaily_woi7 
	i.month i.year i.dow 
	if gaza_war==0, cluster(monthyear) baseoutcome(1) ;
test [2]leaddaily_woi = [3]leaddaily_woi;
scalar P_v=r(p);
#delimit cr
outreg2 using "$tables/table_6_a.xls", append ctitle("Fatal") keep(leaddaily_woi) nocons label bdec(3) addstat("p value", P_v)

* Attacks in high-population-density areas vs. attacks in low-population-density areas 
#delimit;
xi: dmlogit2 attacks_hpd
	leaddaily_woi 
	occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 
	lagdaily_woi-lagdaily_woi7 
	i.month i.year i.dow 
	if gaza_war==0 , cluster(monthyear) baseoutcome(1);
test [2]leaddaily_woi = [3]leaddaily_woi;
scalar P_v=r(p);
#delimit cr
outreg2 using "$tables/table_6_a.xls", append ctitle("HPD") keep(leaddaily_woi) nocons label bdec(3) addstat("p value", P_v)

* Attacks involving the use of heavy-weapons vs. attacks not involving the use of heavy-weapons
#delimit;
xi: dmlogit2 attacks_hw
	leaddaily_woi 
	occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 
	lagdaily_woi-lagdaily_woi7 
	i.month i.year i.dow 
	if gaza_war==0 , cluster(monthyear) baseoutcome(1);
test [2]leaddaily_woi = [3]leaddaily_woi;
scalar P_v=r(p);
#delimit cr
outreg2 using "$tables/table_6_a.xls", append ctitle("HW") keep(leaddaily_woi) nocons label bdec(3) addstat("p value", P_v)

* COLUMNS 2-3: Victims of Israeli attacks

#delimit;
xi: glm victims_target
	    leaddaily_woi  lagdaily_woi lagdaily_woi2 lagdaily_woi3 lagdaily_woi4 lagdaily_woi5 lagdaily_woi6 lagdaily_woi7 
		occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 
		i.month i.year i.dow if gaza_war==0, family(nbinom ml) vce(hac nwest 7);
outreg2 using "$tables/table_6_b.xls", 
replace ctitle("Victims of targeted killings") keep(leaddaily_woi) nocons label bdec(3);
#delimit cr

#delimit;
xi: glm victims_non_target
		leaddaily_woi  lagdaily_woi lagdaily_woi2 lagdaily_woi3 lagdaily_woi4 lagdaily_woi5 lagdaily_woi6 lagdaily_woi7 
		occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 
		i.month i.year i.dow if gaza_war==0, family(nbinom ml) vce(hac nwest 7);
outreg2 using "$tables/table_6_b.xls", 
append   ctitle("Victims of non-targeted attacks") keep(leaddaily_woi) nocons label bdec(3);
#delimit cr

#delimit;
xi: glm non_fatal_victims
		leaddaily_woi  lagdaily_woi lagdaily_woi2 lagdaily_woi3 lagdaily_woi4 lagdaily_woi5 lagdaily_woi6 lagdaily_woi7 
		occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 
		i.month i.year i.dow if gaza_war==0  & occurrence_fatal==0, family(nbinom ml) vce(hac nwest 7);
outreg2 using "$tables/table_6_b.xls", 
append ctitle("Injuries") keep(leaddaily_woi) nocons label bdec(3);
#delimit cr

#delimit;
xi: glm fatal_victims
		leaddaily_woi  lagdaily_woi lagdaily_woi2 lagdaily_woi3 lagdaily_woi4 lagdaily_woi5 lagdaily_woi6 lagdaily_woi7 
		occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 
		i.month i.year i.dow if gaza_war==0, family(nbinom ml) vce(hac nwest 7);
outreg2 using "$tables/table_6_b.xls", 
append ctitle("Fatalities") keep(leaddaily_woi) nocons label bdec(3);
#delimit cr

#delimit;
xi: glm victims_lpd
		leaddaily_woi lagdaily_woi lagdaily_woi2 lagdaily_woi3 lagdaily_woi4 lagdaily_woi5 lagdaily_woi6 lagdaily_woi7 
		occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 
		i.month i.year i.dow if gaza_war==0 , family(nbinom ml) vce(hac nwest 7);
outreg2 using "$tables/table_6_b.xls", 
append ctitle("Casualties in NDP areas") keep(leaddaily_woi) nocons label bdec(3);
#delimit cr

#delimit;
xi: glm victims_hpd
		leaddaily_woi  lagdaily_woi lagdaily_woi2 lagdaily_woi3 lagdaily_woi4 lagdaily_woi5 lagdaily_woi6 lagdaily_woi7 
		occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 
		i.month i.year i.dow if gaza_war==0, family(nbinom ml) vce(hac nwest 7);
outreg2 using "$tables/table_6_b.xls", 
append ctitle("Casualties in DP areas") keep(leaddaily_woi) nocons label bdec(3);
#delimit cr

#delimit;
xi: glm victims_nhw
		leaddaily_woi lagdaily_woi lagdaily_woi2 lagdaily_woi3 lagdaily_woi4 lagdaily_woi5 lagdaily_woi6 lagdaily_woi7 
		occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 
		i.month i.year i.dow if gaza_war==0  & occurrence_hw==0, family(nbinom ml) vce(hac nwest 7);
outreg2 using "$tables/table_6_b.xls", 
append ctitle("Casualties with light weapons") keep(leaddaily_woi) nocons label bdec(3);
#delimit cr

#delimit;
xi: glm victims_hw
		leaddaily_woi  lagdaily_woi lagdaily_woi2 lagdaily_woi3 lagdaily_woi4 lagdaily_woi5 lagdaily_woi6 lagdaily_woi7 
		occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 
		i.month i.year i.dow if gaza_war==0 , family(nbinom ml) vce(hac nwest 7);
outreg2 using "$tables/table_6_b.xls", 
append ctitle("Casualties with heavy weapons") keep(leaddaily_woi) nocons label bdec(3);
#delimit cr

****************************************************************************************************
** Table 7. Google Search Volume, Conflict-related News, and Timing of Attacks
****************************************************************************************************

use "$dta/replication_file1.dta", clear

* Generate interaction terms between presence of conflict news at t and occurrence of Israeli attacks at t and t-1
gen conflict_news_isr_occ_t=any_conflict_news*occurrence
gen conflict_news_isr_occ_t_1=any_conflict_news*l1.occurrence
gen conflict_news_no_isr_occ_t_y=any_conflict_news*(!occurrence&!l1.occurrence)

label var conflict_news_isr_occ_t "Any conflict news x Israeli attack, same day"
label var conflict_news_isr_occ_t_1 "Any conflict news x Israeli attack, previous day"
label var conflict_news_no_isr_occ_t_y "Any conflict news x no Israeli attack, same or previous day"

* Generate interaction terms between length of conflict news at t and occurrence of Israeli attacks at t and t-1
gen l_conflict_news_isr_occ_t=length_conflict_news*occurrence
gen l_conflict_news_isr_occ_t_1=length_conflict_news*l1.occurrence
gen l_conflict_news_no_isr_occ_t_y=length_conflict_news*(!occurrence&!l1.occurrence)

label var l_conflict_news_isr_occ_t "Lenght of conflict news x Israeli attack, same day"
label var l_conflict_news_isr_occ_t_1 "Lenght of  conflict news x Israeli attack, previous day"
label var l_conflict_news_no_isr_occ_t_y "Lenght of  conflict news x no Israeli attack, same or previous day"

* Generate first lags of interaction terms
sort date
foreach var in conflict_news_isr_occ_t conflict_news_isr_occ_t_1 conflict_news_no_isr_occ_t_y l_conflict_news_isr_occ_t l_conflict_news_isr_occ_t_1 l_conflict_news_no_isr_occ_t_y{
gen L`var'=l.`var'
}

xi: newey conflict_searches conflict_news_isr_occ_t conflict_news_isr_occ_t_1 conflict_news_no_isr_occ_t_y lnvic l.lnvic lnvic_pal l.lnvic_pal occurrence l.occurrence occurrence_pal l.occurrence_pal monthyear i.dow  i.month, lag(7) force
test conflict_news_isr_occ_t=conflict_news_isr_occ_t_1
scalar P_v=r(p)
outreg2 using "$tables/table_7.xls", ctitle ("Isr-Pal Conflict") replace stats(coef se) keep(conflict_news_isr_occ_t conflict_news_isr_occ_t_1) nocons label bdec(3) addtext (DOW FEs, Yes, Linear time trend, Yes) addstat("p value", P_v)

xi: newey conflict_searches conflict_news_isr_occ_t conflict_news_isr_occ_t_1 conflict_news_no_isr_occ_t_y Lconflict_news_isr_occ_t Lconflict_news_isr_occ_t_1 Lconflict_news_no_isr_occ_t_y lnvic l.lnvic l2.lnvic lnvic_pal l.lnvic_pal l2.lnvic_pal occurrence l.occurrence  l2.occurrence occurrence_pal l.occurrence_pal   l2.occurrence_pal i.dow monthyear i.month, lag(7) force
test conflict_news_isr_occ_t=conflict_news_isr_occ_t_1
scalar P_v=r(p)
test Lconflict_news_isr_occ_t=Lconflict_news_isr_occ_t_1
scalar P1_v=r(p)
test Lconflict_news_isr_occ_t+conflict_news_isr_occ_t=Lconflict_news_isr_occ_t_1+conflict_news_isr_occ_t_1
scalar P2_v=r(p)
outreg2 using "$tables/table_7.xls", ctitle ("Isr-Pal Conflict") append stats(coef se) keep(conflict_news_isr_occ_t conflict_news_isr_occ_t_1 Lconflict_news_isr_occ_t Lconflict_news_isr_occ_t_1) nocons label bdec(3) addtext (DOW FEs, Yes, Linear time trend, Yes) addstat("p value", P_v, "p value lag", P1_v, "p value sum", P2_v)

xi: newey conflict_searches l_conflict_news_isr_occ_t l_conflict_news_isr_occ_t_1 l_conflict_news_no_isr_occ_t_y lnvic l.lnvic lnvic_pal l.lnvic_pal occurrence l.occurrence occurrence_pal l.occurrence_pal  i.dow monthyear i.month, lag(7) force
test l_conflict_news_isr_occ_t=l_conflict_news_isr_occ_t_1
scalar P_v=r(p)
outreg2 using "$tables/table_7.xls", ctitle ("Isr-Pal Conflict") append stats(coef se) keep(l_conflict_news_isr_occ_t l_conflict_news_isr_occ_t_1) nocons label bdec(3) addtext (DOW FEs, Yes, Linear time trend, Yes) addstat("p value", P_v)

xi: newey conflict_searches l_conflict_news_isr_occ_t l_conflict_news_isr_occ_t_1 l_conflict_news_no_isr_occ_t_y Ll_conflict_news_isr_occ_t Ll_conflict_news_isr_occ_t_1 Ll_conflict_news_no_isr_occ_t_y lnvic l.lnvic l2.lnvic lnvic_pal l.lnvic_pal l2.lnvic_pal occurrence l.occurrence l2.occurrence occurrence_pal l.occurrence_pal l2.occurrence_pal  i.dow monthyear i.month, lag(7) force
test l_conflict_news_isr_occ_t=l_conflict_news_isr_occ_t_1
scalar P_v=r(p)
test Ll_conflict_news_isr_occ_t Ll_conflict_news_isr_occ_t_1
scalar P1_v=r(p)
test Ll_conflict_news_isr_occ_t+l_conflict_news_isr_occ_t=Ll_conflict_news_isr_occ_t_1+l_conflict_news_isr_occ_t_1
scalar P2_v=r(p)
outreg2 using "$tables/table_7.xls", ctitle ("Isr-Pal Conflict") append stats(coef se) keep(l_conflict_news_isr_occ_t l_conflict_news_isr_occ_t_1 Ll_conflict_news_isr_occ_t Ll_conflict_news_isr_occ_t_1) nocons label bdec(3) addtext (DOW FEs, Yes, Linear time trend, Yes) addstat("p value", P_v, "p value lag", P1_v,"p value sum", P2_v)

* Corresponding OLS regressions to display the R-squared
eststo clear
eststo: xi: reg conflict_searches conflict_news_isr_occ_t conflict_news_isr_occ_t_1 conflict_news_no_isr_occ_t_y lnvic l.lnvic lnvic_pal l.lnvic_pal occurrence l.occurrence occurrence_pal l.occurrence_pal i.dow monthyear i.month, vce(cluster monthyear)
eststo: xi: reg conflict_searches conflict_news_isr_occ_t conflict_news_isr_occ_t_1 conflict_news_no_isr_occ_t_y Lconflict_news_isr_occ_t Lconflict_news_isr_occ_t_1 Lconflict_news_no_isr_occ_t_y lnvic l.lnvic l2.lnvic lnvic_pal l.lnvic_pal l2.lnvic_pal occurrence l.occurrence  l2.occurrence occurrence_pal l.occurrence_pal   l2.occurrence_pal i.dow monthyear i.month, vce(cluster monthyear)
eststo: xi: reg conflict_searches l_conflict_news_isr_occ_t l_conflict_news_isr_occ_t_1 l_conflict_news_no_isr_occ_t_y lnvic l.lnvic lnvic_pal l.lnvic_pal occurrence l.occurrence occurrence_pal l.occurrence_pal i.dow monthyear i.month, vce(cluster monthyear)
eststo: xi: reg conflict_searches l_conflict_news_isr_occ_t l_conflict_news_isr_occ_t_1 l_conflict_news_no_isr_occ_t_y Ll_conflict_news_isr_occ_t Ll_conflict_news_isr_occ_t_1 Ll_conflict_news_no_isr_occ_t_y lnvic l.lnvic l2.lnvic lnvic_pal l.lnvic_pal l2.lnvic_pal occurrence l.occurrence l2.occurrence occurrence_pal l.occurrence_pal l2.occurrence_pal  i.dow monthyear i.month, vce(cluster monthyear)
esttab, se r2 star(* 0.10 ** 0.05 *** 0.01)

*********************************************************************************************************
											*** MAIN FIGURES	***
*********************************************************************************************************

************************************************************************
** Figure 1. Israeli and Palestinian Fatalities by Month
************************************************************************

use "$dta/replication_file1.dta", clear
set more off

* Panel A: Entire sample period

preserve
egen sum_vic=sum(victims_isr), by(monthyear)
egen sum_vic_pal=sum(victims_pal), by(monthyear)
collapse sum_vic sum_vic_pal, by(monthyear post_intifada)

* Setting end of second Intifada as missing
replace sum_vic=. if monthyear==541
replace sum_vic_p=. if monthyear==541

duplicates drop monthyear, force

label var sum_vic "Victims of Israeli attacks"
label var sum_vic_p "Victims of Palestinian attacks"

egen sum_vic_intifada=mean(sum_vic) if post_intifada==0
egen sum_vic_post_intifada=mean(sum_vic) if post_intifada==1
egen sum_vic_pal_intifada=mean(sum_vic_pal) if post_intifada==0
egen sum_vic_pal_post_intifada=mean(sum_vic_pal) if post_intifada==1

#delimit;  
twoway (scatteri 1000 586 1000 589 , bcolor(gs13) recast(area)) (connected sum_vic monthyear, sort mcolor(navy) msize(small) msymbol(circle) lpattern(solid) lwidth(medthin) lcolor(navy) cmissing(n)) 
(connected sum_vic_pal monthyear, sort mcolor(maroon) msize(vsmall) msymbol(circle) mfcolor(maroon) mlcolor(maroon) lcolor(maroon) lpattern(shortdash) lwidth(medthin) cmissing(n))
(line sum_vic_intifada monthyear, sort lcolor(navy) lwidth(medthin)) 
(line sum_vic_post_intifada monthyear, sort lcolor(navy) lwidth(medthin)) 
(line sum_vic_pal_intifada monthyear, sort lcolor(maroon) lwidth(medthin)) 
(line sum_vic_pal_post_intifada monthyear, sort lcolor(maroon) lwidth(medthin)), 
ytitle(Victims of Israeli and Palestinian attacks) ytitle(, margin(small)) 
xtitle("") xline(541, lcolor(black)) xlabel(486(17)622, labsize(small) format("%tm")) 
legend(on order(1 "Gaza war (Cast Lead)" 2 3 )) graphregion(fcolor(white));
#delimit cr
graph export "$figures/figure_1_a.pdf", replace
restore

* Panel B: Excluding Gaza war (december 27, 2008 - january 18, 2009)
 
egen sum_vic=sum(victims_isr), by(monthyear)
egen sum_vic_pal=sum(victims_pal), by(monthyear)
collapse sum_vic sum_vic_pal, by(monthyear post_intifada)

* Setting end of second Intifada as missing
replace sum_vic=. if monthyear==541
replace sum_vic_p=. if monthyear==541

* Setting months of Gaza War as missing
replace sum_vic=. if (month==587 | month==588)
replace sum_vic_pal=. if (month==587 | month==588)

duplicates drop monthyear, force

label var sum_vic "Victims of Israeli attacks"
label var sum_vic_p "Victims of Palestinian attacks"

egen sum_vic_intifada=mean(sum_vic) if post_intifada==0
egen sum_vic_post_intifada=mean(sum_vic) if post_intifada==1
egen sum_vic_pal_intifada=mean(sum_vic_pal) if post_intifada==0
egen sum_vic_pal_post_intifada=mean(sum_vic_pal) if post_intifada==1

#delimit;
twoway (scatteri 250 505.5 250 507 , bcolor(gs10) recast(area)) (scatteri 250 586 250 589 , bcolor(gs13) recast(area)) (connected sum_vic monthyear, sort mcolor(navy) msize(small) msymbol(circle) lpattern(solid) lwidth(medthin) lcolor(navy) cmissing(n)) 
(connected sum_vic_pal monthyear, sort mcolor(maroon) msize(vsmall) msymbol(circle) mfcolor(maroon) mlcolor(maroon) lcolor(maroon) lpattern(shortdash) lwidth(medthin) cmissing(n))
(line sum_vic_intifada monthyear, sort lcolor(navy) lwidth(medthin)) 
(line sum_vic_post_intifada monthyear, sort lcolor(navy) lwidth(medthin)) 
(line sum_vic_pal_intifada monthyear, sort lcolor(maroon) lwidth(medthin)) 
(line sum_vic_pal_post_intifada monthyear, sort lcolor(maroon) lwidth(medthin)), 
ytitle(Victims of Israeli and Palestinian attacks) ytitle(, margin(small)) 
xtitle("") xline(541, lcolor(black)) xlabel(486(17)622, labsize(small) format("%tm")) 
legend(on order(1 "Defensive Shield" 2 "Gaza war (Cast Lead)" 3 4)) graphregion(fcolor(white));
#delimit cr
graph export "$figures/figure_1_b.pdf", replace

************************************************************************
** Figure 2. Coverage of Conflict in US News
************************************************************************

* Panel A: News about conflict and attacks

use "$dta/replication_file1.dta", clear

cap drop B0-B8
gen B0=f3.lnvic 
gen B1=f2.lnvic 
gen B2=f1.lnvic 
gen B3=lnvic 
gen B4=l.lnvic 
gen B5=l2.lnvic 
gen B6=l3.lnvic 
gen B7=l4.lnvic 
gen B8=l5.lnvic 
gen B9=l6.lnvic 

cap drop C0-C8
gen C0=f3.lnvic_pal 
gen C1=f2.lnvic_pal 
gen C2=f1.lnvic_pal 
gen C3=lnvic_pal 
gen C4=l.lnvic_pal 
gen C5=l2.lnvic_pal 
gen C6=l3.lnvic_pal 
gen C7=l4.lnvic_pal 
gen C8=l5.lnvic_pal 
gen C9=l6.lnvic_pal 

set more off
gen time=date-14881
gen coef_Isr =.
gen low_g_Isr =.
gen high_g_Isr =.

gen coef_Pal =.
gen low_g_Pal =.
gen high_g_Pal =.
sort date

xi: newey length_conflict_news   B1 B2 B3 B4 B5 B6 B7 B8  C1 C2 C3 C4 C5 C6 C7 C8  i.month i.dow monthyear i.year if high_intensity<2 ,lag(7) force 

forval k=1/8 {
replace coef_Isr = _b[B`k'] if time==`k'
replace low_g_Isr = _b[B`k']-1.96*_se[B`k'] if time==`k'
replace high_g_Isr = _b[B`k']+1.96*_se[B`k'] if time==`k'
replace coef_Pal = _b[C`k'] if time==`k'
replace low_g_Pal = _b[C`k']-1.96*_se[C`k'] if time==`k'
replace high_g_Pal = _b[C`k']+1.96*_se[C`k'] if time==`k'
}

collapse (mean) coef_Isr low_g_Isr high_g_Isr coef_Pal low_g_Pal high_g_Pal, by(time)
keep if time<=6
keep if time>0

cap label drop ti
label def ti 1 "in 2 days" 2 "tomorrow" 3 "today" 4 "yesterday" 5 "2d ago" 6 "3d ago"  
label values time ti

* LEFT FIGURE
twoway (rarea low_g_Isr high_g_Isr time, sort color(gs14)) (scatter coef_Isr time, connect(l) lwidth(medthick) lcolor(maroon) mcolor(maroon) msize(medium) )  (function y=0    ,range(1 6) lcolor(black) lwidth(medthin)),  yscale(range(-.15 .3) titlegap(.05)) yline(0, lcolor(black) lwidth(medthin)) xlabel( 1 2 3 4 5 6 , valuelabel)  xline(2 4) ylabel( -.15 0 .3 ) ytitle(Length of conflict news at t) legend(off)  graphregion(fcolor(white)) xtitle("Log(victims of Israeli attack +1)")  title("News coverage of Israeli attacks") 
graph export     "$figures/figure_2_a_isr.pdf", replace

* RIGHT FIGURE
twoway (rarea low_g_Pal high_g_Pal time, sort color(gs14)) (scatter coef_Pal time, connect(l) lwidth(medthick) lcolor(maroon) mcolor(maroon) msize(medium) )  (function y=0    ,range(1 6) lcolor(black) lwidth(medthin)),  yscale(range(-.3 1) titlegap(.05)) yline(0, lcolor(black) lwidth(medthin)) xlabel( 1 2 3 4 5 6 , valuelabel) xline(2 4) ylabel( -.3 0 1 ) ytitle(Length of conflict news at t) legend(off)  graphregion(fcolor(white))   xtitle("Log(victims of Palestinian attack +1)")   title("News coverage of Palestinian attacks") 
graph export     "$figures/figure_2_a_pal.pdf", replace

* Panel B: Time devoted to news bout conflict and news pressure

use "$dta/replication_file1.dta", clear

xi: nbreg length_conflict_news lnvic_t_y lnvic_pal_y daily_woi i.month i.year i.dow if  (occurrence_t_y==1 | occurrence_pal_t_y ==1), vce(cluster monthyear)
foreach k in 1 10 20 30 40 50 60 70 80 90 99 {
margins, at((p`k') daily_woi) atmeans saving("tab2_col4_p`k'.dta", replace)
}
	
foreach k in 1 10 20 30 40 50 60 70 80 90 99 {
use "tab2_col4_p`k'.dta", clear
keep _margin _ci_lb _ci_ub
rename (_margin _ci_lb _ci_ub) (coef ci_lower ci_upper)
gen var = `k'
save "tab2_col4_p`k'.dta", replace
}

clear
foreach k in 1 10 20 30 40 50 60 70 80 90 99 {
append using "tab2_col4_p`k'.dta", force
}
	
gen var_estimate = .
foreach k in 1 10 20 30 40 50 60 70 80 90 99 {
replace var_estimate = `k' if var == `k'
}
drop var
order var_estimate
sort var_estimate
	
#delimit ;
twoway (rcap ci_lower ci_upper var_estimate, lcolor(emerald)) 
(scatter coef var_estimate, mcolor(emerald) msize(.9) 
ytitle("Predicted length of conflict news", height(3)) 
xtitle("News pressure (percentile)", height(3))
xlabel(1 10 20 30 40 50 60 70 90 80 99)  xmtick(1 10 20 30 40 50 60 70 90 80 99)
graphregion(color(white)) legend(off) 
title("Predicted length of conflict news if an attack occurred today or yesterday", size(medium) color(black))) ;
#delimit cr
graph export     "$figures/figure_2_b.pdf", replace

foreach k in 1 10 20 30 40 50 60 70 80 90 99 {
erase "tab2_col4_p`k'.dta"
}

************************************************************************
** Figure 3. Israeli and Palestinian attacks and US news pressure
************************************************************************

use "$dta/replication_file1.dta", clear
set more off

order date-lagdaily_woi7 lagdaily_woi6 lagdaily_woi5 lagdaily_woi4 lagdaily_woi3 lagdaily_woi2 lagdaily_woi daily_woi leaddaily_woi leaddaily_woi2 leaddaily_woi3 leaddaily_woi4 leaddaily_woi5 leaddaily_woi6 leaddaily_woi7
capture drop D1 D2 D3 D4 D5 D6 D7 D8 D9 D10 D11 D12 D13 D14 D15 lagdaily_woi1 leaddaily_woi1

gen lagdaily_woi1=lagdaily_woi
gen leaddaily_woi1=leaddaily_woi

forval k=1/7 {
local l=8-`k'
gen D`k'=lagdaily_woi`l' 
}

gen D8=daily_woi

forval k=1/7 {
local l=8+`k'
gen D`l'=leaddaily_woi`k' 
}

sort date
order date-D1 D2 D3 D4 D5 D6 D7 D8 D9 D10 D11 D12 D13 D14 D15

preserve

* Probability of Israeli attacks and news pressure

xi: newey occurrence D1-D15 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0,lag(7) force 

gen time=date-14881
gen coef =.
gen low_g =.
gen high_g =.
sort date

forval k=5/13 {
replace coef = _b[D`k'] if time==`k'
replace low_g = _b[D`k']-1.96*_se[D`k'] if time==`k'
replace high_g = _b[D`k']+1.96*_se[D`k'] if time==`k'
}
collapse (mean) coef high_g low_g, by(time)
keep if time<=13
keep if time>4

label def ti 5 "T-3" 6 "T-2" 7 "T-1" 8 "T" 9 "T+1" 10 "T+2" 11 "T+3" 12 "T+4" 13 "T+5" 
label values t ti
twoway (rarea low hi t, sort color(gs14)) (scatter coef t, connect(l) lwidth(medthick) lcolor(maroon) mcolor(maroon) msize(medium) )  (function y=0    ,range(5 13) lcolor(black) lwidth(medthin)),  yscale(range(-.2 .2) titlegap(.05)) yline(0, lcolor(black) lwidth(medthin)) xlabel( 5 6 7 8 9 10 11 12 13, valuelabel) ylabel( -.2 -.1 0 .1 .2) ytitle(Coefficient) legend(off)  graphregion(fcolor(white)) title("Probability of Israeli attack", color(black))  xtitle("") subtitle("news pressure", color(black))
graph export     "$figures/figure_3_a.pdf", replace 
restore

* Probability of Palestinian attacks and news pressure

preserve
xi: newey occurrence_pal D1-D15 occurrence_1 occurrence_2_7 occurrence_8_14 i.month i.year i.dow if gaza_war==0,lag(7) force 

gen time=date-14881
gen coef =.
gen low_g =.
gen high_g =.
sort date

forval k=5/13 {
replace coef = _b[D`k'] if time==`k'
replace low_g = _b[D`k']-1.96*_se[D`k'] if time==`k'
replace high_g = _b[D`k']+1.96*_se[D`k'] if time==`k'
}
collapse (mean) coef high_g low_g, by(time)
keep if time<=13
keep if time>4

label def ti 5 "T-3" 6 "T-2" 7 "T-1" 8 "T" 9 "T+1" 10 "T+2" 11 "T+3" 12 "T+4" 13 "T+5" 
label values t ti
twoway (rarea low hi t, sort color(gs14)) (scatter coef t, connect(l) lwidth(medthick) lcolor(maroon) mcolor(maroon) msize(medium) ) (function y=0    ,range(5 13) lcolor(black) lwidth(medthin)) ,  yscale(range(-.2 .2) titlegap(.05)) yline(0, lcolor(black) lwidth(medthin)) xlabel( 5 6 7 8 9 10 11 12 13, valuelabel) ylabel( -.2 -.1 0 .1 .2) ytitle(Coefficient) legend(off)  graphregion(fcolor(white)) title("Probability of Palestinian attack", color(black))  subtitle("news pressure", color(black)) xtitle("") 
graph export     "$figures/figure_3_b.pdf", replace 
restore

order date-lagdaily_woi7 lagdaily_woi6 lagdaily_woi5 lagdaily_woi4 lagdaily_woi3 lagdaily_woi2 lagdaily_woi daily_woi leaddaily_woi leaddaily_woi2 leaddaily_woi3 leaddaily_woi4 leaddaily_woi5 leaddaily_woi6 leaddaily_woi7
capture drop D1 D2 D3 D4 D5 D6 D7 D8 D9 D10 D11 D12 D13 D14 D15
capture drop  lagdaily_woi1_nc leaddaily_woi1_nc

* With uncorrected news pressure

gen lagdaily_woi1_nc=lagdaily_woi_nc
gen leaddaily_woi1_nc=leaddaily_woi_nc

forval k=1/7 {
local l=8-`k'
gen D`k'=lagdaily_woi`l'_nc 
}

gen D8=daily_woi_nc

forval k=1/7 {
local l=8+`k'
gen D`l'=leaddaily_woi`k'_nc 
}

sort date
order date-D1 D2 D3 D4 D5 D6 D7 D8 D9 D10 D11 D12 D13 D14 D15

* Probability of Israeli attacks and uncorrected news pressure

preserve
xi: newey occurrence D1-D15 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0,lag(7) force 

gen time=date-14881
gen coef =.
gen low_g =.
gen high_g =.
sort date

forval k=5/13 {
replace coef = _b[D`k'] if time==`k'
replace low_g = _b[D`k']-1.96*_se[D`k'] if time==`k'
replace high_g = _b[D`k']+1.96*_se[D`k'] if time==`k'
}
collapse (mean) coef high_g low_g, by(time)
keep if time<=13
keep if time>4

label def ti 5 "T-3" 6 "T-2" 7 "T-1" 8 "T" 9 "T+1" 10 "T+2" 11 "T+3" 12 "T+4" 13 "T+5" 
label values t ti
twoway (rarea low hi t, sort color(gs14)) (scatter coef t, connect(l) lwidth(medthick) lcolor(maroon) mcolor(maroon) msize(medium) ) (function y=0    ,range(5 13) lcolor(black) lwidth(medthin)),  yscale(range(-.2 .2) titlegap(.05)) yline(0, lcolor(black) lwidth(medthin)) xlabel( 5 6 7 8 9 10 11 12 13, valuelabel) ylabel( -.2 -.1 0 .1 .2) ytitle(Coefficient) legend(off)  graphregion(fcolor(white)) title("Probability of Israeli attack", color(black))  xtitle("") subtitle("uncorrected news pressure", color(black))
graph export     "$figures/figure_3_c.pdf", replace 
restore

* Probability of Palestinian attacks and uncorrected news pressure

xi: newey occurrence_pal D1-D15 occurrence_1 occurrence_2_7 occurrence_8_14 i.month i.year i.dow if gaza_war==0,lag(7) force 

gen time=date-14881
gen coef =.
gen low_g =.
gen high_g =.
sort date

forval k=5/13 {
replace coef = _b[D`k'] if time==`k'
replace low_g = _b[D`k']-1.96*_se[D`k'] if time==`k'
replace high_g = _b[D`k']+1.96*_se[D`k'] if time==`k'
}
collapse (mean) coef high_g low_g, by(time)
keep if time<=13
keep if time>4

label def ti 5 "T-3" 6 "T-2" 7 "T-1" 8 "T" 9 "T+1" 10 "T+2" 11 "T+3" 12 "T+4" 13 "T+5" 
label values t ti
twoway (rarea low hi t, sort color(gs14))  (scatter coef t, connect(l) lwidth(medthick) lcolor(maroon) mcolor(maroon) msize(medium) )  (function y=0    ,range(5 13) lcolor(black) lwidth(medthin)),  yscale(range(-.2 .2) titlegap(.05)) yline(0, lcolor(black) lwidth(medthin)) xlabel( 5 6 7 8 9 10 11 12 13, valuelabel) ylabel( -.2 -.1 0 .1 .2) ytitle(Coefficient) legend(off)  graphregion(fcolor(white)) title("Probability of Palestinian attack", color(black))  xtitle("") subtitle("uncorrected news pressure", color(black))
graph export     "$figures/figure_3_d.pdf", replace 

************************************************************************
** Figure 4. Israeli and Palestinian Attacks and Other Predictable 
**           and Exogenous Newsworthy Events in the US
************************************************************************

use "$dta/replication_file1.dta", clear

gen no_major_events=1-lead_maj_events
preserve

* Panel A: Israeli attacks and newsworthy events

reg occurrence lead_maj_events no_major_events, nocons
test lead_maj_events=no_major_events
regsave, ci
foreach x in coef ci_lower ci_upper {
gen `x'_100 = 100*`x'
}
keep var *_100 
encode var, gen(events)
gen x = _n
gen barposition = cond(events==1, _n, _n+0.5)
gen coef_2dec = coef_100
format coef_2dec %9.2f
local c1 = round(coef_2dec[1],0.01)
local c2 = round(coef_2dec[2],0.01)

#delimit ;
twoway (bar coef_100 barposition if events == 1, fcolor(navy)) 
(bar coef_100 barposition if events == 2, fcolor(navy)) 
(rcap ci_lower_100 ci_upper_100 barposition, legend(off)
lwidth(medthick) lcolor(darkblue)
yscale(range(0(10)70)) ytick(0(10)70) ylabel(0(10)70)
xscale(range(0(0.5)3.5)) xtitle("") 
xlabel(1 "Major political/sport events" 2.5 "No major political/sports events")
title("% of days with Israeli attacks", color(black) size(medium))
text(3 0.9 "`c1'%", place(e) color(white) xoffset(-2) yoffset(31))
text(3 2.4 "`c2'%", place(e) color(white) xoffset(-2) yoffset(31))
graphregion(color(white))) ;
#delimit cr
graph export "$figures/figure_4_a.pdf", replace
restore

* Panel B: Palestinian attacks and newsworthy events

reg occurrence_pal lead_maj_events no_major_events, nocons
test lead_maj_events=no_major_events
regsave, ci
foreach x in coef ci_lower ci_upper {
gen `x'_100 = 100*`x'
}
keep var *_100 
encode var, gen(events)
gen x = _n
gen barposition = cond(events==1, _n, _n+0.5)
gen coef_2dec = coef_100
format coef_2dec %9.2f
local c1 = round(coef_2dec[1],0.01)
local c2 = round(coef_2dec[2],0.01)

#delimit ;
twoway (bar coef_100 barposition if events == 1, fcolor(navy)) 
(bar coef_100 barposition if events == 2, fcolor(navy)) 
(rcap ci_lower_100 ci_upper_100 barposition, legend(off)
lwidth(medthick) lcolor(darkblue)
yscale(range(0(2)12)) ytick(0(2)12) ylabel(0(2)12)
xscale(range(0(0.5)3.5)) xtitle("") 
xlabel(1 "Major political/sport events" 2.5 "No major political/sports events")
title("% of days with Palestinian attacks", color(black) size(medium))
text(3 0.9 "`c1'%", place(e) color(white) xoffset(-2) yoffset(-6))
text(3 2.4 "`c2'%", place(e) color(white) xoffset(-2) yoffset(-6))
graphregion(color(white)));
#delimit cr
graph export "$figures/figure_4_b.pdf", replace

************************************************************************
** Figure 5. Types of Attacks and News Pressure
************************************************************************

use "$dta/replication_file1.dta", clear
	
* Event study graphs

set more off
capture drop D1 D2 D3 D4 D5 D6 D7 D8
order date-lagdaily_woi7 lagdaily_woi6 lagdaily_woi5 lagdaily_woi4 lagdaily_woi3 lagdaily_woi2 lagdaily_woi daily_woi leaddaily_woi leaddaily_woi2 leaddaily_woi3 leaddaily_woi4 leaddaily_woi5 leaddaily_woi6 leaddaily_woi7
capture drop  D9 D10 D11 D12 D13 D14 D15 
capture drop lagdaily_woi1 leaddaily_woi1
gen lagdaily_woi1 =lagdaily_woi
gen leaddaily_woi1=leaddaily_woi

forval k=1/7 {
local l=8-`k'
gen D`k'=lagdaily_woi`l' 
}

gen D8=daily_woi

forval k=1/7 {
local l=8+`k'
gen D`l'=leaddaily_woi`k' 
}

sort date
order date-D1 D2 D3 D4 D5 D6 D7 D8 D9 D10 D11 D12 D13 D14 D15

* Event study: occurrence of non-targeted Israeli attacks 

xi: newey occurrence_non_target D5-D13 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0,lag(7) force 
preserve
gen time=date-14881
gen coef =.
gen low_g =.
gen high_g =.
sort date

forval k=5/13 {
replace coef = _b[D`k'] if time==`k'
replace low_g = _b[D`k']-1.64*_se[D`k'] if time==`k'
replace high_g = _b[D`k']+1.64*_se[D`k'] if time==`k'
}
collapse (mean) coef high_g low_g, by(time)
keep if time<=13
keep if time>4

label def ti 5 "T-3" 6 "T-2" 7 "T-1" 8 "T" 9 "T+1" 10 "T+2" 11 "T+3" 12 "T+4" 13 "T+5" 
label values t ti
twoway (rarea low hi t, sort color(gs14)) (scatter coef t, connect(l) lwidth(medthick) lcolor(maroon) mcolor(maroon) msize(medium) )  (function y=0    ,range(5 13) lcolor(black) lwidth(medthin)),  yscale(range(-.2 .2) titlegap(.05)) yline(0, lcolor(black) lwidth(medthin)) xlabel( 5 6 7 8 9 10 11 12 13, valuelabel) ylabel( -.2 -.1 0 .1 .2) ytitle(Coefficient) legend(off)  graphregion(fcolor(white)) title("Probability of Israeli non-targeted attack", color(black))  xtitle("") subtitle("lags and leads of news pressure", color(black))
graph export "$figures/figure_5_col1_a.pdf", replace
restore

* Event study: occurrence of targeted Israeli attacks 

preserve
xi: newey occurrence_target D5-D13 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0,lag(7) force 

gen time=date-14881
gen coef =.
gen low_g =.
gen high_g =.
sort date

forval k=5/13 {
replace coef = _b[D`k'] if time==`k'
replace low_g = _b[D`k']-1.64*_se[D`k'] if time==`k'
replace high_g = _b[D`k']+1.64*_se[D`k'] if time==`k'
}
collapse (mean) coef high_g low_g, by(time)
keep if time<=13
keep if time>4

label def ti 5 "T-3" 6 "T-2" 7 "T-1" 8 "T" 9 "T+1" 10 "T+2" 11 "T+3" 12 "T+4" 13 "T+5" 
label values t ti
twoway (rarea low hi t, sort color(gs14)) (scatter coef t, connect(l) lwidth(medthick) lcolor(maroon) mcolor(maroon) msize(medium) )  (function y=0    ,range(5 13) lcolor(black) lwidth(medthin)),  yscale(range(-.2 .2) titlegap(.05)) yline(0, lcolor(black) lwidth(medthin)) xlabel( 5 6 7 8 9 10 11 12 13, valuelabel) ylabel( -.2 -.1 0 .1 .2) ytitle(Coefficient) legend(off)  graphregion(fcolor(white)) title("Probability of a targeted killing", color(black))  xtitle("") subtitle("lags and leads of news pressure", color(black))
graph export "$figures/figure_5_col2_a.pdf", replace
restore

* Event study: occurrence of fatal Israeli attacks 

xi: newey occurrence_fatal D5-D13 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0,lag(7) force 
preserve
gen time=date-14881
gen coef =.
gen low_g =.
gen high_g =.
sort date

forval k=5/13 {
replace coef = _b[D`k'] if time==`k'
replace low_g = _b[D`k']-1.64*_se[D`k'] if time==`k'
replace high_g = _b[D`k']+1.64*_se[D`k'] if time==`k'
}

collapse (mean) coef high_g low_g, by(time)
keep if time<=13
keep if time>4
label def ti 5 "T-3" 6 "T-2" 7 "T-1" 8 "T" 9 "T+1" 10 "T+2" 11 "T+3" 12 "T+4" 13 "T+5" 
label values t ti
twoway (rarea low hi t, sort color(gs14)) (scatter coef t, connect(l) lwidth(medthick) lcolor(maroon) mcolor(maroon) msize(medium) )  (function y=0    ,range(5 13) lcolor(black) lwidth(medthin)),  yscale(range(-.2 .2) titlegap(.05)) yline(0, lcolor(black) lwidth(medthin)) xlabel( 5 6 7 8 9 10 11 12 13, valuelabel) ylabel( -.2 -.1 0 .1 .2) ytitle(Coefficient) legend(off)  graphregion(fcolor(white)) title("Probability of a fatal Israeli attack", color(black))  xtitle("") subtitle("lags and leads of news pressure", color(black))
graph export "$figures/figure_5_col1_b.pdf", replace
restore

* Event study: occurrence of non-fatal Israeli attacks 

xi: newey occurrence_non_fatal D5-D13 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0&occurrence_fatal ==0,lag(7) force 
preserve
gen time=date-14881
gen coef =.
gen low_g =.
gen high_g =.
sort date

forval k=5/13 {
replace coef = _b[D`k'] if time==`k'
replace low_g = _b[D`k']-1.64*_se[D`k'] if time==`k'
replace high_g = _b[D`k']+1.64*_se[D`k'] if time==`k'
}
collapse (mean) coef high_g low_g, by(time)
keep if time<=13
keep if time>4

label def ti 5 "T-3" 6 "T-2" 7 "T-1" 8 "T" 9 "T+1" 10 "T+2" 11 "T+3" 12 "T+4" 13 "T+5" 
label values t ti
twoway (rarea low hi t, sort color(gs14)) (scatter coef t, connect(l) lwidth(medthick) lcolor(maroon) mcolor(maroon) msize(medium) )  (function y=0    ,range(5 13) lcolor(black) lwidth(medthin)),  yscale(range(-.2 .2) titlegap(.05)) yline(0, lcolor(black) lwidth(medthin)) xlabel( 5 6 7 8 9 10 11 12 13, valuelabel) ylabel( -.2 -.1 0 .1 .2) ytitle(Coefficient) legend(off)  graphregion(fcolor(white)) title("Probability of Israeli non-deadly attacks", color(black))  xtitle("") subtitle("lags and leads of news pressure", color(black))
graph export "$figures/figure_5_col2_b.pdf", replace
restore

* Event study: occurrence of Israeli attacks in highly densely populated areas

xi: newey occurrence_hpd D5-D13 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0,lag(7) force 
preserve
gen time=date-14881
gen coef =.
gen low_g =.
gen high_g =.
sort date

forval k=5/13 {
replace coef = _b[D`k'] if time==`k'
replace low_g = _b[D`k']-1.64*_se[D`k'] if time==`k'
replace high_g = _b[D`k']+1.64*_se[D`k'] if time==`k'
}
collapse (mean) coef high_g low_g, by(time)
keep if time<=13
keep if time>4

label def ti 5 "T-3" 6 "T-2" 7 "T-1" 8 "T" 9 "T+1" 10 "T+2" 11 "T+3" 12 "T+4" 13 "T+5" 
label values t ti
twoway (rarea low hi t, sort color(gs14)) (scatter coef t, connect(l) lwidth(medthick) lcolor(maroon) mcolor(maroon) msize(medium) )  (function y=0    ,range(5 13) lcolor(black) lwidth(medthin)),  yscale(range(-.2 .2) titlegap(.05)) yline(0, lcolor(black) lwidth(medthin)) xlabel( 5 6 7 8 9 10 11 12 13, valuelabel) ylabel( -.2 -.1 0 .1 .2) ytitle(Coefficient) legend(off)  graphregion(fcolor(white)) title("Occurrence of Israeli attacks in high density areas", color(black))  xtitle("") subtitle("lags and leads of news pressure", color(black))
graph export "$figures/figure_5_col1_c.pdf", replace
restore

* Event study: occurrence of Israeli attacks in low densely populated areas

xi: newey occurrence_lpd D5-D13 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0&occurrence_hpd==0,lag(7) force 
preserve
gen time=date-14881
gen coef =.
gen low_g =.
gen high_g =.
sort date

forval k=5/13 {
replace coef = _b[D`k'] if time==`k'
replace low_g = _b[D`k']-1.64*_se[D`k'] if time==`k'
replace high_g = _b[D`k']+1.64*_se[D`k'] if time==`k'
}

collapse (mean) coef high_g low_g, by(time)
keep if time<=13
keep if time>4
label def ti 5 "T-3" 6 "T-2" 7 "T-1" 8 "T" 9 "T+1" 10 "T+2" 11 "T+3" 12 "T+4" 13 "T+5" 
label values t ti
twoway (rarea low hi t, sort color(gs14)) (scatter coef t, connect(l) lwidth(medthick) lcolor(maroon) mcolor(maroon) msize(medium) )  (function y=0    ,range(5 13) lcolor(black) lwidth(medthin)),  yscale(range(-.2 .2) titlegap(.05)) yline(0, lcolor(black) lwidth(medthin)) xlabel( 5 6 7 8 9 10 11 12 13, valuelabel) ylabel( -.2 -.1 0 .1 .2) ytitle(Coefficient) legend(off)  graphregion(fcolor(white)) title("Occurrence of Israeli attacks in low density areas", color(black))  xtitle("") subtitle("lags and leads of news pressure", color(black))
graph export "$figures/figure_5_col2_c.pdf", replace
restore

* Event study: occurrence of Israeli attacks involving the use of heavy weapons

xi: newey occurrence_hw D5-D13 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0,lag(7) force 
preserve
gen time=date-14881
gen coef =.
gen low_g =.
gen high_g =.
sort date

forval k=5/13 {
replace coef = _b[D`k'] if time==`k'
replace low_g = _b[D`k']-1.64*_se[D`k'] if time==`k'
replace high_g = _b[D`k']+1.64*_se[D`k'] if time==`k'
}
collapse (mean) coef high_g low_g, by(time)
keep if time<=13
keep if time>4
label def ti 5 "T-3" 6 "T-2" 7 "T-1" 8 "T" 9 "T+1" 10 "T+2" 11 "T+3" 12 "T+4" 13 "T+5" 
label values t ti
twoway (rarea low hi t, sort color(gs14)) (scatter coef t, connect(l) lwidth(medthick) lcolor(maroon) mcolor(maroon) msize(medium) )  (function y=0    ,range(5 13) lcolor(black) lwidth(medthin)),  yscale(range(-.2 .2) titlegap(.05)) yline(0, lcolor(black) lwidth(medthin)) xlabel( 5 6 7 8 9 10 11 12 13, valuelabel) ylabel( -.2 -.1 0 .1 .2) ytitle(Coefficient) legend(off)  graphregion(fcolor(white)) title("Occurrence of Israeli attacks with heavy weapons", color(black))  xtitle("") subtitle("lags and leads of news pressure", color(black))
graph export "$figures/figure_5_col1_d.pdf", replace
restore

* Event study: occurrence of Israeli attacks involving the use of light weapons

xi: newey occurrence_nhw D5-D13 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0&occurrence_hw==0,lag(7) force 
preserve
gen time=date-14881
gen coef =.
gen low_g =.
gen high_g =.
sort date

forval k=5/13 {
replace coef = _b[D`k'] if time==`k'
replace low_g = _b[D`k']-1.64*_se[D`k'] if time==`k'
replace high_g = _b[D`k']+1.64*_se[D`k'] if time==`k'
}
collapse (mean) coef high_g low_g, by(time)
keep if time<=13
keep if time>4
label def ti 5 "T-3" 6 "T-2" 7 "T-1" 8 "T" 9 "T+1" 10 "T+2" 11 "T+3" 12 "T+4" 13 "T+5" 
label values t ti
twoway (rarea low hi t, sort color(gs14)) (scatter coef t, connect(l) lwidth(medthick) lcolor(maroon) mcolor(maroon) msize(medium) )  (function y=0    ,range(5 13) lcolor(black) lwidth(medthin)),  yscale(range(-.2 .2) titlegap(.05)) yline(0, lcolor(black) lwidth(medthin)) xlabel( 5 6 7 8 9 10 11 12 13, valuelabel) ylabel( -.2 -.1 0 .1 .2) ytitle(Coefficient) legend(off)  graphregion(fcolor(white)) title("Occurrence of Israeli attacks with light weapons", color(black))  xtitle("") subtitle("lags and leads of news pressure", color(black))
graph export "$figures/figure_5_col2_d.pdf", replace
restore

* Multinomial logit: targeted vs. non-targeted attacks

preserve

mlogit attacks_target leaddaily_woi occurrence_pal_1 occurrence_pal_2_7    ///
occurrence_pal_8_14 lagdaily_woi-lagdaily_woi7 ///
i.month i.year i.dow if gaza_war==0, ///
cluster(monthyear) baseoutcome(1)
forvalues k=2/3 {
margins, dydx(leaddaily_woi) atmeans predict(outcome(`k')) saving("attacks_target_`k'.dta", replace)
}

forvalues k=2/3 {
use "attacks_target_`k'.dta", clear
keep _margin _ci_lb _ci_ub
rename (_margin _ci_lb _ci_ub) (coef ci_lower ci_upper)
gen var = `k'
save "attacks_target_`k'.dta", replace
}
	
append using "attacks_target_2.dta", force
	
gen var_estimate = .
forvalues k=2/3 {
replace var_estimate = `k' if var == `k'
}
drop var
order var_estimate
sort var_estimate

#delimit ;
twoway (rcap ci_lower ci_upper var_estimate if var_estimate == 2, lcolor(black) title("Multinomial logit")) 
(scatter coef var_estimate if var_estimate == 2, mcolor(black) msize(.9))
(rcap ci_lower ci_upper var_estimate if var_estimate == 3, lcolor(black)) 
(scatter coef var_estimate if var_estimate == 3, mcolor(black) msize(.9)
ytitle("Marginal effect of P t+1")
xtitle("Days with attacks", height(3) margin(vsmall)) 
xlabel(2 "Targeted" 3 "Non-targeted") 
xscale(range(1(1)4))
graphregion(color(white)) legend(off));
#delimit cr
graph export "$figures/figure_5_col3_a.pdf", replace
restore
	
* Multinomial logit fatal vs. non-fatal attacks

preserve

mlogit attacks_fatal leaddaily_woi occurrence_pal_1 occurrence_pal_2_7    ///
occurrence_pal_8_14 lagdaily_woi-lagdaily_woi7 ///
i.month i.year i.dow if gaza_war==0 ,   ///
cluster(monthyear) baseoutcome(1)
forvalues k=2/3 {
margins, dydx(leaddaily_woi) atmeans predict(outcome(`k')) saving("attacks_fatal_`k'.dta", replace)
}

forvalues k=2/3 {
use "attacks_fatal_`k'.dta", clear
keep _margin _ci_lb _ci_ub
rename (_margin _ci_lb _ci_ub) (coef ci_lower ci_upper)
gen var = `k'
save "attacks_fatal_`k'.dta", replace
}

append using "attacks_fatal_2.dta", force

gen var_estimate = .
forvalues k=2/3 {
replace var_estimate = `k' if var == `k'
}
drop var
order var_estimate
sort var_estimate

#delimit ;
twoway (rcap ci_lower ci_upper var_estimate if var_estimate == 2, lcolor(black) title("Multinomial logit")) 
(scatter coef var_estimate if var_estimate == 2, mcolor(black) msize(.9))
(rcap ci_lower ci_upper var_estimate if var_estimate == 3, lcolor(black)) 
(scatter coef var_estimate if var_estimate == 3, mcolor(black) msize(.9)
ytitle("Marginal effect of P t+1")
xtitle("Days with attacks", height(3) margin(vsmall)) 
xlabel(2 "Non-fatal" 3 "Fatal") 
xscale(range(1(1)4))
graphregion(color(white)) legend(off));
#delimit cr
graph export "$figures/figure_5_col3_b.pdf", replace
restore
	
* Multinomial logit attacks in more vs. less densely populated areas

preserve

mlogit attacks_hpd leaddaily_woi occurrence_pal_1 occurrence_pal_2_7    ///
occurrence_pal_8_14 lagdaily_woi-lagdaily_woi7 ///
i.month i.year i.dow if gaza_war==0 , ///
cluster(monthyear) baseoutcome(1)
forvalues k=2/3 {
margins, dydx(leaddaily_woi) atmeans predict(outcome(`k')) saving("attacks_hpd_`k'.dta", replace)
}

forvalues k=2/3 {
use "attacks_hpd_`k'.dta", clear
keep _margin _ci_lb _ci_ub
rename (_margin _ci_lb _ci_ub) (coef ci_lower ci_upper)
gen var = `k'
save "attacks_hpd_`k'.dta", replace
}

append using "attacks_hpd_2.dta", force

gen var_estimate = .
forvalues k=2/3 {
replace var_estimate = `k' if var == `k'
}
drop var
order var_estimate
sort var_estimate

#delimit ;
twoway (rcap ci_lower ci_upper var_estimate if var_estimate == 2, lcolor(black) title("Multinomial logit")) 
(scatter coef var_estimate if var_estimate == 2, mcolor(black) msize(.9))
(rcap ci_lower ci_upper var_estimate if var_estimate == 3, lcolor(black)) 
(scatter coef var_estimate if var_estimate == 3, mcolor(black) msize(.9)
ytitle("Marginal effect of P t+1")
xtitle("Days w. attacks in areas with population density", height(3) margin(vsmall)) 
xlabel(2 "Low density" 3 "High density")
xscale(range(1(1)4)) 
graphregion(color(white)) legend(off));
#delimit cr
graph export "$figures/figure_5_col3_c.pdf", replace
restore

* Multinomial logit attacks with heavy vs. light weapons

preserve

mlogit attacks_hw leaddaily_woi occurrence_pal_1 occurrence_pal_2_7    ///
occurrence_pal_8_14 lagdaily_woi-lagdaily_woi7 ///
i.month i.year i.dow if gaza_war==0 ,    ///
cluster(monthyear) baseoutcome(1)
forvalues k=2/3 {
margins, dydx(leaddaily_woi) atmeans predict(outcome(`k')) saving("attacks_hw_`k'.dta", replace)
}

forvalues k=2/3 {
use "attacks_hw_`k'.dta", clear
keep _margin _ci_lb _ci_ub
rename (_margin _ci_lb _ci_ub) (coef ci_lower ci_upper)
gen var = `k'
save "attacks_hw_`k'.dta", replace
}

append using "attacks_hw_2.dta", force

gen var_estimate = .
forvalues k=2/3 {
replace var_estimate = `k' if var == `k'
}
drop var
order var_estimate
sort var_estimate

#delimit ;
twoway (rcap ci_lower ci_upper var_estimate if var_estimate == 2, lcolor(black) title("Multinomial logit")) 
(scatter coef var_estimate if var_estimate == 2, mcolor(black) msize(.9))
(rcap ci_lower ci_upper var_estimate if var_estimate == 3, lcolor(black)) 
(scatter coef var_estimate if var_estimate == 3, mcolor(black) msize(.9)
ytitle("Marginal effect of P t+1")
xtitle("Days with attacks using weapons", height(3) margin(vsmall))
xlabel(2 "Light only" 3 "Heavy (and light)") 
xscale(range(1(1)4)) 
graphregion(color(white)) legend(off));
#delimit cr
graph export "$figures/figure_5_col3_d.pdf", replace
restore

foreach x in target fatal hpd hw {
forvalues k=2/3 {
erase "attacks_`x'_`k'.dta"
}
}

******************************************************************************************
** Figure 6. Difference between Conflict Coverage between the Same and the Previous Day
******************************************************************************************

* Panel A: Probability and length of conflict news

* Probability of conflict-related news

use "$dta/replication_file1.dta", clear

preserve
sort date
reg any_conflict_news occurrence occurrence_1 occurrence_pal l.occurrence_pal daily_woi  i.month  i.dow if gaza==0, cluster(monthyear)
regsave, ci
keep if var == "occurrence" | var == "occurrence_1"
keep var coef ci_lower ci_upper
encode var, gen(variable)
gen barposition = cond(variable==1, _n, _n)
gen coef1=coef
replace coef1=0.06 if barposition==2
gen coef2=coef
replace coef2=0.06 if _n==1

#delimit ;
twoway  (bar coef1 barposition, color (navy) base(0.06) fintensity(100)) (bar coef2 barposition, color (gs12) base(0.06) fintensity(100)) 
(rcap ci_lower ci_upper barposition, lwidth(medium) lcolor(gs8)  legend(off)
yscale(range(0.06(0.02)0.18)) ytick(0.06(0.02)0.18) ylabel(0.06(0.02)0.18)
xscale(range(0(0.5)3)) xtitle("") 
xlabel(1 "same-day" 2 "next-day" )
title("Probability of conflict news", color(black)) 
graphregion(color(white))) ;
#delimit cr
graph save Graph "$figures/figure_6_a1.gph", replace
restore

* Length of conflict-related news

preserve
tnbreg length_conflict_news occurrence occurrence_1 occurrence_pal l.occurrence_pal daily_woi i.month  i.dow if gaza==0 & any_conflict_news==1, ll(0)  vce(cluster monthyear)
regsave, ci
keep if var == "length_conflict_news:occurrence" | var == "length_conflict_news:occurrence_1"
keep var coef ci_lower ci_upper
encode var, gen(variable)
gen barposition = cond(variable==1, _n, _n)
gen coef1=coef
replace coef1=0 if barposition==2
gen coef2=coef
replace coef2=0 if _n==1

#delimit ;
twoway (bar coef1 barposition, color (navy) fintensity(100)) (bar coef2 barposition, color (gs12) fintensity(100)) 
(rcap ci_lower ci_upper barposition, lwidth(medium) lcolor(gs8)  legend(off)
yscale(range(-0.4(0.2)0.8)) ytick(-0.4(0.2)0.8) ylabel(-0.4(0.2)0.8)
xscale(range(0(0.5)3)) xtitle("") 
xlabel(1 "same-day" 2 "next-day" )
title("Length of conflict news", color(black))
subtitle("conditional on conflict being covered")
graphregion(color(white))) ;
#delimit cr
graph save Graph "$figures/figure_6_a2.gph", replace

* Combine graphs
cd "$figures/"
graph combine "figure_6_a1.gph" "figure_6_a2.gph", title("The effect of an Israeli attack on the probability and length ", size(medlarge) color(black)) subtitle("of conflict news that air on the same day and on the next day", color(black)) graphregion(color(white))
graph export "$figures/figure_6a.pdf", replace
erase "$figures/figure_6_a2.gph"
erase "$figures/figure_6_a1.gph"
restore

* Volume of Google searches following news about israeli attacks 

use "$dta/replication_file1.dta", clear

* Generate interaction terms between presence of conflict news at t and occurrence of Israeli attacks at t and t-1
gen conflict_news_isr_occ_t=any_conflict_news*occurrence
gen conflict_news_isr_occ_t_1=any_conflict_news*l1.occurrence

label var conflict_news_isr_occ_t "Any conflict news x Israeli attack, same day"
label var conflict_news_isr_occ_t_1 "Any conflict news x Israeli attack, previous day"

reg conflict_searches conflict_news_isr_occ_t conflict_news_isr_occ_t_1 if ((occurrence==0& l.occurrence==1)|(occurrence==1& l.occurrence==0)|(occurrence==1& l.occurrence==1))&occurrence_pal==0&l.occurrence_pal==0&length_conflict_news>0 , nocons cl(monthyear)
test conflict_news_isr_occ_t=conflict_news_isr_occ_t_1
regsave, ci

foreach x in coef ci_lower ci_upper {
gen `x'_100 = `x'
}

keep var *_100 
encode var, gen(events)
gsort -coef_100
gen x = _n
gen barposition = cond(events==1, _n,_n)
gen coef_2dec = coef_100
format coef_2dec %9.2f
local c1 = coef_2dec[1]
local c2 = coef_2dec[2]

#delimit ;
twoway (bar coef_100 barposition if events == 2, fcolor(navy) fintensity(100)) 
(bar coef_100 barposition if events == 1, fcolor(gs12) fintensity(100)) 
(rcap ci_lower_100 ci_upper_100 barposition, legend(off)
lwidth(medium) lcolor(gs8)
yscale(range(0(1)2)) ytick(0(1)3) ylabel(0(1)3)
xscale(range(0(0.5)3)) xtitle("") 
xlabel(1 "next-day" 2 "same-day")
title("Volume of google searches", color(black))
subtitle("following the same-day vs. next-day news about an Israeli attack")
caption("Days with news at t about Isr. attack at t or t-1 and no Pal. attacks at t or t-1")
graphregion(color(white))) ;
#delimit cr
graph export "$figures/figure_6_a3.pdf", replace

* Panel B: Content of news on Israeli attacks (same day vs. next day)

use "$dta/replication_file2.dta", clear

gen q8_inv=1-q8
label define samenext 0 "next-day" 1 "same-day"
label values q8_inv samenext
cibar  q14  if (q5==1)&(q4==1)&(q7==1 | q8==1)&(q6==0), over1(q8_inv) barcol(navy gs12)  level(90) graphopts(ytitle("info: # of civilian victims") name(q14, replace) graphregion(color(white))) 
cibar  q19  if (q5==1)&(q4==1)&(q7==1 | q8==1)&(q6==0), over1(q8_inv) barcol(navy gs12)  level(90) graphopts(ytitle("civilian victim personal info") name(q19, replace) graphregion(color(white)))
cibar  q20  if (q5==1)&(q4==1)&(q7==1 | q8==1)&(q6==0), over1(q8_inv) barcol(navy gs12)  level(90) graphopts(ytitle("footage of burials/mourning") name(q20, replace)  graphregion(color(white)))
cibar  q21_q22   if (q5==1)&(q4==1)&(q7==1 | q8==1)&(q6==0), over1(q8_inv) barcol(navy gs12) level(90) graphopts(ytitle("interview: relatives/witnesses") name(q21, replace)  graphregion(color(white)))
graph combine q14 q19 q20 q21, graphregion(fcolor(white)) title(Content of newscasts about Israeli attacks, color(black) margin(tiny) size(medlarge)) subtitle(when covered on the same and on the next day (frequency), color(black) margin(tiny) size(medlarge))
graph export "$figures/figure_6b.pdf", replace

*********************************************************************************************************
										 *** APPENDIX TABLES ***
*********************************************************************************************************

************************************************************
** Table A1. Descriptive statistics 
************************************************************

use "$dta/replication_file1.dta", clear

#delimit ;
tabstat daily_woi 
		daily_woi_nc 
		any_conflict_news 
		num_conflict_news 
		length_conflict_news 
		conflict_searches
		occurrence
		occurrence_pal
		victims_isr 
		victims_pal
		lnvic 
		lnvic_pal
		occurrence_target
		occurrence_non_target
		victims_target 
		victims_non_target  
		occurrence_all
		occurrence_fatal
		occurrence_non_fatal
		occurrence_hw
		occurrence_nhw
		occurrence_hpd
		occurrence_lpd
		fatal_victims 
		non_fatal_victims
		victims_hw
		victims_nhw
		victims_hpd
		victims_lpd
		high_intensity 
		lead_maj_events 
		lead_disaster, 
		statistics(N mean sd min max) column(statistics) ;
#delimit cr

*********************************************************************
** Table A3. Placebo Test for a Mechanical Relationship Between
**         Disaster-free News Pressure and News on Disasters
*********************************************************************

* Panel A: Onset of disasters gets covered by the news

use "$dta/replication_file3.dta", clear

foreach x in any_disaster_news disaster_onset any_disaster_news_nk disaster_onset_nk length_disasters_news length_disasters_news_nk{
replace `x'=. if (date>td(10sep2001) & date<td(18sep2001))
}

sort date

* Full sample

xi: reg any_disaster_news disaster_onset i.year i.month i.dow, robust cluster(monthyear)
outreg2 using "$tables/table_A3_a.xls", replace ctitle("Any disaster news (same day)") keep(disaster_onset) nocons label bdec(3)

xi: reg f1.any_disaster_news disaster_onset i.year i.month i.dow, robust cluster(monthyear)
outreg2 using "$tables/table_A3_a.xls", append ctitle("Any disaster news (next day)") keep(disaster_onset) nocons label bdec(3)

xi: reg length_disasters_news disaster_onset i.year i.month i.dow, robust cluster(monthyear)
outreg2 using "$tables/table_A3_a.xls", append ctitle("Length of disaster news (same day)") keep(disaster_onset) nocons label bdec(3)

xi: reg f1.length_disasters_news disaster_onset i.year i.month i.dow, robust cluster(monthyear)
outreg2 using "$tables/table_A3_a.xls", append ctitle("Length of disaster news (next day)") keep(disaster_onset) nocons label bdec(3)

* Excluding hurricane Katrina

xi: reg any_disaster_news_nk disaster_onset_nk i.year i.month i.dow, robust cluster(monthyear)
outreg2 using "$tables/table_A3_a.xls", append ctitle("Any disaster news (same day)") keep(disaster_onset_nk) nocons label bdec(3)

xi: reg f1.any_disaster_news_nk disaster_onset_nk i.year i.month i.dow, robust cluster(monthyear)
outreg2 using "$tables/table_A3_a.xls", append ctitle("Any disaster news (next day)") keep(disaster_onset_nk) nocons label bdec(3)

xi: reg length_disasters_news_nk disaster_onset_nk i.year i.month i.dow, robust cluster(monthyear)
outreg2 using "$tables/table_A3_a.xls", append ctitle("Length of disaster news (same day)") keep(disaster_onset_nk) nocons label bdec(3)

xi: reg f1.length_disasters_news_nk disaster_onset_nk i.year i.month i.dow, robust cluster(monthyear)
outreg2 using "$tables/table_A3_a.xls", append ctitle("Length of disaster news (next day)") keep(disaster_onset_nk) nocons label bdec(3)

* Panel B: No mechanical bias in corrected news pressure and a negative bias in uncorrected news pressure

* Full sample

xi: reg disaster_onset daily_wod i.year i.month i.dow if interpolated_news==0, robust cluster(monthyear)
outreg2 using "$tables/table_A3_b.xls", replace ctitle("Onset of disaster") keep(daily_wod) nocons label bdec(3)

xi: reg disaster_onset f1.daily_wod  i.year i.month i.dow if interpolated_news==0, robust cluster(monthyear)
outreg2 using "$tables/table_A3_b.xls", append ctitle("Onset of disaster") keep(f1.daily_wod) nocons label bdec(3)

xi: reg disaster_onset daily_wod_nc i.year i.month i.dow if interpolated_news==0, robust cluster(monthyear)
outreg2 using "$tables/table_A3_b.xls", append ctitle("Onset of disaster") keep(daily_wod_nc) nocons label bdec(3)

xi: reg disaster_onset f1.daily_wod_nc  i.year i.month i.dow if interpolated_news==0, robust cluster(monthyear)
outreg2 using "$tables/table_A3_b.xls", append ctitle("Onset of disaster") keep(f1.daily_wod_nc) nocons label bdec(3)

* Excluding hurricane Katrina

xi: reg disaster_onset_nk daily_wod_nk i.year i.month i.dow if interpolated_news==0, robust cluster(monthyear)
outreg2 using "$tables/table_A3_b.xls", append ctitle("Onset of disaster") keep(daily_wod_nk) nocons label bdec(3)

xi: reg disaster_onset_nk f1.daily_wod_nk  i.year i.month i.dow if interpolated_news==0, robust cluster(monthyear)
outreg2 using "$tables/table_A3_b.xls", append ctitle("Onset of disaster") keep(f1.daily_wod_nk) nocons label bdec(3)

xi: reg disaster_onset_nk daily_wod_nc_nk i.year i.month i.dow if interpolated_news==0, robust cluster(monthyear)
outreg2 using "$tables/table_A3_b.xls", append ctitle("Onset of disaster") keep(daily_wod_nc_nk) nocons label bdec(3)

xi: reg disaster_onset_nk f1.daily_wod_nc_nk  i.year i.month i.dow if interpolated_news==0, robust cluster(monthyear)
outreg2 using "$tables/table_A3_b.xls", append ctitle("Onset of disaster") keep(f1.daily_wod_nc_nk) nocons label bdec(3)

***********************************************************************************
** Table A5. News Pressure and Major Events  
***********************************************************************************

use "$dta/replication_file1.dta", clear

sort date

xi: reg daily_woi presidential_inauguration nh_presidential_primary general_election main_national_conventions super_tuesday iowa_caucuses state_of_the_union  other_presidential_caucuses  other_presidential_primaries statewide_elections congress_start_session special_congressional_elections gubernatorial_elections state_primary  special_senate_elections i.year i.dow i.month, cluster(monthyear)
outreg2 using "$tables/table_A5.xls", replace ctitle("NP ") keep(presidential_inauguration nh_presidential_primary general_election main_national_conventions super_tuesday iowa_caucuses state_of_the_union  other_presidential_caucuses  other_presidential_primaries statewide_elections congress_start_session special_congressional_elections gubernatorial_elections state_primary  special_senate_elections) nocons label bdec(3)

xi: reg daily_woi f.general_election f2.general_election  general_election l.general_election l2.general_election  l.nh_presidential_primary nh_presidential_primary  f.nh_presidential_primary  l.super_tuesday super_tuesday  f.super_tuesday l.presidential_caucuses presidential_caucuses  f.presidential_caucuses f1.presidential_inauguration presidential_inauguration l.presidential_inauguration i.year i.dow i.month, cluster(monthyear)
outreg2 using "$tables/table_A5.xls", append ctitle("NP ") keep(f.general_election f2.general_election  general_election l.general_election l2.general_election  l.nh_presidential_primary nh_presidential_primary  f.nh_presidential_primary  l.super_tuesday super_tuesday  f.super_tuesday l.presidential_caucuses presidential_caucuses  f.presidential_caucuses f1.presidential_inauguration presidential_inauguration l.presidential_inauguration)  nocons label bdec(3)

xi: reg daily_woi worldcup olympics worldseries marchmadness nbafinals eurocup other_sport_events i.month i.year i.dow , cluster(monthyear)
outreg2 using "$tables/table_A5.xls", append ctitle("NP ") keep(worldcup olympics worldseries marchmadness nbafinals eurocup other_sport_events) nocons label bdec(3)

xi: reg daily_woi major_events i.month i.year i.dow , cluster(monthyear)
outreg2 using "$tables/table_A5.xls", append ctitle("NP ") keep(major_events) nocons label bdec(3)

**********************************************************************
**  Table A6.  Palestinian Attacks and Uncorrected News Pressure
**********************************************************************

use "$dta/replication_file1.dta", clear
sort date

xi: reg occurrence_pal daily_woi_nc i.month i.year i.dow if gaza_war==0, cluster(monthyear)
outreg2 using "$tables/table_A6.xls", replace ctitle("Occurrence") keep(daily_woi_nc) nocons label bdec(3)

xi: newey occurrence_pal daily_woi_nc leaddaily_woi_nc occurrence_1 occurrence_2_7 occurrence_8_14 i.month i.year i.dow if gaza_war==0, lag(7) force
outreg2 using "$tables/table_A6.xls", append ctitle("Occurrence") keep(daily_woi_nc leaddaily_woi_nc  lagdaily_woi_nc occurrence_1 occurrence_2_7 occurrence_8_14) nocons label bdec(3)

xi: newey occurrence_pal daily_woi_nc leaddaily_woi_nc lagdaily_woi_nc-lagdaily_woi7_nc occurrence_1 occurrence_2_7 occurrence_8_14 i.month i.year i.dow if gaza_war==0, lag(7) force
outreg2 using "$tables/table_A6.xls", append ctitle("Occurrence") keep(daily_woi_nc leaddaily_woi_nc  lagdaily_woi_nc occurrence_1 occurrence_2_7 occurrence_8_14) nocons label bdec(3)

xi: reg lnvic_pal daily_woi_nc i.month i.year i.dow if gaza_war==0, cluster(monthyear)
outreg2 using "$tables/table_A6.xls", append ctitle("Ln(victims)") keep(daily_woi_nc) nocons label bdec(3)

xi: newey lnvic_pal daily_woi_nc leaddaily_woi_nc  occurrence_1 occurrence_2_7 occurrence_8_14 i.month i.year i.dow if gaza_war==0,lag(7) force 
outreg2 using "$tables/table_A6.xls", append ctitle("Ln(victims)") keep(daily_woi_nc leaddaily_woi_nc lagdaily_woi_nc  lagdaily_woi_nc occurrence_1 occurrence_2_7 occurrence_8_14) nocons label bdec(3)

xi: newey lnvic_pal daily_woi_nc leaddaily_woi_nc lagdaily_woi_nc-lagdaily_woi7_nc occurrence_1 occurrence_2_7 occurrence_8_14 i.month i.year i.dow if gaza_war==0, lag(7) force 
outreg2 using "$tables/table_A6.xls", append ctitle("Ln(victims)") keep(daily_woi_nc leaddaily_woi_nc  lagdaily_woi_nc occurrence_1 occurrence_2_7 occurrence_8_14) nocons label bdec(3)

xi: glm victims_pal daily_woi_nc leaddaily_woi_nc lagdaily_woi_nc-lagdaily_woi7_nc occurrence_1 occurrence_2_7 occurrence_8_14 i.month i.year i.dow if gaza_war==0, family(nbinom ml) vce(hac nwest 7)
outreg2 using "$tables/table_A6.xls", append ctitle("Num. victims") keep(daily_woi_nc leaddaily_woi_nc  lagdaily_woi_nc occurrence_1 occurrence_2_7 occurrence_8_14) nocons label bdec(3)

* Corresponding OLS and negative binomial regressions to display (pseudo) R-squared:
eststo clear
eststo: xi: reg occurrence_pal daily_woi_nc i.month i.year i.dow if gaza_war==0, cluster(monthyear)
eststo: xi: reg occurrence_pal daily_woi_nc leaddaily_woi_nc i.month i.year i.dow if gaza_war==0, cluster(monthyear)
eststo: xi: reg occurrence_pal daily_woi_nc leaddaily_woi_nc lagdaily_woi_nc-lagdaily_woi7_nc occurrence_1 occurrence_2_7 occurrence_8_14 i.month i.year i.dow if gaza_war==0, cluster(monthyear)
eststo: xi: reg lnvic_pal daily_woi_nc i.month i.year i.dow if gaza_war==0, cluster(monthyear)
eststo: xi: reg lnvic_pal daily_woi_nc leaddaily_woi_nc i.month i.year i.dow if gaza_war==0, cluster(monthyear) 
eststo: xi: reg lnvic_pal daily_woi_nc leaddaily_woi_nc lagdaily_woi_nc-lagdaily_woi7_nc occurrence_1 occurrence_2_7 occurrence_8_14 i.month i.year i.dow if gaza_war==0, cluster(monthyear) 
eststo: xi: nbreg victims_pal daily_woi_nc leaddaily_woi_nc lagdaily_woi_nc-lagdaily_woi7_nc occurrence_1 occurrence_2_7 occurrence_8_14 i.month i.year i.dow if gaza_war==0, cluster(monthyear)
esttab, se r2 pr2 star(* 0.10 ** 0.05 *** 0.01)

**************************************************************************************
**   Table A7. Israeli Attacks and News Pressure - Robustness Checks        
**************************************************************************************

use "$dta/replication_file1.dta", clear

* Panel A: Occurrence of Attacks

xi: newey occurrence daily_woi leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 l1.occurrence l2.occurrence l3.occurrence l4.occurrence l5.occurrence l6.occurrence l7.occurrence i.month i.year i.dow if gaza_war==0, lag(7) force
outreg2 using "$tables/table_A7_a.xls", replace ctitle("Occurrence") keep(leaddaily_woi) nocons label bdec(3)

xi: newey occurrence daily_woi leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow , lag(7) force
outreg2 using "$tables/table_A7_a.xls",append ctitle("Occurrence") keep(leaddaily_woi) nocons label bdec(3)

xi: reg  occurrence daily_woi leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, cluster(monthyear)
outreg2 using "$tables/table_A7_a.xls", append ctitle("Occurrence") keep(leaddaily_woi) nocons label bdec(3)

xi: newey occurrence leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, lag(7) force
outreg2 using "$tables/table_A7_a.xls", append ctitle("Occurrence") keep(leaddaily_woi) nocons label bdec(3)

xi: newey occurrence           leaddaily_woi                            occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, lag(7) force
outreg2 using "$tables/table_A7_a.xls", append ctitle("Occurrence") keep(leaddaily_woi) nocons label bdec(3)

xi: newey occurrence leaddaily_woi lagdaily_woi-lagdaily_woi7 leaddaily_woi-leaddaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, lag(7) force
outreg2 using "$tables/table_A7_a.xls", append ctitle("Occurrence") keep(leaddaily_woi) nocons label bdec(3)

xi: newey occurrence daily_woi leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0 & interpolated_news==0, lag(7) force
outreg2 using "$tables/table_A7_a.xls",append ctitle("Occurrence") keep(leaddaily_woi) nocons label bdec(3)

xi: newey occurrence daily_woi_c_med leaddaily_woi_c_med lagdaily_woi_c_med-lagdaily_woi7_c_med occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, lag(7) force
outreg2 using "$tables/table_A7_a.xls",append ctitle("Occurrence") keep(leaddaily_woi_c_med) nocons label bdec(3)

* Corresponding OLS regressions to display the R-squared
eststo clear
eststo: xi: reg occurrence daily_woi leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 l1.occurrence l2.occurrence l3.occurrence l4.occurrence l5.occurrence l6.occurrence l7.occurrence i.month i.year i.dow if gaza_war==0 , cluster(monthyear)
eststo: xi: reg occurrence daily_woi leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow  , cluster(monthyear)
eststo: xi: reg occurrence daily_woi leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, cluster(monthyear) 
eststo: xi: reg occurrence leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, cluster(monthyear)
eststo: xi: reg occurrence leaddaily_woi occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, cluster(monthyear)
eststo: xi: reg occurrence leaddaily_woi lagdaily_woi-lagdaily_woi7 leaddaily_woi-leaddaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, cluster(monthyear)
eststo xi:  reg occurrence daily_woi leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0 & interpolated_news==0, cluster(monthyear)
eststo xi:  reg occurrence daily_woi_c_med leaddaily_woi_c_med lagdaily_woi_c_med-lagdaily_woi7_c_med occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, cluster(monthyear)
esttab, se r2 star(* 0.1 ** 0.05 *** 0.01)

* Panel B: Number of victims

xi: glm victims_isr daily_woi leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 l1.occurrence l2.occurrence l3.occurrence l4.occurrence l5.occurrence l6.occurrence l7.occurrence i.month i.year i.dow if gaza_war==0, family(nbinom ml) vce(hac nwest 7)
outreg2 using "$tables/table_A7_b.xls", replace ctitle("Victims") keep(leaddaily_woi) nocons label bdec(3)

xi: glm victims_isr daily_woi leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow, family(nbinom ml) vce(hac nwest 7)
outreg2 using "$tables/table_A7_b.xls", append ctitle("Victims") keep(leaddaily_woi) nocons label bdec(3)

xi: glm victims_isr daily_woi leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, family(nbinom ml) cluster(monthyear)
outreg2 using "$tables/table_A7_b.xls", append ctitle("Victims") keep(leaddaily_woi) nocons label bdec(3)

xi: glm victims_isr           leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, family(nbinom ml) vce(hac nwest 7)
outreg2 using "$tables/table_A7_b.xls", append ctitle("Victims") keep(leaddaily_woi) nocons label bdec(3)

xi: glm victims_isr           leaddaily_woi                            occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, family(nbinom ml) vce(hac nwest 7)
outreg2 using "$tables/table_A7_b.xls", append ctitle("Victims") keep(leaddaily_woi) nocons label bdec(3)

xi: glm victims_isr leaddaily_woi lagdaily_woi-lagdaily_woi7 leaddaily_woi-leaddaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, family(nbinom ml) vce(hac nwest 7)
outreg2 using "$tables/table_A7_b.xls", append ctitle("Occurrence") keep(leaddaily_woi) nocons label bdec(3)

xi: glm victims_isr daily_woi leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0 & interpolated_news==0, family(nbinom ml) vce(hac nwest 7)
outreg2 using "$tables/table_A7_b.xls", append ctitle("Victims") keep(leaddaily_woi) nocons label bdec(3)

xi: glm victims_isr daily_woi_c_med leaddaily_woi_c_med lagdaily_woi_c_med-lagdaily_woi7_c_med occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, family(nbinom ml) vce(hac nwest 7)
outreg2 using "$tables/table_A7_b.xls", append ctitle("Victims") keep(leaddaily_woi_c_med) nocons label bdec(3)

* Corresponding negative binomial regressions to display the R-squared
eststo clear
eststo: xi: nbreg victims_isr daily_woi leaddaily_woi lagdaily_woi-lagdaily_woi7                              occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 l1.occurrence l2.occurrence l3.occurrence l4.occurrence l5.occurrence l6.occurrence l7.occurrence i.month i.year i.dow if gaza_war==0, cluster(monthyear)
eststo: xi: nbreg victims_isr daily_woi leaddaily_woi lagdaily_woi-lagdaily_woi7                              occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14                                                                                                   i.month i.year i.dow               , cluster(monthyear)
eststo: xi: nbreg victims_isr daily_woi leaddaily_woi lagdaily_woi-lagdaily_woi7                              occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14                                                                                                   i.month i.year i.dow if gaza_war==0, cluster(monthyear)
eststo: xi: nbreg victims_isr           leaddaily_woi lagdaily_woi-lagdaily_woi7                              occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14                                                                                                   i.month i.year i.dow if gaza_war==0, cluster(monthyear)
eststo: xi: nbreg victims_isr           leaddaily_woi                                                         occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14                                                                                                   i.month i.year i.dow if gaza_war==0, cluster(monthyear)
eststo: xi: nbreg victims_isr           leaddaily_woi lagdaily_woi-lagdaily_woi7 leaddaily_woi-leaddaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14                                                                                                   i.month i.year i.dow if gaza_war==0, cluster(monthyear)
eststo: xi: nbreg victims_isr daily_woi leaddaily_woi lagdaily_woi-lagdaily_woi7                              occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14                                                                                                   i.month i.year i.dow if gaza_war==0 & interpolated_news==0, cluster(monthyear)
eststo: xi: nbreg victims_isr daily_woi_c_med leaddaily_woi_c_med lagdaily_woi_c_med-lagdaily_woi7_c_med occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, cluster(monthyear)
esttab, se pr2 star(* 0.1 ** 0.05 *** 0.01)

**************************************************************************************************
**   Table A8. Israeli Attacks and News Pressure Controlling for Jewish and Muslim Holidays        
**************************************************************************************************

use "$dta/replication_file1.dta", clear

xi: reg occurrence daily_woi i.month i.year i.dow jhol* mhol* if gaza_war==0, cluster(monthyear)
outreg2 using "$tables/table_A8.xls", replace ctitle("Occurrence") keep(daily_woi jhol* mhol*) nocons label bdec(3)

xi: newey occurrence daily_woi leaddaily_woi i.month i.year i.dow jhol* mhol* if gaza_war==0, lag(7) force
outreg2 using "$tables/table_A8.xls", append ctitle("Occurrence") keep(daily_woi leaddaily_woi lagdaily_woi occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 jhol* mhol*) nocons label bdec(3)

xi: newey occurrence daily_woi leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow jhol* mhol* if gaza_war==0, lag(7) force
outreg2 using "$tables/table_A8.xls", append ctitle("Occurrence") keep(daily_woi leaddaily_woi lagdaily_woi occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 jhol* mhol*) nocons label bdec(3)

xi: reg lnvic daily_woi i.month i.year i.dow jhol* mhol* if gaza_war==0, cluster(monthyear)
outreg2 using "$tables/table_A8.xls", append ctitle("Ln(victims)") keep(daily_woi jhol* mhol*) nocons label bdec(3)

xi: newey lnvic daily_woi leaddaily_woi i.month i.year i.dow jhol* mhol* if gaza_war==0,lag(7) force 
outreg2 using "$tables/table_A8.xls", append ctitle("Ln(victims)") keep(daily_woi leaddaily_woi lagdaily_woi jhol* mhol*) nocons label bdec(3)

xi: newey lnvic daily_woi leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow  jhol* mhol* if gaza_war==0, lag(7) force 
outreg2 using "$tables/table_A8.xls", append ctitle("Ln(victims)") keep(daily_woi leaddaily_woi lagdaily_woi jhol* mhol*) nocons label bdec(3)

xi: glm victims_isr daily_woi leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow  jhol* mhol* if gaza_war==0, family(nbinom ml) vce(hac nwest 7)
outreg2 using "$tables/table_A8.xls", append ctitle("Num. victims") keep(daily_woi leaddaily_woi lagdaily_woi jhol* mhol*) nocons label bdec(3)

* Corresponding OLS and negative binomial regressions to display the R-squared

eststo clear
eststo: reg occurrence daily_woi i.month i.year i.dow  jhol* mhol* if gaza_war==0, cluster(monthyear)
eststo: reg occurrence daily_woi leaddaily_woi i.month i.year i.dow jhol* mhol* if gaza_war==0, cluster(monthyear)
eststo: reg occurrence daily_woi leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow  jhol* mhol* if gaza_war==0, cluster(monthyear)
eststo: reg lnvic daily_woi i.month i.year i.dow jhol* mhol* if gaza_war==0, cluster(monthyear)
eststo: reg lnvic daily_woi leaddaily_woi i.month i.year i.dow jhol* mhol* if gaza_war==0, cluster(monthyear)
eststo: reg lnvic daily_woi leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow  jhol* mhol* if gaza_war==0, cluster(monthyear) 
eststo: nbreg victims_isr daily_woi leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow  jhol* mhol* if gaza_war==0, vce(cluster monthyear)
esttab, se r2 pr2 star(* 0.10 ** 0.05 *** 0.01)

*******************************************************************************************
** Table A9. Israeli Attacks and News Pressure (Based on the Longest Three News Stories)
*******************************************************************************************

use "$dta/replication_file1.dta", clear

xi: reg occurrence daily_woi_long i.month i.year i.dow if gaza_war==0, cluster(monthyear)
outreg2 using "$tables/table_A9.xls", replace ctitle("Occurrence") keep(daily_woi_long) nocons label bdec(3)

xi: newey occurrence daily_woi_long leaddaily_woi_long i.month i.year i.dow if gaza_war==0, lag(7) force
outreg2 using "$tables/table_A9.xls", append ctitle("Occurrence") keep(daily_woi_long leaddaily_woi_long lagdaily_woi_long occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14) nocons label bdec(3)

xi: newey occurrence daily_woi_long leaddaily_woi_long lagdaily_woi_long-lagdaily_woi7_long occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, lag(7) force
outreg2 using "$tables/table_A9.xls", append ctitle("Occurrence") keep(daily_woi_long leaddaily_woi_long lagdaily_woi_long occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14) nocons label bdec(3)
 
xi: reg lnvic daily_woi_long i.month i.year i.dow if gaza_war==0, cluster(monthyear)
outreg2 using "$tables/table_A9.xls", append ctitle("Ln(victims)") keep(daily_woi_long) nocons label bdec(3)

xi: newey lnvic daily_woi_long leaddaily_woi_long i.month i.year i.dow if gaza_war==0,lag(7) force 
outreg2 using "$tables/table_A9.xls", append ctitle("Ln(victims)") keep(daily_woi_long leaddaily_woi_long lagdaily_woi_long occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14) nocons label bdec(3)

xi: newey lnvic daily_woi_long leaddaily_woi_long lagdaily_woi_long-lagdaily_woi7_long occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, lag(7) force 
outreg2 using "$tables/table_A9.xls", append ctitle("Ln(victims)") keep(daily_woi_long leaddaily_woi_long lagdaily_woi_long occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14) nocons label bdec(3)

xi: glm victims_isr daily_woi_long leaddaily_woi_long lagdaily_woi_long-lagdaily_woi7_long occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, family(nbinom ml) vce(hac nwest 7)
outreg2 using "$tables/table_A9.xls", append ctitle("Num. victims") keep(daily_woi_long leaddaily_woi_long lagdaily_woi_long occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14) nocons label bdec(3)

* Corresponding OLS and negative binomial regressions to display the R-squared
eststo clear
eststo: reg occurrence daily_woi_long i.month i.year i.dow if gaza_war==0, cluster(monthyear)
eststo: reg occurrence daily_woi_long leaddaily_woi_long i.month i.year i.dow if gaza_war==0, cluster(monthyear)
eststo: reg occurrence daily_woi_long leaddaily_woi_long lagdaily_woi_long-lagdaily_woi7_long occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, cluster(monthyear)
eststo: reg lnvic daily_woi_long i.month i.year i.dow if gaza_war==0, cluster(monthyear)
eststo: reg lnvic daily_woi_long leaddaily_woi_long i.month i.year i.dow if gaza_war==0, cluster(monthyear)
eststo: reg lnvic daily_woi_long leaddaily_woi_long lagdaily_woi_long-lagdaily_woi7_long occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, cluster(monthyear) 
eststo: nbreg victims_isr daily_woi_long leaddaily_woi_long lagdaily_woi_long-lagdaily_woi7_long occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, vce(cluster monthyear)
esttab, se r2 pr2 star(* 0.10 ** 0.05 *** 0.01)

**************************************************************************************************
** Table A10. Israeli Attacks and News Pressure: Differences Between Israeli Administrations
**************************************************************************************************

use "$dta/replication_file1.dta", clear

* Occurrence of Israeli attacks

xi: newey occurrence leaddaily_woi i.barak*leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, lag(7) force
outreg2 using "$tables/table_A10.xls", replace ctitle("Occurrence") keep(leaddaily_woi _Ibarak_1 _IbarXleadd_1) nocons label bdec(3)

xi: newey occurrence leaddaily_woi i.sharon*leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, lag(7) force
outreg2 using "$tables/table_A10.xls", append ctitle("Occurrence") keep(leaddaily_woi _Isharon_1 _IshaXleadd_1) nocons label bdec(3)

xi: newey occurrence leaddaily_woi i.olmert*leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, lag(7) force
outreg2 using "$tables/table_A10.xls", append ctitle("Occurrence") keep(leaddaily_woi _Iolmert_1 _IolmXleadd_1) nocons label bdec(3)

xi: newey occurrence leaddaily_woi i.netanyahu*leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, lag(7) force
outreg2 using "$tables/table_A10.xls", append ctitle("Occurrence") keep(leaddaily_woi _Inetanyahu_1 _InetXleadd_1) nocons label bdec(3)

xi: newey occurrence leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0 & barak==0, lag(7) force
outreg2 using "$tables/table_A10.xls", append ctitle("Occurrence") keep(leaddaily_woi) nocons label bdec(3)

* Corresponding OLS regressions to display the R-squared

eststo clear
eststo: xi: reg occurrence leaddaily_woi i.barak*leaddaily_woi     lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, vce(cluster monthyear)
eststo: xi: reg occurrence leaddaily_woi i.sharon*leaddaily_woi    lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, vce(cluster monthyear)
eststo: xi: reg occurrence leaddaily_woi i.olmert*leaddaily_woi    lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, vce(cluster monthyear)
eststo: xi: reg occurrence leaddaily_woi i.netanyahu*leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, vce(cluster monthyear)
eststo: xi: reg occurrence leaddaily_woi                           lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0 & barak==0, vce(cluster monthyear)
esttab, se r2 star(* 0.1 ** 0.05 *** 0.01)

* Victims of Israeli attacks

xi: glm victims_isr leaddaily_woi i.barak*leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, family(nbinom ml) vce(hac nwest 7)
outreg2 using "$tables/table_A10.xls", append ctitle("Victims") keep(leaddaily_woi _Ibarak_1 _IbarXleadd_1) nocons label bdec(3)

xi: glm victims_isr leaddaily_woi i.sharon*leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, family(nbinom ml) vce(hac nwest 7)
outreg2 using "$tables/table_A10.xls", append ctitle("Victims") keep(leaddaily_woi _Isharon_1 _IshaXleadd_1) nocons label bdec(3)

xi: glm victims_isr leaddaily_woi i.olmert*leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, family(nbinom ml) vce(hac nwest 7)
outreg2 using "$tables/table_A10.xls", append ctitle("Victims") keep(leaddaily_woi _Iolmert_1 _IolmXleadd_1) nocons label bdec(3)

xi: glm victims_isr leaddaily_woi i.netanyahu*leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, family(nbinom ml) vce(hac nwest 7)
outreg2 using "$tables/table_A10.xls", append ctitle("Victims") keep(leaddaily_woi _Inetanyahu_1 _InetXleadd_1) nocons label bdec(3)

xi: glm victims_isr leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0 & barak==0, family(nbinom ml) vce(hac nwest 7)
outreg2 using "$tables/table_A10.xls", append ctitle("Victims") keep(leaddaily_woi) nocons label bdec(3)

* Corresponding negative binomial regressions to display the R-squared
eststo clear
eststo: xi: nbreg victims_isr leaddaily_woi i.barak*leaddaily_woi     lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, vce(cluster monthyear)
eststo: xi: nbreg victims_isr leaddaily_woi i.sharon*leaddaily_woi    lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, vce(cluster monthyear)
eststo: xi: nbreg victims_isr leaddaily_woi i.olmert*leaddaily_woi    lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, vce(cluster monthyear)
eststo: xi: nbreg victims_isr leaddaily_woi i.netanyahu*leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, vce(cluster monthyear)
eststo: xi: nbreg victims_isr leaddaily_woi                           lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0 & barak==0, vce(cluster monthyear)
esttab, se pr2 star(* 0.1 ** 0.05 *** 0.01)

**********************************************************************************************
**    Table A11. Israeli Attacks and News Pressure: Differences Between US Administrations
**********************************************************************************************

use "$dta/replication_file1.dta", clear

* Occurrence of Israeli attacks

xi: newey occurrence leaddaily_woi i.us_president_party*leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, lag(7) force
outreg2 using "$tables/table_A11.xls", replace ctitle("Occurrence") keep(leaddaily_woi _Ius_presid_1 _Ius_Xleadd_1) nocons label bdec(3)

xi: newey occurrence leaddaily_woi i.clinton*leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, lag(7) force
outreg2 using "$tables/table_A11.xls", append ctitle("Occurrence") keep(leaddaily_woi _Iclinton_1 _IcliXleadd_1) nocons label bdec(3)

xi: newey occurrence leaddaily_woi i.bush*leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, lag(7) force
outreg2 using "$tables/table_A11.xls", append ctitle("Occurrence") keep(leaddaily_woi _Ibush_1 _IbusXleadd_1) nocons label bdec(3)

xi: newey occurrence leaddaily_woi i.obama*leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, lag(7) force
outreg2 using "$tables/table_A11.xls", append ctitle("Occurrence") keep(leaddaily_woi _Iobama_1 _IobaXleadd_1) nocons label bdec(3)

xi: newey occurrence leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0 & clinton==0, lag(7) force
outreg2 using "$tables/table_A11.xls", append ctitle("Occurrence") keep(leaddaily_woi) nocons label bdec(3)

* Corresponding OLS regressions to display the R-squared

eststo: xi: reg occurrence leaddaily_woi i.us_president_party*leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, vce(cluster monthyear)
eststo: xi: reg occurrence leaddaily_woi i.clinton*leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, vce(cluster monthyear)
eststo: xi: reg occurrence leaddaily_woi i.bush*leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, vce(cluster monthyear)
eststo: xi: reg occurrence leaddaily_woi i.obama*leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, vce(cluster monthyear)
eststo: xi: reg occurrence leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0 & clinton==0, vce(cluster monthyear)
esttab, se r2 star(* 0.1 ** 0.05 *** 0.01)

* Victims of Israeli attacks

xi: glm victims_isr leaddaily_woi i.us_president_party*leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, family(nbinom ml) vce(hac nwest 7)
outreg2 using "$tables/table_A11.xls", append ctitle("Victims") keep(leaddaily_woi _Ius_presid_1 _Ius_Xleadd_1) nocons label bdec(3)

xi: glm victims_isr leaddaily_woi i.clinton*leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, family(nbinom ml) vce(hac nwest 7)
outreg2 using "$tables/table_A11.xls", append ctitle("Victims") keep(leaddaily_woi _Iclinton_1 _IcliXleadd_1) nocons label bdec(3)

xi: glm victims_isr leaddaily_woi i.bush*leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, family(nbinom ml) vce(hac nwest 7)
outreg2 using "$tables/table_A11.xls", append ctitle("Victims") keep(leaddaily_woi _Ibush_1 _IbusXleadd_1) nocons label bdec(3)

xi: glm victims_isr leaddaily_woi i.obama*leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, family(nbinom ml) vce(hac nwest 7)
outreg2 using "$tables/table_A11.xls", append ctitle("Victims") keep(leaddaily_woi _Iobama_1 _IobaXleadd_1) nocons label bdec(3)

xi: glm victims_isr leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0 & clinton==0, family(nbinom ml) vce(hac nwest 7)
outreg2 using "$tables/table_A11.xls", append ctitle("Victims") keep(leaddaily_woi) nocons label bdec(3)

* Corresponding negative binomial regressions to display the R-squared
eststo clear
eststo: xi: nbreg victims_isr leaddaily_woi i.us_president_party*leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, vce(cluster monthyear)
eststo: xi: nbreg victims_isr leaddaily_woi i.clinton*leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, vce(cluster monthyear)
eststo: xi: nbreg victims_isr leaddaily_woi i.bush*leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, vce(cluster monthyear)
eststo: xi: nbreg victims_isr leaddaily_woi i.obama*leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, vce(cluster monthyear)
eststo: xi: nbreg victims_isr leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0 & clinton==0, vce(cluster monthyear)
esttab, se pr2 star(* 0.1 ** 0.05 *** 0.01)

**********************************************************************************************************
**  Table A12. Israeli Attacks and News Pressure: Second Intifada, Peace Process, and Peace Talks
**********************************************************************************************************

use "$dta/replication_file1.dta", clear

* Occurrence of Israeli attacks

xi: newey occurrence leaddaily_woi i.post_intifada*leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, lag(7) force
test leaddaily_woi+_IposXleadd_1=0
outreg2 using "$tables/table_A12.xls", replace ctitle("occurrence") keep(leaddaily_woi _Ipost_inti_1 _IposXleadd_1) nocons label bdec(3)

xi: newey occurrence leaddaily_woi i.p_process*leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, lag(7) force
outreg2 using "$tables/table_A12.xls", append ctitle("occurrence") keep(leaddaily_woi _Ip_process_1 _Ip_pXleadd_1) nocons label bdec(3)

xi: newey occurrence leaddaily_woi i.p_talks*leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, lag(7) force
outreg2 using "$tables/table_A12.xls", append ctitle("occurrence") keep(leaddaily_woi  _Ip_talks_1 _Ip_tXleadd_1) nocons label bdec(3)

* Corresponding OLS regressions to display the R-squaredeststo clear
eststo clear
eststo: xi: reg occurrence leaddaily_woi i.post_intifada*leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, vce(cluster monthyear)
eststo: xi: reg occurrence leaddaily_woi i.p_process*leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, vce(cluster monthyear)
eststo: xi: reg occurrence leaddaily_woi i.p_talks*leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, vce(cluster monthyear)
esttab, se r2 star(* 0.1 ** 0.05 *** 0.01)

* Victims of Israeli attacks

xi: glm victims_isr leaddaily_woi i.post_intifada*leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, family(nbinom ml) vce(hac nwest 7)
test leaddaily_woi+_IposXleadd_1=0
outreg2 using "$tables/table_A12.xls", append ctitle("victims") keep(leaddaily_woi _Ipost_inti_1 _IposXleadd_1) nocons label bdec(3)

xi: glm victims_isr leaddaily_woi i.p_process*leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, family(nbinom ml) vce(hac nwest 7)
outreg2 using "$tables/table_A12.xls", append ctitle("victims") keep(leaddaily_woi _Ip_process_1 _Ip_pXleadd_1) nocons label bdec(3)

xi: glm victims_isr leaddaily_woi i.p_talks*leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, family(nbinom ml) vce(hac nwest 7)
outreg2 using "$tables/table_A12.xls", append ctitle("victims") keep(leaddaily_woi _Ip_talks_1 _Ip_tXleadd_1) nocons label bdec(3)

* Corresponding negative binomial regressions to display the R-squared
eststo clear
eststo: xi: nbreg victims_isr leaddaily_woi i.post_intifada*leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, vce(cluster monthyear) 
eststo: xi: nbreg victims_isr leaddaily_woi i.p_process*leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, vce(cluster monthyear)
eststo: xi: nbreg victims_isr leaddaily_woi i.p_talks*leaddaily_woi lagdaily_woi-lagdaily_woi7 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, vce(cluster monthyear)
esttab, se pr2 star(* 0.1 ** 0.05 *** 0.01)

**********************************************************************************************************
**  Table A13. Israeli Attacks and News Pressure IV Regs (controlling for jewish and muslim holidays)
**********************************************************************************************************

use "$dta/replication_file1.dta", clear

* Occurrence of Israeli attacks

xi: reg leaddaily_woi lead_maj_events occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow jhol* mhol* if gaza_war==0 , first cluster(monthyear)
test lead_maj_events
scalar F_cont=r(F)
outreg2 using "$tables/table_A13.xls", replace ctitle("NP t+1, 1st stage") keep(lead_maj_events jhol* mhol*)  nocons label bdec(3)

xi: ivreg occurrence (leaddaily_woi=lead_maj_events) occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14  i.month i.year i.dow jhol* mhol* if gaza_war==0 , first cluster(monthyear)
outreg2 using "$tables/table_A13.xls", append ctitle("Occurrence, IV 2nd stage") keep(leaddaily_woi jhol* mhol*) addstat ("F excl. instr.", F_cont) nocons label bdec(3)

xi: reg occurrence lead_maj_events occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow jhol* mhol* if gaza_war==0 , first cluster(monthyear)
outreg2 using "$tables/table_A13.xls", append ctitle("Occurrence, Reduced form") keep(lead_maj_events jhol* mhol*) nocons label bdec(3)

* Victims of Israeli attacks

cap drop mon1-mon12 day1-day7 year1-year12
tab month, gen(mon)
tab dow, gen(day)
tab year, gen(year)

#delimit;
     qvf victims_isr
	 leaddaily_woi 
	 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14
	 mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12
	 day2 day3 day4 day5 day6 day7 
	 year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
	 jhol1 jhol2 jhol3 jhol4 jhol5 jhol6 jhol7 jhol8 jhol9 jhol10 jhol11 jhol12 jhol13 jhol14 jhol15 jhol16 jhol17 mhol1 mhol2 mhol3 mhol4 mhol5 mhol6 mhol7 mhol8
	 (lead_maj_events 
	 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14
	 mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12
	 day2 day3 day4 day5 day6 day7 
	 year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12
	 jhol1 jhol2 jhol3 jhol4 jhol5 jhol6 jhol7 jhol8 jhol9 jhol10 jhol11 jhol12 jhol13 jhol14 jhol15 jhol16 jhol17 mhol1 mhol2 mhol3 mhol4 mhol5 mhol6 mhol7 mhol8) 
	 if gaza_war==0, family(nbinom) robust cluster(monthyear);
#delimit cr
outreg2 using "$tables/table_A13.xls", append ctitle("Num. victims, IV 2nd stage") keep(leaddaily_woi jhol* mhol*) addstat ("F excl. instr.", F_cont) nocons label bdec(3)
	 	 
#delimit;
     xi: glm victims_isr 
     lead_maj_events 
	 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14
	 i.month i.year i.dow jhol* mhol* if  gaza_war==0, family(nbinom ml)
	 vce(cluster monthyear);
#delimit cr
outreg2 using "$tables/table_A13.xls", append ctitle("Num. victims, Reduced form") keep(lead_maj_events jhol* mhol*) nocons label bdec(3)
 
* Corresponding negative binomial regression to display the R-squared for the last regression
eststo clear
#delimit;
     eststo: xi: nbreg victims_isr 
     lead_maj_events 
	 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14
	 i.month i.year i.dow jhol* mhol* if  gaza_war==0,
	 vce(cluster monthyear) ;
#delimit cr
esttab, se pr2 star(* 0.1 ** 0.05 *** 0.01)

**************************************************************************************************************
**  Table A14. Israeli Attacks and Predictable News Pressure Based on the Longest Three News Stories (IV)
**************************************************************************************************************

use "$dta/replication_file1.dta", clear

xi: reg leaddaily_woi_long lead_maj_events occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0 , first cluster(monthyear)
test lead_maj_events
scalar F_cont=r(F)
outreg2 using "$tables/table_A14.xls", replace ctitle("NP t+1, 1st stage") keep(lead_maj_events)  nocons label bdec(3)

xi: ivreg occurrence (leaddaily_woi_long=lead_maj_events) occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14  i.month i.year i.dow if gaza_war==0 , first cluster(monthyear)
outreg2 using "$tables/table_A14.xls", append ctitle("Occurrence, IV 2nd stage") keep(leaddaily_woi_long) addstat ("F excl. instr.", F_cont) nocons label bdec(3)

cap drop mon1-mon12 day1-day7 year1-year12
tab month, gen(mon)
tab dow, gen(day)
tab year, gen(year)

#delimit;
     qvf victims_isr
	 leaddaily_woi_long
	 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14
	 mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12
	 day2 day3 day4 day5 day6 day7 
	 year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
	 (lead_maj_events 
	 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14
	 mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12
	 day2 day3 day4 day5 day6 day7 
	 year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12)
	 if gaza_war==0, family(nbinom) robust cluster(monthyear);
#delimit cr
outreg2 using "$tables/table_A14.xls", append ctitle("Num. victims, IV 2nd stage") keep(leaddaily_woi_long) addstat ("F excl. instr.", F_cont) nocons label bdec(3)

**********************************************************************************
** Table A15. Israeli Attacks and Predictable News Pressure - Robustness (IV)
**********************************************************************************

use "$dta/replication_file1.dta", clear

cap drop mon1-mon12 day1-day7 year1-year12
tab month, gen(mon)
tab dow, gen(day)
tab year, gen(year)

* Occurrence of Israeli attacks

* Including Gaza war

* First stage to display F-stat
xi: reg leaddaily_woi lead_maj_events occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow, first cluster(monthyear)
test lead_maj_events
scalar F_cont1=r(F)

xi: ivreg occurrence (leaddaily_woi=lead_maj_events) occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14  i.month i.year i.dow, first cluster(monthyear)
outreg2 using "$tables/table_A15.xls", replace ctitle("Occurrence, IV 2nd stage") keep(leaddaily_woi) addstat ("F excl. instr.", F_cont1) nocons label bdec(3)

* Excluding Gaza war and excluding days with no original news data

* First stage to display F-stat
xi: reg leaddaily_woi lead_maj_events occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0 & interpolated_news==0, first cluster(monthyear)
test lead_maj_events
scalar F_cont2=r(F)

xi: ivreg occurrence (leaddaily_woi=lead_maj_events) occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14  i.month i.year i.dow if gaza_war==0 & interpolated_news==0, first cluster(monthyear)
outreg2 using "$tables/table_A15.xls", append ctitle("Occurrence, IV 2nd stage") keep(leaddaily_woi) addstat ("F excl. instr.", F_cont2) nocons label bdec(3)

* News pressure corrected using median total newstime by network

* First stage to display F-stat
xi: reg leaddaily_woi_c_med lead_maj_events occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0, first cluster(monthyear)
test lead_maj_events
scalar F_cont3=r(F)

xi: ivreg occurrence (leaddaily_woi_c_med=lead_maj_events) occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14  i.month i.year i.dow if gaza_war==0, first cluster(monthyear)
outreg2 using "$tables/table_A15.xls", append ctitle("Occurrence, IV 2nd stage") keep(leaddaily_woi_c_med) addstat ("F excl. instr.", F_cont3) nocons label bdec(3)

* Victims of Israeli attacks

* Including Gaza war
#delimit;
 qvf victims_isr
 leaddaily_woi
 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14
 mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12
 day2 day3 day4 day5 day6 day7 
 year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
 (lead_maj_events 
 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14
 mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12
 day2 day3 day4 day5 day6 day7 
 year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12)
 , family(nbinom) robust cluster(monthyear);
#delimit cr
outreg2 using "$tables/table_A15.xls", append   ctitle("Num. victims, IV 2nd stage") keep(leaddaily_woi) addstat ("F excl. instr.", F_cont1) nocons label bdec(3)

* Excluding Gaza war and excluding days with no original news data
#delimit;
 qvf victims_isr
 leaddaily_woi
 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14
 mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12
 day2 day3 day4 day5 day6 day7 
 year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
 (lead_maj_events 
 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14
 mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12
 day2 day3 day4 day5 day6 day7 
 year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12)
 if gaza_war==0 & interpolated_news==0, family(nbinom) robust cluster(monthyear);
#delimit cr
outreg2 using "$tables/table_A15.xls", append   ctitle("Num. victims, IV 2nd stage") keep(leaddaily_woi) addstat ("F excl. instr.", F_cont2) nocons label bdec(3)

* News pressure corrected using median total newstime by network
#delimit;
 qvf victims_isr
 leaddaily_woi_c_med
 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14
 mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12
 day2 day3 day4 day5 day6 day7 
 year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12 
 (lead_maj_events 
 occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14
 mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12
 day2 day3 day4 day5 day6 day7 
 year2 year3 year4 year5 year6 year7 year8 year9 year10 year11 year12)
 if gaza_war==0, family(nbinom) robust cluster(monthyear);
#delimit cr
outreg2 using "$tables/table_A15.xls", append   ctitle("Num. victims, IV 2nd stage") keep(leaddaily_woi_c_med) addstat ("F excl. instr.", F_cont3) nocons label bdec(3)

********************************************************************************************
**   Table A16. ROBUSTNESS OF TABLE 6 TO CONTROLLING FOR NEWS PRESSURE AT T 
********************************************************************************************

use "$dta/replication_file1.dta", clear

* Multinomial logit regressions

* Targeted vs. non-targeted attacks

#delimit;
xi: dmlogit2 attacks_target 
leaddaily_woi 
occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 
daily_woi lagdaily_woi-lagdaily_woi7 
i.month i.year i.dow 
if gaza_war==0, cluster(monthyear) baseoutcome(1);
test [2]leaddaily_woi = [3]leaddaily_woi;
scalar P_v=r(p);
#delimit cr
outreg2 using "$tables/table_A16_a.xls", replace ctitle("Non-targeted") keep(leaddaily_woi daily_woi) nocons label bdec(3) addstat("p value", P_v)

* Fatal vs. non-fatal attacks                                  *

#delimit;
xi: dmlogit2 attacks_fatal
leaddaily_woi 
occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 
daily_woi lagdaily_woi-lagdaily_woi7 
i.month i.year i.dow 
if gaza_war==0, cluster(monthyear) baseoutcome(1) ;
test [2]leaddaily_woi = [3]leaddaily_woi;
scalar P_v=r(p);
#delimit cr
outreg2 using "$tables/table_A16_a.xls", append ctitle("Fatal") keep(leaddaily_woi daily_woi) nocons label bdec(3) addstat("p value", P_v)

* Attacks in high- vs low-densely populated areas

#delimit;
xi: dmlogit2 attacks_hpd
leaddaily_woi 
occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 
daily_woi lagdaily_woi-lagdaily_woi7 
i.month i.year i.dow 
if gaza_war==0 , cluster(monthyear) baseoutcome(1);
test [2]leaddaily_woi = [3]leaddaily_woi;
scalar P_v=r(p);
#delimit cr
outreg2 using "$tables/table_A16_a.xls", append ctitle("HPD") keep(leaddaily_woi daily_woi) nocons label bdec(3) addstat("p value", P_v)

* Attacks with heavy vs. light weapons

#delimit;
xi: dmlogit2 attacks_hw
leaddaily_woi 
occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 
daily_woi lagdaily_woi-lagdaily_woi7 
i.month i.year i.dow 
if gaza_war==0 , cluster(monthyear) baseoutcome(1);
test [2]leaddaily_woi = [3]leaddaily_woi;
scalar P_v=r(p);
#delimit cr
outreg2 using "$tables/table_A16_a.xls", append ctitle("HW") keep(leaddaily_woi daily_woi) nocons label bdec(3) addstat("p value", P_v)

* Negative binomial regressions

* Victims of targeted attacks
#delimit;
xi: glm victims_target
leaddaily_woi daily_woi lagdaily_woi lagdaily_woi2 lagdaily_woi3 lagdaily_woi4 lagdaily_woi5 lagdaily_woi6 lagdaily_woi7 
occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 
i.month i.year i.dow if gaza_war==0, family(nbinom ml) vce(hac nwest 7);
outreg2 using "$tables/table_A16_b.xls", 
replace ctitle("Victims of targeted killings") keep(leaddaily_woi) nocons label bdec(3);
#delimit cr

* Victims of non-targeted attacks
#delimit;
xi: glm victims_non_target
leaddaily_woi daily_woi lagdaily_woi lagdaily_woi2 lagdaily_woi3 lagdaily_woi4 lagdaily_woi5 lagdaily_woi6 lagdaily_woi7 
occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 
i.month i.year i.dow if gaza_war==0, family(nbinom ml) vce(hac nwest 7);
outreg2 using "$tables/table_A16_b.xls", 
append   ctitle("Victims of non-targeted attacks") keep(leaddaily_woi) nocons label bdec(3);
#delimit cr

* Non-fatal victims
#delimit;
xi: glm non_fatal_victims
leaddaily_woi daily_woi lagdaily_woi lagdaily_woi2 lagdaily_woi3 lagdaily_woi4 lagdaily_woi5 lagdaily_woi6 lagdaily_woi7 
occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 
i.month i.year i.dow if gaza_war==0  & occurrence_fatal==0, family(nbinom ml) vce(hac nwest 7);
outreg2 using "$tables/table_A16_b.xls", 
append ctitle("Injuries") keep(leaddaily_woi daily_woi) nocons label bdec(3);
#delimit cr

* Fatalities
#delimit;
xi: glm fatal_victims
leaddaily_woi daily_woi lagdaily_woi lagdaily_woi2 lagdaily_woi3 lagdaily_woi4 lagdaily_woi5 lagdaily_woi6 lagdaily_woi7 
occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 
i.month i.year i.dow if gaza_war==0, family(nbinom ml) vce(hac nwest 7);
outreg2 using "$tables/table_A16_b.xls", 
append ctitle("Fatalities") keep(leaddaily_woi daily_woi) nocons label bdec(3);
#delimit cr

* Casualties of attacks in less densely populated areas
#delimit;
xi: glm victims_lpd
leaddaily_woi daily_woi lagdaily_woi lagdaily_woi2 lagdaily_woi3 lagdaily_woi4 lagdaily_woi5 lagdaily_woi6 lagdaily_woi7 
occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 
i.month i.year i.dow if gaza_war==0 , family(nbinom ml) vce(hac nwest 7);
outreg2 using "$tables/table_A16_b.xls", 
append ctitle("Casualties in NDP areas") keep(leaddaily_woi daily_woi) nocons label bdec(3);
#delimit cr

* Casualties of attacks in less densely populated areas
#delimit;
xi: glm victims_hpd
leaddaily_woi daily_woi lagdaily_woi lagdaily_woi2 lagdaily_woi3 lagdaily_woi4 lagdaily_woi5 lagdaily_woi6 lagdaily_woi7 
occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 
i.month i.year i.dow if gaza_war==0, family(nbinom ml) vce(hac nwest 7);
outreg2 using "$tables/table_A16_b.xls", 
append ctitle("Casualties in DP areas") keep(leaddaily_woi daily_woi) nocons label bdec(3);
#delimit cr

* Casualties of attacks with light weapons
#delimit;
xi: glm victims_nhw
leaddaily_woi daily_woi lagdaily_woi lagdaily_woi2 lagdaily_woi3 lagdaily_woi4 lagdaily_woi5 lagdaily_woi6 lagdaily_woi7 
occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 
i.month i.year i.dow if gaza_war==0  & occurrence_hw==0, family(nbinom ml) vce(hac nwest 7);
outreg2 using "$tables/table_A16_b.xls", 
append ctitle("Casualties with light weapons") keep(leaddaily_woi daily_woi) nocons label bdec(3);
#delimit cr

* Casualties of attacks with heavy weapons
#delimit;
xi: glm victims_hw
leaddaily_woi  daily_woi lagdaily_woi lagdaily_woi2 lagdaily_woi3 lagdaily_woi4 lagdaily_woi5 lagdaily_woi6 lagdaily_woi7 
occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 
i.month i.year i.dow if gaza_war==0 , family(nbinom ml) vce(hac nwest 7);
outreg2 using "$tables/table_A16_b.xls", 
append ctitle("Casualties with heavy weapons") keep(leaddaily_woi daily_woi) nocons label bdec(3);
#delimit cr

**********************************************************************************
**    Table A17. Same-day vs. Next-day News Coverage of Conflict Events 
**********************************************************************************

use "$dta/replication_file1.dta", clear

reg any_conflict_news occurrence daily_woi i.month i.dow if (occurrence_1==0 & occurrence_pal_1==0 & occurrence_pal==0 & gaza==0) ,  cluster( monthyear)
outreg2 using "$tables/table_A17.xls", replace ctitle("Presence of conflict news") keep(occurrence daily_woi) nocons label bdec(3) 

reg any_conflict_news occurrence_1 daily_woi i.month  i.dow if (occurrence==0 & occurrence_pal==0 & occurrence_pal_1==0 & gaza==0), cluster (monthyear) 
outreg2 using "$tables/table_A17.xls", append ctitle("Presence of conflict news") keep(occurrence_1 daily_woi occurrence l.occurrence occurrence_pal l.occurrence_pal ) nocons label bdec(3) 

reg any_conflict_news occurrence occurrence_1 occurrence_pal l.occurrence_pal daily_woi  i.month  i.dow if gaza==0, cluster(monthyear)
test occurrence=occurrence_1
scalar P_v=r(p)
outreg2 using "$tables/table_A17.xls", append ctitle("Any news on conflict") keep(lnvic l.lnvic lnvic_pal l.lnvic_pal daily_woi occurrence occurrence_1 occurrence_pal l.occurrence_pal  )  nocons label bdec(3) addstat("p value", P_v)

glm  length_conflict_news occurrence occurrence_1 occurrence_pal l.occurrence_pal daily_woi i.month  i.dow if gaza==0  , family(nbinom  ml) vce(cluster monthyear)
test occurrence=occurrence_1
scalar P_v=r(p)
outreg2 using "$tables/table_A17.xls", append ctitle("Length of conflict news")  keep(lnvic l.lnvic lnvic_pal l.lnvic_pal daily_woi occurrence occurrence_1 occurrence_pal l.occurrence_pal ) nocons label bdec(3) addstat("p value", P_v)

tnbreg length_conflict_news occurrence occurrence_1 occurrence_pal l.occurrence_pal daily_woi i.month  i.dow if gaza==0 & any_conflict_news==1, ll(0)  vce(cluster monthyear)
test occurrence=occurrence_1
scalar P_v=r(p)
outreg2 using "$tables/table_A17.xls", append ctitle("Length of conflict news")  keep(lnvic l.lnvic lnvic_pal l.lnvic_pal daily_woi occurrence occurrence_1 occurrence_pal l.occurrence_pal ) nocons label bdec(3) addstat("p value", P_v)

* Corresponding negative binomial regressions to display the pseudo R-squared for columns 4-5
eststo clear
eststo: nbreg  length_conflict_news occurrence occurrence_1 occurrence_pal l.occurrence_pal daily_woi i.month i.dow if gaza==0, vce(cluster monthyear)
eststo: tnbreg length_conflict_news occurrence occurrence_1 occurrence_pal l.occurrence_pal daily_woi i.month  i.dow if gaza==0 & any_conflict_news==1, ll(0) vce(cluster monthyear)
esttab, se pr2 star(* 0.1 ** 0.05 *** 0.01)

**********************************************************************************************
**    Table A18. Content of News Stories that Appear on the Same Day and on the Next Day
**********************************************************************************************

use "$dta/replication_file2.dta", clear

* Panel A: Sample of news stories about an Israeli attack, occurred on the same day or previous day not mentioning Palestinian attacks

sum q12 if (q5==1)&q4==1&(q7==1)&(q6==0)
scalar aa = r(mean)

xi: reg q12 q8 i.network q6 i.coder_name if (q5==1)&(q4==1)&(q7==1 | q8==1)&(q6==0), cluster(monthyear) 
outreg2 using "$tables/table_A18_a.xls", replace   stats(coef se) keep(q8 otherdays q8_palestine  q4 q6) nocons title(q`x' smallest) auto(3)  addstat("mean same day", aa) bdec(3)

foreach x in 14 19 20 21_q22 _info _images _personal_touch {
sum q`x' if (q5==1)&q4==1&(q7==1)&(q6==0)
scalar aa = r(mean) 
xi: reg q`x' q8 i.network q6 i.coder_name if (q5==1)&(q4==1)&(q7==1 | q8==1)&(q6==0), cluster(monthyear)
outreg2 using "$tables/table_A18_a.xls", append   stats(coef se) keep(q8 otherdays q8_palestine  q4 q6) nocons title(q`x' smallest) auto(3)  addstat("mean same day", aa) bdec(3)
}

* Panel B: Sample of all news stories about the Israeli-Palestinian conflict

xi: reg q12 q8 q8_palestine otherdays   i.network q4 q6 i.coder_name, cluster(monthyear)
outreg2 using "$tables/table_A18_b.xls", replace  stats(coef se) keep(q8 otherdays q8_palestine  q4 q6) nocons title(q`x' smallest) auto(3)  

foreach x in 14 19 20 21_q22 _info  _images _personal_touch  {
xi: reg q`x' q8 q8_palestine otherdays   i.network q4 q6 i.coder_name, cluster(monthyear)
outreg2 using "$tables/table_A18_b.xls", append  stats(coef se) keep(q8 otherdays q8_palestine   q4 q6) nocons title() auto(3) bdec(3)
}

****************************************************************************************************
**    TABLE A19: Difference in Content between Same-day and Next-day Coverage (Other Dimensions)
****************************************************************************************************

use "$dta/replication_file2.dta", clear

* Panel A: Sample of news stories about an Israeli attack occurred on the same or previous day not mentioning Palestinian attacks

sum q9 if (q5==1)&q4==1&(q7==1)&(q6==0)
scalar aa = r(mean) 

xi: reg q9 q8 i.network q6 i.coder_name if (q5==1)&(q4==1)&(q7==1 | q8==1)&(q6==0), cluster(monthyear)
outreg2 using "$tables/table_A19_a.xls", replace  stats(coef se) keep(q8 otherdays q8_palestine  q4 q6) nocons title(q`x' smallest) auto(3)  addstat("mean same day", aa) bdec(3)

foreach x in   10 11 13 15 16 17 18 24 23 25 26 {
sum q`x' if (q5==1)& q4==1 & (q7==1) & (q6==0)
scalar aa = r(mean) 
xi: reg q`x' q8 i.network q6 i.coder_name if (q5==1)&(q4==1)&(q7==1 | q8==1)&(q6==0), cluster(monthyear)
outreg2 using "$tables/table_A19_a.xls", append   stats(coef se) keep(q8 otherdays q8_palestine  q4 q6) nocons title(q`x' smallest) auto(3)  addstat("mean same day", aa) bdec(3)
}

* Panel B: Sample of all news stories about Israeli-Palestinian conflict

xi: reg q9 q8 q8_palestine otherdays  i.network q4 q6 i.coder_name, cluster(monthyear)
outreg2 using "$tables/table_A19_b.xls", replace stats(coef se) keep(q8 otherdays q8_palestine   q4 q6) nocons title() auto(3) bdec(3)

foreach x in 10 11 13 15 16 17 18 24 23 25 26 {
xi: reg q`x' q8 q8_palestine otherdays   i.network q4 q6 i.coder_name, cluster(monthyear)
outreg2 using "$tables/table_A19_b.xls", append stats(coef se) keep(q8 otherdays q8_palestine   q4 q6) nocons title() auto(3) bdec(3)
}

*********************************************************************************************************
									   *** APPENDIX FIGURES ***
*********************************************************************************************************

***************************************************************************
**   Figure A1. THE DISTRIBUTION OF NEWS PRESSURE, THE U.S. TV NETWORKS   
***************************************************************************

use "$dta/replication_file1.dta", clear

histogram daily_woi,   bin(50) kdensity kdenopts(lcolor(navy)) fcolor(none) xtitle(News Pressure)             legend(off) graphregion(fcolor(white))  xline(.8333333, lwidth(medthick)) xline(.6133333 , lwidth(medthick)) xline(1.233333 , lwidth(medthick))
graph save Graph "$figures/figure_A1_1.gph", replace

histogram daily_woi_nc, bin(50) kdensity kdenopts(lcolor(navy)) fcolor(none) xtitle(Uncorrected News Pressure) legend(off) graphregion(fcolor(white))  xline(.8166667, lwidth(medthick)) xline(.5833334, lwidth(medthick)) xline(1.216667 , lwidth(medthick))
graph save Graph "$figures/figure_A1_2.gph", replace

graph combine "$figures/figure_A1_1.gph" "$figures/figure_A1_2.gph", graphregion(fcolor(white)) title(Distributions of two measures of daily news pressure (2000-2011), color(black) margin(tiny) size(mlarge)) caption("Vertical lines mark 10th, 50th, and 90th percentiles",  color(black) position(6)) 
graph export "$figures/figure_A1.pdf", replace

erase "$figures/figure_A1_1.gph"
erase "$figures/figure_A1_2.gph"

***************************************************************************************
**      Figure A2. Israeli and Palestinian Attacks and US News Pressure, 
**             Lags and Leads of News Pressure Included One by One 
***************************************************************************************

use "$dta/replication_file1.dta", clear

order date-lagdaily_woi7 lagdaily_woi6 lagdaily_woi5 lagdaily_woi4 lagdaily_woi3 lagdaily_woi2 lagdaily_woi daily_woi leaddaily_woi leaddaily_woi2 leaddaily_woi3 leaddaily_woi4 leaddaily_woi5 leaddaily_woi6 leaddaily_woi7
capture drop D1 D2 D3 D4 D5 D6 D7 D8 D9 D10 D11 D12 D13 D14 D15 lagdaily_woi1 leaddaily_woi1

gen lagdaily_woi1=lagdaily_woi
gen leaddaily_woi1=leaddaily_woi

forval k=1/7 {
local l=8-`k'
gen D`k'=lagdaily_woi`l' 
}

gen D8=daily_woi

forval k=1/7 {
local l=8+`k'
gen D`l'=leaddaily_woi`k' 
}

sort date
order date-D1 D2 D3 D4 D5 D6 D7 D8 D9 D10 D11 D12 D13 D14 D15
preserve

* Probability of Israeli attacks and news pressure

set more off
gen time=date-14881
gen coef =.
gen low_g =.
gen high_g =.
sort date
forval k=5/13 {
xi: newey occurrence D`k' occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0,lag(7) force 
replace coef = _b[D`k'] if time==`k'
replace low_g = _b[D`k']-1.64*_se[D`k'] if time==`k'
replace high_g = _b[D`k']+1.64*_se[D`k'] if time==`k'
}

collapse (mean) coef high_g low_g, by(time)
keep if time<=13
keep if time>4
label def ti 5 "T-3" 6 "T-2" 7 "T-1" 8 "T" 9 "T+1" 10 "T+2" 11 "T+3" 12 "T+4" 13 "T+5" 
label values t ti
twoway (rarea low_g high_g t, sort color(gs14)) (scatter coef t, connect(l) lwidth(medthick) lcolor(maroon) mcolor(maroon) msize(medium) )  (function y=0    ,range(5 13) lcolor(black) lwidth(medthin)),  yscale(range(-.2 .2) titlegap(.05)) yline(0, lcolor(black) lwidth(medthin)) xlabel( 5 6 7 8 9 10 11 12 13, valuelabel) ylabel( -.2 -.1 0 .1 .2) ytitle(Coefficient) legend(off)  graphregion(fcolor(white)) title("Probability of Israeli attack", color(black))  xtitle("") subtitle("news pressure (one by one)", color(black))
graph save "$figures/figure_A2_a.gph", replace 
restore

* Probability of Palestinian attacks and news pressure

preserve
set more off
gen time=date-14881
gen coef =.
gen low_g =.
gen high_g =.
sort date
forval k=5/13 {
xi: newey occurrence_pal D`k' occurrence_1 occurrence_2_7 occurrence_8_14 i.month i.year i.dow if gaza_war==0,lag(7) force 
replace coef = _b[D`k'] if time==`k'
replace low_g = _b[D`k']-1.64*_se[D`k'] if time==`k'
replace high_g = _b[D`k']+1.64*_se[D`k'] if time==`k'
}
collapse (mean) coef high_g low_g, by(time)
keep if time<=13
keep if time>4
label def ti 5 "T-3" 6 "T-2" 7 "T-1" 8 "T" 9 "T+1" 10 "T+2" 11 "T+3" 12 "T+4" 13 "T+5" 
label values t ti
twoway (rarea low_g high_g time, sort color(gs14)) (scatter coef t, connect(l) lwidth(medthick) lcolor(maroon) mcolor(maroon) msize(medium) ) (function y=0    ,range(5 13) lcolor(black) lwidth(medthin)) ,  yscale(range(-.2 .2) titlegap(.05)) yline(0, lcolor(black) lwidth(medthin)) xlabel( 5 6 7 8 9 10 11 12 13, valuelabel) ylabel( -.2 -.1 0 .1 .2) ytitle(Coefficient) legend(off)  graphregion(fcolor(white)) title("Probability of Palestinian attack", color(black))  subtitle("news pressure (one by one)", color(black)) xtitle("") 
graph save Graph "$figures/figure_A2_b.gph", replace 
restore

order date-lagdaily_woi7 lagdaily_woi6 lagdaily_woi5 lagdaily_woi4 lagdaily_woi3 lagdaily_woi2 lagdaily_woi daily_woi leaddaily_woi leaddaily_woi2 leaddaily_woi3 leaddaily_woi4 leaddaily_woi5 leaddaily_woi6 leaddaily_woi7
capture drop D1 D2 D3 D4 D5 D6 D7 D8 D9 D10 D11 D12 D13 D14 D15
capture drop  lagdaily_woi1_nc leaddaily_woi1_nc
gen lagdaily_woi1_nc=lagdaily_woi_nc
gen leaddaily_woi1_nc=leaddaily_woi_nc

forval k=1/7 {
local l=8-`k'
gen D`k'=lagdaily_woi`l'_nc 
}

gen D8=daily_woi_nc

forval k=1/7 {
local l=8+`k'
gen D`l'=leaddaily_woi`k'_nc 
}

sort date
order date-D1 D2 D3 D4 D5 D6 D7 D8 D9 D10 D11 D12 D13 D14 D15

* Probability of Israeli attacks and uncorrected news pressure

preserve
gen time=date-14881
gen coef =.
gen low_g =.
gen high_g =.
sort date
forval k=5/13 {
xi: newey occurrence D`k' occurrence_pal_1 occurrence_pal_2_7 occurrence_pal_8_14 i.month i.year i.dow if gaza_war==0,lag(7) force 

replace coef = _b[D`k'] if time==`k'
replace low_g = _b[D`k']-1.64*_se[D`k'] if time==`k'
replace high_g = _b[D`k']+1.64*_se[D`k'] if time==`k'
}
collapse (mean) coef high_g low_g, by(time)
keep if time<=13
keep if time>4
label def ti 5 "T-3" 6 "T-2" 7 "T-1" 8 "T" 9 "T+1" 10 "T+2" 11 "T+3" 12 "T+4" 13 "T+5" 
label values t ti
twoway (rarea low_g high_g t, sort color(gs14)) (scatter coef t, connect(l) lwidth(medthick) lcolor(maroon) mcolor(maroon) msize(medium) )  (function y=0    ,range(5 13) lcolor(black) lwidth(medthin)),  yscale(range(-.2 .2) titlegap(.05)) yline(0, lcolor(black) lwidth(medthin)) xlabel( 5 6 7 8 9 10 11 12 13, valuelabel) ylabel( -.2 -.1 0 .1 .2) ytitle(Coefficient) legend(off)  graphregion(fcolor(white)) title("Probability of Israeli attack", color(black))  xtitle("") subtitle("uncorrected news pressure (one by one)", color(black))
graph save Graph "$figures/figure_A2_c.gph", replace
restore

* Probability of Palestinian attacks and uncorrected news pressure

preserve
gen time=date-14881
gen coef =.
gen low_g =.
gen high_g =.
sort date
forval k=5/13 {
xi: newey occurrence_pal D`k' occurrence_1 occurrence_2_7 occurrence_8_14 i.month i.year i.dow if gaza_war==0,lag(7) force 

replace coef = _b[D`k'] if time==`k'
replace low_g = _b[D`k']-1.64*_se[D`k'] if time==`k'
replace high_g = _b[D`k']+1.64*_se[D`k'] if time==`k'
}
collapse (mean) coef high_g low_g, by(time)
keep if time<=13
keep if time>4
label def ti 5 "T-3" 6 "T-2" 7 "T-1" 8 "T" 9 "T+1" 10 "T+2" 11 "T+3" 12 "T+4" 13 "T+5" 
label values t ti
twoway (rarea low_g high_g t, sort color(gs14)) (scatter coef t, connect(l) lwidth(medthick) lcolor(maroon) mcolor(maroon) msize(medium) ) (function y=0    ,range(5 13) lcolor(black) lwidth(medthin)) ,  yscale(range(-.2 .2) titlegap(.05)) yline(0, lcolor(black) lwidth(medthin)) xlabel( 5 6 7 8 9 10 11 12 13, valuelabel) ylabel( -.2 -.1 0 .1 .2) ytitle(Coefficient) legend(off)  graphregion(fcolor(white)) title("Probability of Palestinian attack", color(black))  subtitle("uncorrected news pressure (one by one)", color(black)) xtitle("") 
graph save Graph "$figures/figure_A2_d.gph", replace
restore

* Combine graphs
cd "$figures/"
graph combine figure_A2_a.gph figure_A2_b.gph figure_A2_c.gph figure_A2_d.gph, graphregion(color(white))
graph export     "$figures/figure_A2.pdf", replace 

erase "$figures/figure_A2_a.gph"
erase "$figures/figure_A2_b.gph"
erase "$figures/figure_A2_c.gph"
erase "$figures/figure_A2_d.gph"

***************************************************************************************
**   Figure A3. Nonparametric Local Linear Least Squares Bivariate Relationship
**           Between Israeli Attacks and Next-day News Pressure 
***************************************************************************************

use "$dta/replication_file1.dta", clear

* Panel A: Occurrence of Israeli attacks

preserve
label var leaddaily_woi "News pressure, t+1"
sum leaddaily_woi, d 
local Mean=r(mean) 
local Median =r(p50)
local Perc95=r(p95)
local Perc99=r(p99)
cap drop occurrence_leadNP
lowess occurrence leaddaily_woi if gaza==0, bw(0.7) gen(occurrence_leadNP) nograph adjust			
lab var occurrence_leadNP "Lowess: Occurrence of Israeli attacks"	
twoway line occurrence_leadNP leaddaily_woi, sort xline(`Median')  xline(`Perc99') xlabel(`Median' "p50"  `Perc99' "p99") graphregion(color(white))
graph export     "$figures/figure_A3_a.pdf", replace

sum leaddaily_woi, d 
local Mean=r(mean) 
local Median =r(p50)
local Perc95=r(p95)
local Perc99=r(p99)
cap drop occurrence_leadNP

* Panel A: Severity of Israeli attacks

cap drop lnvic_leadNP
lowess lnvic leaddaily_woi if gaza==0, bw(0.7) gen(lnvic_leadNP) nograph adjust			
lab var lnvic_leadNP "Lowess: Log(1+ fatalities of Israeli attacks)"	
twoway line  lnvic_leadNP leaddaily_woi, sort xline(`Median')  xline(`Perc99') xlabel(`Median' "p50"  `Perc99' "p99") graphregion(color(white))
graph export     "$figures/figure_A3_b.pdf", replace
restore
***************************************************************************
**   Figure A4. Frequency and the Number of Victims of Israeli Attacks 
**                by Quintiles of Next-day News Pressure 
***************************************************************************

use "$dta/replication_file1.dta", clear

* Occurrence and newspressure 

preserve
xtile quintile=leaddaily_woi if gaza_war==0, nq(5)
drop if quintile==. 
collapse (mean) occurrence, by(quintile)
#delimit;
twoway bar occurrence quintile, xtitle(Quintiles of next day news pressure, margin(small)) ytitle(Fraction of days with attacks, margin(small)) graphregion(margin(vsmall) fcolor(white) lcolor(none) lwidth(none) ilcolor(none) ilwidth(none))
title(Occurrence and news pressure, margin(medsmall) color(black)) barwidth(0.5) yscale(r(0.32 0.43)) plotregion(margin(0)) xscale(r(0.5 5.5)) ylabel(0.32(0.02)0.42);
#delimit cr
graph save Graph "$figures/figure_A4_a.gph", replace
restore

* Fatalities and newspressure

xtile quintile=leaddaily_woi if gaza_war==0, nq(5)
drop if quintile==.
egen victim_num_q=mean(victims_isr), by (quintile)
egen victim_num_cond_q=mean(victims_isr) if occurrence==1, by (quintile)
keep victim_num_q victim_num_cond_q quintile
duplicates drop
drop if victim_num_cond_q==.
gsort + quintile
label var victim_num_q "Fatalities"
label var victim_num_cond_q "Fatalities, given occurrence"
label var quintile "Quintiles of next-day news pressure"
#delimit;
graph bar victim_num_q victim_num_cond_q, over(quintile) ytitle(Number of fatalities, margin(small)) 
title(Fatalities and news pressure, margin(medsmall) color(black)) yscale(r(0 4)) graphregion(margin(vsmall) 
fcolor(white) lcolor(none) lwidth(none) ilcolor(none) ilwidth(none)) plotregion(margin(0)) ylabel(0(0.5)4) 
b1title(Quintiles of next-day newspressure, size(medsmall)) bar(1, color(maroon)) bar(2, 
color(forest_green)) legend(col(2) lab(1 "Fatalities") lab(2 "Fatalities (given occurrence)"));
#delimit cr
graph save Graph "$figures/figure_A4_b.gph", replace

* Combine graphs
cd "$figures/"
graph combine figure_A4_a.gph figure_A4_b.gph, rows(2) ysize(7) graphregion(margin(vsmall) fcolor(white) lcolor(none) lwidth(none) ilcolor(none) ilwidth(none))
graph export     "$figures/figure_A4.pdf", replace 
erase "$figures/figure_A4_a.gph"
erase "$figures/figure_A4_b.gph"
