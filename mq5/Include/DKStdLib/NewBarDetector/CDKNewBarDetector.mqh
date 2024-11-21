//+------------------------------------------------------------------+
//|                                             CDKNewBarDetector.mqh |
//|                                                  Denis Kislitsyn |
//|                                               http:/kislitsyn.me |
//|
//| v1.01 2024-09-19
//|   [+] Optimized mode for new bar check only once in minimal TF
//+------------------------------------------------------------------+
#property copyright "Denis Kislitsyn"
#property link      "http:/kislitsyn.me"
#property version   "1.01"

#include <Generic\HashMap.mqh>
#include <Arrays\ArrayInt.mqh>


class CDKNewBarDetector {
public: //SETTINGS
  bool                OptimizedCheckEnabled;
  
protected:
  ENUM_TIMEFRAMES     TFMin;
  datetime            NextGlobalCheckDT;
  string              MonitoredSymbol;
  CHashMap            <ENUM_TIMEFRAMES, datetime> BarTime;

protected:
  void                CDKNewBarDetector::Init(void);
  
  void                CDKNewBarDetector::UpdateMinTF();
  datetime            CDKNewBarDetector::UpdateNextGlobalCheckDT(void);
  bool                CDKNewBarDetector::IsNextGlobalCheckAllowed();
  
public:
  void                CDKNewBarDetector::CDKNewBarDetector(void);
  void                CDKNewBarDetector::CDKNewBarDetector(string NewSymbolName);
  void                CDKNewBarDetector::CDKNewBarDetector(string NewSymbolName, ENUM_TIMEFRAMES TimeFrame);
  
  void                CDKNewBarDetector::SetSymbol(string NewSymbolName);
  bool                CDKNewBarDetector::AddTimeFrame(ENUM_TIMEFRAMES PeriodToDetect);
  bool                CDKNewBarDetector::AddTimeFrameSkipCurrentBar(ENUM_TIMEFRAMES aPeriodToDetect);
  
  bool                CDKNewBarDetector::RemoveTimeFrame(ENUM_TIMEFRAMES PeriodToDetect);
  void                CDKNewBarDetector::ClearTimeFrames();
  
  int                 CDKNewBarDetector::TimeFramesCount();
  
  bool                CDKNewBarDetector::IsTimeFrameMonitored(ENUM_TIMEFRAMES aPeriodToDetect);
  datetime            CDKNewBarDetector::GetBarDateTime(ENUM_TIMEFRAMES PeriodToDetect);
  
  void                CDKNewBarDetector::ResetLastBarTime(ENUM_TIMEFRAMES PeriodToDetect);
  void                CDKNewBarDetector::ResetAllLastBarTime();
  
  bool                CDKNewBarDetector::CheckNewBarAvaliable(ENUM_TIMEFRAMES PeriodToDetect);
  bool                CDKNewBarDetector::CheckNewBarAvaliable(CArrayInt &Periods);

};

void CDKNewBarDetector::UpdateMinTF() {
  ENUM_TIMEFRAMES Keys[];
  datetime Values[];

  TFMin = PERIOD_MN1;
  BarTime.CopyTo(Keys, Values);
  for(int i=0; i<BarTime.Count(); i++)
    if(Keys[i] < TFMin)
      TFMin = Keys[i];
}

datetime CDKNewBarDetector::UpdateNextGlobalCheckDT(void) {
  NextGlobalCheckDT = TimeCurrent();
  NextGlobalCheckDT += PeriodSeconds(TFMin);
  MqlDateTime dt_mql;
  TimeToStruct(NextGlobalCheckDT, dt_mql);
  dt_mql.sec = 0;
  NextGlobalCheckDT = StructToTime(dt_mql);  
  
  return NextGlobalCheckDT;
}

bool CDKNewBarDetector::IsNextGlobalCheckAllowed() {
  if(!OptimizedCheckEnabled)
    return true;

  datetime dt = TimeCurrent();
  return dt >= NextGlobalCheckDT;
}

void CDKNewBarDetector::Init(void) {
  TFMin = PERIOD_MN1; 
  NextGlobalCheckDT = 0;
}
   
void CDKNewBarDetector::CDKNewBarDetector(void) { 
  OptimizedCheckEnabled = true;
  Init();
}
 
