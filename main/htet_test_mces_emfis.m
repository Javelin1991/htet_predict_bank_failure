% clear everything
clear;
clc;

% data pre-processing
load BankSet;
load Survived_Banks;
load Failed_Banks;

All = AllBanks;
Survived = Survived_Banks;
Failed = Failed_Banks;
Labels = ["CAPADE", "OLAQLY", "PROBLO", "ADQLLP", "PLAQLY", "NIEOIN", "NINMAR", "ROE", "LIQUID", "GROWLA"];

%calculate mising rows for failed banks
Total_Failed_Banks = size(Failed, 1);
NaN_Rows_Failed = isnan(Failed);
NaN_Sum_Failed = sum(isnan(Failed(:,(3:12))));
Nan_Sum_Percent_Failed  = htet_cal_nan_percent(NaN_Sum_Failed, 10, Total_Failed_Banks);
[M1, I1] = max(Nan_Sum_Percent_Failed);
Max_Missing_Cov_Failed = I1;

%preprocess the data
Sample_Failed_Banks = htet_pre_process_bank_data(Failed, 0.34, 2000);


warning('off');

%%% failed banks
disp('Training 34% random failed bank data, sorted by bank and year');
data_input = Sample_Failed_Banks(:, 3:12);
%correlation matrix
%data_input_cov = cov(data_input);
%[R_Failed, R_Failed_Sigma] = corrcov(data_input_cov);
data_target = Sample_Failed_Banks(:, Max_Missing_Cov_Failed);
% parameter setup
train_data = data_input
train_output = data_target
ite = 2
induction = 'eMFIS'

% weight ranking of the features
weight = evalsel(train_data,train_output,ite,induction);

ranking = weight(:,2)
% plot bar graph for weight ranking
figure;
bar(ranking); % plot the matrix
set(gca, 'XTick', 1:10); % center x-axis ticks on bins
set(gca, 'XTickLabel', Labels); % set x-axis labels
title('Failed Bank Features Weight Ranking', 'FontSize', 14); % set title
colormap('jet'); % set the colorscheme


[~,inx]=sort(ranking, 'descend');
sorted_data_input = data_input(:,inx);
RMSE = [];

for itr = 1: size(ranking, 1)
    %%% failed bankss
    spec = 10;
    algo = 'emfis';

    disp('Training 34% random failed bank data, sorted by bank and year');
    max_cluster = 40;
    half_life = 10; %half_life = 10 works best
    threshold_mf = 0.9999;
    min_rule_weight = 0.7;
    data_input = sorted_data_input(:, 1:itr);
    input = data_input;
    data_target = Sample_Failed_Banks(:, Max_Missing_Cov_Failed);
    start_test = size(data_input, 1) * 0.8;
    inMF = zeros(size(spec, 2), size(data_input, 2));
    outMF = zeros(size(spec, 2), size(data_target, 2));

    disp(['Running algo : ', algo]);
    ie_rules_no = 2;
    create_ie_rule = 0;
    system = mar_trainOnline(ie_rules_no ,create_ie_rule, data_input, data_target, algo, max_cluster, half_life, threshold_mf, min_rule_weight);

%    system = mar_trainOnline(data_input, data_target, algo, max_cluster, half_life, threshold_mf, min_rule_weight);
    system = ron_calcErrors(system, data_target(start_test : size(data_target, 1)));
    system.num_rules = mean(system.net.ruleCount(start_test : size(data_target, 1)));

    % figure;
    % str = [sprintf('Actual VS Predicted <-> '), num2str(max_cluster)];
    % title(str);
    %
    % for l = 1:size(data_target,2)
    %     hold on;
    %     plot(1:size(data_target,1),data_target(1:size(data_target,1)), 'b');
    %     plot(1:size(system.predicted,1),system.predicted(1:size(data_target,1)), 'r');
    % end
    %
    % legend('Actual','Predicted');

    % comp_result(m).rmse = system.RMSE;
    % comp_result(m).num_rules = system.num_rules;
    disp('data input is now')
    disp(data_input)
    
    disp('current RMSE is')
    disp(system.RMSE)
    RMSE = [RMSE system.RMSE]
end

figure;
plot(RMSE');
