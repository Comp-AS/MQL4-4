//+------------------------------------------------------------------+
//|                                                      Krikor2.mq4 |
//|                                                           Krikor |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Krikor"
#property version   "2.13"
#property strict

//Nog te doen:

// EUR/CAD 23 januari, min/max teller slaat op hol, ook op EUR/JPY
// NZD/USD 23 januari, Grid trigger wordt overgeslagen
// EUR/AUS 23 januari, na 6 keer vermenigvuldigen slaat de min/max teller op hol. Slaat Grid trigger over en loopt maar door
// CAD/JPY 23 jan, ook iets vreemds met een verdwijnende 0.02 pips sell rond 14.30u

//Knop maken om alle trades handmatig te sluiten en de boel te resetten
//Knop maken om de EA alle trades te laten sluiten nadat de trades afgerond zijn.
   
 
//+------------------------------------------------------------------+
//| Variables sectie
//+------------------------------------------------------------------+
//Variabelen voor gebruiker
int MagischNummer                =1;
extern string Financieel         ="Financiële opties";
extern bool MoneyManager         =true;         //Use MoneyManager
extern double RiskPercent        =1;            //Risk percentage
extern double FixedLots          =0.1;          //Fixed Lotsize
extern double MaxDrawdownPercent =25;           //Max drawdown percentage
extern int MaxTrades             =6;            //Max number of trades 
extern int CashIn                =4;            //Cashen als trade goed gaat
extern int period                =1;            //Periode voor trade entry

extern string Grid_settings      ="Grid settings section";
extern double GridPosMultiplier  =0.8;          //Grid positive multiplier
extern double GridNegMultiplier  =2;            //Grid negative multiplier
extern double MaxSpread          =0;            //Hier nog iets mee doen!
extern double MinProfitValue     =0.25;         //Minimum profit value
extern double MaxProfitValue     =0.60;         //Max profit value
extern double GridDivider        =7;            //Bij Grid optellen om te delen
extern double GridMultiplier     =3;            //Vermenigvuldigingsfactor

extern bool UseHedge             =false;        //Use hedge function?

extern string RSI                ="Relative Strength Index";
extern int RSIperiod             =7;            //Periode van de RSI

extern string ADX                ="Average Directional Movement Index";
extern int ADXperiod             =14;           //ADX period

extern string Menu_settings      ="Settings voor het menu";
extern int Font                  =8;            //Tekstgrootte
extern color MenuColor           =clrMagenta;   //Kleur van het menu


//Trading public variables
int i=0;                               //Itereren
string sp=" || ";                      //Tussenstuk voor tekst
double pips;                           //Placeholder voor pips
int Magic;                             //Magic no. placeholder
bool Start;                            //De start
bool Hedge;                            //Hedge actief
double TotalProfit;                    //Total profit tot nu toe verdient met deze EA op deze kaart
double Lots;                           //Lots-variabele gebruikt voor MM
double MaxDD=0;                        //Max drawdown
double GridValue;                      //GridValue
string FirstOrderType;                 //Type van de first order
double FirstOrderPrice;                //Prijs van de first order


//ZigZag Larsen variabelen
extern string ZigZagLars ="ZigZag Larsen variabelen";
extern int ZigZagLarsenPeriode =15;
extern int NoiseLevel    = 30;
extern int SwitchPercent = 30;
extern int Mode          = 0;
extern int OncePerCandle = 1;
bool alertsOn        = true;
bool alertsOnCurrent = false;
bool alertsMessage   = true;
bool alertsSound     = true;
bool alertsEmail     = false;
int MaxBars              = 500;
extern int ArrowOffset   = 15;
double Porog1[500];
double Porog2[500];
double Porog3[500];
bool mds = FALSE;
double LevRT;
double mdt;
double Const1 = 0.0;
double Const2 = 0.0;
double Const3 = 0.0;
double Const4 = 0.0;
double Const5 = 0.0;
int rf1 = 0;
int rf2 = 0;
int rf3 = 0;
int mda = 0;
int mdk = -1;
int mdl = 0;
int mdn = 0;
int mdrs = 0;

//ZigAndZag variabelen
extern string ZigAndZagVariables ="ZigandZag variabelen";
extern int ZigAndZagPeriode=15;
extern int KeelOver=55; //Setting for M15 and H1
extern int Slalom=17;   //Setting for M15 and H1
extern int ZigAndZagMaxBars=240; //MaxBars
double KeelOverZigAndZagSECTION[240];
double KeelOverZagBuffer[240];
double SlalomZigBuffer[240];
double SlalomZagBuffer[240];
double LimitOrdersBuffer[240];
double BuyOrdersBuffer[240];
double SellOrdersBuffer[240];
int    shift,back,CountBar,Backstep=3;
int    LastSlalomZagPos,LastSlalomZigPos,LastKeelOverZagPos,LastKeelOverZigPos;
double Something,LimitPoints,Navel;
double CurKeelOverZig,CurKeelOverZag,CurSlalomZig,CurSlalomZag;
double LastSlalomZag,LastSlalomZig,LastKeelOverZag,LastKeelOverZig;
bool   TrendUp,SetBuyOrder,SetLimitOrder,SetSellOrder,Second=false;
string LastZigOrZag="None";

