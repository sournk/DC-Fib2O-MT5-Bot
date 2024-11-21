//+------------------------------------------------------------------+
//|                                                    CDKString.mqh |
//|                                                  Denis Kislitsyn |
//|                                               http:/kislitsyn.me |
//+------------------------------------------------------------------+

#include <Strings\String.mqh> 
#include <Arrays\ArrayString.mqh>

class CDKString : public CString {
public:
  int                     CDKString::Split(string _sep, CArrayString& _arr);
};

int CDKString::Split(string _sep, CArrayString& _arr) {
  int chunk_cnt = 0;
  string src = m_string;
  int idx = StringFind(src, _sep);
  while(idx >= 0) {
    string chunk = StringSubstr(src, 0, idx);
    if (chunk != "") {
      _arr.Add(chunk);
      chunk_cnt++;
    }
    
    src = StringSubstr(src, idx+StringLen(_sep));
    idx = StringFind(src, _sep);
  }
  
  if(src != "") {
    _arr.Add(src);
    chunk_cnt++;
  }
  
  return chunk_cnt++;
}
