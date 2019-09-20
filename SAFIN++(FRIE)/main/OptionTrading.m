function ot=optionTrading()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Author: Aprana
%Revised by Zeng Ye  (26 Mar 2016)
%Revised by VO DUY TUNG  (9 Nov 2017)
%
%----------------option straddle trading -----------------------------
load('optiontrading')   %LOAD TRAIN_IN = 486*5, train_OUT = 486*1 => 486 days of volatility
predictedvol = [];    %predicted volatility
k = 1;      % signifies row no. of the  option dataset
status = 0;    % 0 - neutral, 1 - long, -1 - short     %trading action
tradeduration = 0;
tradesignal = 0;
R = 0;
investment = 0;
rstildeSum = 0;
DR = 0;
S = 0;
numdays = 0;
exitcon = 0;
macdtplus1array = [];   %MACD T+1
macdEmaplus1array = [];    %MACD EMA+1
rsiarray = [];              %RSI
dataset = [];
rstildeArray = [];
dataset = load('fulldataset1.txt'); %370 DAYS OF TRADING DAY
%hsi index future
test = train_IN;   
% train_OUT = train_IN(:,5);
% train_IN = train_IN(:,1:4);
% start_test = 488;
% window = 120;
%PREDICT THE VOLATILITY OF 485 DAYS
IND = 4;
OUTD = 1;
Epochs = 1;
Eta = 0.05;
Sigma0 = sqrt(0.16);
Forgetfactor = 0.99;
Lamda = 0.3;
Rate = 0.25;
Omega = 0.7;
Gamma = 0.1;
forget = 1;
tau = 0.2;
net_out = Run_SaFIN(2, train_IN,test,IND,OUTD,Epochs,Eta,Sigma0,Forgetfactor, forget,Lamda, tau,Rate, Omega, Gamma);
%net_out1=net_out;
%GET THE VOLATILITY FROM DAY 111 to DAY 485 ACCORDING TO 375 DAYS OF TRADING
net_out=net_out(111:485,1);

for i=1:size(dataset,1)  %FOR EACH ROW IN OPTION DATA SET
                                                          
predicted = net_out(i);   %PREDICTED VOLATILITY OF THE DAY
dataset(k,6) = net_out(i);  % ADD PREDICTED VOLATILITY TO 6TH-COLUMN IN DATASET
predictedvol = [predictedvol;predicted];   %ADD PREDICTED VOLUMN TO IT

if k>=35
    
%-------------------------------Trading------------------------------------
    
% at k = 35, trading begins, ie 1st trading day
    
%-------------- check if last day of trading--------------   

          
    if i == 859     
        
        switch status
            
            case -1   %selling
                
                status = 0;
                buyprice = dataset(k,5);
                
                
                 rs = (sellprice - buyprice);
                 
                 rstilde = rs/sellprice *100;
                 rstildeSum = rstildeSum + rstilde;
                 rstildeArray = [rstildeArray; rstilde];
                 DR = DR + rstilde/(tradeduration+1);
                 S = S + 1; 
                
                R = R + rs;
                
               trade = ['neutral last day - buy ', num2str(dataset(k,1)), ' ', num2str(dataset(k,4)), ' ', num2str(buyprice)]
               
               rs
               R
               
            case 1
                
                status = 0;
                sellprice = dataset(k,5);
                
               rs = (sellprice - buyprice);
               
               rstilde = rs/buyprice *100;
                 rstildeSum = rstildeSum + rstilde;
               rstildeArray = [rstildeArray; rstilde];
               DR = DR + rstilde/(tradeduration+1);
                 S = S + 1; 
                 
                R = R + rs;
                
               trade = ['neutral last day - sell ', num2str(dataset(k,1)), ' ', num2str(dataset(k,4)), ' ', num2str(sellprice)]

               rs
               R

            
        end
        
    else
    


today = dataset(k,1);   % stores date of current trading day

expiryday = dataset(k,3);   % stores date of expiry day


data = predictedvol(((k-35)+1):k); % passing the last 35 future volatility, including the one predicted today

[macdvec, nineperma] = macd(data);

macdtplus1 = macdvec(end);
macdEmaplus1 = nineperma(end);
rsi = rsindex(data);