string ZigZagLarsen;
string ZigAndZag;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   //Magisch no. genereren
   Magic=GenerateMagicNumber();
   
   //Definiëren van wat een pip is bij dit Symbol()
   pips=Point;
   if(Digits==3 || Digits==5) pips*=10;
      
   //MoneyManager
   if(MoneyManager){
      Lots=NormalizeDouble((AccountEquity()/MarketInfo(Symbol(),MODE_LOTSIZE))*RiskPercent,2);
      if(Lots<MarketInfo(Symbol(),MODE_MINLOT))Lots=MarketInfo(Symbol(),MODE_MINLOT);
      if(Lots>MarketInfo(Symbol(),MODE_MAXLOT))Lots=MarketInfo(Symbol(),MODE_MAXLOT);
   }
   else{Lots=FixedLots;}
  
   
   return(INIT_SUCCEEDED);
  
  
  //ZigZag Larsen indicator
   mdrs = 0;
   if (Mode == 0) {
      Const1 = iClose(Symbol(),ZigZagLarsenPeriode,0) - NoiseLevel / 2 * Point;
      Const2 = iClose(Symbol(),ZigZagLarsenPeriode,0) + NoiseLevel / 2 * Point;
   } else {
      Const1 = iOpen(Symbol(),ZigZagLarsenPeriode,0) - NoiseLevel / 2 * Point;
      Const2 = iOpen(Symbol(),ZigZagLarsenPeriode,0) + NoiseLevel / 2 * Point;
   }
   Const5 = iOpen(Symbol(),ZigZagLarsenPeriode,0);
   Const2 = Const1;
   Const3 = Const1;
   Const4 = Const1;
   LevRT = Const1;
   mdt = LevRT;
   return (0);
  
  
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Comment("");
  
   ObjectDelete("Version");
   ObjectDelete("ADXplusDI");
   ObjectDelete("ADXminDI");
   ObjectDelete("ADXmain");
   ObjectDelete("RSImainM5");
   ObjectDelete("H1MA");
   ObjectDelete("CurrentProfit");
   ObjectDelete("MinProfit");
   ObjectDelete("MaxProfit");
   ObjectDelete("TotalProfit");
   ObjectDelete("MaxDD");
   ObjectDelete("OpenOrders");      
   ObjectDelete("GridValue");
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   
   RefreshRates();
   //+------------------------------------------------------------------+
   //Moving average indicator
   //+------------------------------------------------------------------+
   //MA indicatoren   
   double H1MA20 = iMA(Symbol(),PERIOD_D1,20,0,MODE_SMA,PRICE_CLOSE,1);
   double H1MA50 = iMA(Symbol(),PERIOD_D1,50,0,MODE_SMA,PRICE_CLOSE,1);
   
   string MAcomp;
   if(H1MA20<H1MA50){MAcomp=" < ";}
   if(H1MA20>H1MA50){MAcomp=" > ";}
           

   //+------------------------------------------------------------------+
   // Relative Strength Index
   //+------------------------------------------------------------------+
   double RSImainM5=iRSI(Symbol(),PERIOD_M5,RSIperiod,PRICE_CLOSE,0);
          
   //+------------------------------------------------------------------+
   // Average Directional Movement Index
   //+------------------------------------------------------------------+
      
   double ADXmain=iADX(Symbol(),period,ADXperiod,PRICE_CLOSE,MODE_MAIN,1);
   double ADXplusDI=iADX(Symbol(),period,ADXperiod,PRICE_CLOSE,MODE_PLUSDI,1); 
   double ADXminDI=iADX(Symbol(),period,ADXperiod,PRICE_CLOSE,MODE_MINUSDI,1);
   
     
   //+------------------------------------------------------------------+
   // Volumes indicator
   //+------------------------------------------------------------------+
   
   //Volume van laatste 500 bars in M5   
   long Volumes[500];
   long totVolume;
   long gemVolume=0;
   int copy=CopyTickVolume(Symbol(),PERIOD_M5,0,500,Volumes);
   for(int v=0;v<500;v++)  {
      totVolume+=Volumes[v];
      gemVolume=totVolume/500;
   }
   
   //Tijdfunctie
   long time0=iTime(Symbol(),PERIOD_M5,0);   
   long timeNu=TimeCurrent();
   
   //+------------------------------------------------------------------+
   // ZigZag Larsen indicator
   //+------------------------------------------------------------------+
   
   //if(!new_candle())
      
   int bars1=iBars(Symbol(),ZigZagLarsenPeriode);
   if(bars1>MaxBars){bars1=MaxBars;}
   int bars2 = bars1;
   mdk=bars2;
   mda=0;
   Porog1[1] = Const5;
   int brshift = bars2-1;
   
   if(Mode==0){Porog1[brshift]=iClose(Symbol(),ZigZagLarsenPeriode,brshift);}
   else{Porog1[brshift]=iOpen(Symbol(),ZigZagLarsenPeriode,brshift);}
   while (brshift >= 0) {
      GetMoving(brshift);
      if (rf3==TRUE) {
         if (rf1 == 1) {
            Porog1[brshift] = Const3;
            Porog3[brshift] = Const3 - ArrowOffset * Point;
            Porog2[brshift] = 0.0;
            if (brshift == 0) Const5 = Const3;
         }
         if (rf1 == -1) {
            Porog1[brshift] = Const4;
            Porog2[brshift] = Const4 + ArrowOffset * Point;
            Porog3[brshift] = 0.0;
            if (brshift == 0) Const5 = Const4;
         }
         rf3 = FALSE;
      } else {
         if (brshift == 0) {
            if (rf1 == 1) Porog1[0] = Const2;
            if (rf1 == -1) Porog1[0] = Const1;
         } else {
            Porog1[brshift] = 0.0;
            Porog2[brshift] = 0.0;
            Porog3[brshift] = 0.0;
            if (brshift == 0) Const5 = 0.0;
         }
      }
      brshift--;
   }
   
   //+------------------------------------------------------------------+
   // ZigAndZag indicator
   //+------------------------------------------------------------------+
   
   CountBar=ZigAndZagMaxBars-KeelOver;
   LimitPoints=Ask-Bid;
   if(CountBar<=3*KeelOver){Print("Indicator ZigAndZag werkt niet");}
   if(KeelOver<=2*Slalom){Print("Indicator ZigAndZag werkt niet");}
   

   for(shift=ZigAndZagMaxBars-1; shift>240-KeelOver; shift--){   
      SlalomZagBuffer[shift]=0.0;
      SlalomZigBuffer[shift]=0.0;
      KeelOverZagBuffer[shift]=0.0;
      KeelOverZigAndZagSECTION[shift]=0.0;
      LimitOrdersBuffer[shift]=0.0;
      BuyOrdersBuffer[shift]=0.0;
      SellOrdersBuffer[shift]=0.0;
   }
   
   The_First_Crusade();
   
   LastSlalomZag=-1; LastSlalomZagPos=-1;
   LastSlalomZig=-1;  LastSlalomZigPos=-1;
   LastKeelOverZag=-1; LastKeelOverZagPos=-1;
   LastKeelOverZig=-1;  LastKeelOverZigPos=-1;
   
   The_Second_Crusade();
   
   LastSlalomZag=-1; LastSlalomZagPos=-1;
   LastSlalomZig=-1;  LastSlalomZigPos=-1;
   LastZigOrZag="None";
   The_Third_Crusade();
   Shift_Zerro();
   
   //+------------------------------------------------------------------+
   // Average Daily Range indicator voor Grid setting
   //+------------------------------------------------------------------+
      
   double R1=0,R5=0,R10=0,R20=0,RAmax1=0,RAmax2=0,RAmax=0;
   
   
   R1 =  iHigh(Symbol(),PERIOD_D1,1)-iLow(NULL,PERIOD_D1,1);
   for(i=1;i<=5;i++){    R5+=iHigh(Symbol(),PERIOD_D1,i)-iLow(NULL,PERIOD_D1,i);}
   for(i=1;i<=10;i++){   R10+=iHigh(Symbol(),PERIOD_D1,i)-iLow(NULL,PERIOD_D1,i);}
   for(i=1;i<=20;i++){   R20+=iHigh(Symbol(),PERIOD_D1,i)-iLow(NULL,PERIOD_D1,i);}

   R5    = NormalizeDouble(R5/5,Digits);
   R10   = NormalizeDouble(R10/10,Digits);
   R20   = NormalizeDouble(R20/20,Digits);
   RAmax1 = NormalizeDouble(MathMax(R1,R5),Digits); 
   RAmax2 = NormalizeDouble(MathMax(R10,R20),Digits);
   RAmax = NormalizeDouble(MathMax(RAmax1, RAmax2),Digits);

   GridValue=NormalizeDouble(RAmax/(MaxTrades+GridDivider),Digits); 
   GridValue+=NormalizeDouble(NumberOfTrades()*GridMultiplier*pips,Digits);
   
   //+------------------------------------------------------------------+
   // Wanneer kopen/verkopen
   //+------------------------------------------------------------------+
   
   if(NumberOfTrades()==0){
      Start=true;
   }
   
   if (Porog2[0]!=0 || Porog3[0]!=0){
         if(Porog2[0]!=0){ZigZagLarsen="Sell";}
         if(Porog3[0]!=0){ZigZagLarsen="Buy";}
   }            
   
   
   if (SellOrdersBuffer[0]!=0 || BuyOrdersBuffer[0]!=0){
      if(SellOrdersBuffer[0]!=0){ZigAndZag="Sell";}
      if(BuyOrdersBuffer[0]!=0){ZigAndZag="Buy";}
   }
   
         
   if(Start){
      if(ADXplusDI>25 && ADXmain>25 && RSImainM5<85){
         if((time0+75)<timeNu){
            if(Volume[0]>(1*gemVolume)){
               if(H1MA20>H1MA50){
                   if(Porog3[0]!=0 || BuyOrdersBuffer[0]!=0){
                     TradeEntry(0,Lots,IntegerToString(NumberOfTrades()));
                     Start=false; FirstOrderPrice=Ask; FirstOrderType="OP_BUY";
                  }
               }
            }
         }
      }
      
      if(ADXminDI>25  && ADXmain>25 && RSImainM5>15){
         if((time0+75)<timeNu)  {
            if(Volume[0]>(1*gemVolume)) {
               if(H1MA20<H1MA50){
                  if(Porog2[0]!=0 || SellOrdersBuffer[0]!=0){
                     TradeEntry(1,Lots,IntegerToString(NumberOfTrades()));
                     Start=false; FirstOrderPrice=Bid; FirstOrderType="OP_SELL";
                  }
               }
            }
         }
      }   
   }
   
   

   
   //+------------------------------------------------------------------+
   // Grid sectie
   //+------------------------------------------------------------------+
   
   if(!Start){
      if(FirstOrderType=="OP_BUY"){
         if(Ask>=FirstOrderPrice+(NumberOfTrades()*GridValue)){
            //CashIn
            if(NumberOfTrades()==CashIn && CurrentProfit()>TargetProfit()*MaxProfitValue){TradeExit();}
            
            //If not, continue to CashIn
            else{
               TradeEntry(0,GLots(GridPosMultiplier),IntegerToString(NumberOfTrades()));
            }
         }
         if(Ask<=FirstOrderPrice-(NumberOfTrades()*GridValue)){
            if(NumberOfTrades()<MaxTrades-1){
               TradeEntry(0,GLots(GridNegMultiplier),IntegerToString(NumberOfTrades()));
            }
            if(UseHedge){
            if(NumberOfTrades()==MaxTrades-1 && Ask<=((FirstOrderPrice-(NumberOfTrades())*GridValue))){
               Hedge=true;
               TradeEntry(0,NormalizeDouble(GLots(GridNegMultiplier)*4,2),IntegerToString(NumberOfTrades()));
            }
            }
         }
      }
      if(FirstOrderType=="OP_SELL"){
         if(Bid<=FirstOrderPrice-(NumberOfTrades()*GridValue)){
            
            //CashIn
            if(NumberOfTrades()==CashIn && CurrentProfit()>TargetProfit()*MaxProfitValue){TradeExit();}
            
            //If not, continue to CashIn
            else{
               TradeEntry(1,GLots(GridPosMultiplier),IntegerToString(NumberOfTrades()));
            }
            }
         if(Bid>=FirstOrderPrice+(NumberOfTrades()*GridValue)){
            if(NumberOfTrades()<MaxTrades-1){
               TradeEntry(1,GLots(GridNegMultiplier),IntegerToString(NumberOfTrades()));
            }
            if(UseHedge){
            if(NumberOfTrades()==MaxTrades-1 && Bid>=((FirstOrderPrice+(NumberOfTrades())*GridValue))){
               Hedge=true;
               TradeEntry(1,NormalizeDouble(GLots(GridNegMultiplier)*4,2),IntegerToString(NumberOfTrades()));   
            }
            }
         }   
      }
   } 
    
   //Normal cashen 
   if(NumberOfTrades()>=3 && CurrentProfit()>MinProfitValue*TargetProfit() && CurrentProfit()<TargetProfit()*MaxProfitValue){
   TradeExit();}
   
   //Hedge cash
   if(Hedge){
      if(FirstOrderType=="OP_BUY"){
         if(Ask>=FirstOrderPrice-((MaxTrades-2)*GridValue)){
            TradeExit(); Hedge=false;
         }
      }
      if(FirstOrderType=="OP_SELL"){
         if(Bid<=FirstOrderPrice+((MaxTrades-2)*GridValue)){
            TradeExit(); Hedge=false;
         }
      }
   }
   
   //Accountbalance exit
   double DrawDown=0;
   if(CurrentProfit()<0){DrawDown=((CurrentProfit()*-1)/AccountBalance())*100;
      if(MaxDD<DrawDown){MaxDD=DrawDown;}
      if(DrawDown>MaxDrawdownPercent){TradeExit();}
   }

  
   //+------------------------------------------------------------------+
   // Comment sectie 
   //+------------------------------------------------------------------+  
    
   int x_afstand=10;
   int y_afstand=12;
      
   ObjectCreate("Version",OBJ_LABEL,0,0,0,0,0);
   ObjectCreate("ADXplusDI",OBJ_LABEL,0,0,0,0,0);
   ObjectCreate("ADXminDI",OBJ_LABEL,0,0,0,0,0);
   ObjectCreate("ADXmain",OBJ_LABEL,0,0,0,0,0);
   ObjectCreate("RSImainM5",OBJ_LABEL,0,0,0,0,0);
   ObjectCreate("H1MA",OBJ_LABEL,0,0,0,0,0);
   ObjectCreate("CurrentProfit",OBJ_LABEL,0,0,0,0,0);
   ObjectCreate("MinProfit",OBJ_LABEL,0,0,0,0,0);
   ObjectCreate("MaxProfit",OBJ_LABEL,0,0,0,0,0);
   ObjectCreate("TotalProfit",OBJ_LABEL,0,0,0,0,0);
   ObjectCreate("MaxDD",OBJ_LABEL,0,0,0,0,0);
   ObjectCreate("OpenOrders",OBJ_LABEL,0,0,0,0,0);
   ObjectCreate("GridValue",OBJ_LABEL,0,0,0,0,0);
   
   ObjectSetText("Version", "Version: 2.13", Font, "Arial",MenuColor);
   ObjectSet("Version",OBJPROP_XDISTANCE,x_afstand);     
   ObjectSet("Version",OBJPROP_YDISTANCE,y_afstand+5);
   ObjectSet("Version",OBJPROP_CORNER,1);
   
   ObjectSetText("ADXplusDI", "ADXplusDI: " + DoubleToStr(ADXplusDI,2), Font, "Arial",MenuColor);
   ObjectSet("ADXplusDI",OBJPROP_XDISTANCE,x_afstand);     
   ObjectSet("ADXplusDI",OBJPROP_YDISTANCE,y_afstand+20);
   ObjectSet("ADXplusDI",OBJPROP_CORNER,1);
   
   ObjectSetText("ADXminDI", "ADXminDI: " + DoubleToStr(ADXplusDI,2), Font, "Arial",MenuColor);
   ObjectSet("ADXminDI",OBJPROP_XDISTANCE,x_afstand);     
   ObjectSet("ADXminDI",OBJPROP_YDISTANCE,y_afstand+35);
   ObjectSet("ADXminDI",OBJPROP_CORNER,1);
   
   ObjectSetText("ADXmain","ADXmain: " + DoubleToStr(ADXmain,2), Font, "Arial",MenuColor);
   ObjectSet("ADXmain",OBJPROP_XDISTANCE,x_afstand);     
   ObjectSet("ADXmain",OBJPROP_YDISTANCE,y_afstand+50);
   ObjectSet("ADXmain",OBJPROP_CORNER,1);
   
   ObjectSetText("RSImainM5", "RSImainM5: " + DoubleToStr(RSImainM5,2), Font, "Arial",MenuColor);
   ObjectSet("RSImainM5",OBJPROP_XDISTANCE,x_afstand);     
   ObjectSet("RSImainM5",OBJPROP_YDISTANCE,y_afstand+65);
   ObjectSet("RSImainM5",OBJPROP_CORNER,1);
   
   ObjectSetText("H1MA", "H1MA: " + DoubleToString(H1MA20,Digits) + MAcomp + DoubleToString(H1MA50,Digits), Font, "Arial",MenuColor);
   ObjectSet("H1MA",OBJPROP_XDISTANCE,x_afstand);     
   ObjectSet("H1MA",OBJPROP_YDISTANCE,y_afstand+80);
   ObjectSet("H1MA",OBJPROP_CORNER,1);
   
   ObjectSetText("CurrentProfit", "CurrentProfit: " + DoubleToString(CurrentProfit(),2), Font, "Arial",MenuColor);
   ObjectSet("CurrentProfit",OBJPROP_XDISTANCE,x_afstand);     
   ObjectSet("CurrentProfit",OBJPROP_YDISTANCE,y_afstand+95);
   ObjectSet("CurrentProfit",OBJPROP_CORNER,1);

   ObjectSetText("MinProfit", "MinProfit: " +  DoubleToStr(MinProfitValue*TargetProfit(),2), Font, "Arial",MenuColor);
   ObjectSet("MinProfit",OBJPROP_XDISTANCE,x_afstand);     
   ObjectSet("MinProfit",OBJPROP_YDISTANCE,y_afstand+110);
   ObjectSet("MinProfit",OBJPROP_CORNER,1);

   ObjectSetText("MaxProfit", "MaxProfit: " +  DoubleToStr(MaxProfitValue*TargetProfit(),2), Font, "Arial",MenuColor);
   ObjectSet("MaxProfit",OBJPROP_XDISTANCE,x_afstand);     
   ObjectSet("MaxProfit",OBJPROP_YDISTANCE,y_afstand+125);
   ObjectSet("MaxProfit",OBJPROP_CORNER,1);

   ObjectSetText("TotalProfit", "TotalProfit: " +  DoubleToStr(TotalProfit,2), Font, "Arial",MenuColor);
   ObjectSet("TotalProfit",OBJPROP_XDISTANCE,x_afstand);     
   ObjectSet("TotalProfit",OBJPROP_YDISTANCE,y_afstand+140);
   ObjectSet("TotalProfit",OBJPROP_CORNER,1);
   
   ObjectSetText("MaxDD", "MaxDD: " +  DoubleToStr(MaxDD,2) + "%", Font, "Arial",MenuColor);
   ObjectSet("MaxDD",OBJPROP_XDISTANCE,x_afstand);     
   ObjectSet("MaxDD",OBJPROP_YDISTANCE,y_afstand+155);
   ObjectSet("MaxDD",OBJPROP_CORNER,1);
               
   ObjectSetText("OpenOrders", "OpenOrders: " + IntegerToString(NumberOfTrades()), Font, "Arial",MenuColor);
   ObjectSet("OpenOrders",OBJPROP_XDISTANCE,x_afstand);     
   ObjectSet("OpenOrders",OBJPROP_YDISTANCE,y_afstand+170);
   ObjectSet("OpenOrders",OBJPROP_CORNER,1); 
   
   ObjectSetText("GridValue", "GridValue: " + DoubleToStr(GridValue,Digits), Font, "Arial",MenuColor);
   ObjectSet("GridValue",OBJPROP_XDISTANCE,x_afstand);     
   ObjectSet("GridValue",OBJPROP_YDISTANCE,y_afstand+185);
   ObjectSet("GridValue",OBJPROP_CORNER,1);
   
}         




