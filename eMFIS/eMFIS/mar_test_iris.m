load Iris;
load Iris_test;

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

run = 13;

switch run
    case 0
        data_input = iris_input;
        data_target = iris_target;
        start_test = 1;
        max_cluster = 13;
        half_life = inf;
        threshold_mf = 0.8;
        min_rule_weight = 0.7;
        
    case 1
        data_input = iris_1_input;
        data_target = iris_1_target(:,1);
        start_test = 61;
        max_cluster = 13;
        half_life = inf;
        threshold_mf = 0.85;
        min_rule_weight = 0.6;
    
    case 11
        data_input = iris_1_input;
        data_target = iris_1_target(:,2);
        start_test = 61;
        max_cluster = 13;
        half_life = inf;
        threshold_mf = 0.95;
        min_rule_weight = 0.6;
    
    case 12
        data_input = iris_1_input;
        data_target = iris_1_target(:,3);
        start_test = 61;
        max_cluster = 13;
        half_life = inf;
        threshold_mf = 0.87;
        min_rule_weight = 0.6;
        
    case 13
        data_input = iris_1_input;
        data_target = iris_1_target(:,4);
        start_test = 61;
        max_cluster = 14;
        half_life = inf;
        threshold_mf = 0.8;
        min_rule_weight = 0.15;
       
    case 2
        data_input = iris_2_input;
        data_target = iris_2_target;
        start_test = 76;
        max_cluster = 13;
        half_life = inf;
        threshold_mf = 0.9;
        min_rule_weight = 0.7;
        
    case 3
        data_input = iris_3_input;
        data_target = iris_3_target;
        start_test = 101;
        max_cluster = 13;
        half_life = inf;
        threshold_mf = 0.65;
        min_rule_weight = 0.1;
end  
    
    %start_test = (size(data_input, 1) / 2) + 1;
for m = 1 : 1
    inMF = zeros(size(spec, 2), size(data_input, 2));
    outMF = zeros(size(spec, 2), size(data_target, 2));
    
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

    for l = 1:size(data_target,2)
        hold on;
        plot(1:size(data_target,1),data_target(1:size(data_target,1)), 'b');
        plot(1:size(system.predicted,1),system.predicted(1:size(data_target,1)), 'r');
    end

    legend('Actual','eMFIS');

    comp_result(m).rmse = system.RMSE;
    comp_result(m).num_rules = system.num_rules;
                
end
%legend('Actual','ieRSPOP++', 'RSPOP', 'ANFIS', 'SAFIN');
clear data_input data_target;