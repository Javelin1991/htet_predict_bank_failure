
%----------------option straddle trading -----------------------------


%voldata = load('volatilitydata1.txt');  

voldata = load('volatilitydata2.txt');  
vdata = [];

num_inputs = 5;

for i = 1:(size(voldata,1) - num_inputs)
    
    for j=0:num_inputs-1
    vdata(i,j+1) = voldata(j+i);
    end
    
    vdata(i,num_inputs+1) = voldata(num_inputs+i);

end

vdata
%----vdata ready



predictedvol = [];

k = 1;      % signifies row no. of the  option dataset

status = 0;    % 0 - neutral, 1 - long, -1 - short

tradeduration = 0;

tradesignal = 0;

R = 0;

investment = 0;

rstildeSum = 0;
DR = 0;
S = 0;

numdays = 0;
exitcon = 0;
macdtplus1array = [];
macdEmaplus1array = [];
rsiarray = [];
dataset = [];
rstildeArray = [];
dataset = load('fulldataset1.txt');


data_input = vdata(:, 1:num_inputs);
data_target = vdata(:, num_inputs+1);

start_test = 487;

window = 120;

ensemble = update_ron_trainOnline(data_input, data_target, 'ierspop', window);
ensemble = ron_calcErrors(ensemble, data_target(start_test : size(data_target,1)));

for i=487:size(vdata,1)    
                                                         
predicted = ensemble.predicted(i);
dataset(k,6) = ensemble.predicted(i);  % dataset is the option dataset as described in the excel file
predictedvol = [predictedvol;predicted];   


if k>=35
    
%-------------------------------Trading------------------------------------
    
% at k = 35, trading begins, ie 1st trading day
    
%-------------- check if last day of trading--------------   

          
    if i == size(vdata,1)     
        
        switch status
            
            case -1
                
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



Raverage = rstildeSum/S;

Roverall = (R/investment) * 100;

DR = DR/S;