//+-----------------------------------------------------------------+
//| GLots
//+-----------------------------------------------------------------+

double GLots(double MultiplicationFactor){

double ReturnWaarde;
   
   ReturnWaarde = NormalizeDouble(Lots*MathPow(MultiplicationFactor,NumberOfTrades()),2);
   
   if(ReturnWaarde<MarketInfo(Symbol(),MODE_MINLOT)){ReturnWaarde=MarketInfo(Symbol(),MODE_MINLOT);}
   if(ReturnWaarde>MarketInfo(Symbol(),MODE_MAXLOT)){ReturnWaarde=MarketInfo(Symbol(),MODE_MAXLOT);}
   
return(ReturnWaarde);
}


//+-----------------------------------------------------------------+
//| Current profit
//+-----------------------------------------------------------------+

double CurrentProfit(){
   
   double ReturnValue=0;
   for(i=OrdersTotal(); i>=0;i--) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)){
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic){
            ReturnValue+=OrderProfit()+OrderSwap()+OrderCommission();   
         }
      }
   }
return(ReturnValue);
}

//+-----------------------------------------------------------------+
//| Count number of trades
//+-----------------------------------------------------------------+
int NumberOfTrades(){   
   //Checken aantal lopende trades
   int CountTrades=0;
   for(i=OrdersTotal(); i>=0;i--) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)){
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic){
            CountTrades++;
       
         }
      }
   }   
