//+------------------------------------------------------------------+
//|                                                CDKSymbolInfo.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//| 2024-11-08:
//|   [+] GetSpreadAt() 
//|   [+] GetSpreadAtOpenning() 
//|   [+] PointsToPrice() & PriceToPoints()
//|   [+] PriceFormat()
//|   [+] Ask(), Bid() & Spread()
//+------------------------------------------------------------------+
#property copyright "Denis Kislitsyn"
#property link      "https://kislitsyn.me"

#include <Trade\PositionInfo.mqh>
#include "..\Common\DKStdLib.mqh"
#include "CDKSymbolInfo.mqh"

class CDKPositionInfo : public CPositionInfo {
protected:
  CDKSymbolInfo                      m_symbol;
  void                               UpdatedSymbolCached();
public:
  double                             GetPriceDeltaCurrentAndOpenToOpen();                   // Returns delta between pos current price and pos open price to OPEN new pos with same dir
  int                                GetPriceDeltaCurrentAndOpenToOpenPoint();              // Returns delta in point between pos current price and pos open price to OPEN new pos with same dir
  
  double                             GetPriceDeltaCurrentAndOpenToClose();                  // Returns delta between pos current price and pos open price to CLOSE new pos with same dir
  int                                GetPriceDeltaCurrentAndOpenClosePoint();               // Returns delta in points between pos current price and pos open price to CLOSE new pos with same dir
  
  double                             GetImprovedtPriceDelta();                              // Returns positive number of price delta if it's improved after the pos opening
  int                                GetImprovedtPriceDeltaPoint();                         // Returns positive number of price delta in points if it's improved after the pos opening
  
  double                             GetWorsenedtPriceDelta();                              // Returns positive number of price delta if it's worsened after the pos opening
  int                                GetWorsenedtPriceDeltaPoint();                         // Returns positive number of price delta in points if it's improved after the pos opening  
  
  bool                               IsPriceGT(const double _price_to_check, const double _price_base); // Check _price_to_check is better (gt) than _price_base for given PositionType()
  bool                               IsPriceGE(const double _price_to_check, const double _price_base); // Check _price_to_check is better (ge) than _price_base for given PositionType()
  bool                               IsPriceLT(const double _price_to_check, const double _price_base); // Check _price_to_check is worst (lt) than _price_base for given PositionType()
  bool                               IsPriceLE(const double _price_to_check, const double _price_base); // Check _price_to_check is worst (le) than _price_base for given PositionType()

  bool                               IsPriceGTOpen(const double _price_to_check); // Check _price_to_check is better (gt) than PriceOpen() for given PositionType()
  bool                               IsPriceGEOpen(const double _price_to_check); // Check _price_to_check is better (ge) than PriceOpen() for given PositionType()
  bool                               IsPriceLTOpen(const double _price_to_check); // Check _price_to_check is worst (lt) than PriceOpen() for given PositionType()
  bool                               IsPriceLEOpen(const double _price_to_check); // Check _price_to_check is worst (le) than PriceOpen() for given PositionType()
  
  int                                GetDirSign(); // Returns dir sign +1 or -1 
  
  double                             PriceToClose();

  double                             AddToPrice(const double _price, const double _price_addition);       // Adds _price_addition to _price given Dir
  double                             AddToPrice(const double _price_base, const int _distance_addition);  // Adds _distance_addition to _price given Dir
  
  bool                               Select(const string symbol);
  bool                               SelectByMagic(const string symbol,const ulong magic);
  bool                               SelectByTicket(const ulong ticket);
  bool                               SelectByIndex(const int index);  
  
  double                             GetSpreadAt(const ulong _ms);
  double                             GetSpreadAtOpenning();
  
  string                             PriceFormat(const double _price);
  double                             PointsToPrice(const int aPoint);
  int                                PriceToPoints(const double aPrice);
  
  double                             Ask();
  double                             Bid();
  double                             Spread();
};

