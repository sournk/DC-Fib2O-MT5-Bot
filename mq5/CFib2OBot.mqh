//+------------------------------------------------------------------+
//|                                                    CFib2OBot.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+
#include <Arrays\ArrayString.mqh>
#include <Arrays\ArrayDouble.mqh>
#include <Trade\DealInfo.mqh>
#include <Trade\OrderInfo.mqh>

#include <ChartObjects\ChartObjectsFibo.mqh>

#include "Include\DKStdLib\Common\CDKString.mqh"
#include "Include\DKStdLib\Common\DKDatetime.mqh"
#include "Include\DKStdLib\Arrays\CDKArrayString.mqh"
#include "Include\DKStdLib\Bot\CDKBaseBot.mqh"

#include "CFib2OBotInputs.mqh"


class CFib2OBot : public CDKBaseBot<CFib2OBotInputs> {
public: 

protected:
  
  
  ENUM_DK_POS_TYPE           Dir;
  
  datetime                   StartDate;
  double                     StartPriceFibo1;
  double                     StartPriceFibo2;
  
  int                        FiboDurationSec;
  
  datetime                   FinishDate;
  double                     FinishPrice;  
  
  datetime                   FiboTimeChange;
  datetime                   OrdersTimeChange;
  
  string                     CFib2OBot::GetFiboName(const int _idx);
  void                       CFib2OBot::DrawFibo(const int _idx, 
                                                 const datetime _start_date, const double _start_value,
                                                 const datetime _finish_date, const double _finish_value,
                                                 const double _lev1, const double _lev2,
                                                 const color _clr,
                                                 const string _suffix);
  void                       CFib2OBot::DrawFibo1();
  void                       CFib2OBot::DrawFibo2();                                                 
  bool                       CFib2OBot::UpdateFibo();
  
  ulong                      CFib2OBot::FindPos(ENUM_DK_POS_TYPE _pos_type_to_find);
  ulong                      CFib2OBot::FindPosByComment(const string _comment);
  ulong                      CFib2OBot::FindOrder(ENUM_DK_ORDER_TYPE _order_type_to_find);
  ulong                      CFib2OBot::FindOrderByComment(const string _comment);
  bool                       CFib2OBot::DeleteOrder(ulong _ticket);
  ulong                      CFib2OBot::UpdateStopOrder(ulong _ticket);
  ulong                      CFib2OBot::UpdateLimitOrder(ulong _ticket, double _tp_rr);
  bool                       CFib2OBot::UpdateOrders();
  bool                       CFib2OBot::SetLimitPosTP2();
  bool                       CFib2OBot::DeleteLimitOrderOnStopSL();
public:
  // Constructor & init
  void                       CFib2OBot::CFib2OBot(void);
  void                       CFib2OBot::~CFib2OBot(void);
  void                       CFib2OBot::InitChild();
  bool                       CFib2OBot::Check(void);

  // Event Handlers
  void                       CFib2OBot::OnDeinit(const int reason);
  void                       CFib2OBot::OnTick(void);
  void                       CFib2OBot::OnTrade(void);
  void                       CFib2OBot::OnTimer(void);
  double                     CFib2OBot::OnTester(void);
  void                       CFib2OBot::OnBar(void);
  
  void                       CFib2OBot::OnOrderPlaced(ulong _order);
  void                       CFib2OBot::OnOrderModified(ulong _order);
  void                       CFib2OBot::OnOrderDeleted(ulong _order);
  void                       CFib2OBot::OnOrderExpired(ulong _order);
  void                       CFib2OBot::OnOrderTriggered(ulong _order);

  void                       CFib2OBot::OnPositionOpened(ulong _position, ulong _deal);
  void                       CFib2OBot::OnPositionStopLoss(ulong _position, ulong _deal);
  void                       CFib2OBot::OnPositionTakeProfit(ulong _position, ulong _deal);
  void                       CFib2OBot::OnPositionClosed(ulong _position, ulong _deal);
  void                       CFib2OBot::OnPositionCloseBy(ulong _position, ulong _deal);
  void                       CFib2OBot::OnPositionModified(ulong _position);  
  
  
  
  // Bot's logic
  void                       CFib2OBot::UpdateComment(const bool _ignore_interval = false);
  
};

//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
void CFib2OBot::CFib2OBot(void) {
}