return(CountTrades);
}


//+-----------------------------------------------------------------+
//| Trade entry section
//+-----------------------------------------------------------------+

void TradeEntry(int cmd, double volume, string comment){

int ticket=0;
int retry=0; 
int maxretry=10;
int err=0;

   if(cmd==0){
      for(i=1;i>0;i--){
         ticket=OrderSend(Symbol(),OP_BUY,volume,Ask,3,0,0,comment,Magic,0,clrGreen);
         if(ticket>0){i=0;Print("OrderSend OP_BUY - Bid: " + DoubleToStr(Bid,Digits) + sp + "GLots: " + DoubleToStr(volume,Digits) + sp + "Comment: " + comment);}
         else{     
            Print("Error OrderSend OP_BUY: " + DoubleToStr(GetLastError(),0) + sp + "Ask: " + DoubleToStr(Ask,Digits) + sp + "GLots: " + DoubleToStr(volume,Digits) + sp + "Comment: " + comment);
            if(retry==maxretry){Print("Maxretry reached, stopped trying"); break;}
            err=GetLastError();
            switch(err){
               case ERR_SERVER_BUSY:
               case ERR_NO_CONNECTION:
               case ERR_INVALID_PRICE:
               case ERR_OFF_QUOTES:
               case ERR_BROKER_BUSY:
               case ERR_TRADE_CONTEXT_BUSY: 
               case ERR_TRADE_TIMEOUT:
                  i++; retry++;
                  break;
               case ERR_INVALID_TRADE_VOLUME:
                  Print("Invalid Trade volume." + sp + "MODE_LOTSIZE: " + DoubleToStr(MarketInfo(Symbol(), MODE_LOTSIZE),Digits) + sp + 
                        "MODE_MINLOT: " + DoubleToStr(MarketInfo(Symbol(), MODE_MINLOT),Digits) + sp + "MODE_LOTSTEP: " + 
                        DoubleToStr(MarketInfo(Symbol(), MODE_LOTSTEP),Digits) + sp + "MODE_MAXLOT: " + DoubleToStr(MarketInfo(Symbol(), MODE_MAXLOT),Digits));
                  break;
               case ERR_TRADE_DISABLED:
                  Print("Trade is disabled" );
                  break;
            }
         }
      }
   }
   
   if(cmd==1){
      for(i=1;i>0;i--){
         ticket=OrderSend(Symbol(),OP_SELL,volume,Bid,3,0,0,comment,Magic,0,clrRed);
         if(ticket>0){i=0; Print("OrderSend OP_SELL - Bid: " + DoubleToStr(Bid,Digits) + sp + "GLots: " + DoubleToStr(volume,Digits) + sp + "Comment: " + comment);}
         else{     
            Print("Error OrderSend OP_SELL: " + DoubleToStr(GetLastError(),0) + sp + "Bid: " + DoubleToStr(Bid,Digits) + sp + "GLots: " + DoubleToStr(volume,Digits) + sp + "Comment: " + comment);
            if(retry==maxretry){Print("Maxretry reached, stopped trying"); break;}
            err=GetLastError();
            switch(err){
               case ERR_SERVER_BUSY:
               case ERR_NO_CONNECTION:
               case ERR_INVALID_PRICE:
               case ERR_OFF_QUOTES:
               case ERR_BROKER_BUSY:
               case ERR_TRADE_CONTEXT_BUSY: 
               case ERR_TRADE_TIMEOUT:
                  i++; retry++;
                  break;
               case ERR_INVALID_TRADE_VOLUME:
                  Print("Invalid Trade volume." + sp + "MODE_LOTSIZE: " + DoubleToStr(MarketInfo(Symbol(), MODE_LOTSIZE),Digits) + sp + 
                        "MODE_MINLOT: " + DoubleToStr(MarketInfo(Symbol(), MODE_MINLOT),Digits) + sp + "MODE_LOTSTEP: " + 
                        DoubleToStr(MarketInfo(Symbol(), MODE_LOTSTEP),Digits) + sp + "MODE_MAXLOT: " + DoubleToStr(MarketInfo(Symbol(), MODE_MAXLOT),Digits));
                  break;
               case ERR_TRADE_DISABLED:
                  Print("Trade is disabled" );
                  break;
            }
         }
      }
   }
      
      
return;
}

