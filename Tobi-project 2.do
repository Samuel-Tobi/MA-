cd "\\filer3.usask.ca\q\qzv804\My Documents\ECONOMETRICS_II\PROJECT 2\"
import excel "Project2completedata.xlsx", firstrow clear

describe
list in 1/10

rename CommodityPr~n CommodityPrice
rename ExchangeRa~o ExchangeRate
rename USCPICon~x USCPI
rename USSSR US_SSR
rename CanadaSSR Canada_SSR

gen log_exrate = log(ExchangeRate)
gen log_commprice = log(CommodityPrice)
gen IRD = US_SSR - Canada_SSR

list log_exrate log_commprice IRD in 1/5

save "Project2_updated.dta", replace

gen str_refdate = string(REFDATE)   
gen date = monthly(str_refdate, "MY")   

rename date date_old  
gen date = mofd(REFDATE)  
format date %tm  
tsset date  

tsset
describe REFDATE

sum CommodityPrice ExchangeRate USCPI US_SSR Canada_SSR

tsline CommodityPrice, title("Commodity Prices Over Time")
tsline ExchangeRate, title("Canada-US Exchange Rate Over Time")
tsline USCPI, title("US CPI Over Time")
tsline US_SSR, title("US SSR Over Time")
tsline Canada_SSR, title("Canada SSR Over Time")

sum IRD
tsline IRD, title("Interest Rate Differential Over Time") ytitle("IRD (US - Canada)")

dfuller log_exrate, lags(4) trend
dfuller log_commprice, lags(4) trend
dfuller IRD, lags(4) trend

gen d_log_exrate = D.log_exrate
gen d_log_commprice = D.log_commprice
gen d_IRD = D.IRD

dfuller d_log_exrate, lags(4) trend
dfuller d_log_commprice, lags(4) trend
dfuller d_IRD, lags(4) trend

vecrank log_exrate log_commprice IRD, lag(4) trend(constant)

varsoc d_log_exrate d_log_commprice d_IRD, maxlag(6)

var d_log_exrate d_log_commprice d_IRD, lags(1)

irf create my_irf, step(12) set(my_irf_results, replace)
irf graph oirf, impulse(d_log_exrate d_log_commprice d_IRD) response(d_log_exrate d_log_commprice d_IRD)

var d_log_exrate d_log_commprice d_IRD, lags(1)
vargranger





