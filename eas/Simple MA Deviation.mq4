#define MAGIC  20131111

input double Lot = 0.1;

input int NrCandlesMA = -1;
input int MAShift = 0;
input int MAPeriod = 200;
input int DeviationPoints = 5000;

// Globals
int tradesOpen = 0;

int indicator = -1;

double currentPrice = -1;

// Utils ==========================================

int getLastOrderNumber(int magic) {
    datetime lastTime  = 0;
    int      lastTicket = -1;

    for(int pos = OrdersTotal()-1; pos >= 0 ; pos--) if (
        OrderSelect(pos, SELECT_BY_POS)                 
    &&  OrderMagicNumber()  == magic            
    &&  OrderSymbol()       == Symbol()                 
    &&  OrderOpenTime()     >  lastTime
    ){
      lastTime   = OrderOpenTime();
      lastTicket = OrderTicket();
    }
    return lastTicket;
}

void OrderSendAux(int opType, double lotSize, double sl, double tp, int magic, color orderColor) {
   double slAux = NormalizeDouble(sl > 0 ? sl : 0, Digits);
   double tpAux = NormalizeDouble(tp > 0 ? tp : 0, Digits);
   double price = opType == OP_SELL ? Bid : Ask;
   
   int res = OrderSend(Symbol(), opType, lotSize, price, 3, slAux, tpAux, "", magic, 0, orderColor);
   if (res == -1) {
      Print("OrderSend Type:", opType, " SL:", slAux, " TP:", tpAux, " Price:", price, " Error:", GetLastError());
   }
}

void OrderCloseAux(int ticketNumber, color orderColor) {
   bool orderSelected = OrderSelect (ticketNumber, SELECT_BY_TICKET);
   if (!orderSelected) return;

   double price = OrderType() == OP_SELL ? Ask : Bid;
   bool res = OrderClose(ticketNumber, OrderLots(), price, 3, orderColor);
   if (!res) {
      Print("OrderClose Error:", GetLastError());
   }
}

int calculateCurrentOrders(int magic)
  {
   int nro=0;

   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic)
        {
         if(OrderType()==OP_BUY || OrderType()==OP_SELL)  nro++;
        }
     }

   return nro;
  }

double calculatePointsDiffAbs(double price1, double price2)
{
    double pipSize = MarketInfo(Symbol(), MODE_POINT);
    return MathAbs(price1 - price2) / pipSize;
}

double getCurrentPrice() {
   if (indicator == OP_BUY) return Ask;
   if (indicator == OP_SELL) return Bid;
   return -1;
}

// MA stats ==================================================

int getCandlesMA(double ma) {
   int nrCandles = -1;
   if (ma > Close[1]) {
      nrCandles = 1;
      for (int i = 2; i <= Bars; i++) {
         if (ma > Close[i]) nrCandles++;
         else break;
      }
   } else if (ma < Close[1]) {
      nrCandles = 1;
      for (i = 2; i <= Bars; i++) {
         if (ma < Close[i]) nrCandles++;
         else break;
      }
   }
   
   return nrCandles;
}

void checkForTrade() {
   if(tradesOpen > 0) return;
   if(Volume[0] > 1) return;
   
   double ma = iMA(NULL,0,MAPeriod,MAShift,MODE_EMA,PRICE_CLOSE,0);
   double devPoints = calculatePointsDiffAbs(ma, Close[1]);

   if (getCandlesMA(ma) > NrCandlesMA && NrCandlesMA != -1) return; 
   if (devPoints > DeviationPoints && Close[1] < ma) indicator = OP_BUY;
   else if (devPoints > DeviationPoints && Close[1] > ma) indicator = OP_SELL;
   else return;

   OrderSendAux(indicator, Lot,
      0,
      0,
      MAGIC, Orange);
}

void checkForTradeClosure() {
   if (tradesOpen == 0) return;
   
   double ma = iMA(NULL,0,MAPeriod,MAShift,MODE_EMA,PRICE_CLOSE,0);
   double price = getCurrentPrice();
   
   if ((indicator == OP_BUY && price > ma) ||
      (indicator == OP_SELL && price < ma)) {
      int orderTicket = getLastOrderNumber(MAGIC);
      OrderCloseAux(orderTicket, Purple);
   }
}

double OnTester() {
   return 0;
}

int OnInit() {
   return INIT_SUCCEEDED;
}

void OnTick()
  {
   if(Bars<100 || IsTradeAllowed()==false)
      return;

    tradesOpen = calculateCurrentOrders(MAGIC);

    checkForTrade();
    checkForTradeClosure();
  }
