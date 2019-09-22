% Real life stock data

load ron_companies;
%load stock_ierspop;

warning('off');

i = 1;
spec(i).algo = 'ierspop'; 
%i = i + 1;
%spec(i).algo = 'rspop'; i = i + 1;
%spec(i).algo = 'efunn'; i = i + 1;
 %spec(i).algo = 'anfis'; i = i + 1;
%spec(i).algo = 'denfis'; i = i + 1;
%spec(i).algo = 'safin'; i = i + 1;

r2 = zeros(size(spec, 2), 1);
rmse = zeros(size(spec, 2), 1);
rules = zeros(size(spec, 2), 1);
windowArray = [50; 50; 50; 50; 50; 50; 50; 160; 50; 140; 50; 50; 50; 50;50; 90; 155; 50; 165; 50; 50; 50; 160; 50; 50; 50; 50];

% window1 = 50;
% window2 = 50;
% window3 = 50;
% window4 = 50;
% window5 = 155;
% window6 = 50;
%  window7 = 50;
% window8 = 160;
% window9 = 50;
% window10 = 140;
%  window11 = 50;
% window12 = 50;
% window13 = 50;
% window14 = 50;
% window15 = 50;
% window16 = 90;
% window17 = 155;
%  window18 = 50;
%  window19 = 165;
%  window20 = 50;
%  window21 = 50;
%  window22 = 50;
%  window23 = 160;
%  window24 = 50;
% window25 = 50;
%  window26 = 50;
%  window27 = 50;


        
for Z=24:24

    data = companies(Z).adjclose;  
%   data = companies(Z).z;

    delay = 5;
    num = size(data,1);
  
    diff_data = zeros(num - 1, 1);
    for i = 1 : num - 1
        diff_data(i, 1) = data(i + 1, 1) - data(i, 1);
    end
    
    end_train = 100;
    %end_train = floor(num/2);
    start_test = end_train + 1;

    for i = 1 : num - (delay - 1) - 2
        data_input(i , 1 : delay) = diff_data(i : i + (delay - 1), 1);
        data_target(i, 1) = diff_data(i + delay, 1);
    end
    


    for i = 1 : size(spec, 2)

        disp(['Running algo : ', spec(i).algo]);
        
        switch spec(i).algo
        % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX ieRSPOP XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
            case {'ierspop'}   
                ensemble = update_ron_trainOnline(data_input, data_target, spec(i).algo, windowArray(Z));                
                predicted = ensemble.predicted;
                for j = 1 : size(predicted, 1)
                    actual_predicted(j, 1) = data(j + delay, 1) + predicted(j, 1);
                end
                ensemble.predicted = actual_predicted;                
                ensemble = ron_calcErrors(ensemble, data(start_test + delay + 1 : size(data, 1)));

                r2(i, 1) = ensemble.R2;
                rmse(i, 1) = sqrt(ensemble.MSE);
                rules(i, 1) = ensemble.num_rules;
                     
%                 s = 251;
%                 e = 2180;
%                 e2 = 2175;
%                 int = floor((e-s)/3);
%                 plot(s:e, data(s:e), 'b');
%                 hold('on')
%                 plot(s:e, p(1).predicted(e2-(e-s):e2), 'm');
%                 plot(s:e, p(2).predicted, 'r');
%                 plot(s:e, p(3).predicted, 'g');
%                 xlim([s e]);
%                 d = companies(27).dates;
%                 labels = {datestr(d(s)), datestr(d(s+(1*int))), datestr(d(s+(2*int))), datestr(d(e))};
%                 set(gca, 'XTick', [s s+(1*int) s+(2*int) e], 'XTickLabel', labels);
%                 title('SingTel stock price');
%                 ylabel('Stock price');
%                 xlabel('Date');
                

 
        % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX RSPOP XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
       
    end
        
    results(Z, 1) = rmse(1,1);
    results(Z, 2) = r2(1,1);
    results(Z, 3) = rules(1,1);
    predict.net_struct(Z, 1).predict = predicted;
    %clear data_input data_target ensemble actual_predicted;
        
    end

           
    figure;    
    s = 251;
    e = size(companies(1,Z).adjclose, 1);
    e2 = e-5;
    int = floor((e-s)/3);
    data = companies(1, Z).adjclose; 
    plot(s:e, data(s:e), 'b');
    hold('on')
    plot(s:e2-1, ensemble.predicted(s:e2-1), 'r');
    h = legend('Actual','ieRSPOP++');
    % set(h,'Interpreter','none')
    xlim([s e2]);
    d = companies(i).dates;
    labels = {datestr(d(s)), datestr(d(s+(1*int))), datestr(d(s+(2*int))), datestr(d(e))};
    set(gca, 'XTick', [s s+(1*int) s+(2*int) e], 'XTickLabel', labels);
    title(companies(1,i).name);
    ylabel('Stock price');
    xlabel('Date');
    
end
