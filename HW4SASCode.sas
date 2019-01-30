/*Loading the csv file after editing the original file to make it comma separated csv file*/

LIBNAME hw 'H:\Predictive SAS'; 
RUN;proc import datafile="H:\Predictive SAS\bank.csv"
     out=hw.banks
     dbms=csv
     replace;
     getnames=yes;
run;

proc import datafile="H:\Predictive SAS\bankpred.csv"
     out=hw.bankpred
     dbms=csv
     replace;
     getnames=yes;
run;
proc print;
run;

proc logistic data=hw.banks descending outmodel=hw.model;
  class job marital education default housing loan contact month poutcome/ param=ref ;
  model y = age job marital education default balance housing loan contact day month duration campaign pdays previous poutcome/expb;
run;

/*Scoring the Dataset Hw.bankpred*/

proc logistic inmodel=hw.model;
      score data=hw.bankpred out=Score;
   run;
   proc print;run;



/* QUESTION 2 */


/* read data */

DATA q2;
INFILE "h:\hw4\WAGE.DAT" MISSOVER FIRSTOBS = 2;
INPUT edu hr wage famearn self sal mar numkid age unemp;
RUN;

DATA temp1;
INPUT year;
CARDS;
1984
1985
1986
;
RUN;

DATA temp2;
do id =1 to 334;
output; 
end;
RUN;

proc sql;                  
	create table temp3 as select temp1.year as year, temp2.id as id       
	from temp1, temp2 order by id, year;
quit;                      
                           
data q2a;
merge temp3 q2;
run;

data q2a;
set q2a;
lwage = log(wage);
agesq = age*age;
edusq = edu*edu;
hrsq = hr*hr;
run;


/* PROC print data=q2a; run; */


/* running regression and checking for
Multicolliniearity */


PROC REG Data=q2a outest = reg1;
MODEL lwage = age edu numkid hr mar sal self 
/ VIF COLLIN WHITE;
RUN;


/* removing all insignificant variables */

PROC REG Data=q2a outest = reg2;
MODEL lwage = age edu hr sal self 
/ VIF COLLIN WHITE;
RUN;

/* testing for non linearity */

PROC REG Data=q2a outest = reg3 TABLEOUT;
MODEL lwage = age edu edusq hr hrsq sal self 
/ VIF COLLIN WHITE BP;
RUN;

/* Panel data regression */

proc panel data=q2a outest = reg4;
   model lwage = age edu edusq hr hrsq sal self / DURBINWATSON BP fixone fixtwo ranone rantwo;
   id id year;
run;

/* Panel data regression alternate syntax, dont run, found no benefit

proc tscsreg data=q2a outest=reg5; 
id id year;       
model lwage = age edu edusq hr hrsq sal self / fixone fixtwo ranone rantwo;    
Run;

*/


/* Question 3 */

Data HW4.PIMS;
Infile 'H:\MKT 6337\HW4\pims.dat' dsd dlm = ' ';
input MS QUAL PRICE PLB DC PION EF PHPF PLPF PSC PAPC NCOMP MKTEXP TYRP PNP CUSTTYP NCUST CUSTSIZE PENEW CAP RBVI EMPRODY UNION;
Run;


Proc syslin 2SLS simple data = hw4.pims;
Endogenous ms qual plb price dc;
Instruments pion tyrp ef phpf plpf psc papc ncomp mktexp pnp tyrp custtyp ncust custsize penew cap rbvi emprody union; 
model ms = qual plb price pion tyrp ef phpf plpf psc papc ncomp mktexp;
model qual = price dc pion ef tyrp mktexp pnp;
model plb=dc pion tyrp ef pnp custtyp ncust custsize;
model price=ms qual dc pion ef tyrp mktexp pnp;
model dc=ms qual pion ef tyrp penew cap rbvi emprody union;
Run;

proc reg data = hw4.PIMS;
model ms=qual plb price pion tyrp ef phpf plpf psc papc ncomp mktexp;
quit;

proc reg data = hw4.PIMS;
model qual = price dc pion ef tyrp mktexp pnp;
quit;

proc reg data = hw4.PIMS;
model plb=dc pion tyrp ef pnp custtyp ncust custsize;
quit;

proc reg data = hw4.PIMS;
model price=ms qual dc pion ef tyrp mktexp pnp;
quit;

proc reg data = hw4.PIMS;
model dc=ms qual pion ef tyrp penew cap rbvi emprody union;
quit;
