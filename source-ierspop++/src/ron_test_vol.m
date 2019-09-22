% Nakanishi datasets

load otmVolatility;

vdata = [];

num_inputs = 5;

for i = 1:(size(voldata,1) - num_inputs)
    
    for j=0:num_inputs-1
    vdata(i,j+1) = voldata(j+i);
    end
    
    vdata(i,num_inputs+1) = voldata(num_inputs+i);

end

warning('off');

i = 1;
spec(i).algo = 'ierspop'; 
% i = i + 1;
% spec(i).algo = 'rspop'; i = i + 1;
% spec(i).algo = 'pop'; i = i + 1;
% spec(i).algo = 'efunn'; i = i + 1;
% spec(i).algo = 'denfis'; i = i + 1;
% spec(i).algo = 'saifin';  i = i + 1;
% spec(i).algo = 'anfis'; 

    data_input = vdata(:, 1:num_inputs);
    data_target = vdata(:, num_inputs+1);


    start_test = 487;
    window = 125;

    for i = 1 : size(spec, 2)

        switch spec(i).algo
        % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX ieRSPOP XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
         case {'ierspop'}   
                ensemble = update_ron_trainOnline(data_input, data_target, spec(i).algo, 120);                             
                ensemble = ron_calcErrors(ensemble, data_target(start_test : size(data_target,1)));

                r2(i, 1) = ensemble.R2;
                rmse(i, 1) = sqrt(ensemble.MSE);
                rules(i, 1) = ensemble.num_rules;
                %predict.net_struct(i).predicted = ensemble.predicted;

            % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX RSPOP XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
            case {'rspop'}

                net = member('gen', 'spsec', data_input(1 : start_test - 1, :), data_target(1 : start_test - 1, :));

                [net Ot] = popfnn('train', 'rspop', net, data_input(1 : start_test - 1, :), data_target(1 : start_test - 1, :));
                [net Ot] = popfnn('train', 'reduce1', net, data_input(1 : start_test - 1, :), data_target(1 : start_test - 1, :), [0 NaN]);
                clear Ot;

                Ot = popfnn('compute', net, data_input(1 : start_test - 1, :));
                Oc = popfnn('compute', net, data_input(start_test : size(data_target, 1), :));

                train_predicted = Ot;
                test_predicted = Oc;

                net.predicted = test_predicted;
                net = ron_calcErrors(net, data_target(start_test : size(data_target, 1)));
                r2(i, 1) = net.R2;
                rmse(i, 1) = sqrt(net.MSE);
                rules(i, 1) = net.num_rules;
                predict.net_struct(i).predicted = net.predicted;
             
             % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX POP XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
            case 'pop'

                net = member('gen', 'spsec', data_input(1 : start_test - 1, :), data_target(1 : start_test - 1, :));

                [net Ot] = popfnn('train', 'pop', net, data_input(1 : start_test - 1, :), data_target(1 : start_test - 1, :));
                clear D.Ot;

                Ot = popfnn('compute', net, data_input(1 : start_test - 1, :));
                Oc = popfnn('compute', net, data_input(start_test : size(data_target, 1), :));

                train_predicted = Ot;
                test_predicted = Oc;

                net.predicted = test_predicted;
                net = ron_calcErrors(net, data_target(start_test : size(data_target, 1)));
                r2(i, 1) = net.R2;
                rmse(i, 1) = sqrt(net.MSE);
                rules(i, 1) = net.num_rules;     
                predict.net_struct(i).predicted = net.predicted;
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX EFuNN XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
            case 'efunn'

                C.dispmode = 0;
                trnData = [data_input(1 : start_test - 1, :), data_target(1 : start_test - 1, :)];
                tstData = [data_input(start_test : size(data_target, 1), :), data_target(start_test : size(data_target, 1), :)];
                net = efunn(trnData, C);
                tfis = efunns(trnData, net);
                cfis = efunns(tstData, net);

                train_predicted = tfis.Out;
                test_predicted = cfis.Out;  

                net.predicted = test_predicted;
                net = ron_calcErrors(net, data_target(start_test : size(data_target, 1)));
                r2(i, 1) = net.R2;
                rmse(i, 1) = sqrt(net.MSE);
                rules(i, 1) = net.num_rules;       
                predict.net_struct(i).predicted = net.predicted;
        % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX ANFIS XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
            case 'anfis'            

                trnData = [data_input(1 : start_test - 1, :), data_target(1 : start_test - 1, :)];
                epoch_n = 100;
                % Parameters fixed at 0.3
                infis = genfis2(data_input(1 : start_test - 1, :), data_target(1 : start_test - 1, :), 0.3);
                net = anfis(trnData, infis, epoch_n);

                train_predicted = evalfis(data_input(1 : start_test - 1, :)', net);
                test_predicted = evalfis(data_input(start_test : size(data_target, 1), :)', net); 

                net.predicted = test_predicted;
                net = ron_calcErrors(net, data_target(start_test : size(data_target, 1)));
                
                r2(i, 1) = net.R2;    
                rmse(i, 1) = sqrt(net.MSE);
                rules(i, 1) = net.num_rules;
                predict.net_struct(i).predicted = net.predicted;
        % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX DENFIS XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
            case 'denfis'

                C.trainmode = 2;

                trnData = [data_input(1 : start_test - 1, :), data_target(1 : start_test - 1, :)];
                tstData = [data_input(start_test : size(data_target, 1), :), data_target(start_test : size(data_target, 1), :)];
                net = denfis(trnData, C);
                tfis = denfiss(trnData, net);
                cfis = denfiss(tstData, net);

                train_predicted = tfis.Out';
                test_predicted = cfis.Out';

                net.predicted = test_predicted;
                net = ron_calcErrors(net, data_target(start_test : size(data_target, 1)));
                r2(i, 1) = net.R2;
                rmse(i, 1) = sqrt(net.MSE);
                rules(i, 1) = net.num_rules;
                predict.net_struct(i).predicted = net.predicted;
                            
            case 'saifin'

                train_IN= data_input(1 : start_test - 1, :);
                train_OUT = data_target(1 : start_test - 1, :);
                test= [data_input(start_test : size(data_target, 1), :), data_target(start_test : size(data_target, 1), :)];
                [predicted, R, Rules, MSE] = Run_SaFIN(train_IN,train_OUT,test,0.25,0.65,300,0.05);

                net.predicted = predicted;
                r2(i, 1) = R;
                rmse(i, 1) = sqrt(MSE);
                rules(i, 1) = size(Rules,1);
                predict.net_struct(i).predicted = net.predicted;

        end        
    end
    results = [r2, rmse, rules];
    
    
       figure
       hold on;
       title('Volatility Prediction');
       plot(1:size(data_target,1),vdata(1:size(data_target,1)), 'b');
       plot(1:size(data_target,1),predict.net_struct(1,1).predicted(1:size(data_target,1)), 'r' );
       h = legend('Actual','ieRSPOP++');
       ylabel('Volatility level (%)');
       xlabel('Trading day (t)');

       figure
       hold on;
       title('Volatility Prediction');
       plot(start_test:size(data_target,1),vdata(start_test:size(data_target,1)), 'b');
       plot(start_test:size(data_target,1),predict.net_struct(1,1).predicted(start_test:size(data_target,1)),'r');
       plot(start_test:size(data_target,1),predict.net_struct(1,2).predicted, 'g');
       plot(start_test:size(data_target,1),predict.net_struct(1,3).predicted, 'm');
       h = legend('Actual','ieRSPOP++', 'RSPOP', 'POP');
       ylabel('Volatility level (%)');
       xlabel('Trading day (t)');

       figure
       hold on;
       title('Volatility Prediction');
       plot(start_test:size(data_target,1),vdata(start_test:size(data_target,1)), 'b');
       plot(start_test:size(data_target,1),predict.net_struct(1,1).predicted(start_test:size(data_target,1)),'r');
       plot(start_test:size(data_target,1),predict.net_struct(1,4).predicted, 'g');
       plot(start_test:size(data_target,1),predict.net_struct(1,6).predicted, 'm');
    %   plot(start_test:size(data_target,1),predict.net_struct(1,1).predicted);
       h = legend('Actual','ieRSPOP++', 'EFuNN',  'SAFIN');
       ylabel('Volatility level (%)');
       xlabel('Trading day (t)');

       figure
       hold on;
       title('Volatility Prediction');
       plot(start_test:size(data_target,1),vdata(start_test:size(data_target,1)), 'b');
       plot(start_test:size(data_target,1),predict.net_struct(1,1).predicted(start_test:size(data_target,1)),'r');
       plot(start_test:size(data_target,1),predict.net_struct(1,5).predicted, 'g');
       plot(start_test:size(data_target,1),predict.net_struct(1,7).predicted, 'm');
       h = legend('Actual','ieRSPOP++','DENFIS', 'ANFIS');
       ylabel('Volatility level (%)');
       xlabel('Trading day (t)');
