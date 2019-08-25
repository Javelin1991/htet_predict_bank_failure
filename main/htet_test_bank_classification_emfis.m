clear;
clc;

load Correct_All_Banks;
load Survived_Banks;
load Failed_Banks;
load Survived;
load Failed;


Failed_Banks_Group_By_Bank_ID = [];
Survived_Banks_Group_By_Bank_ID = [];

backward_offset = 0;
output_1 = htet_filter_bank_data_by_index(Survived_Banks, backward_offset);
output_2 = htet_filter_bank_data_by_index(Failed_Banks, backward_offset);

Survived_Banks_Group_By_Bank_ID = output_1.result;
SB_IDs = output_1.IDs;

Failed_Banks_Group_By_Bank_ID = output_2.result;
FB_IDs = output_2.IDs;

SB = cvpartition(length(SB_IDs),'KFold',5);
FB = cvpartition(length(FB_IDs),'KFold',5);

CV = [];

for i = 1:5
    I = test(SB,i);
    cv_sb = [];
    for j = 1:length(I)
        if I(j,:) == 1
            cv_sb = [cv_sb; Survived_Banks_Group_By_Bank_ID(j, :)];
        end
    end

    I2 = test(FB, i);
    cv_fb = [];
    for k = 1:length(I2)
        if I2(k,:) == 1
           cv_fb = [cv_fb; Failed_Banks_Group_By_Bank_ID(k, :)];
        end
    end

    cv_sb_plus_cv_fb = vertcat(cv_sb,cv_fb);
    final_cv = htet_pre_process_bank_data(cv_sb_plus_cv_fb, 1, 0);
    CV = [CV; {final_cv}];
end


% spec = 10;
% algo = 'emfis';
% max_cluster = 40;
% half_life = 10;
% threshold_mf = 0.9999;
% min_rule_weight = 0.7;
% x = sorted_data_input(:, 1:itr);
% y = Sample_Failed_Banks(:, col_to_predict);
% start_test = size(x, 1) * 0.8;

algo = 'emfis';
max_cluster = 13;
half_life = inf;
threshold_mf = 0.8;
min_rule_weight = 0.1;
spec = 6;
ie_rules_no = 2;
create_ie_rule =1;

for config = 1:1
    for data_set = 1:5
        data_input = CV{data_set};
        data_input = data_input(:,3:12)
        start_test = (size(data_input, 1) * 0.8) + 1;

        data_target = data_input(:,2)

        disp(['Running algo : ', algo]);
        ie_rules_no = 2;
        create_ie_rule =0;
        system = mar_trainOnline(ie_rules_no ,create_ie_rule, data_input, data_target, algo, max_cluster, half_life, threshold_mf, min_rule_weight);
        system = ron_calcErrors(system, data_target(start_test : size(data_target, 1)));
        system.num_rules = mean(system.net.ruleCount(start_test : size(data_target, 1)));

        after_threshold = zeros(size(data_target, 1),1);
        for x=1: size(data_target, 1)
            if system.predicted(x) > 0.5
                after_threshold(x) = 1;
            elseif system.predicted(x) < 0.5
                after_threshold(x) = 0;
            else
                after_threshold(x) = 0.5;
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

        legend('Actual','Prediction');
        comp_result(data_set).rmse = system.RMSE;
        comp_result(data_set).num_rules = system.num_rules;
        comp_result(data_set).R = system.R;
        comp_result(data_set).predicted = system.predicted;
        comp_result(data_set).after_threshold = after_threshold;
        comp_result(data_set).accuracy = length( find(data_target(start_test : size(data_target, 1)) - after_threshold(start_test : size(data_target, 1))== 0));
    end
end
%legend('Actual','ieRSPOP++', 'RSPOP', 'ANFIS', 'SAFIN');
clear data_input data_target;
