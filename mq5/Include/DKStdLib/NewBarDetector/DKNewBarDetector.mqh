//+------------------------------------------------------------------+
//|                                             DKNewBarDetector.mqh |
//|                                                  Denis Kislitsyn |
//|                                               http:/kislitsyn.me |
//|
//| 1. New v1.01 class moved to CDKNewBarDetector.mqh file.
//| 2. Old class name DKNewBarDetector kept here just for backwards compatibility
//| 3. New project must use C-version.
//+------------------------------------------------------------------+

#property copyright "Denis Kislitsyn"
#property link      "http:/kislitsyn.me"
#property version   "1.01"

#include "CDKNewBarDetector.mqh"

// Class without C prefix. Just for backwards compatibility
class DKNewBarDetector : public CDKNewBarDetector  {
public:
  void DKNewBarDetector::DKNewBarDetector(void);
  void DKNewBarDetector::DKNewBarDetector(string NewSymbolName);
  void DKNewBarDetector::DKNewBarDetector(string NewSymbolName, ENUM_TIMEFRAMES TimeFrame);
};

void DKNewBarDetector::DKNewBarDetector(void) { 
  OptimizedCheckEnabled = false;
}

void DKNewBarDetector::DKNewBarDetector(string NewSymbolName) {
  Init();
  SetSymbol(NewSymbolName);
  OptimizedCheckEnabled = false;
}

void DKNewBarDetector::DKNewBarDetector(string NewSymbolName, ENUM_TIMEFRAMES TimeFrame) {
  Init();
  SetSymbol(NewSymbolName);
  AddTimeFrame(TimeFrame);
  OptimizedCheckEnabled = false;
}