void CDKPositionInfo::UpdatedSymbolCached(){
  if (m_symbol.Name() == NULL) 
    m_symbol.Name(this.Symbol());
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Pos Selection
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

bool CDKPositionInfo::Select(const string symbol) {
  bool res = CPositionInfo::Select(symbol);
  UpdatedSymbolCached();
  return res;
}

bool CDKPositionInfo::SelectByMagic(const string symbol,const ulong magic) {
  bool res = CPositionInfo::SelectByMagic(symbol, magic);
  UpdatedSymbolCached();
  return res;
}

bool CDKPositionInfo::SelectByTicket(const ulong ticket) {
  bool res = CPositionInfo::SelectByTicket(ticket);
  UpdatedSymbolCached();
  return res;
}

bool CDKPositionInfo::SelectByIndex(const int index) {
  bool res = CPositionInfo::SelectByIndex(index);
  UpdatedSymbolCached();
  return res;
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Price Operations
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Check if _price_to_check is better (gt) _price_base 
//| given pos dir
//+------------------------------------------------------------------+
bool CDKPositionInfo::IsPriceGT(const double _price_to_check, const double _price_base) {
  return IsPosPriceGT(PositionType(), _price_to_check, _price_base);
}

//+------------------------------------------------------------------+
//| Check if _price_to_check is better (ge) _price_base 
//| given pos dir
//+------------------------------------------------------------------+
bool CDKPositionInfo::IsPriceGE(const double _price_to_check, const double _price_base) {
  return IsPosPriceGE(PositionType(), _price_to_check, _price_base);
}

//+------------------------------------------------------------------+
//| Check if _price_to_check is worst (lt) _price_base 
//| given pos dir
//+------------------------------------------------------------------+
bool CDKPositionInfo::IsPriceLT(const double _price_to_check, const double _price_base) {
  return IsPosPriceLT(PositionType(), _price_to_check, _price_base);
}

//+------------------------------------------------------------------+
//| Check if _price_to_check is worst (le) _price_base 
//| given pos dir
//+------------------------------------------------------------------+
bool CDKPositionInfo::IsPriceLE(const double _price_to_check, const double _price_base) {
  return IsPosPriceLE(PositionType(), _price_to_check, _price_base);
}

//+------------------------------------------------------------------+
//| Check if _price_to_check is better (gt) PriceOpen()
//| given pos dir
//+------------------------------------------------------------------+
bool CDKPositionInfo::IsPriceGTOpen(const double _price_to_check) {
  return IsPriceGT(_price_to_check, PriceOpen());
}

//+------------------------------------------------------------------+
//| Check if _price_to_check is better (ge) PriceOpen() 
//| given pos dir
//+------------------------------------------------------------------+
bool CDKPositionInfo::IsPriceGEOpen(const double _price_to_check) {
  return IsPriceGE(_price_to_check, PriceOpen());
}

//+------------------------------------------------------------------+
//| Check if _price_to_check is worst (lt) PriceOpen() 
//| given pos dir
//+------------------------------------------------------------------+
bool CDKPositionInfo::IsPriceLTOpen(const double _price_to_check) {
  return IsPriceLT(_price_to_check, PriceOpen());
}

//+------------------------------------------------------------------+
//| Check if _price_to_check is worst (le) PriceOpen() 
//| given pos dir
//+------------------------------------------------------------------+
bool CDKPositionInfo::IsPriceLEOpen(const double _price_to_check) {
  return IsPriceLE(_price_to_check, PriceOpen()); 
}

//+------------------------------------------------------------------+
//| Returns dir sign +1 or -1                                                                   
//+------------------------------------------------------------------+
int CDKPositionInfo::GetDirSign(){
  return GetPosDirSign(PositionType());
}

double CDKPositionInfo::GetPriceDeltaCurrentAndOpenToOpen() {
  return m_symbol.GetPriceToOpen(PositionType()) - PriceOpen();
}

int CDKPositionInfo::GetPriceDeltaCurrentAndOpenToOpenPoint() {
  return m_symbol.PriceToPoints(GetPriceDeltaCurrentAndOpenToOpen());
}

double CDKPositionInfo::GetPriceDeltaCurrentAndOpenToClose(){
  return m_symbol.GetPriceToClose(PositionType()) - PriceOpen();
}

int CDKPositionInfo::GetPriceDeltaCurrentAndOpenClosePoint() {
  return m_symbol.PriceToPoints(GetPriceDeltaCurrentAndOpenToClose());
}

double CDKPositionInfo::GetImprovedtPriceDelta() {
  double delta = GetPriceDeltaCurrentAndOpenToOpen();
  if(PositionType() == POSITION_TYPE_BUY)  return (delta > 0) ? delta : 0;
  if(PositionType() == POSITION_TYPE_SELL) return (delta > 0) ? 0 : -1 * delta;
  
  return 0;
}

int CDKPositionInfo::GetImprovedtPriceDeltaPoint() {
  return m_symbol.PriceToPoints(GetImprovedtPriceDelta());
}

double CDKPositionInfo::GetWorsenedtPriceDelta() {
  double delta = GetPriceDeltaCurrentAndOpenToOpen();
  if(PositionType() == POSITION_TYPE_BUY)  return (delta > 0) ? 0 : -1 * delta;
  if(PositionType() == POSITION_TYPE_SELL) return (delta > 0) ? delta : 0;
  
  return 0;
}

int CDKPositionInfo::GetWorsenedtPriceDeltaPoint() {
  return m_symbol.PriceToPoints(GetWorsenedtPriceDelta());
}

double CDKPositionInfo::PriceToClose() {
  if (!m_symbol.RefreshRates()) return 0.0;
  if (PositionType() == POSITION_TYPE_BUY)  return m_symbol.Bid();
  if (PositionType() == POSITION_TYPE_SELL) return m_symbol.Ask();
  return 0.0;
}

double CDKPositionInfo::AddToPrice(const double _price_base, const double _price_addition) {
  return _price_base + GetDirSign()*_price_addition;
}

double CDKPositionInfo::AddToPrice(const double _price_base, const int _distance_addition) {
  return AddToPrice(_price_base, m_symbol.PointsToPrice(_distance_addition));
}

double CDKPositionInfo::GetSpreadAt(const ulong _ms) {
  return m_symbol.GetSpreadAt(_ms);
}

double CDKPositionInfo::GetSpreadAtOpenning() {
  return m_symbol.GetSpreadAt(TimeMsc());
}

//+------------------------------------------------------------------+
//| Convert aPrice to price value for current Symbol                 |
//+------------------------------------------------------------------+
int CDKPositionInfo::PriceToPoints(const double aPrice) {
  return m_symbol.PriceToPoints(aPrice);  
}

//+------------------------------------------------------------------+
//| Convert aPoint to points for current Symbol                      |
//+------------------------------------------------------------------+
double CDKPositionInfo::PointsToPrice(const int aPoint) {
  return m_symbol.PointsToPrice(aPoint);
}

//+------------------------------------------------------------------+
//| Make price format with Sym digits
//+------------------------------------------------------------------+
string CDKPositionInfo::PriceFormat(const double _price) {
  return m_symbol.PriceFormat(_price);
}

double CDKPositionInfo::Ask() {
  m_symbol.RefreshRates();
  return m_symbol.Ask();
}

double CDKPositionInfo::Bid() {
  m_symbol.RefreshRates();
  return m_symbol.Bid();
}

double CDKPositionInfo::Spread()   {
  m_symbol.RefreshRates();
  return m_symbol.Ask()-m_symbol.Bid();
}