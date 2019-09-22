% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_playground_test_any_code_snippet XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   dummy file that is used to test any code snippet in matlab
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
clear;
clc;

load Failed_Banks;
load Survived_Banks;

for k = 1:1
  backward_offset = k-1;
  Failed_Banks_Group_By_Bank_ID = [];
  Survived_Banks_Group_By_Bank_ID = [];

  output_1 = htet_filter_bank_data_by_index(Survived_Banks(:,[1 2 3 7 12]), backward_offset);
  output_2 = htet_filter_bank_data_by_index(Failed_Banks(:,[1 2 3 7 12]), backward_offset);

  Survived_Banks_Group_By_Bank_ID = output_1.result;
  Failed_Banks_Group_By_Bank_ID = output_2.result;

  if k == 1
    CV1_with_top_5_features = htet_generate_cross_validation_data(Survived_Banks_Group_By_Bank_ID, Failed_Banks_Group_By_Bank_ID, 5, true);
  elseif k == 2
    CV2_with_top_5_features = htet_generate_cross_validation_data(Survived_Banks_Group_By_Bank_ID, Failed_Banks_Group_By_Bank_ID, 5, true);
  else
    CV3_with_top_5_features = htet_generate_cross_validation_data(Survived_Banks_Group_By_Bank_ID, Failed_Banks_Group_By_Bank_ID, 5, true);
  end
end

ACC = 0;
fn = 0;
total_FN = [];
total_FP = [];
for cv_num = 1:5
  D = CV1_with_top_5_features{cv_num,1};
  data_input = D(:,[3:5]);
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
  D = CV1_with_top_5_features{cv_num,1};
  data_input = D(:,[3:5]);
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
