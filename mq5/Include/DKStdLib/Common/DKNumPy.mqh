//+------------------------------------------------------------------+
//|                                                      DKNumPy.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+
#property copyright "Denis Kislitsyn"
#property link      "https://kislitsyn.me"

enum ENUM_COMPARE_TYPE {
  COMPARE_TYPE_LE = -100,
  COMPARE_TYPE_LT = -10,  

  COMPARE_TYPE_EQ = +1,
  COMPARE_TYPE_NE = +0,
  
  COMPARE_TYPE_GT = +10,
  COMPARE_TYPE_GE = +100,
};

bool CompareDoubleExtraMode(double a, double b, const ENUM_COMPARE_TYPE _mode=COMPARE_TYPE_EQ) {       
  if (_mode == COMPARE_TYPE_EQ) return (fabs(a-b)<=DBL_MIN+8*DBL_EPSILON*fmax(fabs(a),fabs(b)));
  if (_mode == COMPARE_TYPE_NE) return !CompareDoubleExtraMode(a, b, COMPARE_TYPE_EQ);
  
  if (_mode == COMPARE_TYPE_LE) return a <= b;
  if (_mode == COMPARE_TYPE_LT) return a < b;
  
  if (_mode == COMPARE_TYPE_GT) return a > b;
  if (_mode == COMPARE_TYPE_GE) return a >= b;
  
  return false;  
}

//+------------------------------------------------------------------+
//| Returns index of max value of the array that 
//| satisfied conditions
//+------------------------------------------------------------------+
int ArrayMaximumConditional(double& _arr[], 
                            const bool _greater_filter_active = false, const double _greater_value = 0, const ENUM_COMPARE_TYPE _greater_compare_mode = COMPARE_TYPE_GT,
                            const bool _less_filter_active = false, const double _less_value = 0,  const ENUM_COMPARE_TYPE _less_compare_mode = COMPARE_TYPE_LT,
                            const int _start=0, const int _count=WHOLE_ARRAY) {
                            
  if (!_greater_filter_active && !_less_filter_active) return ArrayMaximum(_arr, _start, _count);
                           
  double curr_max_value = 0;                           
  int curr_max_idx = -1;
  int count = (_count == WHOLE_ARRAY) ? ArraySize(_arr) : MathMin(_count, ArraySize(_arr));
  for (int i=_start; i<count; i++) {
    if (_greater_filter_active && !(CompareDoubleExtraMode(_arr[i], _greater_value, _greater_compare_mode))) continue;
    if (_less_filter_active && !(CompareDoubleExtraMode(_arr[i], _less_value, _less_compare_mode))) continue;
    
    if (curr_max_idx < 0 || _arr[i] > curr_max_value) {
      curr_max_value = _arr[i];
      curr_max_idx = i;
    }
  }
  
  return curr_max_idx;
}

//+------------------------------------------------------------------+
//| Returns index of min value of the array that 
//| satisfied conditions
//+------------------------------------------------------------------+
int ArrayMinimumConditional(double& _arr[], 
                            const bool _greater_filter_active = false, const double _greater_value = 0, const ENUM_COMPARE_TYPE _greater_compare_mode = COMPARE_TYPE_GT,
                            const bool _less_filter_active = false, const double _less_value = 0,  const ENUM_COMPARE_TYPE _less_compare_mode = COMPARE_TYPE_LT,
                            const int _start=0, const int _count=WHOLE_ARRAY) {
                            
  if (!_greater_filter_active && !_less_filter_active) return ArrayMinimum(_arr, _start, _count);
                           
  double curr_min_value = 0;                           
  int curr_min_idx = -1;
  int count = (_count == WHOLE_ARRAY) ? ArraySize(_arr) : MathMin(_count, ArraySize(_arr));
  for (int i=_start; i<count; i++) {
    if (_greater_filter_active && !(CompareDoubleExtraMode(_arr[i], _greater_value, _greater_compare_mode))) continue;
    if (_less_filter_active && !(CompareDoubleExtraMode(_arr[i], _less_value, _less_compare_mode))) continue;
    
    if (curr_min_idx < 0 || _arr[i] < curr_min_value) {
      curr_min_value = _arr[i];
      curr_min_idx = i;
    }
  }
  
  return curr_min_idx;
}

//+------------------------------------------------------------------+
//| Returns index of first value of the array that 
//| satisfied conditions
//+------------------------------------------------------------------+
int ArrayFindFirstConditional(double& _arr[], 
                              const bool _greater_filter_active = false, const double _greater_value = 0, const ENUM_COMPARE_TYPE _greater_compare_mode = COMPARE_TYPE_GT,
                              const bool _less_filter_active = false, const double _less_value = 0,  const ENUM_COMPARE_TYPE _less_compare_mode = COMPARE_TYPE_LT,
                              const int _start=0, const int _count=WHOLE_ARRAY) {
                            
  int count = (_count == WHOLE_ARRAY) ? ArraySize(_arr) : MathMin(_count, ArraySize(_arr));
  for (int i=_start; i<count; i++) {
    if (_greater_filter_active && !(CompareDoubleExtraMode(_arr[i], _greater_value, _greater_compare_mode))) continue;
    if (_less_filter_active && !(CompareDoubleExtraMode(_arr[i], _less_value, _less_compare_mode))) continue;
    
    return i;
  }

  return -1;  
}

//+------------------------------------------------------------------+
//| Returns arrays if indecies of values of the array that 
//| satisfied conditions
//+------------------------------------------------------------------+
int ArrayFindConditional(int& _res_arr[],
                         double& _src_arr[], 
                         const bool _greater_filter_active = false, const double _greater_value = 0, const ENUM_COMPARE_TYPE _greater_compare_mode = COMPARE_TYPE_GT,
                         const bool _less_filter_active = false, const double _less_value = 0,  const ENUM_COMPARE_TYPE _less_compare_mode = COMPARE_TYPE_LT,
                         const int _start=0, const int _count=WHOLE_ARRAY) {
                         
  ArrayResize(_res_arr, 0);
        
  int idx = ArrayFindFirstConditional(_src_arr, 
                                      _greater_filter_active, _greater_value, _greater_compare_mode,
                                      _less_filter_active, _less_value, _less_compare_mode,
                                      _start, _count);
  while (idx >= 0) {
    ArrayResize(_res_arr, ArraySize(_res_arr) + 1);
    _res_arr[ArraySize(_res_arr) - 1] = idx;
    
    idx = ArrayFindFirstConditional(_src_arr, 
                                    _greater_filter_active, _greater_value, _greater_compare_mode,
                                    _less_filter_active, _less_value, _less_compare_mode,
                                    idx+1, _count);
  }          
        
  return ArraySize(_res_arr);  
}

//+------------------------------------------------------------------+
//| Returns mean of _arr
//+------------------------------------------------------------------+
double ArrayMean(double& _arr[]) {
  double Sum()
  for(int i=0;i<ArraySize(_arr);i++)    {
         
    }
}
