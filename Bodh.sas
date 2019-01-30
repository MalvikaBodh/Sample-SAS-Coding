/*QUESTION NO. 1*/

/*readind data from .dat file into SAS data set*/
DATA cars; 
INFILE 'H:\Predictive SAS\93cars.dat';
INPUT Manufacturer $ 1-14 Model $ 15-29 Type $ 30-36  Minimum_Price 38-41 Midrange_Price 43-46 Maximum Price 48-51 City_MPG 53-54 Highway_MPG 56-57 
Air_Bags 59 Drive_Train 61 Cylinders 63 Engine_Liters 65-67 Horsepower 69-71 
RPMinute 73-76 
#2  
RPMile 1-4 Manual_Transmission 6 Fuel_Capacity 8-11 Passengers 13 
Length 15-17 Wheelbase 19-21 Width 23-24 U_turn 26-27 Rear_Seat 29-32 
Luggage_Capacity 34-35 Weight 37-40 Domestic 42; 
RUN;
/*Viewing the data tabel*/
PROC PRINT DATA= CARS;
/*Verifying missing values in the dataset and comparing with special notes*/
PROC MEANS DATA= CARS NMISS N; RUN;
/* a) Correlation between horsepower and midrange price*/
PROC CORR;
VAR Horsepower Midrange_Price;
RUN;
/*Run Regression between midrange price and other variables using adjrsq as the selection criteria*/
PROC reg data=cars outest=est;
model Midrange_Price = Horsepower Manual_Transmission City_MPG Air_Bags Domestic / selection=adjrsq ;
RUN; QUIT; 
PROC reg data=cars;
model Midrange_Price = Horsepower Manual_Transmission City_MPG Air_Bags Domestic;
RUN;
/*Printing the standardized betas to compare the importance of variables in describing price */
PROC REG data=cars;
MODEL Midrange_Price =Horsepower Manual_Transmission City_MPG Air_Bags Domestic / STB;
RUN;
/*Viewing the scatterplots of different variables with Midrange_Price */
proc corr data=cars plots=matrix(histogram);
var Midrange_Price Horsepower Manual_Transmission City_MPG Air_Bags Domestic;
run;
/*running individual regression to check the models and residuals*/
PROC reg data=cars;
model Midrange_Price = City_MPG;run;
PROC reg data=cars;
model Midrange_Price=horsepower;run;
/*Runnning polynomial regression with horsepower and hpsq and hpqb*/
DATA A2; SET cars;hpsq =(Horsepower)*(Horsepower);mpgsq=City_MPG*City_MPG;lnhp=log(Horsepower); lnp= log(Midrange_Price);hpqb =(Horsepower)*(Horsepower)*(Horsepower);run;
PROC REG;
MODEL Midrange_Price=Horsepower hpsq hpqb Manual_Transmission City_MPG Air_Bags Domestic ;run;
/*Regressing with other variables */
PROC reg data=A2 outest=est;
	model lnp = City_MPG Highway_MPG Air_Bags Drive_Train Cylinders Engine_Liters Horsepower RPMinute RPMile Manual_Transmission Fuel_Capacity Passengers Length Wheelbase Width U_turn Rear_Seat Luggage_Capacity Weight Domestic  /selection=adjrsq ;
RUN;
/*Optimum model according to the adjusted R-squared*/
PROC reg data=A2 outest=est;
model lnp = City_MPG Passengers hpsq hpqb mpgsq Air_Bags Cylinders Horsepower Fuel_Capacity Wheelbase Width Weight Domestic /selection=adjrsq;
RUN;
/*Final Model Selected*/
PROC reg data=A2 outest=est;
model lnp = City_MPG Passengers mpgsq Air_Bags Horsepower Wheelbase Width Domestic /selection=adjrsq;
run;
/*FINAL MODEL*/
PROC reg data=A2 outest=est;
Model lnp = City_MPG  mpgsq Air_Bags Horsepower Wheelbase Width Domestic;Run;



/* QUESTION NO. 2 */
/*Reading the data daimonddata.dat in SAS*/
DATA diamond; 
INFILE 'H:\Predictive SAS\diamonddata.dat' firstobs=2;
INPUT cut $ color $ clarity $ carat  price; run;
PROC PRINT DATA=diamond;
/*t-test for testing difference in prices between Color D and E*/
PROC ttest; var price;class color;run;
Data diamond1;
set diamond;
if cut = "Fair" then cut_fair = 1;else cut_fair=0;
if cut = "Good" then cut_good = 1;else cut_good=0;
if cut = "VeryGood" then cut_verygood = 1;else cut_verygood=0;
if cut = "Ideal" then cut_ideal = 1;else cut_ideal=0;
if color = "E" then color_E=1;else color_E=0;
if color = "D" then color_D=1;else color_D=0;
if clarity = "VS2" then clarity_VS2=1;else clarity_VS2=0;
if clarity = "VS1" then clarity_VS1=1;else clarity_VS1=0;
if clarity = "VVS2" then clarity_VVS2=1;else clarity_VVS2=0;
if clarity = "VVS1" then clarity_VVS1=1;else clarity_VVS1=0;
Run;
Proc print data= diamond1;run;
/*Running regression between price and other variables*/
Proc reg data=diamond1;
model price = cut_fair cut_good cut_verygood cut_ideal color_E color_D clarity_VS2 clarity_VS1 clarity_VVS2 clarity_VVS1  carat; run;
/*Running regression model again by removing clarity_VS2 and color_E to solve question 2 d)*/
Proc reg data=diamond1;
model price = cut_fair cut_good cut_verygood cut_ideal  color_D  clarity_VS1 clarity_VVS2 clarity_VVS1  carat; run;
/* Using Chi-square test, testing whether there is a relationship between color and clarity */
proc freq data=diamond;
 tables color*clarity / chisq; 
run;
/*ANOVA and then t-test for checking whether the average price is different for different levels of clarity*/
proc anova data=diamond;
Class clarity;
model price = clarity;
means clarity /hovtest welch;
run;
/*There are 4 clarity levels, so we can have 6 t-tests */
proc ttest data=diamond;
         where clarity in ('VS1','VS2');
         class clarity;
         var price;
         run;
proc ttest data=diamond;
         where clarity in ('VS2','VVS1');
         class clarity;
         var price;
         run;
proc ttest data=diamond;
         where clarity in ('VVS1','VVS2');
         class clarity;
         var price;
         run;
proc ttest data=diamond;
         where clarity in ('VS1','VVS1');
         class clarity;
         var price;
         run;
proc ttest data=diamond;
         where clarity in ('VS1','VVS2');
         class clarity;
         var price;
        run;
proc ttest data=diamond;
         where clarity in ('VS2','VVS2');
         class clarity;
         var price;
         run;
 

