load Iris_cv;

warning('off');


algo = 'emfis';


max_cluster = 13;
half_life = inf;
threshold_mf = 0.8;
min_rule_weight = 0.1;         

for config = 1:1
start_test = 51;

for cv = 1:1

data_input = inp{cv};
data_target = out{cv};

    
    %start_test = (size(data_input, 1) / 2) + 1;
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
     
    disp(['Running algo : ', algo]);

    system = mar_trainOnline(data_input, data_target, algo, max_cluster, half_life, threshold_mf, min_rule_weight);
    system = ron_calcErrors(system, data_target(start_test : size(data_target, 1)));

    system.num_rules = mean(system.net.ruleCount(start_test : size(data_target, 1)));
    
    after_threshold = zeros(size(data_target, 1),1);
    for x=1: size(data_target, 1)
        if system.predicted(x) >= 2.2
            after_threshold(x) = 3;
        else if system.predicted(x) >= 1.2
                after_threshold(x) = 2;
            else
                after_threshold(x) = 1;
            end
        end
    end
    
    figure;
    str = [sprintf('Actual VS Predicted <-> '), num2str(max_cluster)];
    title(str);

    for l = 1:size(data_target,2)
        hold on;
        plot(1:size(data_target,1),data_target(1:size(data_target,1)), 'b');
        plot(1:size(system.predicted,1),system.predicted(1:size(data_target,1)), 'g');
        plot(1:size(after_threshold,1),after_threshold(1:size(data_target,1)), 'r');
    end

    legend('Actual','eMFIS');

%     r(i, Z) = system.R;
%     r2(i,Z) = system.R2;
%     rmse(i, Z) = sqrt(system.MSE);
%     rules(i, Z) = system.num_rules;
    comp_result(cv).rmse = system.RMSE;
    comp_result(cv).num_rules = system.num_rules;
    comp_result(cv).R = system.R;
    comp_result(cv).predicted = system.predicted;
    comp_result(cv).after_threshold = after_threshold;
    comp_result(cv).accuracy = length( find(data_target(start_test : size(data_target, 1)) - after_threshold(start_test : size(data_target, 1))== 0));
                
end
end
%legend('Actual','ieRSPOP++', 'RSPOP', 'ANFIS', 'SAFIN');
clear data_input data_target;