//+-----------------------------------------------------------------+
//| Trade exit section
//+-----------------------------------------------------------------+

void TradeExit(){

bool ticketClose;
     
   for(i=OrdersTotal(); i>=0; i--){
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderMagicNumber()==Magic && OrderSymbol()==Symbol()){
         ticketClose=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrYellow);
         TotalProfit+=OrderProfit()+OrderSwap()+OrderCommission();   
         if(!ticketClose){
            Print("Error OrderClose: " + DoubleToStr(GetLastError(),0));
         }                       
      }
   }
return;
}

//+-----------------------------------------------------------------+
//| Target profit
//+-----------------------------------------------------------------+

double TargetProfit(){

double target=0;
double ReturnValue=0;
double TickValue = MarketInfo(OrderSymbol(),MODE_TICKVALUE);
//double TickSize = MarketInfo(OrderSymbol(),MODE_TICKSIZE);
double LotSize = MarketInfo(OrderSymbol(),MODE_LOTSIZE);
if(MarketInfo(OrderSymbol(),MODE_MARGINCALCMODE)==0){LotSize=LotSize/100000;}

   for(i=OrdersTotal(); i>=0;i--){
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol()==Symbol() && OrderMagicNumber()==Magic){
         
         if(OrderType()==OP_BUY){target=OrderOpenPrice()+GridValue;}
         if(OrderType()==OP_SELL){target=OrderOpenPrice()-GridValue;}
         
         double RiskInPoints=MathAbs((OrderOpenPrice()-target)/pips);
         RiskInPoints*=10;
         double TradeTargetProfit=RiskInPoints*(OrderLots()/LotSize)*TickValue+OrderSwap()+OrderCommission();  
   
         ReturnValue+=TradeTargetProfit;
      }
   }   
