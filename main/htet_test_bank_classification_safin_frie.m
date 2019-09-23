% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_test_bank_classification_safin_frie XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   used to test bank failure prediction/classification using SaFIN_FRIE
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% diary SaFIN_Learning_Process_Trace;
%
% clear;
% clc;

% load '5_Fold_CVs_with_top_3_features';
% load CV1_Classification;
% load CV2_Classification;
% load CV3_Classification;
% load 'Reconstructed_Data_LL';
% load RECON_5_fold_cv_top_3_feat;
load Failed_Banks;
load Survived_Banks;
% load '5_fold_CV_top3_feat_FB';

Epochs = 0;
Eta = 0.05;
Sigma0 = sqrt(0.16);
Forgetfactor = 0.99;
Lamda = 0.3;
Rate = 0.25;
Omega = 0.7;
Gamma = 0.1;
forget = 1;
tau = 0.2;

% for k = 1:3
%   backward_offset = k-1;
%   Failed_Banks_Group_By_Bank_ID = [];
%   Survived_Banks_Group_By_Bank_ID = [];
%
%   output_1 = htet_filter_bank_data_by_index(Survived_Banks(:,[1 2 3 7 10 12]), backward_offset);
%   output_2 = htet_filter_bank_data_by_index(Failed_Banks(:,[1 2 3 7 10 12]), backward_offset);
%
%   Survived_Banks_Group_By_Bank_ID = output_1.result;
%   Failed_Banks_Group_By_Bank_ID = output_2.result;
%
%   if k == 1
%     CV1_with_top_5_features = htet_generate_cross_validation_data(Survived_Banks_Group_By_Bank_ID, Failed_Banks_Group_By_Bank_ID, 5, true);
%   elseif k == 2
%     CV2_with_top_5_features = htet_generate_cross_validation_data(Survived_Banks_Group_By_Bank_ID, Failed_Banks_Group_By_Bank_ID, 5, true);
%   else
%     CV3_with_top_5_features = htet_generate_cross_validation_data(Survived_Banks_Group_By_Bank_ID, Failed_Banks_Group_By_Bank_ID, 5, true);
%   end
% end

threshold = 0;
target_col = 5;

IND_a = 10;
OUTD_a = 1;

IND_b = 3;
OUTD_b = 1;

A = [];
B = [];
C = [];

