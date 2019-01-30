LIBNAME hw 'H:\Predictive SAS'; 
DATA loans; 
set hw.big_loan;
RUN;
proc corr data= loans;
VAR loan_amnt int_rate installment annual_inc delinq_2yrs total_rec_prncp total_rec_int total_rec_late_fee;
run;
proc sgscatter data=loans; 
matrix  loan_amnt int_rate installment annual_inc delinq_2yrs total_rec_prncp total_rec_int total_rec_late_fee / diagonal=(histogram kernel);;
run;
proc means data=loans;
run;
proc freq data = loans;
tables grade;
run; 
PROC GCHART DATA=loans;
VBAR grade;
run;
proc means data=loans;
var int_rate;
class grade;
run;
proc sort data = loans;by grade;
PROC boxplot data= loans;
plot int_rate*grade;run;
proc freq data = loans;
tables home_ownership;
run; 
PROC GCHART DATA=loans;
VBAR home_ownership;
run;
PROC GCHART data= loans;
vbar home_ownership /
        type = mean outside = mean sumvar = int_rate;
run;
proc freq data = loans;
tables emp_length;
run; 
PROC GCHART DATA=loans;
VBAR emp_length;
run;
proc freq data= loans;
table delinq_2yrs;run;

/* Hypothesis 1 */
proc anova data=loans;
Class delinq_2yrs;
model int_rate=delinq_2yrs;
means delinq_2yrs /hovtest welch;
run;
 
/*Hypothesis 2 */
Data hw.Big_loan;
set hw.big_loan;
if emp_length = "< 1 year" then year = 1;
if emp_length = "1 year" then year = 2;
if emp_length = "2 years" then year = 3;
if emp_length = "3 years" then year = 4;
if emp_length = "4 years" then year = 5;
if emp_length = "5 years" then year = 6;
if emp_length = "6 years" then year = 7;
if emp_length = "7 years" then year = 8;
if emp_length = "8 years" then year = 9;
if emp_length = "9 years" then year = 10;
if emp_length = "10+ years" then year = 11;
Run;
 
proc anova data=hw.big_loan (where = (emp_length ne "n/a"));
Class EMP_LENGTH;
model int_rate=EMP_LENGTH;
means emp_length /hovtest welch;
run;
 
proc anova data=hw.big_loan (where = (emp_length ne "n/a"));
Class year;
model int_rate=year;
means year /hovtest welch;
run;
 
 
/*Hypothesis 3 */
proc anova data=hw.big_loan;
Class home_ownership;
model delinq_2yrs=home_ownership;
means home_ownership /hovtest welch;
run;
proc sort data=loans; by grade; run;
proc means data = loans; class grade;run;



