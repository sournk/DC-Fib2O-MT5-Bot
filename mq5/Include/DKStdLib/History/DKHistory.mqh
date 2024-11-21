//+------------------------------------------------------------------+
//|                                                    DKHistory.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+
#property copyright "Denis Kislitsyn"
#property link      "https://kislitsyn.me"
#property version   "1.00"


#include <Trade/HistoryOrderInfo.mqh>
#include <Generic/HashMap.mqh>
#include <Arrays/ArrayLong.mqh>
#include <Arrays/ArrayObj.mqh>


class CDKHistoryDeal : public CObject {
public:
  ulong                        Ticket;
  ENUM_DEAL_TYPE               Type;  
  ENUM_DEAL_ENTRY              Entry;
  ENUM_DEAL_REASON             Reason;
  ulong                        Magic;
  
  double                       Volume;
  double                       Price;
  double                       Commission;
  double                       Swap;
  double                       Profit;
  double                       Fee;
  double                       SL;
  double                       TP;
  
  datetime                     Time;
  string                       Symbol;
  string                       Comment;
};

struct DKHistoryPos {
  ulong                        Count;
  ulong                        Magic;
  
  ulong                        DealInTicket;
  ulong                        DealOutTicket;
  
  double                       VolumeIn;
  double                       PriceIn;
  double                       PriceOut;
  double                       Commission;
  double                       Swap;
  double                       Profit;
  double                       Fee;
  double                       SLIn;
  double                       TPIn;
  
  datetime                     TimeIn;
  datetime                     TimeOut;
  ulong                        DurationSec;
  
  string                       Symbol;
  string                       Comment;
};


class CDKHistoryPositionList : public CObject {
protected:
  CHashMap<ulong, CArrayObj*>  DealMap;
  
  bool                         CDKHistoryPositionList::AddDeal(const ulong _ticket);
public:
  void                         CDKHistoryPositionList::~CDKHistoryPositionList(); 
  int                          CDKHistoryPositionList::Load(const datetime _dt_from, const datetime _dt_to);
  int                          CDKHistoryPositionList::Total();
  bool                         CDKHistoryPositionList::GetDealsByIndex(int _idx, CArrayObj *&_arr);
  string                       CDKHistoryPositionList::GetFirstInDealCommentByIndex(const int _idx);
  bool                         CDKHistoryPositionList::GetSummaryByIndex(const int _idx, DKHistoryPos& _pos);
};

void CDKHistoryPositionList::~CDKHistoryPositionList() {
  ulong keys[];
  CArrayObj* vals[];
  if(DealMap.CopyTo(keys, vals)<=0) return;

  for(int i=0;i<ArraySize(vals);i++) {
    vals[i].Clear();
    delete vals[i];   
  }

  DealMap.Clear();
} 

bool CDKHistoryPositionList::AddDeal(const ulong _ticket){
  ulong pos_id = HistoryDealGetInteger(_ticket, DEAL_POSITION_ID);
  if(pos_id <= 0) return false;
  
  CArrayObj* deal_list;
  if(!DealMap.TryGetValue(pos_id, deal_list)){
    deal_list = new CArrayObj();
    DealMap.Add(pos_id, deal_list);
  }

  CDKHistoryDeal* deal = new CDKHistoryDeal();
  deal.Ticket     = HistoryDealGetInteger(_ticket, DEAL_TICKET);
  deal.Type       = (ENUM_DEAL_TYPE)HistoryDealGetInteger(_ticket, DEAL_TYPE);
  deal.Entry      = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(_ticket, DEAL_ENTRY); 
  deal.Reason     = (ENUM_DEAL_REASON)HistoryDealGetInteger(_ticket, DEAL_REASON); 
  deal.Magic      = HistoryDealGetInteger(_ticket, DEAL_MAGIC); 
  deal.Volume     = HistoryDealGetDouble(_ticket, DEAL_VOLUME); 
  deal.Price      = HistoryDealGetDouble(_ticket, DEAL_PRICE); 
  deal.Commission = HistoryDealGetDouble(_ticket, DEAL_COMMISSION);
  deal.Swap       = HistoryDealGetDouble(_ticket, DEAL_SWAP); 
  deal.Profit     = HistoryDealGetDouble(_ticket, DEAL_PROFIT);
  deal.Fee        = HistoryDealGetDouble(_ticket, DEAL_FEE);     
  deal.SL         = HistoryDealGetDouble(_ticket, DEAL_SL); 
  deal.TP         = HistoryDealGetDouble(_ticket, DEAL_TP);  
  deal.Time       = (datetime)HistoryDealGetInteger(_ticket, DEAL_TIME); 
  deal.Symbol     = HistoryDealGetString(_ticket, DEAL_SYMBOL); 
  deal.Comment    = HistoryDealGetString(_ticket, DEAL_COMMENT);
  
  return deal_list.Add(deal);
}