for cv_num = 1:5
  disp('');
  formatSpec = 'The current cv used is: %d';
  str = sprintf(formatSpec,cv_num)
  disp(str);

  D0 = CV1_with_top_5_features{cv_num};
  D1 = CV2_with_top_5_features{cv_num};
  D2 = CV3_with_top_5_features{cv_num};

  % D0 = CV1{cv_num};
  % D1 = CV2{cv_num};
  % D2 = CV3{cv_num};

  % this result is decent
  D01 = D0(:,[3:5 2]);
  D11 = D1(:,[3:5 2]);
  D21 = D2(:,[3:5 2]);

  % top feature indentified as per SaFIN_FRIE
  % D01 = D0(:,[3:7 2]);
  % D11 = D1(:,[3:7 2]);
  % D21 = D2(:,[3:7 2]);
  % top feature same as FCMAC
  D0 = D0(:,[3:6 2]);
  D1 = D1(:,[3:6 2]);
  D2 = D2(:,[3:6 2]);

  % D0 = CV1_with_top_3_features{cv_num};
  % D1 = CV2_with_top_3_features{cv_num};
  % D2 = CV3_with_top_3_features{cv_num};
  %
  % D0 = D0(:,[3 4 5 2]);
  % D1 = D1(:,[3 4 5 2]);
  % D2 = D2(:,[3 4 5 2]);

  start_test = (size(D0, 1) * 0.2) + 1;
  trainData_D0 = D0(1:start_test-1,:);
  testData_D0 = D0(start_test:length(D0), :);
  trainData_D01 = D01(1:start_test-1,:);
  testData_D01 = D01(start_test:length(D0), :);

  trainData_D1 = D1(1:start_test-1,:);
  testData_D1 = D1(start_test:length(D1), :);
  trainData_D11 = D11(1:start_test-1,:);
  testData_D11 = D11(start_test:length(D1), :);

  trainData_D2 = D2(1:start_test-1,:);
  testData_D2 = D2(start_test:length(D2), :);
  trainData_D21 = D21(1:start_test-1,:);
  testData_D21 = D21(start_test:length(D2), :);

  % network prediction
  [net_out_0, net_structure_0] = Run_SaFIN_FRIE(1, trainData_D0,testData_D0,IND_a,OUTD_a,Epochs,Eta,Sigma0,Forgetfactor, forget,Lamda, tau,Rate, Omega, Gamma);
  [net_out_01, net_structure_01] = Run_SaFIN_FRIE(1, trainData_D01,testData_D01,IND_b,OUTD_b,Epochs,Eta,Sigma0,Forgetfactor, forget,Lamda, tau,Rate, Omega, Gamma);
  avg_net_out_0 = (net_out_0 + net_out_01)./2;
  output_0 = htet_find_optimal_cut_off(testData_D0(:,target_col), net_out_0, threshold);
  output_01 = htet_find_optimal_cut_off(testData_D0(:,target_col), net_out_01, threshold);
  output_0avg = htet_find_optimal_cut_off(testData_D0(:,target_col), avg_net_out_0, threshold);
  result_0.net_out = net_out_0;
  result_0.net_structure = net_structure_0;
  result_0.output = output_0;
  result_0.output01 = output_01;
  result_0.outputavg = output_0avg;
  % net_result_for_last_record(cv_num,:) = result_0;
  A = [A; result_0]

  [net_out_1, net_structure_1] = Run_SaFIN_FRIE(1, trainData_D1,testData_D1,IND_a,OUTD_a,Epochs,Eta,Sigma0,Forgetfactor, forget,Lamda, tau,Rate, Omega, Gamma);
  [net_out_11, net_structure_11] = Run_SaFIN_FRIE(1, trainData_D11,testData_D11,IND_b,OUTD_b,Epochs,Eta,Sigma0,Forgetfactor, forget,Lamda, tau,Rate, Omega, Gamma);
  avg_net_out_1 = (net_out_1 + net_out_11)./2;
  output_1 = htet_find_optimal_cut_off(testData_D1(:,target_col), net_out_1, threshold);
  output_11 = htet_find_optimal_cut_off(testData_D1(:,target_col), net_out_11, threshold);
  output_1avg = htet_find_optimal_cut_off(testData_D1(:,target_col), avg_net_out_1, threshold);
  result_1.net_out = net_out_1;
  result_1.net_structure = net_structure_1;
  result_1.output = output_1;
  result_1.output11 = output_11;
  result_1.outputavg = output_1avg;
  % net_result_for_one_year_prior(cv_num,:) = result_1;
  B = [B; result_1]

  [net_out_2, net_structure_2] = Run_SaFIN_FRIE(1, trainData_D2,testData_D2,IND_a,OUTD_a,Epochs,Eta,Sigma0,Forgetfactor, forget,Lamda, tau,Rate, Omega, Gamma);
  [net_out_21, net_structure_21] = Run_SaFIN_FRIE(1, trainData_D21,testData_D21,IND_b,OUTD_b,Epochs,Eta,Sigma0,Forgetfactor, forget,Lamda, tau,Rate, Omega, Gamma);
  avg_net_out_2 = (net_out_2 + net_out_21)./2;
  output_2 = htet_find_optimal_cut_off(testData_D2(:,target_col), net_out_2, threshold);
  output_21 = htet_find_optimal_cut_off(testData_D2(:,target_col), net_out_21, threshold);
  output_2avg = htet_find_optimal_cut_off(testData_D2(:,target_col), avg_net_out_2, threshold);
  result_2.net_out = net_out_2;
  result_2.net_structure = net_structure_2;
  result_2.output = output_2;
  result_2.output21 = output_21;
  result_2.outputavg = output_2avg;
  % net_result_for_two_year_prior(cv_num,:) = result_2;
  C = [C; result_2]

  disp('Processing of one CV group has completed');
end