return(ReturnValue);
}

//+-----------------------------------------------------------------+
//| Magic Number                                         
//+-----------------------------------------------------------------+
int GenerateMagicNumber()
{  if(MagischNummer>99)return(MagischNummer);
   return(JenkinsHash(IntegerToString(MagischNummer)+"_"+Symbol()+"__"+IntegerToString(Period())));
}

int JenkinsHash(string Input)
{  int MagicNo=0;
   for(i=0;i<StringLen(Input);i++)
   {  MagicNo+=StringGetChar(Input,i);
      MagicNo+=(MagicNo<<10);
      MagicNo^=(MagicNo>>6);
   }
   MagicNo+=(MagicNo<<3);
   MagicNo^=(MagicNo>>11);
   MagicNo+=(MagicNo<<15);
   MagicNo=MathAbs(MagicNo);
   return(MagicNo);
}


//+-----------------------------------------------------------------+
//| GetMoving functie voor ZigZag Larsen
//+-----------------------------------------------------------------+

int GetMoving(int smet) {
   int shifting = (Const2 - Const1) * SwitchPercent / 100.0;
   if (shifting < NoiseLevel) shifting = NoiseLevel;
   if (Mode == 1) LevRT = iOpen(Symbol(),ZigZagLarsenPeriode,smet);
   else {
      if (rf1 != -1) LevRT = iHigh(Symbol(),ZigZagLarsenPeriode,smet);
      else LevRT = iLow(Symbol(),ZigZagLarsenPeriode,smet);
   }
   if (rf1 != -1 && LevRT > Const2) Const2 = LevRT;
   if (rf1 != 1 && LevRT < Const1) Const1 = LevRT;
   if (Const2 - Const1 >= NoiseLevel * Point) {
      if (rf1 != 1 && LevRT - Const1 >= shifting * Point) {
         rf1 = 1;
         Const3 = Const1;
         Const2 = LevRT;
         mdt = LevRT;
      }
      if (rf1 != -1 && Const2 - LevRT >= shifting * Point) {
         rf1 = -1;
         Const4 = Const2;
         Const1 = LevRT;
         mdt = LevRT;
      }
   }
   if (rf2 != rf1) {
      rf2 = rf1;
      rf3 = TRUE;
   }
   return (rf1);
}

