% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_test_mces_emfis_regression XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   used to select important features using MCES and eMFIS(FRIE) for regression task
% i.e. to predict missing values
% Stars     :
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

clear;
clc;

% data pre-processing
load BankSet;
load Survived_Banks;
load Failed_Banks;

All = AllBanks;
Survived = Survived_Banks;
Failed = Failed_Banks;

%preprocess the data by random sampling and afterwards, sorted by sorted by bank and year
Sample_Failed_Banks = htet_pre_process_bank_data(Failed, 0.1, 0);
% Sample_Failed_Banks = Failed(1:size(Failed, 1) * 0.1, :);
% Sample_Failed_Banks(any(isnan(Sample_Failed_Banks), 2), :) = [];

Sample_Failed_Banks = Sample_Failed_Banks(:,3:12);

warning('off');


% parameter setup
col_to_predict = 1;

% Labels = ["CAPADE", "OLAQLY", "PROBLO", "ADQLLP", "PLAQLY", "NIEOIN", "NINMAR", "ROE", "LIQUID", "GROWLA"];

if col_to_predict == 1
  Labels = ["OLAQLY", "PROBLO", "ADQLLP", "PLAQLY", "NIEOIN", "NINMAR", "ROE", "LIQUID", "GROWLA"];
elseif col_to_predict == 5
  Labels = ["CAPADE", "OLAQLY", "PROBLO", "ADQLLP", "NIEOIN", "NINMAR", "ROE", "LIQUID", "GROWLA"];
else
  Labels = ["CAPADE", "OLAQLY", "PROBLO", "ADQLLP", "PLAQLY", "NIEOIN", "NINMAR", "LIQUID", "GROWLA"];
end


data_input = Sample_Failed_Banks;
data_input(:,col_to_predict) = [];
data_target = Sample_Failed_Banks(:, col_to_predict);

train_data = data_input;
train_output = data_target;
ite = 3;
induction = 'eMFIS';

% weight ranking of the features
weight = evalsel(train_data,train_output,ite,induction);

ranking = weight(:,2);
% plot bar graph for weight ranking
figure;
bar(ranking); % plot the matrix
set(gca, 'XTick', 1:10); % center x-axis ticks on bins
set(gca, 'XTickLabel', Labels); % set x-axis labels
title('Failed Bank Features Weight Ranking', 'FontSize', 14); % set title
colormap('jet'); % set the colorscheme


[~,inx]=sort(ranking, 'descend');
sorted_data_input = data_input(:,inx);
sorted_labels = Labels(:, inx);
RMSE = [];

% iterate through each feature starting from the higest rank to lowest rank
for itr = 1: size(ranking, 1)

    % failed banks
    disp('Training random failed bank data, sorted by bank and year');

    % experiment setup
    spec = 10;
    algo = 'emfis';
    max_cluster = 40;
    half_life = 10;
    threshold_mf = 0.9999;
    min_rule_weight = 0.7;
    x = sorted_data_input(:, 1:itr);
    y = Sample_Failed_Banks(:, col_to_predict);
    start_test = size(x, 1) * 0.8;

    disp(['Running algo : ', algo]);
    ie_rules_no = 2;
    create_ie_rule = 0;
    system = mar_trainOnline(ie_rules_no ,create_ie_rule, x, y, algo, max_cluster, half_life, threshold_mf, min_rule_weight);
    system = ron_calcErrors(system, data_target(start_test : size(y, 1)));
    system.num_rules = mean(system.net.ruleCount(start_test : size(y, 1)));

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

    disp('data input is now');
    disp(x);

    disp('current RMSE is');
    disp(system.RMSE);
    RMSE = [RMSE system.RMSE];
end

figure;
plot(RMSE');
set(gca, 'XTick', 1:10); % center x-axis ticks on bins
set(gca, 'XTickLabel', sorted_labels); % set x-axis labels
title('RMSE produced by ranked features (highest-lowest)', 'FontSize', 14); % set title
colormap('jet'); % set the colorscheme
