#property version   "1.00"
#property strict

#property show_inputs
#define ABOVE_MA 1
#define BELOW_MA 2

input int MAPeriod = 200;
input int CandlesToCheck = 20000; // Nr. of candles in the past to check

// Globals
// MA
string fileNameExport = "";

struct MAdata {
   int maxDiff; // diff of ma and current price in points
   int candleMaxDiff; // index
   int candleStart; // index
   int candleStop; // index
   int direction;
};

int size = 0; // size of MA crosses entries
MAdata array[20000]; // MA crosses entries

void drawMessage(string message) {
   MessageBox(message, StringConcatenate("Instrument: ", Symbol(), " || Timeframe: ", Period(), " (minutes) ", "|| ", CandlesToCheck, " candles details"), 0);
}

// MA -------------------------------------------------------------------------------------------------------------------

double getMA(int movingPeriod, int shift) {
    return NormalizeDouble(iMA(NULL, 0, movingPeriod, 0, MODE_EMA, PRICE_CLOSE, shift), Digits);
}

string getMAinfo() {
   if (Bars < 10) return "Chart has less than 10 bars";
   if (CandlesToCheck > Bars) return "There are more candles to check than candles that exist in the chart";

   double ma = getMA(MAPeriod, CandlesToCheck);
   int direction = Close[CandlesToCheck - 1] > ma ? ABOVE_MA : BELOW_MA;
   int maxDiffInPoints = (int) (MathAbs(ma - Close[CandlesToCheck - 1]) / Point);
   int maxDiffCandle = CandlesToCheck - 1;
   int maxDiffInPointsAux = 0;

   array[size].candleStart = CandlesToCheck - 1;
   array[size].direction = direction;
   array[size].candleMaxDiff = CandlesToCheck - 1;
   array[size++].maxDiff = maxDiffInPoints;

   int i;
   for (i = CandlesToCheck - 1; i >= 2; i--) {
      ma = getMA(MAPeriod, i);

      // reset direction
      if (Close[i] <= ma && direction == ABOVE_MA) {
         direction = BELOW_MA;
         
         array[size-1].candleStop = i+1;
         array[size].candleStart = i;
         array[size-1].candleMaxDiff = maxDiffCandle;
         array[size-1].maxDiff = maxDiffInPoints;
         array[size++].direction = direction;

         maxDiffCandle = i;
         maxDiffInPoints = 0;
      } else if (Close[i] > ma && direction == BELOW_MA) {
         direction = ABOVE_MA;
         
         array[size-1].candleStop = i+1;
         array[size].candleStart = i;
         array[size-1].candleMaxDiff = maxDiffCandle;
         array[size-1].maxDiff = maxDiffInPoints;
         array[size++].direction = direction;
     
         maxDiffCandle = i;
         maxDiffInPoints = 0;
      } else if ((Close[i] <= ma && direction == BELOW_MA) || (Close[i] > ma && direction == ABOVE_MA)) {
         maxDiffInPointsAux = (int) (MathAbs(ma - Close[i]) / Point);
         if (maxDiffInPoints < maxDiffInPointsAux) {
            maxDiffCandle = i;
            maxDiffInPoints = maxDiffInPointsAux;
         }
      }
   }
  
   return "ok";
}

// Export --------------------------------------------------------------------------------------------------------------

void exportToFile() {
   if (FileIsExist(fileNameExport)) {
     FileDelete(fileNameExport);
   }
    
   string maMessage = StringConcatenate(
      "Time start,", // time when the MA crossed in "Direction"
      "Time stop,", // time when the MA changed "Direction"
      "Number,", // Number of order
      "Max diff on side,", // max diff on "Direction" side of current price and ma in points
      "Duration before max diff,", // duration in candles before max diff occurred
      "Duration after max diff,", // duration in candles after max diff occurred
      "Points gain after max diff,", // points gain after max diff calculated at direction change
      "Duration in candles,", // duration of MA in candles on side "Direction"
      "Direction," // can be "Above" or "Below" referring to where the current bar/candle close is to MA
   );
   exportLogs(maMessage);
   
   for (int j = 1; j < size - 1; j++) {
      string dirConv = "";
      if (array[j].direction == 1) dirConv = "Above";
      else if (array[j].direction == 2) dirConv = "Below";
      
      double maCloseAfterMax = getMA(MAPeriod, array[j].candleStop);
      int pointsAfter = (int) (MathAbs(maCloseAfterMax - Close[array[j].candleMaxDiff]) / Point);

      maMessage = StringConcatenate(
         Time[array[j].candleStart], ",",
         Time[array[j].candleStop], ",",
         j, ",",
         array[j].maxDiff, ",",
         array[j].candleStart - array[j].candleMaxDiff + 1, ",",
         array[j].candleMaxDiff - array[j].candleStop - 1, ",",
         pointsAfter, ",",
         array[j].candleStart - array[j].candleStop + 1, ",",
         dirConv, ","
      );
      
      exportLogs(maMessage);
   }
   
   drawMessage("MA data generated at " + TerminalInfoString(TERMINAL_DATA_PATH) + "\\MQL4\\Files\\" + fileNameExport);   
}

// -------------------------------------------------------------------------------------------------------------------

void exportLogs(string logText) {
    int fileHandle = FileOpen(fileNameExport, FILE_READ|FILE_WRITE|FILE_TXT|FILE_SHARE_READ, ";");

    if (fileHandle != INVALID_HANDLE) {
        FileSeek(fileHandle, 0, SEEK_END);
        FileWriteString(fileHandle, logText + "\r\n");
        FileClose(fileHandle);
    }
    else {
        Print("Failed to open the log file!");
    }
}

void OnStart() {
   fileNameExport = StringConcatenate(CandlesToCheck, "_", Symbol(), "_", Period(), "_", "instrument-analysis.csv");
   string result = getMAinfo();
 
   if (result == "ok") {
      exportToFile();
   } else {
      drawMessage(result);
   }
}
//+------------------------------------------------------------------+
