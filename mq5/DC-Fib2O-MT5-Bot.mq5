//+------------------------------------------------------------------+
//|                                      DS-NewsBreakout-MT5-Bot.mq5 |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

#property script_show_inputs


#include "Include\DKStdLib\Logger\CDKLogger.mqh"
#include "Include\DKStdLib\TradingManager\CDKTrade.mqh"


#include "CFib2OBot.mqh"


input  group                    "1. FIBO (FIB)"
input  ENUM_FIB2OBOT_MODE       Inp_FIB_MD_Mode                                          = FIB2OBOT_MODE_SWING_SWING;        // FIB_MD: Mode

       bool                     Inp_FIB_BOS_BOSEnabled                                   = true;                             // FIB_BOS: Update on BOS Enabled
       bool                     Inp_FIB_CHO_CHOEnabled                                   = true;                             // FIB_CHO: Update on CHoCH Enabled

input  ENUM_TIMEFRAMES          Inp_FIB_TF                                               = PERIOD_H1;                        // FIB_TF: Timeframe to detect BOS/CHoCH and Fibo
       uint                     Inp_FIB_DPT_Depth                                        = 100;                              // FIB_DPT: Depth to find BOS/CHoCH

input  double                   Inp_FIB_STP_EPL_StopEPLevel                              = 0.764;                            // FIB_STP_EPL: STOP order EP Level
input  double                   Inp_FIB_STP_SLL_StopSLLevel                              = 0.236;                            // FIB_STP_SLL: STOP order SL Level

input  double                   Inp_FIB_LIM_EPL_LimitEPLevel                             = 0.764;                            // FIB_LIM_EPL: LIMIT order EP Level
input  double                   Inp_FIB_LIM_SLL_LimitSLLevel                             = 100.0;                            // FIB_LIM_SLL: LIMIT order SL Level

input  color                    Inp_FIB_COL_BUY_Color_Buy                                = clrDarkGreen;                     // FIB_COL_BUY: Color Buy
input  color                    Inp_FIB_COL_SELL_Color_Sell                              = clrCrimson;                       // FIB_COL_SELL: Color Sell


input  group                    "2. ENTRY (ENT)"
       bool                     Inp_ENT_STP_ENB_Stop_Enabled                             = true;                             // ENT_STP_ENB: STOP Order Enabled
input  double                   Inp_ENT_STP_RR_Stop_RR                                   = 1.0;                              // ENT_STP_RR: STOP Order TP RR

       bool                     Inp_ENT_LIM_ENB_Limit_Enabled                            = true;                             // ENT_LIM_ENB: LIMIT Order Enabled
input  double                   Inp_ENT_LIM_RR1_Limit_RR1                                = 5.0;                              // ENT_LIM_RR1: LIMIT Order TP RR
       double                   Inp_ENT_LIM_RR2_Limit_RR2                                = 1.0;                              // ENT_LIM_RR2: LIMIT Order TP RR after STOP order SL
input  bool                     Inp_ENT_ORD_DEL_Order_Delete                             = true;                             // ENT_ORD_DEL: Delete orders when Fibo's updated 

input  ENUM_MM_TYPE             Inp_ENT_MMT_MoneyManagmentType                          = ENUM_MM_TYPE_FIXED_LOT;            // ENT_MMT: Money Management Type
input  double                   Inp_ENT_MMV_MoneyManagmentValue                         = 0.01;                              // ENT_MMV: Money Management Value

input  group                    "5. MISCELLANEOUS (MSC)"
input  ulong                    Inp_MS_MGC                                              = 20241120;                          // MSC_MGC: Expert Adviser ID - Magic
sinput string                   Inp_MS_EGP                                              = "DCFIB";                           // MSC_EGP: Expert Adviser Global Prefix
sinput LogLevel                 Inp_MS_LOG_LL                                           = LogLevel(WARN);                    // MSC_LOG_LL: Log Level
       string                   Inp_MS_LOG_FI                                           = "";                                // MSC_LOG_FI: Log Filter IN String (use ';' as sep)
       string                   Inp_MS_LOG_FO                                           = "";                                // MSC_LOG_FO: Log Filter OUT String (use ';' as sep)
       bool                     Inp_MS_COM_EN                                           = false;                             // MSC_COM_EN: Comment Enable (turn off for fast testing)
       uint                     Inp_MS_COM_IS                                           = 5;                                 // MSC_COM_IS: Comment Interval, Sec
       bool                     Inp_MS_COM_CW                                           = false;                             // MSC_COM_EW: Comment Custom Window
       
       long                     Inp_PublishDate                                         = 20241126;                           // Date of publish
       int                      Inp_DurationBeforeExpireSec                             = 3*24*60*60;                         // Duration before expire, sec
       

