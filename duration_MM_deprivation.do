* =======================================================
* Project: MM_GPconsultation_length
* code for deriving dataset for analysis of consultation length by area deprivation and multimorbidity;
* Authors: Anya Gopfert & Mai Stafford
* Date: May 2019
* =======================================================

use "file_path_removed\conslevel.dta", clear 

generate multim = total>1
gen multimental = total>1 & ( depanx==1 | ano==1 | alc==1 | ops==1 | scz==1 | lea==1)
gen mm_ment_phys=multim
replace mm_ment_phys=2 if multim==1 & multimental==1 
label define mm_ment_phys 0 "Not MM" 1 "MM phys" 2 "MM ment"
label values mm_ment_phys mm_ment_phys
tab mm_ment_phys

**clean data and check bias in sample selection**
drop if startage<18

tabulate multim f2f, row col chi2
 
drop if f2f==0
tab sex

**create gp variable**
generate gp1=.
replace gp1=1 if role==1
replace gp1=1 if role==2
replace gp1=1 if role==3
replace gp1=1 if role==4
replace gp1=1 if role==7
replace gp1=1 if role==10
replace gp1=1 if role==47
replace gp1=1 if role==50

generate role1=0
replace role1=1 if gp1==1
replace role1=1 if gpregistrar==1
tabulate multim role1, row col chi2
keep if role1==1
tab sex

* drop infeasibly short consultations **
tabulate duratcons, missing
recode duratcons (0/1=1) (2/61=0), gen(shortdur)
tabulate multim shortdur, row col chi2
drop if duratcons<2
tab sex


**recode deprivation **
recode imd2015_10 (1/2=1) (3/4=2) (5/6=3) (7/8=4) (9/10=5), gen(depriv5)
label define deprivation5 1 "Q1least deprived" 2 "Q2" 3 "Q3" 4 "Q4" 5 "Q5 most deprived"
label values depriv5 deprivation5


recode startage (18/29=1) (30/39=2) (40/49=3) (50/59=4) (60/69=5) (70/79=6) (80/150=7), gen(startageg)
label define ageg 1 "18-29y" 2 "30-39y"  3 "40-49y" 4 "50-59y" 5 "60-69y" 6 "70-79y" 7 "80+y"
label values startageg ageg

* Add total # consultations in the period *
egen N_consultations=count(duratcons), by(patid)

save  "file_path_removed\conslevel_cleaned.dta", replace


* descriptives at patient level
bysort patid: keep if _n==1
tab sex
tabulate depriv5 sex, row col chi2
tab startageg sex, row col chi2
tab multim sex, row col chi2
tab mm_ment_phys sex, row col chi2
tabulate sex, summarize(N_consultations)
tabulate startageg, summarize(N_consultations)
tabulate depriv5, summarize(N_consultations)
tabulate multim, summarize(N_consultations)
tabulate mm_ment_phys, summarize(N_consultations)


* Analysis at Consultation level *
use "file_path_removed\conslevel_cleaned.dta", clear

tab gpregistrar sex, row col chi2
tab gpregistrar multim, row col chi2
tab gpregistrar mm_ment_phys, row col chi2

hist duratf2f
summ duratf2f, detail

tabulate sex, summarize(duratf2f)
tabulate startageg, summarize(duratf2f)
tabulate depriv5, summarize(duratf2f)
tabulate multim, summarize(duratf2f)
tabulate mm_ment_phys, summarize(duratf2f)
tabulate gpregistrar, summarize(duratf2f)



**Preliminary models incl age, sex, GP registrar status**
xtmixed duratcons startage i.sex i.gpregistrar N_consultations || patid:
estimates store linage
xtmixed duratcons i.startageg i.sex i.gpregistrar N_consultations || patid:
estimates store categage
* decide between age as continuous or categorical variable
lrtest linage categage

*add IMD**
xtmixed duratcons i.startageg i.sex i.gpregistrar N_consultations depriv5 || patid:
estimates store lindep
xtmixed duratcons i.startageg i.sex i.gpregistrar N_consultations i.depriv5 || patid:
estimates store categdep
lrtest lindep categdep


**add multim**
xtmixed duratcons i.startageg i.sex i.gpregistrar N_consultations i.multim || patid:

** IMD and multim in same model
xtmixed duratcons i.startageg i.sex i.gpregistrar N_consultations i.depriv5 i.multim || patid:
*margins multim depriv5, atmeans
estimates store mm_depriv

**multim interacting with IMD**
xtmixed duratcons i.startageg i.sex i.gpregistrar N_consultations i.depriv5##i.multim || patid:
margins i.multim##i.depriv5, atmeans
estimates store mm_depriv_interaction
lrtest mm_depriv mm_depriv_interaction

* 3 level **
gen pracid=real(substr(string(patid),-3,.))
xtmixed duratcons i.startageg i.sex i.gpregistrar N_consultations i.depriv5##i.multim || pracid:  || patid:
margins i.multim##i.depriv5, atmeans



*** mental and physical comorbidity ***
xtmixed duratcons i.startageg i.sex i.gpregistrar N_consultations i.depriv5 i.mm_ment_phys || patid:
estimates store mmmhph
xtmixed duratcons i.startageg i.sex i.gpregistrar N_consultations i.depriv5##i.mm_ment_phys || patid:
margins i.depriv5##i.mm_ment_phys, atmeans 
estimates store mmmhph_interaction
lrtest mmmhph mmmhph_interaction

xtmixed duratcons i.startageg i.sex i.gpregistrar N_consultations i.depriv5##i.mm_ment_phys || pracid: || patid:
estimates store mmmhph3_interaction
margins i.depriv5##i.mm_ment_phys, atmeans 
xtmixed duratcons i.startageg i.sex i.gpregistrar N_consultations i.depriv5 i.mm_ment_phys || pracid: || patid:
estimates store mmmhph3
lrtest mmmhph3 mmmhph3_interaction
