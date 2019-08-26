clear;
clc;

load CV_Classification;
% load Correct_All_Banks;
% load Survived_Banks;
% load Failed_Banks;
% load Survived;
% load Failed;
%
%
% Failed_Banks_Group_By_Bank_ID = [];
% Survived_Banks_Group_By_Bank_ID = [];
%
% backward_offset = 0;
% output_1 = htet_filter_bank_data_by_index(Survived_Banks, backward_offset);
% output_2 = htet_filter_bank_data_by_index(Failed_Banks, backward_offset);
%
% Survived_Banks_Group_By_Bank_ID = output_1.result;
% SB_IDs = output_1.IDs;
%
% Failed_Banks_Group_By_Bank_ID = output_2.result;
% FB_IDs = output_2.IDs;
%
% SB = cvpartition(length(SB_IDs),'KFold',5);
% FB = cvpartition(length(FB_IDs),'KFold',5);
%
% CV = [];
%
% for i = 1:5
%     cv_sb_test = htet_generate_cross_validation_data(test(SB,i), Survived_Banks_Group_By_Bank_ID);
%     cv_fb_test = htet_generate_cross_validation_data(test(FB,i), Failed_Banks_Group_By_Bank_ID);
%
%     cv_sb_train = htet_generate_cross_validation_data(training(SB, i), Survived_Banks_Group_By_Bank_ID);
%     cv_fb_train = htet_generate_cross_validation_data(training(FB, i), Failed_Banks_Group_By_Bank_ID);
%
%     cv_train = vertcat(cv_sb_train,cv_fb_train);
%     cv_test = vertcat(cv_sb_test,cv_fb_test);
%
%     train_cv = htet_pre_process_bank_data(cv_train, 1, 0);
%     test_cv = htet_pre_process_bank_data(cv_test, 1, 0);
%
%     final_cv = vertcat(train_cv, test_cv);
%     CV = [CV; {final_cv}];
% end

algo = 'emfis';
max_cluster = 40;
half_life = inf;
threshold_mf = 0.9999;
min_rule_weight = 0.7;
spec = 10;

% algo = 'emfis';
% max_cluster = 13;
% half_life = inf;
% threshold_mf = 0.8;
% min_rule_weight = 0.1;
% spec = 6;
% ie_rules_no = 2;
% create_ie_rule =1;

for data_set = 5:5

    D = CV{data_set};
    data_target = D(:,2);
    data_input = D(:,3:12);
    target_size = size(data_target, 1);
    start_test = (size(data_input, 1) * 0.8) + 1;

    disp(['Running algo : ', algo]);
    ie_rules_no = 2;
    create_ie_rule = 0;
    system = mar_trainOnline(ie_rules_no ,create_ie_rule, data_input, data_target, algo, max_cluster, half_life, threshold_mf, min_rule_weight);
    system = ron_calcErrors(system, data_target(start_test : target_size));
    system.num_rules = mean(system.net.ruleCount(start_test : target_size));

    after_threshold = zeros(target_size,1);
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
        plot(1:size(system.predicted,1),system.predicted(1:size(data_target,1)), 'r');
        % plot(1:size(after_threshold,1),after_threshold(1:size(data_target,1)), 'r');
    end
    legend('Actual','Prediction');

    comp_result(data_set).rmse = system.RMSE;
    comp_result(data_set).num_rules = system.num_rules;
    comp_result(data_set).R = system.R;
    comp_result(data_set).predicted = system.predicted;
    comp_result(data_set).after_threshold = after_threshold;
    correct_predictions = length(find(data_target(start_test : target_size) - after_threshold(start_test :target_size) == 0));
    test_examples = (target_size - start_test) + 1;
    comp_result(data_set).accuracy = (correct_predictions * 100)/test_examples;
end

total_accuracy = comp_result.accuracy;

% for i = 1: 5
%   total_accuracy = total_accuracy + comp_result(data_set).accuracy(i);
% end
%
% final_accuracy = total_accuracy/5;
