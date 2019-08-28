% XXXXXXXXXXXXXXXXXXXXXXXXXXX sus_scale XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Mar 3 2019
% Function  :
% Syntax    :   pre_process_bank_data(input, data_percent, total)
%
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

clc;
clear;

load Failed_Banks;
load Survived_Banks;


input = Failed_Banks;

input_with_NaN = input(any(isnan(input), 2), :)
input(any(isnan(input), 2), :) = [];
input_without_NaN = input;


D = input_without_NaN(:,3:12);
data_to_train_system = D(:,[1 5]);
data_to_predict = D(:,8);


spec = 10;
algo = 'emfis';
max_cluster = 40;
half_life = 10;
threshold_mf = 0.9999;
min_rule_weight = 0.7;
x = data_to_train_system;
y = data_to_predict;
start_test = size(x, 1) * 0.8;

disp(['Running algo : ', algo]);
ie_rules_no = 2;
create_ie_rule = 0;
trained_system = mar_trainOnline(ie_rules_no ,create_ie_rule, x, y, algo, max_cluster, half_life, threshold_mf, min_rule_weight);

E = input_with_NaN(5,3:12);
E = [E; input_with_NaN(10,3:12)];
E = [E; input_with_NaN(20,3:12)];

x = E(:,[1 5]);
y = E(:,8);

for i = 1:length(x)
    y(i) = htet_reconstruct_using_trained_emfis(trained_system, x(i), );
end