//+------------------------------------------------------------------+
//| Destructor
//+------------------------------------------------------------------+
void CFib2OBot::~CFib2OBot(void){
}

//+------------------------------------------------------------------+
//| Inits bot
//+------------------------------------------------------------------+
void CFib2OBot::InitChild() {
  Inputs.IndStrucBlockHndl = iCustom(Sym.Name(), Inputs.FIB_TF, "Market\\Structure Blocks");
  
  Dir = BUY;
  
  StartDate = 0;
  StartPriceFibo1 = 0;
  StartPriceFibo2 = 0;
  
  FiboDurationSec = PeriodSeconds(Period())*5;
  
  FinishDate = 0;
  FinishPrice = 0;
  
  FiboTimeChange = 0;
  OrdersTimeChange = 0;
  
  COrderInfo order;
  for(int i=0;i<Orders.Total();i++){
    long ticket = Orders.At(i);
    if(!order.Select(ticket)) 
      continue;       
    
    Logger.Assert(Trade.OrderDelete(Orders.At(i)),
                  StringFormat("%s/%d: RET_CODE=%d; TICKET=%I64u",
                               __FUNCTION__, __LINE__,
                               Trade.ResultRetcode(), Orders.At(i)),
                  WARN, ERROR);
  }
  
  OnBar();
}

//+------------------------------------------------------------------+
//| Check bot's params
//+------------------------------------------------------------------+
bool CFib2OBot::Check(void) {
  if(!CDKBaseBot<CFib2OBotInputs>::Check())
    return false;

  bool res = true;
  // IndStrucBlockHndl
  if(Inputs.IndStrucBlockHndl <= 0) {
    Logger.Critical("Indicator 'Structure Block' init failed", true);
    res = false;
  }  
  
  // FIB_STP_EPL_StopEPLevel
  if(Inputs.FIB_STP_EPL_StopEPLevel <= 0) {
    Logger.Critical("'FIB_STP_EPL' must be positive", true);
    res = false;
  }  
  
  // FIB_STP_EPL_StopEPLevel
  if(Inputs.FIB_STP_SLL_StopSLLevel < 0) {
    Logger.Critical("'FIB_STP_SLL' must be positive", true);
    res = false;
  }    
  
  // FIB_DPT_Depth
  if(Inputs.FIB_DPT_Depth <= 0) {
    Logger.Critical("'FIB_DPT' must be positive", true);
    res = false;
  }   
  
  // FIB_LIM_EPL_LimitEPLevel
  if(Inputs.FIB_LIM_EPL_LimitEPLevel <= 0) {
    Logger.Critical("'FIB_LIM_EPL' must be positive", true);
    res = false;
  }  
  
  // FIB_LIM_SLL_LimitSLLevel
  if(Inputs.FIB_LIM_SLL_LimitSLLevel < 0) {
    Logger.Critical("'FIB_LIM_SLL' must be positive", true);
    res = false;
  }     
  
  // ENT_STP_RR_Stop_RR
  if(Inputs.ENT_STP_RR_Stop_RR <= 0) {
    Logger.Critical("'ENT_STP_RR' must be positive", true);
    res = false;
  }     
  
  // ENT_LIM_RR1_Limit_RR1
  if(Inputs.ENT_LIM_RR1_Limit_RR1 <= 0) {
    Logger.Critical("'ENT_LIM_RR1' must be positive", true);
    res = false;
  }     
    
  // ENT_LIM_RR2_Limit_RR2
  if(Inputs.ENT_LIM_RR2_Limit_RR2 <= 0) {
    Logger.Critical("'ENT_LIM_RR2' must be positive", true);
    res = false;
  }      
  

  return res;
}


//+------------------------------------------------------------------+
//| OnDeinit Handler
//+------------------------------------------------------------------+
void CFib2OBot::OnDeinit(const int reason) {
  ObjectsDeleteAll(0, StringFormat("%s-Fibo", Logger.Name));  
}

//+------------------------------------------------------------------+
//| OnTick Handler
//+------------------------------------------------------------------+
void CFib2OBot::OnTick(void) {
  CDKBaseBot<CFib2OBotInputs>::OnTick(); // Check new bar and show comment
  
  //if(Poses.Total() > 0) {
  //  //UpdateTrailing();       // 01. Trailing
  //  //ClosePosOnExpiration(); // 02. Close pos on exp
  //}
    
  UpdateComment();
}

