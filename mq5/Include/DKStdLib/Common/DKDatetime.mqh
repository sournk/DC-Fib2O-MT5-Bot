//+------------------------------------------------------------------+
//|                                                   DKDatetime.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+
#property copyright "Denis Kislitsyn"
#property link      "https://kislitsyn.me"
#property version   "0.0.1"


enum ENUM_DATETIME_PART {
  DATETIME_PART_YEAR    = 1*60*60*24*366,
  DATETIME_PART_QUARTER = 1*60*60*24*(31+30+31),
  DATETIME_PART_MON     = 1*60*60*24*31,
  DATETIME_PART_WEEK    = 1*60*60*24*7,
  DATETIME_PART_DAY     = 1*60*60*24,
  DATETIME_PART_HOUR    = 1*60*60,
  DATETIME_PART_MIN     = 1*60,
  DATETIME_PART_SEC     = 1,
};

//+------------------------------------------------------------------+
//| Returns begining of datetime part, i.g:
//|   - Begining of the month: TimeBegining(D'2023-12-22 10:10:10', DATETIME_PART_MON) == D'2023-12-01 00:00:00'
//|   - Begining of the day:   TimeBegining(D'2023-12-22 10:10:10', DATETIME_PART_DAY) == D'2023-12-22 00:00:00'
//+------------------------------------------------------------------+
datetime TimeBeginning(datetime _dt, ENUM_DATETIME_PART _dt_part) {
  MqlDateTime dt_struc;
  TimeToStruct(_dt, dt_struc);
  
  // Proccessing datetime
  if (_dt_part == DATETIME_PART_WEEK) {
    int day_of_week_ru = (dt_struc.day_of_week > 0) ? dt_struc.day_of_week : 7;
    _dt = _dt - (day_of_week_ru-1) * ((int)DATETIME_PART_DAY);
    TimeToStruct(_dt, dt_struc);
    _dt_part = DATETIME_PART_DAY;
  }
  
  if (_dt_part >= DATETIME_PART_YEAR)    dt_struc.mon  = 1;
  if (_dt_part >= DATETIME_PART_QUARTER) dt_struc.mon  = ((int)((dt_struc.mon-1)/3))*3+1;
  if (_dt_part >= DATETIME_PART_MON)     dt_struc.day  = 1;
  if (_dt_part >= DATETIME_PART_WEEK)    dt_struc.day  = 1;
  if (_dt_part >= DATETIME_PART_DAY)     dt_struc.hour = 0;
  if (_dt_part >= DATETIME_PART_HOUR)    dt_struc.min  = 0;
  if (_dt_part >= DATETIME_PART_MIN)     dt_struc.sec  = 0;
  
  return StructToTime(dt_struc);
}

//+------------------------------------------------------------------+
//| Returns end of datetime part, i.g:
//|   - End of the month: TimeBegining(D'2023-12-22 10:10', DATETIME_PART_MON) == D'2023-12-31 23:59:59'
//|   - End of the day:   TimeBegining(D'2023-12-22 10:10', DATETIME_PART_DAY) == D'2023-12-22 23:59:59'
//+------------------------------------------------------------------+
datetime TimeEnd(datetime _dt, const ENUM_DATETIME_PART _dt_part) {
  _dt = _dt + (int)_dt_part;
  return TimeBeginning(_dt, _dt_part)-1;
}

//+------------------------------------------------------------------+
//| Return time duration in HH:MM:SS format
//+------------------------------------------------------------------+
string TimeDurationToString(datetime _dt) {
  int seconds = (int)_dt;
  int days = seconds / 86400;
  int hours = (seconds % 86400) / 3600;
  int minutes = (seconds % 3600) / 60;
  int sec = seconds % 60;

  string strDays = IntegerToString(days);
  string strHours = IntegerToString(hours, 2, '0');
  string strMinutes = IntegerToString(minutes, 2, '0');
  string strSeconds = IntegerToString(sec, 2, '0');

  if (days > 0) {
      return strDays + "d " + strHours + ":" + strMinutes + ":" + strSeconds;
  } else if (hours > 0) {
      return strHours + ":" + strMinutes + ":" + strSeconds;
  } else if (minutes > 0) {
      return strMinutes + ":" + strSeconds;
  } else {
      return strSeconds;
  }
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| DTS
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
ENUM_DAY_OF_WEEK TimeDayOfWeek( const datetime time )  {
  int WEEK2 = 7;
  int HOUR = 3600;
  int DAY = (24 * HOUR);
  return((ENUM_DAY_OF_WEEK)((time / DAY + THURSDAY) % WEEK2));
}
  
datetime FirstDayWeekMonth( const int Year, const int Month, const int Count = 1, const ENUM_DAY_OF_WEEK DayWeek = SUNDAY ){
  int WEEK2 = 7;
  int HOUR = 3600;
  int DAY = (24 * HOUR);
  const datetime time2 = (datetime)((string)Year + "-" + (string)Month + "-01");
  return(time2 + ((WEEK2 + DayWeek - TimeDayOfWeek(time2)) % WEEK2) * DAY + (Count - 1) * WEEK2 * DAY);
}

datetime LastDayWeekMonth( const int Year, const int Month, const ENUM_DAY_OF_WEEK DayWeek = SUNDAY ){
  int WEEK2 = 7;
  int HOUR = 3600;
  int DAY = (24 * HOUR);;
  const datetime time2 = (datetime)((string)(Year + (Month == 12)) + "-" + (string)((Month + 1) % 12) + "-01") - DAY;
  return(time2 - ((WEEK2 + TimeDayOfWeek(time2) - DayWeek) % WEEK2) * DAY);
}
  
//+------------------------------------------------------------------+
//| Checks _dt has DST extra shift
//| by Eupropian rules:
//|   Summer DST starts last SUN of March and finishes last SUN of October
//+------------------------------------------------------------------+
bool TimeHasDST(const datetime _dt) {
  MqlDateTime dt_mql;
  TimeToStruct(_dt, dt_mql);
  
  datetime start_dst  = LastDayWeekMonth(dt_mql.year, 3)  + 24*60*60;
  datetime finish_dst = LastDayWeekMonth(dt_mql.year, 10) + 24*60*60;
  
  return (_dt >= start_dst && _dt < finish_dst); 
}