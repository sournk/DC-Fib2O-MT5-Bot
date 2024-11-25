# DC-Fib2O-MT5-Bot
The Expert Adviser for MetaTrader 5. The trading strategy of the bot is Fibo retracement after BOS or CHoCH using two pending orders.

* Created by Denis Kislitsyn | denis@kislitsyn.me | [kislitsyn.me](https://kislitsyn.me)
* https://www.mql5.com/en/job/228450
* Version: 1.03

!!! error WARNING
    1. The bot's trading strategy was defined by the customer, and the author is not responsible for it.
    2. The bot does not guarantee a profit.
    3. The bot does not guarantee 100% deposit protection.
    4. The bot can hold positions from a few minutes to several weeks.
    5. Use the bot at your own risk.

![FIB_MD](img/UM002.%20FIB_MD.gif)

## What's New

```
- 1.03: [+] New 'FIB_MD'=SWING&SWING added. It's also changes Fibo dir using last swing updated.
- 1.02: [+] 'FIB_MD' adds Fibo's two modes: between BOS&CHoCH levels or between BOS&SWING levels.
- 1.01: [*] Removed tester property for MQ VPS.
```

## Installation
1. Make sure that your MetaTrader 5 terminal is updated to the latest version. To test Expert Advisors, it is recommended to update the terminal to the latest beta version. To do this, run the update from the main menu `Help->Check For Updates->Latest Beta Version`. The Expert Advisor may not run on previous versions because it is compiled for the latest version of the terminal. In this case you will see messages on the `Journal` tab about it.
2. Copy the bot executable file `*.ex5` to the terminal data directory `MQL5\Experts`.
4. Install free [*Structure Blocks*](https://www.mql5.com/en/market/product/115943?source=External) indicator from MQL5 market. Sign in your MQL Community account inside your terminal. Enter `Structure Blocks` in search field of the terminal. Press `Install` button.
5. Open the pair chart.
6. Move the Expert Advisor from the Navigator window to the chart.
7. Check `Allow Auto Trading` in the bot settings.
8. Enable the auto trading mode in the terminal by clicking the `Algo Trading` button on the main toolbar.
9. Load the set of settings by clicking the `Load` button and selecting the set-file.

## Requirements

Complete requirements are posted on the [task page](https://www.mql5.com/en/job/228450).

- [x] **The bot will have two entries.** 
    - Use inputs `FIB_STP_EPL`, `FIB_LIM_EPL` to set Entry point of each order. Other inputs set SL and TP.
    - The bot uses two different Fibo object:
        1. Fibo 1 for STOP orders.
        2. Fibi 2 for LIMIT orders.
- [x] **When price breaks structure, a high/low structure, the bot starts plotting the fib for a possible 76.4 buy/sell stop**
    - The bot uses `Structure Blocks` indicator to detect BOS and CHoCH using classic Smart Money way.
- [x] **76.4 order will be a buy/sell stop with SL at the 23.6 area and tp of 1:1 ratio**
    - Use `ENT_STP_RR` input to set another RR for STOP order.
- [x] **Second position will be a  limit order at the 100.00 area... In an uptrend, price breaks a high, the aim of this entry is to catch reversals after there is a run on liquidity..**
    - Use `FIB_LIM_EPL` input to set Entry Point for LIMIT order.
- [x] **The SL of this position is  going to be the equivalent of placing your 76.4 at the high/low** (Ask questions on this SL part, I will send screenshots)
    - The bot places Fibo2 on the chart so that level `FIB_LIM_EPL` matches level 100.0 of Fibo1.
- [x] **The SL of this second position will be the TP of the first position**
    - Use `FIB_LIM_SLL` input to set another SL level.
- [x] **The second position will have TP set at 1:5**
    - Use `ENT_LIM_RR1` input to set another RR.
- [x] **When the first position hit SL, the second position will move SL into a 1:1**
    - The bot changes TP for LIMIT pos using `ENT_LIM_RR2` when STOP pos reaches SL. If the new TP is lower than the current price, the position simply closes on the market with the current profit.
    - The bot deletes LIMIT order when STOP pos reaches SL and LIMIT order is still open *(WhatsApp chat: Once a the first order hit SL without triggering the second order, the second order becomes invalidated)*
- [x] **A prototype must be ready within 14 day's**
- [x] **Bot must work across synthetic indices and forex pairs**
- [x] **It must work across multiple timeframe**
    - ==The bot detect BOS/CHoCH and built Fibo only using `FIB_TF` timeframe on every new bar appears.==
    - You can change TF on your chart to have a best view, but detection BOS/CHoCH is always made on `FIB_TF` timeframe. 

!!! warning WARNING
    Every time you change TF on the chart bot deletes orders and builds new Fibo object again. All open pos are ignored.
    **So it's not recommended to change TF while bot is running.**
    
- [x] **It must be able to be turned off during rollover periods in forex**
    - You can stop the bot any time.
- [x] **Bot must have risk management settings**
    - Use `ENT_MMT` and `ENT_MMV` inputs.
- [x] **The presence of an ongoing trade should not prevent the bot from following the rules and placing new trades whenever the conditions are met**
    -    The bot operates only orders and positions with Magic ID set in `MSC_MGC` input. Ant other orders and positions are ignored.

## Bot's inputs

![Layout](img/UM001.%20Layout.png)

#### 1. FIBO (FIB)
- [x] <a name="FIB_MD"></a> `FIB_MD`: Mode:
    - [x] `Fibo between BOS & CHoCH`
    - [x] `Fibo between BOS & SWING`
    - [x] `Fibo between SWING & SWING`
- [x] `FIB_TF`: Timeframe to detect BOS/CHoCH and Fibo
- [x] `FIB_STP_EPL`: STOP order EP Level
- [x] `FIB_STP_SLL`: STOP order SL Level
- [x] `FIB_LIM_EPL`: LIMIT order EP Level
- [x] `FIB_LIM_SLL`: LIMIT order SL Level
- [x] `FIB_COL_BUY`: Color Buy
- [x] `FIB_COL_SELL`: Color Sell

#### 2. ENTRY (ENT)
- [x] `ENT_STP_RR`: STOP Order TP RR
- [x] `ENT_LIM_RR1`: LIMIT Order TP RR
- [x] `ENT_LIM_RR2`: LIMIT Order TP RR after STOP order SL
- [x] `ENT_MMT`: Money Management Type:
    - `Fixed lot`: Lot size is fixed with value from `ENT_MMV` input
    - `Fixed max loss`: The bot calculates lot size of every order and position to make max loss in account currency set in `ENT_MMV` input
    - `% of Balance`: The bot calculates lot size of every order and position to make lot size cost equal % of your Balance in account currency
    - `% of Equity`: Same as Balance but base is Equity
    - `% of Free Margin`: Same as Balance but base is Free Margin
    - `Auto (limit % of risk)`: The bot calculates lot size of every order and position to make max loss not more than % of your Balance in account currency
- [x] `ENT_MMV`: Money Management Value

#### 3. MISCELLANEOUS (MSC)
- [x] `MSC_MGC`: Expert Adviser ID - Magic
- [x] `MSC_EGP`: Expert Adviser Global Prefix
- [x] `MSC_LOG_LL`: Log Level