% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_test_bank_classification_safin_frie XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   used to test bank failure prediction/classification using SaFIN_FRIE
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% diary SaFIN_FRIE_Learning_Trace;
%
clear;
clc;

% load 'CV_3T_27_Feat';
load CV1_Classification;
load CV2_Classification;
load CV3_Classification;
% load 'Reconstructed_Data_LL';
% load RECON_5_fold_cv_top_3_feat;
% load Failed_Banks;
% load Survived_Banks;
% load '5_fold_CV_top3_feat_FB';
% load '5_fold_CV_Bank_Cells';
% load DATA_5_CV;

Epochs = 0;
Eta = 0.05;
Sigma0 = sqrt(0.16);
Forgetfactor = 0.99;
Lamda = 0.62;
Rate = 0.25;
Omega = 0.7;
Gamma = 0.1;
forget = 1;
tau = 0.57;
threshold = 0;

% % used to generate 5 fold CV
% for k = 1:3
%   backward_offset = k-1;
%   Failed_Banks_Group_By_Bank_ID = [];
%   Survived_Banks_Group_By_Bank_ID = [];
%
%   output_1 = htet_filter_bank_data_by_index(Survived_Banks(:,[1 2 3 7 10]), backward_offset);
%   output_2 = htet_filter_bank_data_by_index(Failed_Banks(:,[1 2 3 7 10]), backward_offset);
%
%   Survived_Banks_Group_By_Bank_ID = output_1.result;
%   Failed_Banks_Group_By_Bank_ID = output_2.result;
%
%   CV1_with_top_5_features = htet_generate_cross_validation_data(Survived_Banks_Group_By_Bank_ID, Failed_Banks_Group_By_Bank_ID, 5, true);
%
%   if k == 1
%     CV1_with_top_5_features = htet_generate_cross_validation_data(Survived_Banks_Group_By_Bank_ID, Failed_Banks_Group_By_Bank_ID, 5, true);
%   elseif k == 2
%     CV2_with_top_5_features = htet_generate_cross_validation_data(Survived_Banks_Group_By_Bank_ID, Failed_Banks_Group_By_Bank_ID, 5, true);
%   else
%     CV3_with_top_5_features = htet_generate_cross_validation_data(Survived_Banks_Group_By_Bank_ID, Failed_Banks_Group_By_Bank_ID, 5, true);
%   end
% end

% % used to generate 9 inputs taking 3 input each from t, t-1 and t-2
% DATA_5_CV = [];
%
% for cv_num = 1:5
%   DATA = [];
%   TMP = CV5_FB_SB_Cells{cv_num, 1}
%   for j=1:size(TMP,1)
%     mat = cell2mat(TMP(j));
%     input_record = [];
%     for k=1:3
%       input_record = [input_record, mat(k,[3:5])]
%     end
%     label = mat(k,2);
%     input_record = [input_record, label];
%     DATA = [DATA; input_record];
%   end
%   DATA_5_CV = [DATA_5_CV; {DATA}];
%   clear DATA;
% end

for cv_num = 1:5
  disp('');
  formatSpec = 'The current cv used is: %d';
  str = sprintf(formatSpec,cv_num)
  disp(str);

  D0 = CV1{cv_num,1};
  D0(:,6) = [];
  D1 = CV2{cv_num,1};
  D1(:,6) = [];
  D2 = CV3{cv_num,1};
  D2(:,6) = [];


  D0 = D0(:,[3:11 2]);
  D1 = D1(:,[3:11 2]);
  D2 = D2(:,[3:11 2]);

  IND_a = size(D0,2) - 1;
  OUTD_a = 1;
  start_test = (size(D0, 1) * 0.2) + 1;

  trainData_D0 = D0(1:start_test-1,:);
  testData_D0 = D0(start_test:length(D0), :);

  trainData_D1 = D1(1:start_test-1,:);
  testData_D1 = D1(start_test:length(D1), :);

  trainData_D2 = D2(1:start_test-1,:);
  testData_D2 = D2(start_test:length(D2), :);

  % network prediction
  [net_out_0, net_structure_0] = Run_SaFIN_FRIE(1, trainData_D0,testData_D0,IND_a,OUTD_a,Epochs,Eta,Sigma0,Forgetfactor, forget,Lamda, tau,Rate, Omega, Gamma);
  output_0 = htet_find_optimal_cut_off(testData_D0(:,IND_a+OUTD_a), net_out_0, threshold);
  result_0.net_out = net_out_0;
  result_0.net_structure = net_structure_0;
  result_0.output = output_0;
  result_0.MIN_MEE = output_0.MIN_MEE(1,1);
  result_0.FNR = output_0.MIN_FNR(1,1);
  result_0.FPR = output_0.MIN_FPR(1,1);
  result_0.EER = output_0.true_eer;
  result_0.ACC = output_0.accuracy;
  result_0.Feat = IND_a;
  result_0.Rules = net_structure_0.ruleCount;
  net_result_for_last_record(cv_num,:) = result_0;


  [net_out_1, net_structure_1] = Run_SaFIN_FRIE(1, trainData_D1,testData_D1,IND_a,OUTD_a,Epochs,Eta,Sigma0,Forgetfactor, forget,Lamda, tau,Rate, Omega, Gamma);
  output_1 = htet_find_optimal_cut_off(testData_D1(:,IND_a+OUTD_a), net_out_1, threshold);
  result_1.net_structure = net_structure_1;
  result_1.output = output_1;
  result_1.MIN_MEE = output_0.MIN_MEE(1,1);
  result_1.FNR = output_1.MIN_FNR(1,1);
  result_1.FPR = output_1.MIN_FPR(1,1);
  result_1.EER = output_0.true_eer;
  result_1.ACC = output_0.accuracy;
  result_1.Feat = IND_a;
  result_1.Rules = net_structure_1.ruleCount;
  net_result_for_one_year_prior(cv_num,:) = result_1;

  [net_out_2, net_structure_2] = Run_SaFIN_FRIE(1, trainData_D2,testData_D2,IND_a,OUTD_a,Epochs,Eta,Sigma0,Forgetfactor, forget,Lamda, tau,Rate, Omega, Gamma);
  output_2 = htet_find_optimal_cut_off(testData_D2(:,IND_a+OUTD_a), net_out_2, threshold);
  result_2.net_out = net_out_2;
  result_2.net_structure = net_structure_2;
  result_2.output = output_2;
  result_2.MME = output_2.MIN_MEE(1,1);
  result_2.FNR = output_2.MIN_FNR(1,1);
  result_2.FPR = output_2.MIN_FPR(1,1);
  result_2.EER = out_2.true_eer;
  result_2.ACC = output_2.accuracy;
  result_2.Feat = IND_a;
  result_2.Rules = net_structure_2.ruleCount;
  net_result_for_two_year_prior(cv_num,:) = result_2;

  disp('Processing of one CV group has completed');
end