macdtplus1array = [macdtplus1array; macdtplus1];
macdEmaplus1array = [macdEmaplus1array; macdEmaplus1];
rsiarray = [rsiarray; rsi(end)]; 
rstildeArray = [];

switch status

    case -1
        
        %--------exit condition
        
        if dataset(k,5) > sellprice
            numdays = numdays + 1;
            
            if numdays == 5
                       
                exitcon = 1;
                
            end
            
        else
            numdays = 0;
            
        end
        
      
           if dataset(k,5) >= 1.1*sellprice || dataset(k,5) <= 0.9*sellprice
            
            exitcon = 1;
            
        end
        
        if exitcon == 1
            
            % close position
            
            
           status = 0;   
                buyprice = dataset(k,5);
                
                 rs = (sellprice - buyprice);
                 
                 rstilde = rs/sellprice *100;
                 rstildeSum = rstildeSum + rstilde;
                 rstildeArray = [rstildeArray; rstilde];
                 DR = DR + rstilde/(tradeduration+1);
                 S = S + 1; 
                
                R = R + rs;
                
                trade = ['neutral - buy exitcon',  num2str(dataset(k,1)), ' ', num2str(dataset(k,4)), ' ', num2str(buyprice)]
                
                rs
                R
                
                numdays = 0; 
                exitcon = 0;
                
                k = k+1;

                predicted
                continue 
            
        end
        
     %--------------------------------   
        
        if macdtplus1 >= 1.2 * macdEmaplus1
            tradesignal = 1;
            
        else
            tradesignal = 0;
        
        end
        
        if rsi(end) < 8
            tradesignal = 1;
        end
        
        %-------------trading signal is generated for the day
        
        
        switch tradesignal
            
            case 1
                
                status = 0;
                buyprice = dataset(k,5);
                
                
                rs = (sellprice - buyprice);
                
                rstilde = rs/sellprice *100;
                 rstildeSum = rstildeSum + rstilde;
                rstildeArray = [rstildeArray; rstilde];
                DR = DR + rstilde/(tradeduration+1);
                 S = S + 1; 
                
                R = R + rs;
                
                trade = ['neutral - buy ', num2str(dataset(k,1)), ' ',  num2str(dataset(k,4)), ' ', num2str(buyprice)]
                
            rs
            R
            
            case 0
                
                %check if straddle is expiring
                
                if expiryday - today == 1  %dataset(k,2) is TTM  ; means straddle is expiring
                    buyprice = dataset(k,5);
                    
                    status = 0;
                    
                    rs = (sellprice - buyprice);
                    
                    rstilde = rs/sellprice *100;
                 rstildeSum = rstildeSum + rstilde;
                    rstildeArray = [rstildeArray, rstilde];
                    DR = DR + rstilde/(tradeduration+1);
                    S = S + 1; 
                    
                     R = R + rs;
                    
                     trade = ['neutral - expiring buy ', num2str(dataset(k,1)), ' ', num2str(dataset(k,4)), ' ', num2str(buyprice)]
                     
                     rs
                     R
                     %else status will remain -1
                
                end
                
                
        end
      
        %----------------------
        
    case 0
        
        numdays = 0;
        
        
        if macdEmaplus1 > 0
            
           if macdtplus1 <= 0.8 * macdEmaplus1
              
                tradesignal = -1;
                
          elseif macdtplus1 >= 1.2 * macdEmaplus1
              
                   tradesignal = 1;
                   
            else
                tradesignal = 0;
                
            end
            
            
        elseif macdEmaplus1 < 0
            
              if macdtplus1 <= 1.2 * macdEmaplus1
              
                tradesignal = -1;
                
           elseif macdtplus1 >= 0.8 * macdEmaplus1
             
                   tradesignal = 1;
                   
            else
                tradesignal = 0;
                
               end
            
            
        elseif macdEmaplus1 == 0
            
               if macdtplus1 <= -0.2
                tradesignal = -1;
                
            elseif macdtplus1 >= 0.2
                   tradesignal = 1;
                   
            else
                tradesignal = 0;
                
               end
            
            
        end

        if rsi(end) > 80
            tradesignal = 1;
        elseif rsi(end) < 10
            tradesignal = -1;
        end
            
   %-------------------trading signal is generated for the day   
   
   
   switch tradesignal
       
       case 1
           
           status = 1;
           buyprice = dataset(k,5);
           
           trade = ['long ', num2str(dataset(k,1)), ' ', num2str(dataset(k,4)), ' ', num2str(buyprice)]
           
          begindate = dataset(k,1);
          tradeduration = 0;
           investment = investment + buyprice;
       case -1
           
           status = -1;
           sellprice = dataset(k,5);
           
           trade = ['short ', num2str(dataset(k,1)), ' ', num2str(dataset(k,4)), ' ', num2str(sellprice)]
           
           begindate = dataset(k,1);
           tradeduration = 0;
           investment = investment + sellprice;
       %else status will remain 0
   end
                        
   %--------------------
   
    case 1
        
         %--------exit condition
        
        if dataset(k,5) < buyprice
            numdays = numdays + 1;
            
            if numdays == 5    %consecutive 5 days
                       
                exitcon = 1;
                
            end
            
        else
            numdays = 0;
            
        end
        
        
        if dataset(k,5) <= 0.9*buyprice || dataset(k,5) >= 1.1*buyprice
            
            exitcon = 1;
            
        end
        
        if exitcon == 1
            
            % close position
                status = 0;   
                sellprice = dataset(k,5);
                
                
                rs = (sellprice - buyprice);
                
                rstilde = rs/buyprice *100;
                 rstildeSum = rstildeSum + rstilde;
                rstildeArray = [rstildeArray; rstilde];
                DR = DR + rstilde/(tradeduration+1);
                 S = S + 1; 
                
                R = R + rs;
                
                trade = ['neutral - sell exitcon', num2str(dataset(k,1)), ' ', num2str(dataset(k,4)), ' ', num2str(sellprice)]
                
                rs
                R
                
                numdays = 0; 
                exitcon = 0;
                
                k = k+1;

                predicted
                continue 
            
        end
        
     %--------------------------------   
        
        if macdtplus1 <= 1.2 * macdEmaplus1
            tradesignal = -1;
            
        else
            tradesignal = 0;
        
        end

        if rsi(end) > 80
            tradesignal = -1;
        end
        
        %-----------------trading signal is generated for the day
        
         switch tradesignal
            
            case -1
                
                status = 0;
                sellprice = dataset(k,5);
                
                
                rs = (sellprice - buyprice);
                
                rstilde = rs/buyprice *100;
                 rstildeSum = rstildeSum + rstilde;
                 rstildeArray = [rstildeArray; rstilde];
                
                DR = DR + rstilde/(tradeduration+1);
                 S = S + 1; 
                
                R = R + rs;
                
                trade = ['neutral - sell ', num2str(dataset(k,1)), ' ', num2str(dataset(k,4)), ' ', num2str(sellprice)]
                
                rs
                R
             
             case 0
                
                %check if straddle is expiring
                
                if expiryday - today == 1   %dataset(k,2) is TTM  ; means straddle is expiring
                    sellprice = dataset(k,5);
                    
                    status = 0;
                    
                    rs = (sellprice - buyprice);
                    
                    rstilde = rs/buyprice *100;
                    rstildeSum = rstildeSum + rstilde;
                    
                    rstildeArray = [rstildeArray; rstilde];
                    
                    DR = DR + rstilde/(tradeduration+1);
                    S = S + 1; 
                    
                     R = R + rs;
                    
                     trade = ['neutral expiry - sell ', num2str(dataset(k,1)), ' ', num2str(dataset(k,4)), ' ', num2str(sellprice)]
                     
                     rs
                     R
                     
                     %else status will remain 1
                
                end
                
                
         end
         
    
end





%----------------------------end of daily trading algo-------------------
    end

end


k = k+1;

tradeduration = tradeduration + 1;

predicted

    
end


S
Raverage = rstildeSum/S;

Roverall = (R/investment) * 100;

DR = DR/S;
ot.DR=DR;
ot.net_out=net_out;
ot.Raverage=Raverage;
ot.Roverall=Roverall;



