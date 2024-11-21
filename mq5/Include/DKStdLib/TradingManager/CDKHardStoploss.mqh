//+------------------------------------------------------------------+
//|                                           CDKHardDayStoploss.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+
#property copyright "Denis Kislitsyn"
#property link      "https://kislitsyn.me"

#include <Trade\AccountInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>

class CDKHardStoploss {
protected:
  int                   m_day_shift;
  double                m_max_loss_percent;
  double                m_max_loss;
  ulong                 m_magic[];
  
  int CDKHardStoploss::ArrayFind(const ulong _value);
public:
  void CDKHardStoploss::Init(const double _max_loss, const double _max_loss_percent, const int _day_shift = 0);
  void CDKHardStoploss::Init(const double _max_loss, const double _max_loss_percent, const ulong _magic, const int _day_shift = 0);
  void CDKHardStoploss::Init(const double _max_loss, const double _max_loss_percent, ulong& _magic[], const int _day_shift = 0);
  
  double CDKHardStoploss::GetProfit(const bool _ignore_magic = false);
  double CDKHardStoploss::GetProfitPercent(const bool _ignore_magic = false);
  
  bool CDKHardStoploss::IsLossExceeded(const bool _ignore_magic = false);
  bool CDKHardStoploss::IsLossPercentExceeded(const bool _ignore_magic = false);
  bool CDKHardStoploss::IsAnyLossExceeded(const bool _ignore_magic = false);
  
  uint CDKHardStoploss::CloseAll(const bool _ignore_magic = false);
  uint CDKHardStoploss::CheckLossAndCloseAll(const bool _ignore_magic_get_prifit = true, const bool _ignore_magic_close_pos = false);
};

int CDKHardStoploss::ArrayFind(const ulong _value) {
  for (int i=0; i < ArraySize(m_magic); i++)
    if (m_magic[i] == _value) return i;
    
  return -1;
}

void CDKHardStoploss::Init(const double _max_loss, const double _max_loss_percent, const int _day_shift = 0) {
  m_day_shift = _day_shift;
  m_max_loss = _max_loss;
  m_max_loss_percent = _max_loss_percent;  
  
  ArrayResize(m_magic, 0);
}

void CDKHardStoploss::Init(const double _max_loss, const double _max_loss_percent, const ulong _magic, const int _day_shift = 0) {
  m_day_shift = _day_shift;
  m_max_loss = _max_loss;
  m_max_loss_percent = _max_loss_percent;  
  
  ArrayResize(m_magic, 1);
  m_magic[0] = _magic;
}

void CDKHardStoploss::Init(const double _max_loss, const double _max_loss_percent, ulong& _magic[], const int _day_shift = 0) {
  m_day_shift = _day_shift;
  m_max_loss = _max_loss;
  m_max_loss_percent = _max_loss_percent;  
  
  ArrayResize(m_magic, ArraySize(_magic));
  ArrayCopy(m_magic, _magic);
}

double CDKHardStoploss::GetProfit(const bool _ignore_magic = false) {
  double profit = 0;
  datetime start_date = iTime(NULL, PERIOD_D1, m_day_shift); 
 
  HistorySelect(start_date, TimeCurrent());      
  int history_total = HistoryDealsTotal(); 

  for (int i = history_total; i >= 0; i--) {
    ulong history_deal = HistoryDealGetTicket(i);
    if (history_deal > 0) {
      if (HistoryDealGetInteger(history_deal, DEAL_TIME) < start_date) break;
      
      if (!_ignore_magic)
        if (ArraySize(m_magic) > 0)
          if (ArrayFind(HistoryDealGetInteger(history_deal, DEAL_MAGIC)) < 0) continue;

      // BUY or SELL deals only
      if (HistoryDealGetInteger(history_deal, DEAL_TYPE) < 2) 
        profit += HistoryDealGetDouble(history_deal,  DEAL_PROFIT) 
                + HistoryDealGetDouble(history_deal, DEAL_SWAP) 
                + HistoryDealGetDouble(history_deal, DEAL_COMMISSION);
    }
  }   
 
 CAccountInfo account;
 return profit + account.Profit();
}

double CDKHardStoploss::GetProfitPercent(const bool _ignore_magic = false){
  CAccountInfo m_account;
  double curr_balance = m_account.Balance();
  double profit = GetProfit(_ignore_magic);
  double start_balance = curr_balance - profit;  
  
  return (start_balance != 0) ? profit / start_balance * 100 : 0;
}

bool CDKHardStoploss::IsLossExceeded(const bool _ignore_magic = false) {
  if(m_max_loss <= 0) return false;
  
  double profit = GetProfit(_ignore_magic);
  if (profit >= 0) return false;
  return (MathAbs(profit) >= m_max_loss);
}

bool CDKHardStoploss::IsLossPercentExceeded(const bool _ignore_magic = false) {
  if(m_max_loss_percent <= 0) return false;

  double profit = GetProfitPercent(_ignore_magic);
  if (profit >= 0) return false;
  return (MathAbs(profit) >= m_max_loss_percent);
}

bool CDKHardStoploss::IsAnyLossExceeded(const bool _ignore_magic = false) {
  return IsLossExceeded(_ignore_magic) || IsLossPercentExceeded(_ignore_magic);
}

uint CDKHardStoploss::CloseAll(const bool _ignore_magic = false) {
  CPositionInfo pos;
  CTrade trade;
  
  int cnt = 0;
  int i = PositionsTotal() - 1;
  while (i >= 0) {
    if (pos.SelectByIndex(i))
      if (_ignore_magic || (ArraySize(m_magic) <= 0) || ((ArraySize(m_magic) > 0) && (ArrayFind(pos.Magic()) >= 0)))
        if (trade.PositionClose(pos.Ticket()))
          if (trade.ResultRetcode() == TRADE_RETCODE_DONE) {
            cnt++;
            continue;    
          }
    i--;
  }
      
  return cnt;  
}

uint CDKHardStoploss::CheckLossAndCloseAll(const bool _ignore_magic_get_prifit = true, const bool _ignore_magic_close_pos = false) {
  if (IsAnyLossExceeded(_ignore_magic_get_prifit)) return CloseAll(_ignore_magic_close_pos);
  return 0;
}
