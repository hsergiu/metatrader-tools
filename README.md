**Simple MA Deviation** is an expert advisor that opens transactions based on the difference in number of points of the current price and the moving average. If the current price is at X number of points above moving average, EA opens a sell, otherwise if it is at X points below moving average, EA opens a buy. This deviation can be invalidated based on a number of candles (to filter deviation based on how fast it happened). Order is closed when price reaches the moving average once again. EA opens only 1 order at a time.

**Parameters:**
 *- Lot* (size of the position which will be opened) 
 *- NrCandlesMA* (candles with price close above or below moving average, depending where the price is now; put -1 to ignore this parameter)
 *- MAShift* (shift parameter for moving average)
 *- MAPeriod* (period of the moving average)
 *- DeviationPoints* (number of points below or above moving average at which the price is now and which triggers the order open, along with NrCandlesMA if it is the case)
 
 **Results:** On forex pairs, this EA can have favorable results on lower timeframes considering there are multiple spikes below/above moving averages in these cases.
 This can be used with other automated scripts if your transaction target number is low in, let's say, a year. To find best setups, run an optimization test using mt4 strategy tester and considering the parameter interval for each timeframe (Ex: DeviationPoints input for USDCHF M1 - Start 200, Step 10, Stop 400).

**Other improvements:** 
 *- Stop level > 0* case can be handled on TP,SL set
 *- Order open retry* can be added for multiple broker errors