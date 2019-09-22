% Nakanishi datasets

load ventilator;


warning('off');

i = 1;
spec(i).algo = 'ierspop'; 
%i = i + 1;
% spec(i).algo = 'saifin'; i = i + 1;
%  spec(i).algo = 'rspop'; i = i + 1;
%  spec(i).algo = 'pop'; i = i + 1;
%  spec(i).algo = 'efunn'; i = i + 1;
%  spec(i).algo = 'anfis'; i = i + 1;
%  spec(i).algo = 'denfis'; i = i + 1;
%        
    data_input = venti_input;
    data_target = venti_output;

    start_test1 = 124;
    end_test1 = 204;
    start_test2 = 226;
    end_test2 = 306;
    start_test3 = 328;
    end_test3 = 408;
    end_test = size(data_target,1);
%     start_test1 = 82;
%     end_test1 = 136;
%     start_test2 = 150;
%     end_test2 = 204;
%     start_test3 = 218;
%     end_test3 = 272;
%     start_test4 = 286;
%     end_test4 = 340;
%     start_test5 = 354;
%     end_test5 = 408;
%     
    
    start_test = 102;

    for i = 1 : size(spec, 2)

        switch spec(i).algo
        % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX ieRSPOP XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
            case {'ierspop'}  
                disp(['Running algo : ', spec(i).algo]);
                 
                ensemble = update_ron_trainOnline(data_input, data_target, spec(i).algo, 122);
                ensemble = ron_calcErrors(ensemble, data_target(102 : size(data_target,1)));
                r2(i, 1) = ensemble.R2;
                rmse(i, 1) = sqrt(ensemble.MSE);
                rules(i, 1) = ensemble.num_rules;  

%                 ensemble1 = update_ron_trainOnline(data_input(1:end_test1, :), data_target(1:end_test1, :), spec(i).algo, 50);
%                 ensemble1 = ron_calcErrors(ensemble1, data_target(start_test1 : end_test1, :));
%                 input = [data_input(102:end_test2, :)];%  data_input(204:end_test3, :); data_input(1:end_test1, :)];
%                 output = [data_target(102:end_test2, :)];%  data_target(204:end_test3, :); data_target(1:end_test1, :)];
%                 ensemble2 = update_ron_trainOnline(input, output, spec(i).algo, 55);
%                 ensemble2 = ron_calcErrors(ensemble2, output(start_test1 : end_test1, :));
%                 input = [data_input(204:end_test3, :)];% data_input(1:end_test1, :); data_input(102:end_test2, :)];
%                 output = [data_target(204:end_test3, :)];% data_target(1:end_test1, :); data_target(102:end_test2, :)];
%                 ensemble3 = update_ron_trainOnline(input, output, spec(i).algo, 35);
%                 ensemble3 = ron_calcErrors(ensemble3, output(start_test1 : end_test1, :));


                figure;
                str = [sprintf('Actual VS Predicted')];
                title(str);
                for l = 1:size(data_target,2)
                hold;
%               axis([start_test1, end_test1, 25, 55]);
                plot(2:end_test,data_target(2:end_test),'b');
                plot(2:end_test,ensemble.predicted(2:end_test),'r');
                legend('Actual','Predicted');
                ylabel('FiO2');
                xlabel('Hour (h)');
                end
%                 
%                 figure;
%                 str = [sprintf('Actual VS Predicted')];
%                 title(str);
%                 for l = 1:size(data_target,2)
%                 hold;
% %               axis([start_test1, end_test1, 25, 55]);
%                 plot(2:204,data_target(2:end_test1),'b');
%                 plot(2:204,ensemble.predicted(2:end_test1),'r');
%                 legend('Actual','Predicted');
%                 ylabel('FiO2');
%                 xlabel('Hour (h)');
%                 end
% %                 
% %                 
%                 figure;
%                 str = [sprintf('Actual VS Predicted')];
%                 title(str);
%                 for l = 1:size(data_target,2)
%                 hold;
%                 %axis([start_test2, end_test2, 25, 55]);
%                 plot(103:end_test2,data_target(103:end_test2),'b');
%                 plot(103:end_test2,ensemble.predicted(103:end_test2),'r');
%                 legend('Actual','Predicted');
%                 ylabel('FiO2');
%                 xlabel('Hour (h)');
%                 end
% % %                 
%                 figure;
%                 str = [sprintf('Actual VS Predicted')];
%                 title(str);
%                 for l = 1:size(data_target,2)
%                 hold;
% %                 axis([start_test3, end_test3, 25, 55]);
%                 plot(205:end_test3,data_target(205:end_test3),'b');
%                 plot(205:end_test3,ensemble.predicted(205:end_test3),'r');
%                 legend('Actual','Predicted');
%                 ylabel('FiO2');
%                 xlabel('Hour (h)');
%                 end
% %                 
%                 figure;
%                 str = [sprintf('Actual VS Predicted')];
%                 title(str);
%                 for l = 1:size(data_target,2)
%                 hold;
% %               axis([start_test1, end_test1, 25, 55]);
%                 plot(2:204,data_target(2:end_test1),'b');
%                 plot(2:204,ensemble1.predicted(2:end_test1),'r');
%                 legend('Actual','Predicted');
%                 ylabel('FiO2');
%                 xlabel('Hour (h)');
%                 end
% %                 
% %                 
%                 figure;
%                 str = [sprintf('Actual VS Predicted')];
%                 title(str);
%                 for l = 1:size(data_target,2)
%                 hold;
%                 %axis([start_test2, end_test2, 25, 55]);
%                 plot(2:205,data_target(103:end_test2),'b');
%                 plot(2:205,ensemble2.predicted(2:end_test1+1),'r');
%                 legend('Actual','Predicted');
%                 ylabel('FiO2');
%                 xlabel('Hour (h)');
%                 end
% %                 
%                 figure;
%                 str = [sprintf('Actual VS Predicted')];
%                 title(str);
%                 for l = 1:size(data_target,2)
%                 hold;
%               axis([1, 82, 30, 42]);
%                 plot(1:82,data_target(327:end_test3),'b');
%                 plot(1:82,ensemble3.predicted(124:205),'r');
%                 legend('Actual','Predicted');
%                 ylabel('FiO2');
%                 xlabel('Hour (h)');
%                 end
% %                 

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
                rmse(i, 1) = sqrt(net.MSE);
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
            
            
            case 'saifin'

                train_IN= data_input(1 : start_test - 1, :);
                train_OUT = data_target(1 : start_test - 1, :);
                test= [data_input(start_test : size(data_target, 1), :), data_target(start_test : size(data_target, 1), :)];
                [predicted, R, Rules, MSE] = Run_SaFIN(train_IN,train_OUT,test,0.25,0.65,300,0.05);

                net.predicted = predicted;
                %net = ron_calcErrors(net, data_target(start_test : size(data_target, 1)));
                r2(i, 1) = R;
                rmse(i, 1) = sqrt(MSE);
                rules(i, 1) = size(Rules,1);


        end        
    end
       
