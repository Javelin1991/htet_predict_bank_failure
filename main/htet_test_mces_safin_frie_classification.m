% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_test_mces_safin_frie_classification XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   used to select important features using MCES and SaFIN_FRIE for bank failure classification
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

clear;
clc;

load Failed_Banks;
load Survived_Banks;

warning('off');

Labels = ["CAPADE", "OLAQLY", "PROBLO", "ADQLLP", "PLAQLY", "NIEOIN", "NINMAR", "ROE", "LIQUID", "GROWLA"];


FB = htet_pre_process_bank_data(Failed_Banks,1,0);
SB = htet_pre_process_bank_data(SB,1,length(FB));

trainData_D0 = htet_pre_process_bank_data(vertcat(FB,SB),1,0);
trainData_D0 = trainData_D0(:,[3:12 2]);

start_test = (size(D0, 1) * 0.70) + 1;
trainData_D0 = D0(1:start_test-1,:);
testData_D0 = D0(start_test:length(D0), :);

ite = 2;
induction = 'SaFIN_FRIE';

% weight ranking of the features
[weight, net] = evalsel(trainData_D0,[],ite,induction, params);
total_weight = [total_weight weight(:,2)];

ranking = total_weight';
%%% mces feature selection using five folds %%%

% plot bar graph for weight ranking
figure;
bar(ranking); % plot the matrix
set(gca, 'XTick', 1:10); % center x-axis ticks on bins
set(gca, 'XTickLabel', Labels); % set x-axis labels
title('Bank Failure Classification Features Weight Ranking', 'FontSize', 14); % set title
colormap('jet'); % set the colorscheme

[~,inx]=sort(ranking, 'descend');
sorted_labels = Labels(:, inx);
EER = [];
%%% iterate through each feature starting from the higest rank to lowest rank %%%
%%% using single fold %%%
sorted_data_input = testData_D0(:,inx);
for itr = 1: 10
    for i = 1 : size(testData_D0,1)
        net_out(i,:) = SaFIN_FRIE_test(testData_D0(i, 1:itr),itr,1,net.no_InTerms,net.InTerms,net.no_OutTerms,net.OutTerms,net.Rules);
    end
    out = htet_find_optimal_cut_off(testData_D0(:,11), net_out, threshold);
    EER = [EER out.MIN_EER{1,1}];
end

figure;
plot(EER');
set(gca, 'XTick', 1:10); % center x-axis ticks on bins
set(gca, 'XTickLabel', sorted_labels); % set x-axis labels
title('RMSE produced by ranked features (highest-lowest)', 'FontSize', 14); % set title
colormap('jet'); % set the colorscheme
