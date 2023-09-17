#property strict
#property indicator_chart_window

extern double RiskPercentage = 1.0; // Risk percentage of account balance

double refPrice;
int mode = 0; // 0 -> bid/ask for current order, 1 -> ref price for pending order 
ulong clickMicroSec = 0;
ulong clickMicroSecMax = 200000;
string refLineName = "Ref price";

double calculateLotSize(int stopLossPoints)
{
    double tickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
    if (stopLossPoints == 0 || tickValue == 0) return 0;
    double accountBalance = AccountBalance();
    double accountRisk = accountBalance * RiskPercentage / 100.0;
    double lotSize = NormalizeDouble(accountRisk / (stopLossPoints * tickValue), 2);
    return lotSize;
}



int OnInit()
{
    ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);
    return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
    Comment(""); // Remove comment with indicator details
    ObjectDelete(refLineName);
}

int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[], const long &tick_volume[], const long &volume[], const int &spread[])
{
    return rates_total;
}

void OnChartEvent(const int id,         // Event identifier   
                  const long& lparam,   // Event parameter of long type 
                  const double& dparam, // Event parameter of double type 
                  const string& sparam) // Event parameter of string type 
{ 
   datetime time;
   double price;
   int subwindow;
   int pointsDiff = 0;
   double lotSize;
   int x = (int)lparam;
   int y = (int)dparam;
   ChartXYToTimePrice(0, x, y, subwindow, time, price);

   if (id == CHARTEVENT_CLICK && mode == 0) {
      if (GetMicrosecondCount() - clickMicroSec < clickMicroSecMax) {
         clickMicroSec = 0;
         mode = 1;
         refPrice = price;
         ObjectCreate(refLineName, OBJ_HLINE, 0, Time[0], refPrice, 0, 0);
      } else {
         clickMicroSec = GetMicrosecondCount();
      }
   } else if (id == CHARTEVENT_CLICK && mode == 1) {
      ObjectDelete(refLineName);
      mode = 0;
   }
 
   switch(mode) {
      case 1:
          pointsDiff = MathAbs(refPrice - price) / Point;
         lotSize = calculateLotSize(pointsDiff);
         if (price > refPrice) {
            Comment("Sell SL points diff: ", pointsDiff, " Lot size: ", DoubleToString(lotSize, 2));
         } else if (price < refPrice) {
            Comment("Buy SL points diff: ", pointsDiff, " Lot size: ", DoubleToString(lotSize, 2));
         }
         break;
      default:
         if (price > Bid) { // then it's a sell
            pointsDiff = MathAbs(Bid - price) / Point;
            lotSize = calculateLotSize(pointsDiff);
            Comment("Sell SL points diff: ", pointsDiff, " Lot size: ", DoubleToString(lotSize, 2));
         } else if (price < Ask) { // then it's a buy
            pointsDiff = MathAbs(Ask - price) / Point;
            lotSize = calculateLotSize(pointsDiff);
            Comment("Buy SL points diff: ", pointsDiff, " Lot size: ", DoubleToString(lotSize, 2));
         }
         break;
   }
}