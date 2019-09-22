% Nakanishi datasets

load inter_CV4;

inter_target = [P1(:, 5); P3_1(:, 5); ];
inter_input = [P1(:, 1:4); P3_1(:, 1:4);];
start_test = size(P4, 1) + 1;
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
    data_input = inter_input;
    data_target = inter_target;

    end_test = size(data_target,1);

    
    

    for i = 1 : size(spec, 2)

        switch spec(i).algo
        % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX ieRSPOP XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
            case {'ierspop'}  
                disp(['Running algo : ', spec(i).algo]);
                 
                ensemble = update_ron_trainOnline(data_input, data_target, spec(i).algo, 35);
                ensemble = ron_calcErrors(ensemble, data_target(start_test : size(data_target,1)));
                r2(i, 1) = ensemble.R2;
                rmse(i, 1) = sqrt(ensemble.MSE);
                rules(i, 1) = ensemble.num_rules;  



                figure;
                str = [sprintf('Actual VS Predicted')];
                title(str);
                for l = 1:size(data_target,2)
                hold;
%               axis([start_test1, end_test1, 25, 55]);
                plot(1:start_test,data_target(1:start_test),'b');
                %plot(1:start_test,ensemble.predicted(1:start_test),'r');
                legend('Actual','Predicted');
                ylabel('FiO2');
                xlabel('Hour (h)');
                end
                
                figure;
                str = [sprintf('Actual VS Predicted')];
                title(str);
                for l = 1:size(data_target,2)
                hold;
%               axis([start_test1, end_test1, 25, 55]);
                plot(start_test:end_test,data_target(start_test:end_test),'b');
                plot(start_test:end_test,ensemble.predicted(start_test:end_test),'r');
                legend('Actual','Predicted');
                ylabel('FiO2');
                xlabel('Hour (h)');
                end
%                 
%                     figure;
%                     hold all;
%                     for l=1:size(data_input,2)
%                     plot(1:size(data_input,1),data_input(1:size(data_input,1), l));
%                     end
%                     h = legend('SAO2', 'FIO2', 'PEEP', 'RR');

        end        
    end
       