int CDKHistoryPositionList::Load(const datetime _dt_from, const datetime _dt_to) {
  DealMap.Clear();
  
  HistorySelect(_dt_from, _dt_to); 
  int totalTrades = HistoryDealsTotal();
  if(totalTrades == 0) return 0;

  for (int i=0; i<totalTrades; i++) {
    ulong dealTicket = HistoryDealGetTicket(i);
    if(dealTicket > 0) AddDeal(dealTicket);
  }
  
  return DealMap.Count();
}

int CDKHistoryPositionList::Total() {
  return DealMap.Count();
}

bool CDKHistoryPositionList::GetDealsByIndex(int _idx, CArrayObj *&_arr) {
  if(_idx < 0 || _idx >= DealMap.Count()) return false;
  
  ulong keys[];
  CArrayObj* vals[];
  if(DealMap.CopyTo(keys, vals)<=0) return false;
    
  _arr = vals[_idx];
  return true;
}

string CDKHistoryPositionList::GetFirstInDealCommentByIndex(const int _idx) {
  CArrayObj* arr = NULL;
  if(!GetDealsByIndex(_idx, arr)) return "";
  
  for(int i=0;i<arr.Total();i++){
    CDKHistoryDeal* deal = arr.At(i);
    if(deal.Entry == DEAL_ENTRY_IN) 
      return deal.Comment;
  }
  
  return "";
}

bool CDKHistoryPositionList::GetSummaryByIndex(const int _idx, DKHistoryPos& _pos) {
  CArrayObj *arr;
  if(!GetDealsByIndex(_idx, arr)) return false; 
  
   _pos.Count = 0;
   _pos.Magic = 0;
   _pos.DealInTicket = 0;
   _pos.DealOutTicket = 0;
   _pos.VolumeIn = 0;
   _pos.PriceIn = 0;
   _pos.PriceOut = 0;
   _pos.Commission = 0;
   _pos.Swap = 0;
   _pos.Profit = 0;
   _pos.Fee = 0;
   _pos.SLIn = 0;
   _pos.TPIn = 0;
   _pos.TimeIn = 0;
   _pos.TimeOut = 0;
   _pos.DurationSec = 0;
   _pos.Symbol = "";
   _pos.Comment = "";  

  for(int i=0;i<arr.Total();i++) {
    CDKHistoryDeal* curr_deal = arr.At(i);
    
    _pos.Count++;    
    if(curr_deal.Entry == DEAL_ENTRY_IN) {
      _pos.Magic = curr_deal.Magic; 
      _pos.VolumeIn = curr_deal.Volume;
      _pos.PriceIn = curr_deal.Price;
      _pos.SLIn = curr_deal.SL;
      _pos.TPIn = curr_deal.TP;
      _pos.TimeIn = curr_deal.Time;
      _pos.Symbol = curr_deal.Symbol;
      _pos.Comment = curr_deal.Comment;
      _pos.DealInTicket = curr_deal.Ticket;
    }
    if(curr_deal.Entry == DEAL_ENTRY_OUT) {
       _pos.PriceOut = curr_deal.Price;
       _pos.TimeOut = curr_deal.Time;
       _pos.DealOutTicket = curr_deal.Ticket;
    }
  
    _pos.Commission += curr_deal.Commission;
    _pos.Swap += curr_deal.Swap;
    _pos.Profit += curr_deal.Profit;
    _pos.Fee += curr_deal.Fee;     
  }
  
  _pos.DurationSec = _pos.TimeOut-_pos.TimeIn;
  return true;
}