//+------------------------------------------------------------------+
//| ZigAndZag The First Crusade
//+------------------------------------------------------------------+

void The_First_Crusade(){
   for(shift=CountBar; shift>0; shift--){
      CurSlalomZig=iLow(Symbol(),ZigAndZagPeriode,iLowest(Symbol(),ZigAndZagPeriode,MODE_LOW,Slalom,shift));
      CurSlalomZag=iHigh(Symbol(),ZigAndZagPeriode,iHighest(Symbol(),ZigAndZagPeriode,MODE_HIGH,Slalom,shift));
      
      if(CurSlalomZig==LastSlalomZig) CurSlalomZig=0.0;
      else
        {
         LastSlalomZig=CurSlalomZig;
         if((iLow(Symbol(),ZigAndZagPeriode,shift)-CurSlalomZig)>LimitPoints) CurSlalomZig=0.0;
         else
           {
            for(back=1; back<=Backstep; back++)
              {
               Something=SlalomZigBuffer[shift+back];
               if((Something!=0)&&(Something>CurSlalomZig))
                  SlalomZigBuffer[shift+back]=0.0;
              }
           }
        }
      if(CurSlalomZag==LastSlalomZag) CurSlalomZag=0.0;
      else
        {
         LastSlalomZag=CurSlalomZag;
         if((CurSlalomZag-iHigh(Symbol(),ZigAndZagPeriode,shift))>LimitPoints) CurSlalomZag=0.0;
         else
           {
            for(back=1; back<=Backstep; back++)
              {
               Something=SlalomZagBuffer[shift+back];
               if((Something!=0)&&(Something<CurSlalomZag))
                  SlalomZagBuffer[shift+back]=0.0;
              }
           }
        }
      SlalomZigBuffer[shift]=CurSlalomZig;
      SlalomZagBuffer[shift]=CurSlalomZag;

      CurKeelOverZig=iLow(Symbol(),ZigAndZagPeriode,iLowest(Symbol(),ZigAndZagPeriode,MODE_LOW,KeelOver,shift));
      CurKeelOverZag=iHigh(Symbol(),ZigAndZagPeriode,iHighest(NULL,ZigAndZagPeriode,MODE_HIGH,KeelOver,shift));
      
      if(CurKeelOverZig==LastKeelOverZig) CurKeelOverZig=0.0;
      else
        {
         LastKeelOverZig=CurKeelOverZig;
         if((iLow(Symbol(),ZigAndZagPeriode,shift)-CurKeelOverZig)>LimitPoints) CurKeelOverZig=0.0;
         else
           {
            for(back=1; back<=Backstep; back++)
              {
               Something=KeelOverZigAndZagSECTION[shift+back];
               if((Something!=0)&&(Something>CurKeelOverZig))
                  KeelOverZigAndZagSECTION[shift+back]=0.0;
              }
           }
        }
      if(CurKeelOverZag==LastKeelOverZag) CurKeelOverZag=0.0;
      else
        {
         LastKeelOverZag=CurKeelOverZag;
         if((CurKeelOverZag-iHigh(Symbol(),ZigAndZagPeriode,shift))>LimitPoints) CurKeelOverZag=0.0;
         else
           {
            for(back=1; back<=Backstep; back++)
              {
               Something=KeelOverZagBuffer[shift+back];
               if((Something!=0)&&(Something<CurKeelOverZag))
                  KeelOverZagBuffer[shift+back]=0.0;
              }
           }
        }
      KeelOverZigAndZagSECTION[shift]=CurKeelOverZig;
      KeelOverZagBuffer[shift]=CurKeelOverZag;
     }
   return;
  }

