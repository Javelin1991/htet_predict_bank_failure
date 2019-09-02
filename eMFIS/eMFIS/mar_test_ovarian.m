load ovarian_cv;

warning('off');

i = 1;
spec(i).algo = 'emfis';       

 
for g = 1:1
    
for m = 1 : 1
    
%     if g == 1
%         data_input = cv_g0{m}.input;
%         data_target = cv_g0{m}.label;
%     else if g == 2
%             data_input = cv_g1{m}.input;
%             data_target = cv_g1{m}.label;
%         else if g == 3
%                 data_input = cv_g2{m}.input;
%                 data_target = cv_g2{m}.label;
%             else if g == 4
%                     data_input = cv_g3{m}.input;
%                     data_target = cv_g3{m}.label;
%                 else
%                     data_input = cv_g4{m}.input;
%                     data_target = cv_g4{m}.label;
%                 end
%             end
%         end
%     end
            
    data_input = cv_ovarian{g}{m}.input;
    data_target = cv_ovarian{g}{m}.label;    

    start_test = 31;
    inMF = zeros(size(spec, 2), size(data_input, 2));
    outMF = zeros(size(spec, 2), size(data_target, 2));
    max_cluster = 13;
    half_life = inf;
    threshold_mf = 0.7;
    min_rule_weight = 0.4;
    
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
    
%     after_threshold = zeros(size(data_target, 1),1);
%     for x=1: size(data_target, 1)
%         if system.predicted(x) > 0.7151
%             after_threshold(x) = 1;
%         else 
%             after_threshold(x) = 0;
%         end
%     end
    
    figure;
    str = [sprintf('Actual VS Predicted <-> CV'), num2str(m)];
    title(str);

    for l = 1:size(data_target,2)
        hold on;
        plot(1:size(data_target,1),data_target(1:size(data_target,1)), 'b');
        plot(1:size(system.predicted,1),system.predicted(1:size(data_target,1)), 'r');
%        plot(1:size(after_threshold,1),after_threshold(1:size(data_target,1)), 'g');
    end

    legend('Actual','eMFIS');

%     r(i, Z) = system.R;
%     r2(i,Z) = system.R2;
%     rmse(i, Z) = sqrt(system.MSE);
%     rules(i, Z) = system.num_rules;
    ovarian_result{g}{m}.rmse = system.RMSE;
    ovarian_result{g}{m}.num_rules = system.num_rules;
    ovarian_result{g}{m}.predicted = system.predicted;
%    accuracy = length( find(data_target(start_test : size(data_target, 1)) - after_threshold(start_test : size(data_target, 1))== 0));                  
end
end
%legend('Actual','ieRSPOP++', 'RSPOP', 'ANFIS', 'SAFIN');
clear data_input data_target;