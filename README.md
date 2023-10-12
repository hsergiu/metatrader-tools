## Table of contents
- [Indicators](#indicators)
- [Scripts](#scripts)
- [Expert advisors](#expert-advisors)

## Indicators
`CrosshairRiskPercentage` can be useful for calculating the lot size by moving your crosshair to where the Stop Loss will be for a sell/buy corresponding to the percentage of the account balance you want to risk. If you want to do this for a pending order, then double click the chart and a new line is created at the ref price and based on this price, you will get the lot. Click again to undo the line.

`Inputs:`

*- Risk percentage of account balance*

`PercentageDiff` is another indicator which shows the price % change in a number of days of the current asset + a list you define in the input. This will also be displayed as a comment in the top left of your chart.

`Inputs:`

*- Nr of days since last close to do the difference as % change*
*- Symbols string*

## Scripts
`InstrumentMAAnalysis` is a script that calculates a few parameters based on which side the close of the index bar (Close[i]) is to the MA. If the current set of candles is under/above the MA, max deviation/difference in points from the MA and the nr of candles till a change in direction are calculated. And other parameters based on this two. A csv is generated based on your inputs. Note that you might need to have a few bars in the current chart before you run it.

The csv generated has the following columns:

      "Time start,", // time when the MA crossed in "Direction"
      "Time stop,", // time when the MA changed "Direction"
      "Number,", // Number of order
      "Max diff on side,", // max diff on "Direction" side of current price and ma in points
      "Duration before max diff,", // duration in candles before max diff occurred
      "Duration after max diff,", // duration in candles after max diff occurred
      "Points gain after max diff,", // points gain after max diff calculated at direction change
      "Duration in candles,", // duration of MA in candles on side "Direction"
      "Direction," // can be "Above" or "Below" referring to where the current bar/candle close is to MA

`Inputs:`

*- MA period*

*- Nr of candles in the past to check*

## Expert advisors

`Simple MA Deviation` is an expert advisor that opens transactions based on the difference in number of points of the current price and the moving average. If the current price is at X number of points above moving average, EA opens a sell, otherwise if it is at X points below moving average, EA opens a buy. This deviation can be invalidated based on a number of candles (to filter deviation based on how fast it happened). Order is closed when price reaches the moving average once again. EA opens only 1 order at a time.

`Inputs:`

 *- Lot* (size of the position which will be opened) 
 
 *- NrCandlesMA* (candles with price close above or below moving average, depending where the price is now; put -1 to ignore this parameter)
 
 *- MAShift* (shift parameter for moving average)
 
 *- MAPeriod* (period of the moving average)
 
 *- DeviationPoints* (number of points below or above moving average at which the price is now and which triggers the order open, along with NrCandlesMA if it is the case)
 
`Results:` On forex pairs, this EA can have favorable results on lower timeframes considering there are multiple spikes below/above moving averages in these cases. 

`Other improvements:` 

 *- Stop level > 0* case can be handled on TP,SL set
 
 *- Order open retry* can be added for multiple broker errors
