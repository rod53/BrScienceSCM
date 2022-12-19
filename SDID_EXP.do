*****************************************************************
* O efeito dos investimentos XXXX
*****************************************************************
clear all
* Installing Packedges
ssc install synth, replace
ssc install distinct, replace
ssc install elasticregress, replace
ssc install allsynth, replace
ssc install sdid, replace

*****************************************************************
* Data
cd "C:\Users\rodri\Desktop" // complete with data directory (Rodrigo, vc coloca o teu directory aqui)
import excel "C:\Users\rodri\Desktop\df2.xlsx", sheet("Sheet1") firstrow

*****************************************************************
* Filtragem
egen id = group(Country)
g y1 = Web_of_Science_Documents
g y2 = Times_Cited
g y3 = Green_Only_Documents
g y4 = Documents_in_JIF_Journals
g y5 = International_Collaborations
g y6 = All_Open_Access_Documents
g y7 = Gold_Documents
g y8 = Citation_Impact
g y9 = Citations_From_Patents
g y10 = Average_Percentile
g y11 = Free_to_Read_Documents
g y12 = Industry_Collaborations
g y13 = Impact_Relative_to_World
g y14 = Domestic_Collaborations
g y15 = Green_Submitted_Documents
g y16 = Green_Accepted_Documents
g y17 = Green_Published_Documents
g y18 = Documents_in_Q1_Journals
g y20 = Documents_in_Q2_Journals
g y21 = Documents_in_Q3_Journals
g y22 = Documents_in_Q4_Journals
g y23 = Documents_in_Top_1
g y24 = Documents_in_Top_10

* Estimations
sort ID Year
xtset ID Year
g D = 1 if id==21 & Year>=2006
recode D .=0

*****************************************************************
*Synthetic Difference in Difference - SDD
* Treated variable

log using "C:\Users\rodri\Desktop\LOG.log", replace

sdid y24 id Year D, vce(placebo) reps(100) seed(1213) graph
di e(ATT)
di e(se)

log close





sdid y id Year D, vce(placebo) reps(100) seed(1213) covariates(x1 x2) graph
di e(ATT)
di e(se)

*****************************************************************

* SC method
* Difference in Treatment - Classic SCM & Bias-correction SCM 
allsynth y y(2000) y(2001) y(2002) y(2003) y(2004) y(2005), trunit(23) trperiod(2006) bcorrect(merge posonly) gapfigure(classic bcorrect lineback) keep(results) replace 
* Placebo Bias-Corrected SCM
allsynth y y(2000) y(2001) y(2002) y(2003) y(2004) y(2005), trunit(23) trperiod(2006) bcorrect(merge posonly) gapfig(bcorrect placebos lineback) pvalues keep(results) replace
* Placebo Classic SCM
allsynth y y(2000) y(2001) y(2002) y(2003) y(2004) y(2005), trunit(23) trperiod(2006)  gapfig(classic placebos lineback) pvalues keep(results) replace
*****************************************************************
* ATT - SCM
use results.dta,clear
*ATT Classic SCM
sum gap if id==23 & _time>2005
* ATT Bias-Corrected SCM
sum gap_bc if id==23 & _time>2005
* P-values
label var p "p-values"
label var p_bc "p-values"
label var _time "Years"
* Graph: p-values Bias-Corrected SC
scatter p_bc _time if id==23 & _time>2005, ysc(r(0 0.5)) ylabel(0.05 .10 .15 .20 .25 .30 .35 .40 .45) scheme(s1mono) title((B) Bias-Corrected Syntetic Control)
* Graph: p-values Classic SC
scatter p _time if id==23 & _time>2005, ysc(r(0 0.5)) ylabel(0.05 .10 .15 .20 .25 .30 .35 .40 .45) scheme(s1mono) title((A) Classic Syntetic Control)

