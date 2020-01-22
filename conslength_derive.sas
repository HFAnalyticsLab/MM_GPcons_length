
* =======================================================
* Project: MM_GPconsultation_length
* code for deriving dataset for analysis of consultation length by area deprivation and multimorbidity;
* Author: Mai Stafford
* Date: May 2019
* =======================================================


title;
libname cldata "file_paths_removed";
libname p036 "file_paths_removed";
libname mm  "file_paths_removed";
libname rawcprd "file_paths_removed";
libname rawhes "file_paths_removed";

proc format;
value agefmt 0-24='<25y' 25-44='25-44y' 45-64='45-64y' 65-84='65-84y' 85-high='85+y';
value mentalb 4-high='4+';
value physicalb 4-high='4+';
value total 4-high='4+';
value mmorb 0-1='not MM' 2-high='MM 2+';
run;

* select consultations in the HES year 2014/2015 and 2015/2016;
data consultation; 
set  rawcprd.extract_consultation;
where eventdate ge '01apr2014'd and eventdate le '31mar2016'd ;
run;

proc sort data=consultation; by staffid; run;
proc sort data=rawcprd.'17_150R_Extract_Staff_001'n out=staff; by staffid; run;

* merge consultation and staff role data;
data cons1;
merge consultation (in=ina) staff;
by staffid;
if ina;
run;

proc sort data=cons1; by patid; run;


/*
Face to face consultation codes:	Home consultation codes:		Telephone consultation codes:
--------------------------------	------------------------		-----------------------------
Clinic,1,							Home Visit,27,					Telephone call from a patient,10,
Follow-up/routine visit,3,			Hotel Visit,28,					Telephone call to a patient,21,
Night visit , practice,6,			Nursing Home Visit,30,			Triage,33,
Out of hours, Practice,7,			Residential Home Visit,31,		Telephone Consultation,55,
Surgery consultation,9,				Twilight Visit,32,
Acute visit,11,						Night Visit,50,
Emergency Consultation,18,
Initial Post Discharge Review,48,

GP codes from rol:				Nurse codes from rol:				Other clinician codes from rol:
------------------				---------------------				-------------------------------
Senior Partner,1,				Practice Nurse,11,					Physiotherapist,26,
Partner,2,						Other Nursing & Midwifery,54		Other Health Care Professional,33
Assistant,3,
Associate,4, 
Locum,7,
GP Registrar,8,
Sole Practitioner,10,
Salaried Partner,47,
GP Retainer,50,
Other Students,53
*/

data cons1;
set cons1;
* include non-admin consultations only;
if constype in (1 3 6 7 9 11 18 48) then f2f=1;
else f2f=0;
if constype in (27 28 30 31 32 50) then homevis=1;
else homevis=0;
if constype in (10 21 33 55) then telecons=1;
else telecons=0;
if f2f=1 OR homevis=1 OR telecons=1 then consult=1;
else consult=0;
* derive duration of consultation;
if duration=0 then do;
  duration=0.5;
end;
if duration gt 60 then duration=60;
* Note duration of home visits is time taken to enter data so not used here. Just count f2f and telephone consultations;
if consult=1 and homevis=0 then duratcons=duration;
else duratcons=.;
if f2f=1 and homevis=0 then duratf2f=duration;
else duratf2f=.;

* Staff role. Only include doctor, nurse and other clinical staff;
if consult=1 then do;
  if role in (1 2 3 4 7 8 10 47 50 53) then gp=1;
  else gp=0;
  if role in (11 54) then nurse=1;
  else nurse=0;
  if role in (26 33) then otherstaff=1;
  else otherstaff=0;
end;
if role ne . and role ne 8 then gpregistrar=0;
if role=8 then gpregistrar=1;
drop gender; * this is gender of staff member not patient;
run;


*********************************************************;
* derive consultation level data for multilevel modelling;

* merge in medcode (CPRD unique code for medical term selected by GP) from the clinical file;
data clinical;
set rawcprd.extract_clinical;
where eventdate ge '01apr2014'd and eventdate le '31mar2016'd ;
keep patid eventdate constype consid medcode;
run;

proc sort data=clinical; by patid consid; run;

proc transpose data=clinical out=clinwide prefix=medcode;
by patid consid;
var medcode;
run;

* up to 81 medcodes in a consultation - just keep the first 5;
data clinwide;
set clinwide;
drop _name_ medcode6-medcode81;
run;

data conslevel;
merge cons1 (in=ina) clinwide;
by patid;
if ina;
run;

proc sort data=conslevel; by patid eventdate; run;

data patientsex;
set rawcprd.'17_150R_Extract_Patient_001'n ;
if gender=1 then sex=1;
if gender=2 then sex=2;
keep patid sex;
run;
proc sort data=patientsex; by patid; run;

data conslevel2;
merge conslevel (in=ina) mm.ltsuse (in=inb) patientsex;
by patid;
if ina and inb;
run;

data mm.conslevel;
set conslevel2;
label f2f="face-to-face consultation" homevis="home visit consultation" 
 telecons="telephone consultation" duratcons="duration of consultation (mins)" gp="GP consultation" nurse="nurse consultation" 
 otherstaff="other clinician consultation";
keep patid staffid  constype f2f homevis telecons duratcons duratf2f role gp nurse otherstaff
 medcode episode enttype gpregistrar eventdate
 total imd2015_10 sex startage medcode1-medcode5
  ALC ANO DEM EPI LEA MIG OPS PRK SCZ AST ATR BLI BRO CAN CHD CKD CLD CON 
  COP DIB DIV HEF HEL HYP IBD IBS MSC PNC PRO PSO PVD RHE SIN STR THY depanx;
  * dataset too large so limit only to GP, nurse and other staff consultations;
  if consult=1;
run;

