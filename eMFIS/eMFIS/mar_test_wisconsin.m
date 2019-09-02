load Wisconsin;

warning('off');

i = 1;
spec(i).algo = 'sopop';
%spec(i).algo = 'esopop';

%i = i + 1;
%spec(i).algo = 'rspop'; i = i + 1;
% %(i).algo = 'pop'; i = i + 1;
% % spec(i).algo = 'efunn'; i = i + 1;
%spec(i).algo = 'anfis'; i = i + 1;
% % spec(i).algo = 'denfis'; i = i + 1;
%spec(i).algo = 'saifin'; i = i + 1;
%         

data_input = wisconsin_input;
data_target = wisconsin_target;
    
    %start_test = (size(data_input, 1) / 2) + 1;
for m = 1 : 1
    start_test = 301;
    inMF = zeros(size(spec, 2), size(data_input, 2));
    outMF = zeros(size(spec, 2), size(data_target, 2));
    max_cluster = m + 199;
    half_life = inf;
    threshold_mf = 0.87;
    min_rule_weight = 0.001;
    
%     figure;
%     plot(1:size(data_input,1),data_input(1:size(data_input,1), 2));
%     figure;
%     hold all;
%     plot(1:size(data_input,1),data_input(1:size(data_input,1), 1));
%     for l=3:size(data_input,2)
%         plot(1:size(data_input,1),data_input(1:size(data_input,1), l));
%     end
     
    disp(['Running algo : ', spec(i).algo]);

    ensemble = mar_trainOnline(data_input, data_target, spec(i).algo, max_cluster, half_life, threshold_mf, min_rule_weight);
    ensemble = ron_calcErrors(ensemble, data_target(start_test : size(data_target, 1)));

    ensemble.num_rules = mean(ensemble.net_struct.net.ruleCount(start_test : size(data_target, 1)));
                    
    figure;
    str = [sprintf('Actual VS Predicted <-> '), num2str(max_cluster)];
    title(str);

    for l = 1:size(data_target,2)
        hold on;
        plot(1:size(data_target,1),data_target(1:size(data_target,1)), 'b');
        plot(1:size(ensemble.predicted,1),ensemble.predicted(1:size(data_target,1)), 'r');
    end

    legend('Actual','eMFIS');

%     r(i, Z) = ensemble.R;
%     r2(i,Z) = ensemble.R2;
%     rmse(i, Z) = sqrt(ensemble.MSE);
%     rules(i, Z) = ensemble.num_rules;
    comp_result(m).rmse = ensemble.RMSE;
    comp_result(m).num_rules = ensemble.num_rules;
                
end
%legend('Actual','ieRSPOP++', 'RSPOP', 'ANFIS', 'SAFIN');
clear data_input data_target;