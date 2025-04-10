import excel "\\filer3.usask.ca\q\qzv804\My Documents\Project_1_data.xlsb.xlsx", sheet("Sheet1") firstrow clear
list in 1/10
rename Commod~x commodity_price
rename Exchang~e exchange_rate

describe

gen date_corrected = mofd(Date)
format date_corrected %tmMonCCYY

describe date_corrected

list date_corrected
order date_corrected commodity_price exchange_rate

tsset date_corrected, monthly

tsline commodity_price, title("Commodity Price Index Over Time") ytitle("Commodity Price Index") xtitle("Year")

tsline exchange_rate, title("Exchange Rate (CAD/USD) Over Time") ytitle("Exchange Rate") xtitle("Year")

twoway (line commodity_price date, yaxis(1) lcolor(blue)) ///
       (line exchange_rate date, yaxis(2) lcolor(red)), ///
       title("Commodity Prices vs Exchange Rate") ///
       ytitle("Commodity Price Index", axis(1)) ///
       ytitle("Exchange Rate (CAD/USD)", axis(2)) ///
       legend(order(1 "Commodity Prices" 2 "Exchange Rate")) ///
       xlabel(, angle(45))

	   
// the ADF test
dfuller commodity_price, lags(4)

//difference the commodity price index to make it stationary
gen d_commodity_price = d.commodity_price
dfuller d_commodity_price, lags(4)


dfuller exchange_rate, lags(4)

// first difference of the exchange rate
gen d_exchange_rate = d.exchange_rate
dfuller d_exchange_rate, lags(4)

//Johansen Cointegration Test
vecrank commodity_price exchange_rate, lags(4) trace
vecrank commodity_price exchange_rate, lags(4) max

//Vector Error Correction Model (VECM)
vec commodity_price exchange_rate, lags(4) rank(1)

//Impulse Response Functions
//  Create IRF for 10 periods
irf create vec_irf, step(10) set(myirf) replace

// Generate IRF Graphs
irf graph irf, impulse(commodity_price) response(exchange_rate) ///
              title("IRF: Commodity Price Shock to Exchange Rate") yline(0)

// Another IRF Graph (Reverse Direction)
irf graph irf, impulse(exchange_rate) response(commodity_price) ///
              title("IRF: Exchange Rate Shock to Commodity Price") yline(0)

// Generate Confidence Intervals
irf graph irf, impulse(commodity_price exchange_rate) ///
              response(commodity_price exchange_rate) level(95) ///
              title("Impulse Response Functions with 95% CI")
		  




