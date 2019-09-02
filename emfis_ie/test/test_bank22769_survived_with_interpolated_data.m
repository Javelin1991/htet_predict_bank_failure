load Bank22769_Inter_Input;
load Bank22769_Inter_Output;

load Bank22769_target;
load Bank22769_input;

load Bank22769_Inter_Delta_Input;
load Bank22769_Inter_Delta_Output;

load Bank22769_Delta_Delta_Input;
load Bank22769_Delta_Delta_Output;

warning('off');

i = 1;
algo = 'emfis';
spec = 9;
res = [];
% data_input = Bank22769_input;
% data_target = Bank22769_target;

    %start_test = (size(data_input, 1) / 2) + 1;
for Z = 1: 3
for m = 1 : 1
    switch Z
        case 1
            %%% the code below works for Bank22769_Inter_Input
              start_test = 1;
              max_cluster = 20;
              half_life = 10;
              threshold_mf = 0.9995;
              min_rule_weight = 0.5;
              data_input = Bank22769_Inter_Input;
              data_target = Bank22769_Inter_Output;
              inMF = zeros(size(spec, 2), size(data_input, 2));
              outMF = zeros(size(spec, 2), size(data_target, 2));
        case 2
            %%% the code below works for Bank22769_Inter_Delta_Input
            start_test = 1;
            max_cluster = 25;
            half_life = 10; %half_life = 10 works best
            threshold_mf = 0.9999;
            min_rule_weight = 0.7;
            data_input = Bank22769_Inter_Delta_Input;
            data_target = Bank22769_Inter_Delta_Output;
            inMF = zeros(size(spec, 2), size(data_input, 2));
            outMF = zeros(size(spec, 2), size(data_target, 2));
        case 3
              %%% the code below works for Bank22769_Delta_Delta_Input
            start_test = 1;
            max_cluster = 25;
            half_life = 10; %half_life = 10 works best
            threshold_mf = 0.995;
            min_rule_weight = 0.65;
            data_input = Bank22769_Delta_Delta_Input;
            data_target = Bank22769_Delta_Delta_Output;
            inMF = zeros(size(spec, 2), size(data_input, 2));
            outMF = zeros(size(spec, 2), size(data_target, 2));
    end


%     figure;
%     plot(1:size(data_input,1),data_input(1:size(data_input,1), 2));
%     figure;
%     hold all;
%     plot(1:size(data_input,1),data_input(1:size(data_input,1), 1));
%     for l=3:size(data_input,2)
%         plot(1:size(data_input,1),data_input(1:size(data_input,1), l));
%     end

    disp(['Running algo : ', algo]);
    ie_rules_no = 2;
    create_ie_rule = 0;
    system = mar_trainOnline(ie_rules_no ,create_ie_rule, data_input, data_target, algo, max_cluster, half_life, threshold_mf, min_rule_weight);

%    system = mar_trainOnline(data_input, data_target, algo, max_cluster, half_life, threshold_mf, min_rule_weight);
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

    legend('Actual','Predicted');

    comp_result(m).rmse = system.RMSE;
    comp_result(m).num_rules = system.num_rules;


    r = [system.RMSE system.num_rules];
    res = [res; r];

end

clear data_input data_target;
end


disp('Final RMSE and Rules');
disp(r);
disp(res);
