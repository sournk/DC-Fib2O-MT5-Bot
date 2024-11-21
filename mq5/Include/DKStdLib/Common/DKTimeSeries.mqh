//+------------------------------------------------------------------+
//|                                                 DKTimeSeries.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+
#property copyright "Denis Kislitsyn"
#property link      "https://kislitsyn.me"
#property version   "0.0.1"

//+------------------------------------------------------------------+
//| Modifies stdlib iBarShfit to find closest bar in the right dir
//| unlike to the standard function, which searches for the closest 
//| one to the left if the parameter excat=false
//+------------------------------------------------------------------+
int iBarShiftRight(const string _symbol, const ENUM_TIMEFRAMES _timeframe, const datetime _dt) {
  // Exact bar found
  int bar = iBarShift(_symbol, _timeframe, _dt, true);
  if (bar >= 0) return bar;
  
  // Try to find closest bar to _dt
  bar = iBarShift(_symbol, _timeframe, _dt, false);
  if (bar < 0) return bar; 
  
  datetime bar_dt = iTime(_symbol, _timeframe, bar);
  // Go to right to find 1st bar with bar_dt>=_dt
  while (bar_dt < _dt && bar > 0){
    bar--;
    bar_dt = iTime(_symbol, _timeframe, bar);
  }
  
  return (bar_dt >= _dt) ? bar : -1;  
}