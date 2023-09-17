#property strict
#property indicator_chart_window

input int Days = 1; // Nr of days since last close to do the difference as % change
input string SymbolString = "US500"; // Symbols string; use max 10 symbols separated by ","

string sep = ",";
string symbols[];

double calculatePriceChange(string symbol, int days)
{
    double priceChange = -1;

    double currentPrice = SymbolInfoDouble(symbol, SYMBOL_BID);
    double previousPrice = iClose(symbol, PERIOD_D1, days);

    if (previousPrice != -1)
    {
        priceChange = ((currentPrice - previousPrice) / previousPrice) * 100.0;
    }

    return priceChange;
}

int OnInit()
{
    StringSplit(Symbol() + "," + SymbolString, StringGetCharacter(sep, 0), symbols);

    if (ArraySize(symbols) > 10) return INIT_FAILED;

    return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
    Comment("");
}

int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[], const long &tick_volume[], const long &volume[], const int &spread[])
{
    string pricesInfo = "";
    for (int i = 0; i < ArraySize(symbols); i++) {
      double priceChange = calculatePriceChange(symbols[i], Days);
      string priceChangeShown = DoubleToString(priceChange, 2) + "%";
      if (priceChange == -1) priceChangeShown = "No data";
      
      pricesInfo += symbols[i] + ": " + priceChangeShown + "  ";
    }

    Comment(pricesInfo + " (last " + IntegerToString(Days) + " day(s) change)");
    return rates_total;
}
