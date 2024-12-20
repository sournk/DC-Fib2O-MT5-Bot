//+------------------------------------------------------------------+
//|                                          CNewsBreakoutInputs.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

enum ENUM_FIB2OBOT_MODE {
  FIB2OBOT_MODE_BOS_CHOCH   = 0, // Fibo between BOS & CHoCH
  FIB2OBOT_MODE_BOS_SWING   = 1, // Fibo between BOS & SWING
  FIB2OBOT_MODE_SWING_SWING = 2, // Fibo between SWING & SWING
};

struct CFib2OBotInputs {
  // USER INPUTS
  ENUM_FIB2OBOT_MODE       FIB_MD_Mode;                                    // FIB_MD: Mode
  
  bool                     FIB_BOS_BOSEnabled;                             // FIB_BOS: Update on BOS Enabled
  bool                     FIB_CHO_CHOEnabled;                             // FIB_CHO: Update on CHoCH Enabled
  
  ENUM_TIMEFRAMES          FIB_TF;                                         // FIB_TF: Timeframe to detect BOS/CHoCH and Fibo

  uint                     FIB_DPT_Depth;                                  // FIB_DPT: Depth to find BOS/CHoCH  

  double                   FIB_STP_EPL_StopEPLevel;                        // FIB_STP_EPL: STOP EP Level
  double                   FIB_STP_SLL_StopSLLevel;                        // FIB_STP_SLL: STOP SL Level
  
  color                    FIB_COL_BUY_Color_Buy;                          // FIB_COL_BUY: Color Buy
  color                    FIB_COL_SELL_Color_Sell;                        // FIB_COL_SELL: Color Sell  

  double                   FIB_LIM_EPL_LimitEPLevel;                       // FIB_LIM_EPL: LIMIT EP Level
  double                   FIB_LIM_SLL_LimitSLLevel;                       // FIB_LIM_SLL: LIMIT SL Level

  bool                     ENT_STP_ENB_Stop_Enabled;                       // ENT_STP_ENB: STOP Order Enabled
  double                   ENT_STP_RR_Stop_RR;                             // ENT_STP_RR: STOP Order TP RR

  bool                     ENT_LIM_ENB_Limit_Enabled;                      // ENT_LIM_ENB: LIMIT Order Enabled
  double                   ENT_LIM_RR1_Limit_RR1;                          // ENT_LIM_RR1: LIMIT Order TP RR
  double                   ENT_LIM_RR2_Limit_RR2;                          // ENT_LIM_RR2: LIMIT Order TP RR After STOP SL
  bool                     ENT_ORD_DEL_Order_Delete;                       // ENT_ORD_DEL: Delete orders when Fibo's updated   

  ENUM_MM_TYPE             ENT_MMT_MoneyManagmentType;                     // ENT_MMT: Money Managment Type
  double                   ENT_MMV_MoneyManagmentValue;                    // ENT_MMV: Money Managment Value
  
  // GLOBAL VARS
  int                      IndStrucBlockHndl; 

  // CONSTRUCTOR  
  void                     CFib2OBotInputs():
                             FIB_MD_Mode(FIB2OBOT_MODE_BOS_SWING),
                              
                             FIB_BOS_BOSEnabled(true),
                             FIB_CHO_CHOEnabled(true),
                             
                             FIB_TF(PERIOD_H1),
                             FIB_DPT_Depth(100),
                             
                             FIB_STP_EPL_StopEPLevel(0.764),
                             FIB_STP_SLL_StopSLLevel(0.236),
                             
                             FIB_COL_BUY_Color_Buy(clrDarkGreen),
                             FIB_COL_SELL_Color_Sell(clrCrimson),
                             
                             FIB_LIM_EPL_LimitEPLevel(0.764),
                             FIB_LIM_SLL_LimitSLLevel(100.0),
                             
                             ENT_STP_ENB_Stop_Enabled(true),
                             ENT_STP_RR_Stop_RR(1.0),
                             
                             ENT_LIM_ENB_Limit_Enabled(true),
                             ENT_LIM_RR1_Limit_RR1(5.0),
                             ENT_LIM_RR2_Limit_RR2(1.0),
                             
                             ENT_ORD_DEL_Order_Delete(true),
                             
                             ENT_MMT_MoneyManagmentType(ENUM_MM_TYPE_FIXED_LOT),
                             ENT_MMV_MoneyManagmentValue(0.01)

                             {};
};
