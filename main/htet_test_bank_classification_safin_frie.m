% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_test_bank_classification_emfis XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   used to test bank failure prediction/classification using eMFIS(FRIE)
% CV refers to cross validation and 5-fold CV is used below for:
% last year (t) prediction
% one year prior (t-1) prediction
% two year prior (t-2) prediction
% It takes around 70 min to run this file
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

clear;
clc;

load CV1_Classification;

D = CV1{1,1};
data_target = D(:,2);
D = D(:,[3 7 10 2]);

start_test = (size(D, 1) * 0.2) + 1;
target_size = length(D);
trainData = D(1:start_test-1,:);
testData = D(start_test:length(D), :);
IND = 3;
OUTD = 1;
Alpha = 0.25;
Beta = 0.65;
Eta = 0.05;
Forgetfactor = 0.99;
Epochs = 300;

[net_out, net_structure] = Run_SaFIN(trainData,testData,IND,OUTD,Alpha,Beta,Epochs,Eta,Forgetfactor);

unclassified_count = 0;
eer_count = 0;
after_threshold = zeros(length(testData),1);
cut_off = 0.2550;
Acc = [];
Acc2 = [];
FPR = [];
FNR = [];
Optimal_Ratio = [];
Min_Weighted_Sum = [];
CURR_SMALLEST = 100;

%%%%%%%%%%%%%% after finding the best EER value, calculate misclassification cost %%%%%%%%%%%%%%%%%

for i=1: length(testData)
    if net_out(i) > cut_off
        after_threshold(i) = 1;
    elseif net_out(i) < cut_off
        after_threshold(i) = 0;
    elseif net_out(i) == cut_off
        after_threshold(i) = cut_off;
        eer_count = eer_count + 1;
    else
        unclassified_count = unclassified_count + 1;
    end
end
net_result.predicted = {net_out};
net_result.after_threshold = {after_threshold};
correct_predictions = length(find(testData(:,4) - after_threshold(:,1) == 0));
test_examples = length(testData);
net_result.accuracy = (correct_predictions * 100)/test_examples;
net_result.unclassified = (unclassified_count * 100)/test_examples;
net_result.EER = (eer_count * 100)/test_examples;

[TP, FP, TN, FN, fnr, fpr, acc, min_weight_sum, optimal_ratio] = htet_get_classification_results(testData(:,4), after_threshold(:,1))

i = 1;
counter = 1;
FNR_Cost = 1;
FPR_Cost = 1;

while (i <= 30)
  FNR_Cost = FNR_Cost * i * fnr;
  FPR_Cost = FPR_Cost * fpr;
  FPR = [FPR; FPR_Cost];
  FNR = [FNR; FNR_Cost];
  i = 5 * counter;
  counter = counter + 1;
  FNR_Cost = 1;
  FPR_Cost = 1;
end


%%%%%%%%%%%%%% to find out the best cut-off point or EER value %%%%%%%%%%%%%%%%%
%
% while(cut_off <= 1)
%   for i=1: length(testData)
%       if net_out(i) > cut_off
%           after_threshold(i) = 1;
%       elseif net_out(i) < cut_off
%           after_threshold(i) = 0;
%       elseif net_out(i) == cut_off
%           after_threshold(i) = cut_off;
%           eer_count = eer_count + 1;
%       else
%           unclassified_count = unclassified_count + 1;
%       end
%   end
%   net_result.predicted = {net_out};
%   net_result.after_threshold = {after_threshold};
%   correct_predictions = length(find(testData(:,4) - after_threshold(:,1) == 0));
%   test_examples = length(testData);
%   net_result.accuracy = (correct_predictions * 100)/test_examples;
%   net_result.unclassified = (unclassified_count * 100)/test_examples;
%   net_result.EER = (eer_count * 100)/test_examples;
%
%   [TP, FP, TN, FN, fnr, fpr, acc, min_weight_sum, optimal_ratio] = htet_get_classification_results(testData(:,4), after_threshold(:,1))
%
%   FPR = [FPR; fpr];
%   FNR = [FNR; fnr];
%
%   TOTAL = (fpr + fnr)/2;
%
%   if TOTAL < CURR_SMALLEST
%     min_eer_point = cut_off;
%     CURR_SMALLEST = TOTAL;
%   end
%
%   Acc = [Acc; net_result.accuracy];
%   Acc2 = [Acc2; acc];
%   Optimal_Ratio = [Optimal_Ratio; optimal_ratio];
%   Min_Weighted_Sum = [Min_Weighted_Sum; min_weight_sum];
%
%   cut_off = cut_off + 0.001;
%   unclassified_count = 0;
%   eer_count = 0;
%   after_threshold = zeros(length(testData),1);
% end
%
% % Labels = ["0.05", "0.1", "0.1"', "0.2", "0.25", "0.3", "0.35", "0.4", "0.45", "0.5", "0.55", "0.6", "0.65", "0.7", "0.75", "0.8", "0.85", "0.9", "0.95", "1"];
%
% figure;
% bar(Acc); % plot the matrix
% % set(gca, 'XTick', 1:20); % center x-axis ticks on bins
% % set(gca, 'XTickLabel', Labels); % set x-axis labels
% title('Bank Failure Classification Accuracy', 'FontSize', 14); % set title
% colormap('jet'); % set the colorscheme
%
% figure;
% plot(FNR, FPR); % plot the matrix
% title('Bank Failure Classification Accuracy', 'FontSize', 14); % set title
% colormap('jet'); % set the colorscheme

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load handel
sound(y,Fs)
