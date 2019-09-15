% XXXXXXXXXXXXXXXXXXXXXXXXXXX htet_get_classification_results XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   to calculate equal error rate or false positive rate or false negative rate
% Syntax    :
%
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function [TP, FP, TN, FN, FNR, FPR, Acc, Min_Weighted_Sum, Optimal_Class_Cost_Ratio] = htet_get_classification_results(trueMat, predictedMat)
% This function calculates True Positives, False Positives, True Negatives
% and False Negatives for two matrices of equal size assuming they are
% populated by 1's and 0's.
% The trueMat contains the actual true values while the predictedMat
% contains the 1's and 0's predicted from the algorithm used.
  adder = trueMat + predictedMat;
  TP = length(find(adder == 2));
  TN = length(find(adder == 0));
  subtr = trueMat - predictedMat;
  FP = length(find(subtr == -1));
  FN = length(find(subtr == 1));

  correct_predictions = length(find(subtr == 0));
  test_examples = length(trueMat);
  Acc = (correct_predictions * 100)/test_examples;

  FNR = (FN/(TP + FN)) * 100; % TP + FN = #POS
  FPR = (FP/(TN + FP)) * 100; % TN + FP = #NEG

  FNR_raw = (FN/(TP + FN));
  FPR_raw = (FP/(TN + FP));

  FNR_Cost = 1
  FPR_Cost = 1
  COST = [];

  % for i=1:30
  %   FNR_Cost = FNR_Cost * i * FNR_raw;
  %   FPR_Cost = FPR_Cost * FPR_raw;
  %   tc = FNR_Cost + FPR_Cost;
  %   COST = [COST, tc]
  % end
  % [M, I] = min(COST);
  % Min_Weighted_Sum = M;
  % Optimal_Class_Cost_Ratio = I;

  Min_Weighted_Sum = 1; % hardcoded temporarily
  Optimal_Class_Cost_Ratio = 1; % hardcoded temporarily
end
