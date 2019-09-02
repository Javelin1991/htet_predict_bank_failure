load MackeyGlass;

warning('off');

i = 1;
spec(i).algo = 'emfis';

%i = i + 1;
%spec(i).algo = 'rspop'; i = i + 1;
% %(i).algo = 'pop'; i = i + 1;
% % spec(i).algo = 'efunn'; i = i + 1;
%spec(i).algo = 'anfis'; i = i + 1;
% % spec(i).algo = 'denfis'; i = i + 1;
%spec(i).algo = 'saifin'; i = i + 1;
%         

data_input = mackeyglass_input;
data_target = mackeyglass_target;
    
    %start_test = (size(data_input, 1) / 2) + 1;
for m = 1 : 1
    start_test = 3001;
    inMF = zeros(size(spec, 2), size(data_input, 2));
    outMF = zeros(size(spec, 2), size(data_target, 2));
    max_cluster = m + 29;
    half_life = 110;
    threshold_mf = 0.94;
    min_rule_weight = 0.55;
    
%     figure;
%     plot(1:size(data_input,1),data_input(1:size(data_input,1), 2));
%     figure;
%     hold all;
%     plot(1:size(data_input,1),data_input(1:size(data_input,1), 1));
%     for l=3:size(data_input,2)
%         plot(1:size(data_input,1),data_input(1:size(data_input,1), l));
%     end
     
    disp(['Running algo : ', spec(i).algo]);

    system = mar_trainOnline(data_input, data_target, spec(i).algo, max_cluster, half_life, threshold_mf, min_rule_weight);
    system = ron_calcErrors(system, data_target(start_test : size(data_target, 1)));

    system.num_rules = mean(system.net.ruleCount(start_test : size(data_target, 1)));
    
    figure;
    str = [sprintf('Actual VS Predicted <-> '), num2str(max_cluster)];
    title(str);

%     for l = 1:size(data_target,2)
%         hold on;
%         plot(1:size(data_target,1),data_target(1:size(data_target,1)), 'b');
%         plot(1:size(system.predicted,1),system.predicted(1:size(data_target,1)), 'r');
%     end
    
    for l = 1:size(data_target,2)
        hold on;
        plot(start_test:size(data_target,1),data_target(start_test:size(data_target,1)), 'b');
        plot(start_test:size(system.predicted,1),system.predicted(start_test:size(data_target,1)), 'r');
    end

    legend('Actual','eMFIS');

%     r(i, Z) = system.R;
%     r2(i,Z) = system.R2;
%     rmse(i, Z) = sqrt(system.MSE);
%     rules(i, Z) = system.num_rules;
    comp_result(m).rmse = system.RMSE;
    comp_result(m).num_rules = system.num_rules;
                
end
%legend('Actual','ieRSPOP++', 'RSPOP', 'ANFIS', 'SAFIN');
clear data_input data_target;