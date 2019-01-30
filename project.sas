libname project "h:\project\";

proc import datafile="h:\project\demo.csv"
     out=demo
     dbms=csv
     replace;
     getnames=yes;
run;

DATA panel_gr;
SET project.panel_grocery;
RUN;

DATA panel_ma;
SET project.panel_ma;
RUN;

DATA panel_dr;
SET project.panel_drug;
RUN;

DATA panel_grocery;
SET panel_gr panel_dr panel_ma; run;

proc print data= panel_grocery; run;

PROC IMPORT OUT= upc DATAFILE= "h:\project\upc.xlsx" 
            DBMS=xlsx REPLACE;
     SHEET="prod_diapersUPC"; 
     GETNAMES=YES; RUN;

Data upc;
format upccol best32.;
set upc;
Item_id = put(item,z5.);
vend_id = put(vend,z5.);
upc_new = strip(cats(sy,ge,vend_id,Item_id));
COLUPC = upc_new *1;
Run;

PROC sql; 
CREATE TABLE temp1 AS SELECT * FROM panel_grocery g JOIN upc u ON u.COLUPC = g.COLUPC;
quit;

proc print data = temp1 ; run;

data temp2; set temp1;
brand = scan(L5, 1); 
RUN;
/*
proc print data = panel_grocery (obs=2);run;
proc print data = demo (obs=2);run;
proc print data = upc (obs=2);run; */

proc sql;
create table temp3 as select count( distinct BRAND) as BU, PANID from temp2 GROUP BY PANID; quit;

PROC SQL; 
CREATE TABLE temp_r as SELECT PANID, 1166-MAX(WEEK) as R, brand as BRAND FROM temp2 GROUP BY PANID, brand; quit;

PROC SQL;
CREATE TABLE temp_m as SELECT PANID, SUM(DOLLARS) as M, brand as BRAND FROM temp2 GROUP BY PANID, brand; quit;

PROC SQL;
CREATE TABLE temp_f as SELECT PANID, count(*) as F, brand as BRAND FROM temp2 GROUP BY PANID, brand; quit;

PROC SQL; SELECT count(*) from temp_f;quit;

PROC SQL;
CREATE TABLE QPO as SELECT PANID, sum(VOL_EQ*units)/count(units) as QPO, sum(DOLLARS)/count(units) as SPO, brand as BRAND FROM temp2 GROUP BY PANID, brand; quit;
PROC SQL; SELECT count(*) from QPO;quit;

proc sql; select count(distinct BRANDS), PANID from temp2 GROUP BY PANID; quit;

/*
proc print data = temp_r (obs=2);run;
proc print data = temp2 (obs=2);run;
proc print data = temp_f (obs=2);run; */

PROC SQL;
CREATE TABLE temp_rfm as 
SELECT r.PANID as PANID, r.BRAND as BRAND, R, M, F, QPO, SPO 
FROM temp_r r JOIN temp_m m ON (r.PANID = m.PANID AND r.BRAND = m.BRAND) 
JOIN temp_f f ON (f.PANID = r.PANID AND f.BRAND = r.BRAND)
JOIN QPO q ON (q.PANID = r.PANID AND q.BRAND = r.BRAND) ;quit;

PROC SQL; SELECT count(*) from temp_rfm;quit;

PROC SORT data=temp_rfm;
  BY BRAND;
RUN;

PROC RANK DATA=temp_rfm out=data2 ties=low groups=6;
BY BRAND;
VAR F M;
RANKS fscore mscore;run;

PROC RANK data=data2 out=data3 ties=low descending groups=6;
BY BRAND;
VAR R;
RANKS rscore;run;

PROC CORR DATA = temp_rfm;
VAR R F M; run;

DATA data4; SET data3;
fmscore = (fscore + mscore)/2;
RUN;

DATA data5; SET data4;
RFM = cats(rscore,fmscore); RUN;

PROC SQL; SELECT count(*) from data5;quit;

proc print data = data5 (obs=2);run;

DATA buckets; SET data5;
IF  (2 <= rscore <= 5) AND (3 <= fmscore <= 5 ) THEN bucket = "Champions";
IF  (3 <= rscore <= 5) AND (1 <= fmscore <= 3 ) THEN bucket = "potential loyals";
IF  (4 <= rscore <= 5) AND (0 <= fmscore <= 1 ) THEN bucket = "potential loyals";
IF  (3 <= rscore <= 4) AND (0 <= fmscore <= 1 ) THEN bucket = "potential loyals";
IF  (3 <= rscore <= 3) AND (2 <= fmscore <= 3 ) THEN bucket = "at risk";
IF  (2 <= rscore <= 3) AND (0 <= fmscore <= 2 ) THEN bucket = "lost";
IF  (0 <= rscore <= 2) AND (2 <= fmscore <= 5 ) THEN bucket = "at risk";
IF  (0 <= rscore <= 1) AND (4 <= fmscore <= 5 ) THEN bucket = "at risk";
IF  (0 <= rscore <= 2) AND (0 <= fmscore <= 2 ) THEN bucket = "lost";
IF  (1 <= rscore <= 2) AND (1 <= fmscore <= 2 ) THEN bucket = "lost";
RUN;

proc print data = buckets (obs=2); run;

proc means data = buckets;
  class BRAND bucket;
  var M;
  output out=bucketsummary;
run;

PROC EXPORT data=bucketsummary outfile = 'h:\project\heatmap.csv'
dbms = csv
replace;
run;

proc print data = buckets (obs=2);run;
proc print data = demo (obs=2);run;

PROC SQL;
Create table bucket_demo as SELECT * FROM buckets b JOIN demo d ON b.PANID = d.Panelist_ID; quit;

PROC SQL; select COUNT(*) from bucket_demo;quit;

PROC SQL;
Create table bucket_demo2 as SELECT * FROM buckets b JOIN demo d ON b.PANID = d.Panelist_ID LEFT JOIN temp3 t ON t.PANID = b.PANID; quit;

PROC SQL; select COUNT(*) from bucket_demo2 ;quit;

PROC PRINT DATA = bucket_demo (obs=2); run;

PROC EXPORT data=bucket_demo2 outfile = 'h:\project\bucket_demo_final.csv'
dbms = csv
replace;
run;

PROC EXPORT data=buckets outfile = 'h:\project\data5.csv'
dbms = csv
replace;
run;