//+------------------------------------------------------------------+
//| ZigAndZag The Second Crusade
//+------------------------------------------------------------------+
void The_Second_Crusade()
  {
   for(shift=CountBar; shift>0; shift--)
     {
      CurSlalomZig=SlalomZigBuffer[shift];
      CurSlalomZag=SlalomZagBuffer[shift];
      if((CurSlalomZig==0)&&(CurSlalomZag==0)) continue;
      if(CurSlalomZag!=0)
        {
         if(LastSlalomZag>0)
           {
            if(LastSlalomZag<CurSlalomZag) SlalomZagBuffer[LastSlalomZagPos]=0;
            else SlalomZagBuffer[shift]=0;
           }
         if(LastSlalomZag<CurSlalomZag || LastSlalomZag<0)
           {
            LastSlalomZag=CurSlalomZag;
            LastSlalomZagPos=shift;
           }
         LastSlalomZig=-1;
        }
      if(CurSlalomZig!=0)
        {
         if(LastSlalomZig>0)
           {
            if(LastSlalomZig>CurSlalomZig) SlalomZigBuffer[LastSlalomZigPos]=0;
            else SlalomZigBuffer[shift]=0;
           }
         if((CurSlalomZig<LastSlalomZig)||(LastSlalomZig<0))
           {
            LastSlalomZig=CurSlalomZig;
            LastSlalomZigPos=shift;
           }
         LastSlalomZag=-1;
        }
      CurKeelOverZig=KeelOverZigAndZagSECTION[shift];
      CurKeelOverZag=KeelOverZagBuffer[shift];
      if((CurKeelOverZig==0)&&(CurKeelOverZag==0)) continue;
      if(CurKeelOverZag !=0)
        {
         if(LastKeelOverZag>0)
           {
            if(LastKeelOverZag<CurKeelOverZag)
               KeelOverZagBuffer[LastKeelOverZagPos]=0;
            else KeelOverZagBuffer[shift]=0.0;
           }
         if(LastKeelOverZag<CurKeelOverZag || LastKeelOverZag<0)
           {
            LastKeelOverZag=CurKeelOverZag;
            LastKeelOverZagPos=shift;
           }
         LastKeelOverZig=-1;
        }
      if(CurKeelOverZig!=0)
        {
         if(LastKeelOverZig>0)
           {
            if(LastKeelOverZig>CurSlalomZig)
               KeelOverZigAndZagSECTION[LastKeelOverZigPos]=0;
            else KeelOverZigAndZagSECTION[shift]=0;
           }
         if((CurKeelOverZig<LastKeelOverZig)||(LastKeelOverZig<0))
           {
            LastKeelOverZig=CurKeelOverZig;
            LastKeelOverZigPos=shift;
           }
         LastKeelOverZag=-1;
        }
     }
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void The_Third_Crusade()
  {
   bool first=true;
   for(shift=CountBar; shift>0; shift--)
     {
      LimitOrdersBuffer[shift]=0.0;
      BuyOrdersBuffer[shift]=0.0;
      SellOrdersBuffer[shift]=0.0;
      
      Navel=(5*iClose(Symbol(),ZigAndZagPeriode,shift)+2*iOpen(Symbol(),ZigAndZagPeriode,shift)+
               iHigh(Symbol(),ZigAndZagPeriode,shift)+iLow(Symbol(),ZigAndZagPeriode,shift))/9;
    
      if(KeelOverZigAndZagSECTION[shift]!=0.0)
        {
         TrendUp=true;
         first=false;
        }
      if(KeelOverZagBuffer[shift]!=0.0)
        {
         TrendUp=false;
         first=false;
        }
      if(KeelOverZagBuffer[shift]!=0.0 || KeelOverZigAndZagSECTION[shift]!=0.0)
        {
         KeelOverZigAndZagSECTION[shift]=Navel;
        }
      else KeelOverZigAndZagSECTION[shift]=0.0;

      if(SlalomZigBuffer[shift]!=0.0)
        {
         LastZigOrZag="Zig";
         LastSlalomZig=Navel;
         SetBuyOrder=false;
         SetLimitOrder=false;
         SetSellOrder=false;
        }
      if(SlalomZagBuffer[shift]!=0.0)
        {
         LastZigOrZag="Zag";
         LastSlalomZag=Navel;
         SetBuyOrder=false;
         SetLimitOrder=false;
         SetSellOrder=false;
        }
 
      if(SlalomZigBuffer[shift]==0.0 &&
         SlalomZagBuffer[shift]==0.0 &&
         first==false)                  Slalom_With_A_Scalpel();
     }
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Shift_Zerro()
  {
   shift=0;
   Navel=(5*iClose(Symbol(),ZigAndZagPeriode,0)+2*iOpen(Symbol(),ZigAndZagPeriode,0)+
            iHigh(Symbol(),ZigAndZagPeriode,0)+iLow(Symbol(),ZigAndZagPeriode,0))/9;
   Slalom_With_A_Scalpel();
   KeelOverZigAndZagSECTION[0]=Navel;
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Slalom_With_A_Scalpel()
  {

   if(LastZigOrZag=="Zig")
     {
      if(TrendUp==true)
        {
         if((Navel-LastSlalomZig)>=LimitPoints && SetBuyOrder==false)
           {
            SetBuyOrder=true;
            BuyOrdersBuffer[shift]=iLow(Symbol(),ZigAndZagPeriode,shift+1);
            LastSlalomZigPos=shift;
           }
         if(Navel<=LastSlalomZig && SetBuyOrder==true)
           {
            SetBuyOrder=false;
            BuyOrdersBuffer[LastSlalomZigPos]=0.0;
            LastSlalomZigPos=-1;
           }
        }
      if(TrendUp==false)
        {
         if(Navel>LastSlalomZig && SetLimitOrder==false)
           {
            SetLimitOrder=true;
            LimitOrdersBuffer[shift]=Navel;
            //            LimitOrdersBuffer[shift]=Close[shift];
            LastSlalomZigPos=shift;
           }
         if(Navel<=LastSlalomZig && SetLimitOrder==true)
           {
            SetLimitOrder=false;
            LimitOrdersBuffer[LastSlalomZigPos]=0.0;
            LastSlalomZigPos=-1;
           }
        }
     }
   if(LastZigOrZag=="Zag")
     {
      if(TrendUp==false)
        {
         if((LastSlalomZag-Navel)>=LimitPoints && SetSellOrder==false)
           {
            SetSellOrder=true;
            SellOrdersBuffer[shift]=iHigh(Symbol(),ZigAndZagPeriode,shift+1);
            LastSlalomZagPos=shift;
           }
         if(Navel>=LastSlalomZag && SetSellOrder==true)
           {
            SetSellOrder=false;
            SellOrdersBuffer[LastSlalomZagPos]=0.0;
            LastSlalomZagPos=-1;
           }
        }
      if(TrendUp==true)
        {
         if(LastSlalomZag>Navel && SetLimitOrder==false)
           {
            SetLimitOrder=true;
            LimitOrdersBuffer[shift]=Navel;
            //            LimitOrdersBuffer[shift]=Close[shift];
            LastSlalomZagPos=shift;
           }
         if(Navel>=LastSlalomZag && SetLimitOrder==true)
           {
            SetLimitOrder=false;
            LimitOrdersBuffer[LastSlalomZagPos]=0.0;
            LastSlalomZagPos=-1;
           }
        }
     }
   return;
  }