//+------------------------------------------------------------------+
//| OnBar Handler
//+------------------------------------------------------------------+
void CFib2OBot::OnBar(void) {
  UpdateFibo();
  DrawFibo1();
  DrawFibo2();
  UpdateOrders();
  
  UpdateComment();
}

//+------------------------------------------------------------------+
//| OnTrade Handler
//+------------------------------------------------------------------+
void CFib2OBot::OnTrade(void) {
  CDKBaseBot<CFib2OBotInputs>::OnTrade(); 
}

//+------------------------------------------------------------------+
//| OnTimer Handler
//+------------------------------------------------------------------+
void CFib2OBot::OnTimer(void) {
  CDKBaseBot<CFib2OBotInputs>::OnTimer();
  UpdateComment();
}

//+------------------------------------------------------------------+
//| OnTester Handler
//+------------------------------------------------------------------+
double CFib2OBot::OnTester(void) {
  return 0;
}

void CFib2OBot::OnOrderPlaced(ulong _order){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

void CFib2OBot::OnOrderModified(ulong _order){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

void CFib2OBot::OnOrderDeleted(ulong _order){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

void CFib2OBot::OnOrderExpired(ulong _order){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

void CFib2OBot::OnOrderTriggered(ulong _order){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

void CFib2OBot::OnPositionTakeProfit(ulong _position, ulong _deal){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

void CFib2OBot::OnPositionClosed(ulong _position, ulong _deal){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

void CFib2OBot::OnPositionCloseBy(ulong _position, ulong _deal){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

void CFib2OBot::OnPositionModified(ulong _position){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}  
  
//+------------------------------------------------------------------+
//| OnPositionOpened
//+------------------------------------------------------------------+
void CFib2OBot::OnPositionOpened(ulong _position, ulong _deal) {
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

//+------------------------------------------------------------------+
//| OnStopLoss Handler
//+------------------------------------------------------------------+
void CFib2OBot::OnPositionStopLoss(ulong _position, ulong _deal) {
  if(Poses.SearchLinear(_position) < 0)
    return;

  Logger.Warn(StringFormat("%s/%d: TICKET=%I64u", 
                           __FUNCTION__, __LINE__, 
                           _position));
  
  SetLimitPosTP2(); 
  DeleteLimitOrderOnStopSL(); 
}


//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Bot's logic
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Updates comment
//+------------------------------------------------------------------+
void CFib2OBot::UpdateComment(const bool _ignore_interval = false) {
  ClearComment();
  
//  // 01. Time and left to trigger
//  long next_event_in = (NextEventDT != LONG_MAX) ? NextEventDT-TimeCurrent() : LONG_MAX;
//  AddCommentLine(TimeToString(TimeCurrent()) + ": Next trigger in " + ((next_event_in != LONG_MAX) ? TimeDurationToString(next_event_in) : "N/A"));
//  
//  // 02. In progress
//  if(Channels.Total() > 0){
//    AddCommentLine("");
//    AddCommentLine("News in progress: " + (string)Channels.Total(),
//                 0, clrRed);
//
//    CARRAYOBJ_ITER(Channels, CNewsBreakoutChannel, 
//      EVENT event;
//      el.GetEvent(event);
//      string event_text = "  " + TimeToString(event.time) + " " + event.CurrencySymbol[] + " " + event.Name[];
//      AddCommentLine(event_text);
//    );                 
//  }
//  
//  // 03. Upcoming events
//  AddCommentLine("");
//  AddCommentLine("Next " + (string)ArraySize(UpcomingEvents) + " upcoming events of " + (string)Calendar.GetAmount() + ":",
//                 0, clrLightSteelBlue);
//  
//  for(int i=0;i<ArraySize(UpcomingEvents);i++) {
//    EVENT event = UpcomingEvents[i];
//    string event_text = "  " + TimeToString(event.time) + " " + event.CurrencySymbol[] + " " + event.Name[];
//    color clr = 0;
//    if(event.Importance == CALENDAR_IMPORTANCE_HIGH)     clr = clrPink;
//    if(event.Importance == CALENDAR_IMPORTANCE_MODERATE) clr = clrLightYellow;
//    AddCommentLine(event_text, 0, clr);
//  }
               
  ShowComment(_ignore_interval);     
}

//+------------------------------------------------------------------+
//| Return Fibo name
//+------------------------------------------------------------------+
string CFib2OBot::GetFiboName(const int _idx) {
  return StringFormat("%s-Fibo%d", Logger.Name, _idx);
}

//+------------------------------------------------------------------+
//| Draws Fibo
//+------------------------------------------------------------------+
void CFib2OBot::DrawFibo(const int _idx, 
                         const datetime _start_date, const double _start_value,
                         const datetime _finish_date, const double _finish_value,
                         const double _lev1, const double _lev2,
                         const color _clr,
                         const string _suffix) {
  string name = GetFiboName(_idx);
  CChartObjectFibo fibo;
  fibo.Create(0, name, 0, _start_date, _start_value, _finish_date, _finish_value);
  fibo.Description(StringFormat("Fibo%d-%s", _idx, _suffix));
  fibo.Detach();
  
  ObjectSetInteger(0, name, OBJPROP_LEVELS, 4); // Set number of level
  
  // Set Levels
  ObjectSetDouble(0, name, OBJPROP_LEVELVALUE, 0, 0);
  ObjectSetString(0, name, OBJPROP_LEVELTEXT, 0, "0.0");
  
  ObjectSetDouble(0, name, OBJPROP_LEVELVALUE, 1, _lev1);
  ObjectSetString(0, name, OBJPROP_LEVELTEXT, 1, StringFormat("%0.1f", _lev1*100));
  
  ObjectSetDouble(0, name, OBJPROP_LEVELVALUE, 2, _lev2);
  ObjectSetString(0, name, OBJPROP_LEVELTEXT, 2, StringFormat("%0.1f", _lev2*100));  
  
  ObjectSetDouble(0, name, OBJPROP_LEVELVALUE, 3, 1);
  ObjectSetString(0, name, OBJPROP_LEVELTEXT, 3, "100.0");
  
  ObjectSetInteger(0, name, OBJPROP_COLOR, _clr); 
  ObjectSetInteger(0, name, OBJPROP_LEVELCOLOR, 0, _clr);   
  ObjectSetInteger(0, name, OBJPROP_LEVELCOLOR, 1, _clr);   
  ObjectSetInteger(0, name, OBJPROP_LEVELCOLOR, 2, _clr);   
  ObjectSetInteger(0, name, OBJPROP_LEVELCOLOR, 3, _clr);     
  
  ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| Draws Fibo1
//+------------------------------------------------------------------+
void CFib2OBot::DrawFibo1() {
  color clr = (Dir == BUY) ? Inputs.FIB_COL_BUY_Color_Buy : Inputs.FIB_COL_SELL_Color_Sell;
  DrawFibo(1, 
           StartDate, StartPriceFibo1, FinishDate, FinishPrice,
           Inputs.FIB_STP_SLL_StopSLLevel, Inputs.FIB_STP_EPL_StopEPLevel,
           clr,
           PosTypeDKToString(PosReverse(Dir))+"_STOP");
}

//+------------------------------------------------------------------+
//| Draws Fibo2
//+------------------------------------------------------------------+
void CFib2OBot::DrawFibo2() {
  color clr = (Dir == BUY) ? Inputs.FIB_COL_BUY_Color_Buy : Inputs.FIB_COL_SELL_Color_Sell;
  DrawFibo(2, 
           FinishDate+FiboDurationSec, StartPriceFibo2, FinishDate+FiboDurationSec*2, FinishPrice,
           Inputs.FIB_LIM_EPL_LimitEPLevel, Inputs.FIB_LIM_EPL_LimitEPLevel,
           clr,
           PosTypeDKToString(Dir) + "_LIMIT");
}

//+------------------------------------------------------------------+
//| Updates prices and dates of Fibo using Structure Blocks 
//+------------------------------------------------------------------+
bool CFib2OBot::UpdateFibo() {
  //// There're pos in market => No Fibo update
  //if(Poses.Total() > 0)
  //  return false;

  double MarketType[];
  double UltimateHigh[];
  double UltimateLow[];
  double SwingHigh[];
  double SwingLow[];
  
  if(CopyBuffer(Inputs.IndStrucBlockHndl, 4, 0, Inputs.FIB_DPT_Depth, MarketType)   < (int)Inputs.FIB_DPT_Depth ||
     CopyBuffer(Inputs.IndStrucBlockHndl, 0, 0, Inputs.FIB_DPT_Depth, UltimateHigh) < (int)Inputs.FIB_DPT_Depth ||
     CopyBuffer(Inputs.IndStrucBlockHndl, 1, 0, Inputs.FIB_DPT_Depth, UltimateLow)  < (int)Inputs.FIB_DPT_Depth ||
     CopyBuffer(Inputs.IndStrucBlockHndl, 6, 0, Inputs.FIB_DPT_Depth, SwingHigh)    < (int)Inputs.FIB_DPT_Depth ||
     CopyBuffer(Inputs.IndStrucBlockHndl, 7, 0, Inputs.FIB_DPT_Depth, SwingLow)     < (int)Inputs.FIB_DPT_Depth) {
    Logger.Error(StringFormat("%s/%d: Error CopyBuffer()",
                              __FUNCTION__, __LINE__));
    return false;
  }
  
  MqlRates rates[]; 
  if(!CopyRates(Sym.Name(), Inputs.FIB_TF, 0, Inputs.FIB_DPT_Depth, rates) || ArraySize(rates) < (int)Inputs.FIB_DPT_Depth) {
    Logger.Error(StringFormat("%s/%d: Error CopyRates()",
                              __FUNCTION__, __LINE__));
    return false;
  }
  
  int bar_idx = ArraySize(MarketType)-2;
    
  ENUM_DK_POS_TYPE new_possible_dir = (MarketType[bar_idx] == 0.0) ? BUY: SELL;
  if(Inputs.FIB_MD_Mode == FIB2OBOT_MODE_SWING_SWING) {
    if(CompareDouble(rates[bar_idx].high, SwingHigh[bar_idx])) 
      new_possible_dir = BUY;
    else if(CompareDouble(rates[bar_idx].low, SwingLow[bar_idx])) 
      new_possible_dir = SELL;
    else
      return false;
      
    // Check back in history that swing was broken
    bool swing_broken = false;
    for(int i=bar_idx-1; i>=0; i--) {
      if((new_possible_dir == BUY  && !CompareDouble(SwingHigh[i], rates[i].high)) ||
         (new_possible_dir == SELL && !CompareDouble(SwingLow[i],  rates[i].low))) {
         if((new_possible_dir == BUY  && SwingHigh[bar_idx] > SwingHigh[i]) ||
            (new_possible_dir == SELL && SwingLow[bar_idx]  < SwingLow[i]))
            swing_broken = true;
         break;
      }
    }
    
    if(!swing_broken)
      return false;
  }
  Dir = new_possible_dir;

  double start_price_prev = StartPriceFibo1;
  double finish_price_prev = FinishPrice;

  StartDate = TimeCurrent();
  StartPriceFibo1 = (Dir == BUY) ? UltimateLow[bar_idx] : UltimateHigh[bar_idx];
  if(Inputs.FIB_MD_Mode == FIB2OBOT_MODE_BOS_SWING || Inputs.FIB_MD_Mode == FIB2OBOT_MODE_SWING_SWING)
    StartPriceFibo1 = (Dir == BUY) ? SwingLow[bar_idx] : SwingHigh[bar_idx];
  
  FinishDate = StartDate + FiboDurationSec;
  FinishPrice = (Dir == BUY) ? UltimateHigh[bar_idx] : UltimateLow[bar_idx];
  if(Inputs.FIB_MD_Mode == FIB2OBOT_MODE_SWING_SWING)
    FinishPrice = (Dir == BUY) ? SwingHigh[bar_idx] : SwingLow[bar_idx];
  
  double range = MathAbs(FinishPrice - StartPriceFibo1);
  StartPriceFibo2 = Sym.AddToPrice((ENUM_POSITION_TYPE)Dir, FinishPrice, -1*range/Inputs.FIB_LIM_EPL_LimitEPLevel); 
  
  if(!CompareDouble(StartPriceFibo1, start_price_prev) || !CompareDouble(FinishPrice, finish_price_prev)) {
    FiboTimeChange = TimeCurrent();
    Logger.Info(StringFormat("%s/%d: Updated: FIBO(%s, %s, %s-%s)",
                          __FUNCTION__, __LINE__,
                          TimeToString(FiboTimeChange),
                          PosTypeDKToString(Dir),
                          Sym.PriceFormat(StartPriceFibo1), Sym.PriceFormat(FinishPrice)));
    return true;
  }

  Logger.Debug(StringFormat("%s/%d: No change: FIBO(%s, %s, %s-%s)",
                            __FUNCTION__, __LINE__,
                            TimeToString(FiboTimeChange),
                            PosTypeDKToString(Dir),
                            Sym.PriceFormat(StartPriceFibo1), Sym.PriceFormat(FinishPrice)));
    
  return false;
}

//+------------------------------------------------------------------+
//| Find order with a specific type
//+------------------------------------------------------------------+
ulong CFib2OBot::FindPos(ENUM_DK_POS_TYPE _pos_type_to_find) {
  CDKPositionInfo pos;
  for(int i=0;i<Poses.Total();i++) {
    if(!pos.SelectByTicket(Poses.At(i))) continue;
    
    if(pos.PositionType() == (ENUM_POSITION_TYPE)_pos_type_to_find)   
      return pos.Ticket();
  }
  return 0;
}

//+------------------------------------------------------------------+
//| Find order with a specific type
//+------------------------------------------------------------------+
ulong CFib2OBot::FindOrder(ENUM_DK_ORDER_TYPE _order_type_to_find) {
  COrderInfo order;
  ulong ticket = 0;
  for(int i=0;i<Orders.Total();i++) {
    if(!order.Select(Orders.At(i))) continue;
    
    if(_order_type_to_find == STOP && (order.OrderType() == ORDER_TYPE_BUY_STOP || order.OrderType() == ORDER_TYPE_SELL_STOP))   
      return order.Ticket();
    if(_order_type_to_find == LIMIT && (order.OrderType() == ORDER_TYPE_BUY_LIMIT || order.OrderType() == ORDER_TYPE_SELL_LIMIT))   
      return order.Ticket();
  }
  
  return 0;
}

//+------------------------------------------------------------------+
//| Delete Order
//+------------------------------------------------------------------+
bool CFib2OBot::DeleteOrder(ulong _ticket) {
  if(!Inputs.ENT_ORD_DEL_Order_Delete) return false;
  COrderInfo order;
  if(!order.Select(_ticket)) return false;
  
  
  bool res = Trade.OrderDelete(_ticket);
  Logger.Assert(res,
                StringFormat("%s/%d: RET_CODE=%d; TICKET=%I64u",
                             __FUNCTION__, __LINE__,
                             Trade.ResultRetcode(), _ticket),
                WARN, ERROR);
                
  return res;
}

//+------------------------------------------------------------------+
//| Update Stop Order
//+------------------------------------------------------------------+
ulong CFib2OBot::UpdateStopOrder(ulong _ticket) {
  DeleteOrder(_ticket);

  ENUM_DK_POS_TYPE order_dir = PosReverse(Dir);
  
  double range = MathAbs(FinishPrice - StartPriceFibo1);
  double ep = Sym.AddToPrice((ENUM_POSITION_TYPE)order_dir, FinishPrice, range*Inputs.FIB_STP_EPL_StopEPLevel); 
  double sl = Sym.AddToPrice((ENUM_POSITION_TYPE)order_dir, FinishPrice, range*Inputs.FIB_STP_SLL_StopSLLevel); 
  double tp = Sym.AddToPrice((ENUM_POSITION_TYPE)order_dir, ep, MathAbs(ep-sl)*Inputs.ENT_STP_RR_Stop_RR);
  string comment = GetFiboName(1)+"-"+TimeToString(FiboTimeChange);
  double lot = CalculateLotSuper(Sym.Name(), Inputs.ENT_MMT_MoneyManagmentType, Inputs.ENT_MMV_MoneyManagmentValue, ep, sl);
  
  // Price is already low EP => impossible to open STOP order
  double curr_price = Sym.GetPriceToOpen((ENUM_POSITION_TYPE)order_dir);
  if(IsPosPriceGT((ENUM_POSITION_TYPE)PosReverse(order_dir), ep, curr_price)) {
    Logger.Debug(StringFormat("%s/%d: Skip update due EP>CP: EP=%s; CP=%s",
                              __FUNCTION__, __LINE__,
                              Sym.PriceFormat(ep), Sym.PriceFormat(curr_price)));
    return 0;
  }
  
  ulong ticket = Trade.OrderOpen(Sym.Name(), PosToOrderType(order_dir, STOP), lot, 0, ep, sl, tp, ORDER_TIME_GTC, 0, comment);  
  Logger.Assert(ticket > 0,
                StringFormat("%s/%d: RET_CODE=%d; TICKET=(%s, %I64u); FIBO1(%s, %s, %s-%s)",
                             __FUNCTION__, __LINE__,
                             Trade.ResultRetcode(),
                             
                             PosTypeDKToString(order_dir),
                             ticket,                      
                                    
                             TimeToString(FiboTimeChange),
                             PosTypeDKToString(Dir),
                             Sym.PriceFormat(StartPriceFibo1), Sym.PriceFormat(FinishPrice)),
                WARN, ERROR);
                
  return ticket;
}

//+------------------------------------------------------------------+
//| Update Limit Order
//+------------------------------------------------------------------+
ulong CFib2OBot::UpdateLimitOrder(ulong _ticket, double _tp_rr) {
  DeleteOrder(_ticket);

  ENUM_DK_POS_TYPE order_dir = Dir;
  
  double range = MathAbs(FinishPrice - StartPriceFibo2);
  double ep = Sym.AddToPrice((ENUM_POSITION_TYPE)order_dir, FinishPrice, -1*range*Inputs.FIB_LIM_EPL_LimitEPLevel); 
  double sl = StartPriceFibo2;
  double tp = Sym.AddToPrice((ENUM_POSITION_TYPE)order_dir, ep, MathAbs(ep-sl)*_tp_rr);
  string comment = GetFiboName(2)+"-"+TimeToString(FiboTimeChange);
  double lot = CalculateLotSuper(Sym.Name(), Inputs.ENT_MMT_MoneyManagmentType, Inputs.ENT_MMV_MoneyManagmentValue, ep, sl);
  
  // Price is already low EP => impossible to open STOP order
  double curr_price = Sym.GetPriceToOpen((ENUM_POSITION_TYPE)order_dir);
  if(IsPosPriceGT((ENUM_POSITION_TYPE)order_dir, ep, curr_price)) {
    Logger.Debug(StringFormat("%s/%d: Skip update due EP>CP: EP=%s; CP=%s",
                              __FUNCTION__, __LINE__,
                              Sym.PriceFormat(ep), Sym.PriceFormat(curr_price)));
    return 0;
  }
  
  ulong ticket = Trade.OrderOpen(Sym.Name(), PosToOrderType(order_dir, LIMIT), lot, 0, ep, sl, tp, ORDER_TIME_GTC, 0, comment);  
  Logger.Assert(ticket > 0,
                StringFormat("%s/%d: RET_CODE=%d; TICKET=(%s, %I64u); FIBO2(%s, %s, %s-%s)",
                             __FUNCTION__, __LINE__,
                             Trade.ResultRetcode(),
                             
                             PosTypeDKToString(order_dir),
                             ticket,                      
                                    
                             TimeToString(FiboTimeChange),
                             PosTypeDKToString(Dir),
                             Sym.PriceFormat(StartPriceFibo2), Sym.PriceFormat(FinishPrice)),
                WARN, ERROR);
                
  return ticket;
}

//+------------------------------------------------------------------+
//| Updates orders
//+------------------------------------------------------------------+
bool CFib2OBot::UpdateOrders() {
  //// Pos is open => No more orders
  //if(Poses.Total() > 0) {
  //  Logger.Debug(StringFormat("%s/%d: Skip update due pos in market: POS_CNT=%d",
  //                            __FUNCTION__, __LINE__,
  //                            Poses.Total())) ;
  //  return false;    
  //}
  
  if(FiboTimeChange < OrdersTimeChange)
    return false;
    
  ulong ticket_stop = FindOrder(STOP);
  UpdateStopOrder(ticket_stop);
  
  ulong ticket_limit = FindOrder(LIMIT);
  UpdateLimitOrder(ticket_limit, Inputs.ENT_LIM_RR1_Limit_RR1);
  
  OrdersTimeChange = TimeCurrent();
  
  return true;
}

//+------------------------------------------------------------------+
//| Find pos by comment
//+------------------------------------------------------------------+
ulong CFib2OBot::FindPosByComment(const string _comment) {
  CDKPositionInfo pos;
  for(int j=0;j<Poses.Total();j++){
    if(!pos.SelectByTicket(Poses.At(j))) continue;
    if(pos.Comment() == _comment) 
      return pos.Ticket();
  }
  return 0;
}

//+------------------------------------------------------------------+
//| Find order by comment
//+------------------------------------------------------------------+
ulong CFib2OBot::FindOrderByComment(const string _comment) {
  COrderInfo order;
  for(int j=0;j<Orders.Total();j++){
    if(!order.Select(Orders.At(j))) continue;
    if(order.Comment() == _comment) 
      return order.Ticket();
  }
  return 0;
}


//+------------------------------------------------------------------+
//| Set TP2 to limit order and limit pos
//+------------------------------------------------------------------+
bool CFib2OBot::SetLimitPosTP2() {
  bool res = false;
  CDKPositionInfo pos;
  COrderInfo order;
  for(int i=0;i<Poses.Total();i++) {
    if(!pos.SelectByTicket(Poses.At(i))) continue;
    if(StringFind(pos.Comment(), "Fibo2") < 0) continue; // This is not Limit Pos
    
    string comment_of_stop = pos.Comment();
    StringReplace(comment_of_stop, "Fibo2", "Fibo1");

    ulong pos_sell = FindPosByComment(comment_of_stop);
    // There's no pos Fibo1 in market => Fibo2 pos must change TP to RR2
    if(pos_sell <= 0 && pos.SelectByTicket(Poses.At(i))){
      double ep = pos.PriceOpen();
      
      //double sl = pos.StopLoss();
      //double sl_dist = MathAbs(ep-sl);
      double sl_dist = MathAbs(pos.PriceOpen() - pos.StopLoss());
      sl_dist = (Inputs.FIB_STP_EPL_StopEPLevel-Inputs.FIB_STP_SLL_StopSLLevel)*sl_dist*Inputs.FIB_LIM_EPL_LimitEPLevel/(1-Inputs.FIB_LIM_EPL_LimitEPLevel);
      double sl = pos.AddToPrice(pos.PriceOpen(), -1*sl_dist);
      
      //double tp = pos.AddToPrice(ep, sl_dist*Inputs.ENT_LIM_RR2_Limit_RR2);
      double tp = pos.TakeProfit();
      
      if(tp<pos.PriceToClose()) {
        bool oper_res = Trade.PositionClose(pos.Ticket());
        res = oper_res || res;
        Logger.Assert(oper_res,
                      StringFormat("%s/%d: Pos Fibo2 TP with RR2 is less than price. Close pos: RET_CODE=%d; TICKET=(%s, %I64u)",
                                   __FUNCTION__, __LINE__,
                                   Trade.ResultRetcode(),
                                   
                                   PositionTypeToString(pos.PositionType()),
                                   pos.Ticket()),
                      WARN, ERROR);      
      }
      else {
        bool oper_res = Trade.PositionModify(pos.Ticket(), sl, tp);
        res = oper_res || res;
        Logger.Assert(oper_res,
                      StringFormat("%s/%d: Pos Fibo2 TP set to RR2: RET_CODE=%d; TICKET=(%s, %I64u)",
                                   __FUNCTION__, __LINE__,
                                   Trade.ResultRetcode(),
                                   
                                   PositionTypeToString(pos.PositionType()),
                                   pos.Ticket()),
                      WARN, ERROR);
      }
    }    
  }
  
  return res;
}

//+------------------------------------------------------------------+
//| Deletes LIMIT order on STOP order SL
//+------------------------------------------------------------------+
bool CFib2OBot::DeleteLimitOrderOnStopSL(){
  bool res = false;
  CDKPositionInfo pos;
  COrderInfo order;
  for(int i=0;i<Orders.Total();i++) {
    if(!order.Select(Orders.At(i))) continue;
    if(StringFind(order.Comment(), "Fibo2") < 0) continue; // This is not Limit Pos
    
    string comment_of_stop = order.Comment();
    StringReplace(comment_of_stop, "Fibo2", "Fibo1");

    ulong order_sell = FindOrderByComment(comment_of_stop);
    ulong pos_sell = FindPosByComment(comment_of_stop);
    
    // There're no pos&order Fibo1 in market => delete Fibo2 order
    if(order_sell <= 0 && pos_sell <= 0 && order.Select(Orders.At(i))){
      bool oper_res = Trade.OrderDelete(order.Ticket());
      res = oper_res || res;
      Logger.Assert(oper_res,
                    StringFormat("%s/%d: RET_CODE=%d; TICKET=%I64u",
                                 __FUNCTION__, __LINE__,
                                 Trade.ResultRetcode(),
                                 pos.Ticket()),
                    WARN, ERROR);      
    }
  }
  
  return res;
}