CFib2OBot                       bot;
CDKTrade                        trade;
CDKLogger                       logger;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){  
  logger.Init(Inp_MS_EGP, Inp_MS_LOG_LL);
  logger.FilterInFromStringWithSep(Inp_MS_LOG_FI, ";");
  logger.FilterOutFromStringWithSep(Inp_MS_LOG_FO, ";");
  
  //if (TimeCurrent() > StringToTime((string)Inp_PublishDate) + Inp_DurationBeforeExpireSec) {
  //  logger.Critical("Test version is expired", true);
  //  return(INIT_FAILED);
  //}  
  
  trade.Init(Symbol(), Inp_MS_MGC, 0, GetPointer(logger));

  CFib2OBotInputs inputs;
  inputs.FIB_MD_Mode = Inp_FIB_MD_Mode;
  inputs.FIB_BOS_BOSEnabled = Inp_FIB_BOS_BOSEnabled;
  inputs.FIB_CHO_CHOEnabled = Inp_FIB_CHO_CHOEnabled;
  inputs.FIB_TF = Inp_FIB_TF;
  inputs.FIB_DPT_Depth = Inp_FIB_DPT_Depth;
  inputs.FIB_STP_EPL_StopEPLevel = Inp_FIB_STP_EPL_StopEPLevel;
  inputs.FIB_STP_SLL_StopSLLevel = Inp_FIB_STP_SLL_StopSLLevel;
  inputs.FIB_COL_BUY_Color_Buy = Inp_FIB_COL_BUY_Color_Buy;
  inputs.FIB_COL_SELL_Color_Sell = Inp_FIB_COL_SELL_Color_Sell;
  inputs.FIB_LIM_EPL_LimitEPLevel = Inp_FIB_LIM_EPL_LimitEPLevel;
  inputs.FIB_LIM_SLL_LimitSLLevel = Inp_FIB_LIM_SLL_LimitSLLevel;
  inputs.ENT_STP_ENB_Stop_Enabled = Inp_ENT_STP_ENB_Stop_Enabled;
  inputs.ENT_STP_RR_Stop_RR = Inp_ENT_STP_RR_Stop_RR;
  inputs.ENT_LIM_ENB_Limit_Enabled = Inp_ENT_LIM_ENB_Limit_Enabled;
  inputs.ENT_LIM_RR1_Limit_RR1 = Inp_ENT_LIM_RR1_Limit_RR1;
  inputs.ENT_LIM_RR2_Limit_RR2 = Inp_ENT_LIM_RR2_Limit_RR2;
  inputs.ENT_MMT_MoneyManagmentType = Inp_ENT_MMT_MoneyManagmentType;
  inputs.ENT_MMV_MoneyManagmentValue = Inp_ENT_MMV_MoneyManagmentValue;
  inputs.ENT_ORD_DEL_Order_Delete = Inp_ENT_ORD_DEL_Order_Delete;
  
  bot.CommentEnable      = Inp_MS_COM_EN;
  bot.CommentIntervalSec = Inp_MS_COM_IS;
  
  bot.Init(Symbol(), inputs.FIB_TF, Inp_MS_MGC, trade, Inp_MS_COM_CW, inputs, GetPointer(logger));
  bot.SetFont("Courier New");
  bot.SetHighlightSelection(true);

  if (!bot.Check()) 
    return(INIT_PARAMETERS_INCORRECT);

  //EventSetTimer(Inp_MS_COM_IS);
  
  return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)  {
  EventKillTimer();
  bot.OnDeinit(reason);
}
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()  {
  bot.OnTick();
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()  {
  bot.OnTimer();
}

//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()  {
  bot.OnTrade();
}

//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result) {
  bot.OnTradeTransaction(trans, request, result);
}

double OnTester() {
  return bot.OnTester();
}

void OnChartEvent(const int id,
                  const long& lparam,
                  const double& dparam,
                  const string& sparam) {
  bot.OnChartEvent(id, lparam, dparam, sparam);                                    
}