% Mackey-Glass Chaotic time series datasets

load ron_mg;

warning('off');

i = 1;
spec(i).algo = 'ierspop'; i = i + 1;
%spec(i).algo = 'irspop'; i = i + 1;
% spec(i).algo = 'rspop'; i = i + 1;
% spec(i).algo = 'pop'; i = i + 1;
% spec(i).algo = 'efunn'; i = i + 1;
% spec(i).algo = 'anfis'; i = i + 1;
% spec(i).algo = 'denfis'; i = i + 1;
%spec(i).algo = 'safin'; i = i + 1;
r2 = zeros(size(spec, 2), 3);
rmse = zeros(size(spec, 2), 3);
rules = zeros(size(spec, 2), 3);

for Z =2:2

    switch Z
        case 1
            data_input = mg1_input;
            data_target = mg1_target;
        case 2
            data_input = mg2_input;
            data_target = mg2_target;
        case 3
            data_input = mg4_input;
            data_target = mg4_target;
    end

    start_test = (size(data_input, 1) / 2) + 1;
    inMF = zeros(size(spec, 2), size(data_input, 2));
    outMF = zeros(size(spec, 2), size(data_target, 2));

    for i = 1 : 1

        disp(['Running algo : ', spec(i).algo]);

        switch spec(i).algo
        % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX ieRSPOP XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
            case {'ierspop'}
                ensemble = update_ron_trainOnline(data_input, data_target, spec(i).algo, 90);
                ensemble = ron_calcErrors(ensemble, data_target(start_test : size(data_target, 1)));

                r2(i, Z) = ensemble.R2;
                rmse(i, Z) = sqrt(ensemble.MSE);
                rules(i, Z) = ensemble.num_rules;

                figure;
                str = [sprintf('Actual VS Predicted')];
                title(str);
                for l = 1:size(data_target,2)
                hold;
                plot(start_test:size(data_target,1),data_target(start_test:size(data_target,1)),'b');
                plot(start_test:size(ensemble.predicted,1),ensemble.predicted(start_test:size(data_target,1)),'r');
                legend('Actual','Predicted');
                end

                figure;
                for l = 1:size(data_input,2)
                hold all;
                plot(start_test:size(data_input,1),data_input(start_test:size(data_input,1), l));
                end


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
                r2(i, Z) = net.R2;
                rmse(i, Z) = sqrt(net.MSE);
                rules(i, Z) = net.num_rules;
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
                r2(i, Z) = net.R2;
                rmse(i, Z) = sqrt(net.MSE);
                rules(i, Z) = net.num_rules;
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
                r2(i, Z) = net.R2;
                rmse(i, Z) = sqrt(net.MSE);
                rules(i, Z) = net.num_rules;
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
                r2(i, Z) = net.R2;
                rmse(i, Z) = sqrt(net.MSE);
                rules(i, Z) = net.num_rules;
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
                r2(i, Z) = net.R2;
                rmse(i, Z) = sqrt(net.MSE);
                rules(i, Z) = net.num_rules;

            case 'safin'

                train_IN= data_input(1 : start_test - 1, :);
                train_OUT = data_target(1 : start_test - 1, :);
                test= [data_input(start_test : size(data_target, 1), :), data_target(start_test : size(data_target, 1), :)];
                [predicted, R, Rules, MSE] = Run_SaFIN(train_IN,train_OUT,test,0.25,0.65,300,0.05);

                net.predicted = predicted;
                %net = ron_calcErrors(net, data_target(start_test : size(data_target, 1)));
                r2(i, Z) = R;
                rmse(i, Z) = sqrt(MSE);
                rules(i, Z) = size(Rules,1);
        end
    end

    D(Z).p = ensemble.predicted;
    clear data_input data_target;

end