void CDKNewBarDetector::CDKNewBarDetector(string NewSymbolName) {
  OptimizedCheckEnabled = true;
  Init();
  SetSymbol(NewSymbolName);
}

void CDKNewBarDetector::CDKNewBarDetector(string NewSymbolName, ENUM_TIMEFRAMES TimeFrame) {
  OptimizedCheckEnabled = true;
  Init();
  SetSymbol(NewSymbolName);
  AddTimeFrame(TimeFrame);
}

void CDKNewBarDetector::SetSymbol(string NewSymbolName) {
  MonitoredSymbol = NewSymbolName;
}

bool CDKNewBarDetector::AddTimeFrame(ENUM_TIMEFRAMES PeriodToDetect) {
  bool res = BarTime.Add(PeriodToDetect, 0);
  UpdateMinTF();      
  return res;
}

bool CDKNewBarDetector::AddTimeFrameSkipCurrentBar(ENUM_TIMEFRAMES aPeriodToDetect) {
  bool res = BarTime.Add(aPeriodToDetect, iTime(MonitoredSymbol, aPeriodToDetect, 0));
  UpdateMinTF();
  return res;
}

int CDKNewBarDetector::TimeFramesCount() {
  return(BarTime.Count());
}

bool CDKNewBarDetector::RemoveTimeFrame(ENUM_TIMEFRAMES PeriodToDetect) {
  bool res =BarTime.Remove(PeriodToDetect);
  UpdateMinTF();
  return res;
}

void CDKNewBarDetector::ClearTimeFrames() {
  BarTime.Clear();
  UpdateMinTF();
}

// Return true if new bar avaliable on PeriodToDetect timeframe.
bool CDKNewBarDetector::CheckNewBarAvaliable(ENUM_TIMEFRAMES PeriodToDetect) {
  if(!IsNextGlobalCheckAllowed())
    return false;
      
  datetime CurrentBarDateTime, LastBarDateTime;

  if (BarTime.TryGetValue(PeriodToDetect, LastBarDateTime)) {
    CurrentBarDateTime = iTime(MonitoredSymbol, PeriodToDetect, 0);
    if (CurrentBarDateTime > LastBarDateTime) {
      BarTime.Remove(PeriodToDetect);
      BarTime.Add(PeriodToDetect, CurrentBarDateTime);
      UpdateNextGlobalCheckDT();

      return true;
    }
  }

  return false;
}

// Return true if new bar avaliable on any timeframe.
// CArrayInt contains array of ENUM_TIMEFRAMES with new bar.
bool CDKNewBarDetector::CheckNewBarAvaliable(CArrayInt &Periods) {
  if(!IsNextGlobalCheckAllowed())
    return false;
    
  ENUM_TIMEFRAMES Keys[];
  datetime Values[];

  BarTime.CopyTo(Keys, Values);
  for (int i = 0; i < BarTime.Count(); i++)
    if (CheckNewBarAvaliable(Keys[i])) 
      Periods.Add(Keys[i]);

  int update_cnt = Periods.Total();
  if(update_cnt > 0)
    UpdateNextGlobalCheckDT();
    
  return update_cnt > 0;
}

// Checks is timeframes monitored or not?
bool CDKNewBarDetector::IsTimeFrameMonitored(ENUM_TIMEFRAMES aPeriodToDetect) {
  datetime dt;
  if (BarTime.TryGetValue(aPeriodToDetect, dt))
    return true;

  return false;
}

// Return last bar datetime by dataframe
datetime CDKNewBarDetector::GetBarDateTime(ENUM_TIMEFRAMES PeriodToDetect) {
  datetime dt;
  if (BarTime.TryGetValue(PeriodToDetect, dt))
    return dt;

  return 0;
}

void CDKNewBarDetector::ResetLastBarTime(ENUM_TIMEFRAMES PeriodToDetect) {
  datetime dt;
  if (BarTime.TryGetValue(PeriodToDetect, dt)) {
    BarTime.Remove(PeriodToDetect);
    BarTime.Add(PeriodToDetect, 0);
  }
}

void CDKNewBarDetector::ResetAllLastBarTime() {
  ENUM_TIMEFRAMES Keys[];
  datetime Values[];

  BarTime.CopyTo(Keys, Values);
  for (int i = 0; i < BarTime.Count(); i++)
    ResetLastBarTime(Keys[i]);
}
