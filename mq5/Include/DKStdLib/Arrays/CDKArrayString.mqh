//+------------------------------------------------------------------+
//|                                               CDKArrayString.mqh |
//|                                                  Denis Kislitsyn |
//|                                               http:/kislitsyn.me |
//+------------------------------------------------------------------+

#include <Arrays\ArrayString.mqh>

class CDKArrayString : public CArrayString {
public:
  int                     CDKArrayString::SaveToArray(string& _arr[]);
};

int CDKArrayString::SaveToArray(string& _arr[]){
  int size = Total();
  ArrayResize(_arr, size);
  for(int i=0;i<size;i++)
    _arr[i] = At(i);
    
  return size;
}
