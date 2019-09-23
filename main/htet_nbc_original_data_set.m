% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_nbc_original_data_set XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% File  :   htet_nbc_original_data_set
% Testing bank failure prediction using Naive Bayes Classifier (with original data set)
% Refer to FYP for more details
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
clear;
clc;

load 'CV1_Classification';
% load 'CV1_with_top_3_features';
ACC = 0;
fn = 0;
total_FN = [];
total_FP = [];
for cv_num = 1:5
  D = CV1{cv_num,1};
  data_input = D(:,[3 7 12]);
  data_target = D(:,2);
  start_test = (size(D, 1) * 0.8) + 1;
  trainDataInput = data_input(1:start_test-1,:);
  trainDataTarget = data_target(1:start_test-1,:);
  clf = fitcnb(trainDataInput, trainDataTarget);

  testDataInput = data_input(start_test:length(data_input),:);
  testDataTarget = data_target(start_test:length(data_target),:);

  label = predict(clf,testDataInput)
  [TP, FP, TN, FN, FNR, FPR, Acc] = htet_get_classification_results(testDataTarget, label);
  total_FN = [total_FN; FNR];
  total_FP = [total_FP; FPR];
  ACC = ACC + Acc;
  fn = FN + fn;
end
fn = fn/5;
ACC = ACC/5;

ACC_1 = 0;
fn_1 = 0;
total_FN_1 = [];
total_FP_1 = [];

for cv_num = 1:5
  D = CV1{cv_num,1};
  data_input = D(:,[3 7 12]);
  data_target = D(:,2);
  start_test = (size(D, 1) * 0.8) + 1;
  trainDataInput = data_input(1:start_test-1,:);
  trainDataTarget = data_target(1:start_test-1,:);
  clf = fitcnb(trainDataInput, trainDataTarget);

  testDataInput = data_input(start_test:length(data_input),:);
  testDataTarget = data_target(start_test:length(data_target),:);

  label = predict(clf,testDataInput)
  [TP, FP, TN, FN, FNR, FPR, Acc] = htet_get_classification_results(testDataTarget, label);
  total_FN_1 = [total_FN_1; FNR];
  total_FP_1 = [total_FP_1; FPR];
  ACC_1 = ACC_1 + Acc;
  fn_1 = FN + fn_1;
end
fn_1 = fn_1/5;
ACC_1 = ACC_1/5;
