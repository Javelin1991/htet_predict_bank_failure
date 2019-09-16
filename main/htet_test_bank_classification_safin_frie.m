% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_test_bank_classification_safin_frie XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   used to test bank failure prediction/classification using SaFIN(FRIE)
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
RESOLUTION = 0.001;

% adjust cut_off value
% cut_off = 0.185;
cut_off = 0;

Acc = [];
Acc2 = [];
FPR = [];
FNR = [];
Optimal_Ratio = [];
Min_Weighted_Sum = [];
CURR_SMALLEST = intmax;
fpr_penalized_cost = 1;
fnr_penalized_cost = [1; 5; 10; 15; 20; 25; 30];
b_count = 1;
MIN_EER = [];
MIN_FPR = [];
MIN_FNR = [];

Bisector = [];

for k=0:99
  Bisector = [Bisector, k];
end

best_acc = intmin;

%%%%%%%%%%%%%% after finding the best EER value, calculate misclassification cost %%%%%%%%%%%%%%%%%

% for i=1: length(testData)
%     if net_out(i) > cut_off
%         after_threshold(i) = 1;
%     elseif net_out(i) < cut_off
%         after_threshold(i) = 0;
%     elseif net_out(i) == cut_off
%         after_threshold(i) = cut_off;
%         eer_count = eer_count + 1;
%     else
%         unclassified_count = unclassified_count + 1;
%     end
% end
% net_result.predicted = {net_out};
% net_result.after_threshold = {after_threshold};
% correct_predictions = length(find(testData(:,4) - after_threshold(:,1) == 0));
% test_examples = length(testData);
% net_result.accuracy = (correct_predictions * 100)/test_examples;
% net_result.unclassified = (unclassified_count * 100)/test_examples;
% net_result.EER = (eer_count * 100)/test_examples;
%
% [TP, FP, TN, FN, fnr, fpr, acc, min_weight_sum, optimal_ratio] = htet_get_classification_results(testData(:,4), after_threshold(:,1))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%% to find out the best cut-off point or EER value %%%%%%%%%%%%%%%%%
%
% for z=1:length(fnr_penalized_cost)

  while(cut_off <= 1)
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

    FPR = [FPR, fpr];
    FNR = [FNR, fnr];

    % fpr_cost = fpr * fpr_penalized_cost;
    % fnr_cost = fnr * fnr_penalized_cost(z,:);
    fpr_cost = fnr;
    fnr_cost = fpr;

    if 6.3636 == round(fpr_cost,4)
      eer_cut_off = cut_off;
    end

    TOTAL = (fpr_cost + fnr_cost)/2;

    if TOTAL < CURR_SMALLEST
      min_eer_point = cut_off;
      CURR_SMALLEST = TOTAL;
      BEST_FPR = fpr;
      BEST_FNR = fnr;
    end

    if acc > best_acc
      best_acc = acc;
      best_acc_cutoff = cut_off;
      best_acc_fpr = fpr;
      best_acc_fnr = fnr;
    end

    Acc = [Acc; net_result.accuracy];
    Acc2 = [Acc2; acc];
    Optimal_Ratio = [Optimal_Ratio; optimal_ratio];
    Min_Weighted_Sum = [Min_Weighted_Sum; min_weight_sum];

    b_count = b_count + 1;
    cut_off = cut_off + 0.001;
    unclassified_count = 0;
    eer_count = 0;
    after_threshold = zeros(length(testData),1);
  end


  % reset all values
  % MIN_EER = [MIN_EER; min_eer_point];
  % MIN_FPR = [MIN_FPR; BEST_FPR];
  % MIN_FNR = [MIN_FNR; BEST_FNR];
  %
  % % Labels = ["0.05", "0.1", "0.1"', "0.2", "0.25", "0.3", "0.35", "0.4", "0.45", "0.5", "0.55", "0.6", "0.65", "0.7", "0.75", "0.8", "0.85", "0.9", "0.95", "1"];
  % % reset all values
  % unclassified_count = 0;
  % eer_count = 0;
  % after_threshold = zeros(length(testData),1);
  % cut_off = 0;
  % Acc = [];
  % Acc2 = [];
  % FPR = [];
  % FNR = [];
  % Optimal_Ratio = [];
  % Min_Weighted_Sum = [];
  % CURR_SMALLEST = intmax;
  % fpr_penalized_cost = 1;
  % TOTAL = 0;
  %
  % figure;
  % bar(Acc); % plot the matrix
  % % set(gca, 'XTick', 1:20); % center x-axis ticks on bins
  % % set(gca, 'XTickLabel', Labels); % set x-axis labels
  % title('Bank Failure Classification Accuracy', 'FontSize', 14); % set title
  % colormap('jet'); % set the colorscheme

  figure;
  plot(FPR, FNR, 'b'); % plot the matrix
  hold on;
  plot(Bisector, Bisector, 'r'); % plot the matrix

  %
  % hold on;
  % plot(Bisector, Bisector); % plot the matrix
  % title('Bank Failure Classification Accuracy', 'FontSize', 14); % set title
  % colormap('jet'); % set the colorscheme

% end
% Intersection = InterX([FPR;FNR],[Bisector;Bisector]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load handel
sound(y,Fs)
