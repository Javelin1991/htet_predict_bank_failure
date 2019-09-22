% Traffic prediction

load ron_traffic;

warning('off');

i = 1;
spec(i).algo = 'ierspop'; i = i + 1;
% spec(i).algo = 'irspop'; i = i + 1;
% spec(i).algo = 'rspop'; i = i + 1;
% spec(i).algo = 'pop'; i = i + 1;
% spec(i).algo = 'efunn'; i = i + 1;
% spec(i).algo = 'anfis'; i = i + 1;
% spec(i).algo = 'denfis'; i = i + 1;
% spec(i).algo = 'ffnn'; i = i + 1;

r2 = zeros(size(spec, 2), 1);
rmse = zeros(size(spec, 2), 1);
rules = zeros(size(spec, 2), 1);
% inMF = zeros(size(spec, 2), size(data_input, 2));
% outMF = zeros(size(spec, 2), size(data_target, 2));
    
for Z = 1 : 3
    for Y = 1 : 5
        switch Y
            case 1
                traffic = traffic_1_5(Z).data;
            case 2
                traffic = traffic_1_15(Z).data;
            case 3
                traffic = traffic_1_30(Z).data;
            case 4
                traffic = traffic_1_45(Z).data;
            case 5
                traffic = traffic_1_60(Z).data;
        end
    
        data_input = traffic(:, 1 : 4);
        data_target = traffic(:, 5);

        num = size(traffic, 1);

        end_train = 550;
        start_test = end_train + 1;

        for i = 1 : size(spec, 2)

            disp(['Running algo : ', spec(i).algo]);

            switch spec(i).algo
            % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX ieRSPOP XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
                case {'ierspop', 'irspop'}                
                    ensemble = update_ron_trainOnline(data_input, data_target, spec(i).algo, 120);
                    ensemble = ron_calcErrors(ensemble, data_target(start_test : size(data_target, 1)));

                    r2(i, 1) = ensemble.R2;
                    rmse(i, 1) = sqrt(ensemble.MSE);
                    rules(i, 1) = ensemble.num_rules;
%                     for j = 1 : size(data_input, 2)
%                         for k = 1 : size(ensemble.net_struct, 2)
%                             inMF(i, j) = inMF(i, j) + (size(ensemble.net_struct(k).net.input(j).mf, 2) * ensemble.net_struct(k).net.weight);
%                         end
%                     end
%                     for j = 1 : size(data_target, 2)
%                         for k = 1 : size(ensemble.net_struct, 2)
%                             outMF(i, j) = outMF(i, j) + (size(ensemble.net_struct(k).net.output(j).mf, 2) * ensemble.net_struct(k).net.weight);
%                         end
%                     end  
            % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX RSPOP XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
                case 'rspop'

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
                    mse(i, 1) = net.MSE;
                    rules(i, 1) = net.num_rules;
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
            end     
            p(i).p = ensemble.predicted;
        end
    
    results(3*(Y-1)+Z, 1) = rmse(1, 1);
    results(3*(Y-1)+Z, 2) = r2(1, 1);
    results(3*(Y-1)+Z, 3) = rules(1, 1);
    clear r2 rmse rules data_input data_target;
    end
end

