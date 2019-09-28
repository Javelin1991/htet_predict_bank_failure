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

load '5_Fold_CVs_with_top_3_features';
% load CV1_Classification;
% load CV2_Classification;
% load CV3_Classification;
% load 'Reconstructed_Data_LL';
% load RECON_5_fold_cv_top_3_feat;
% load Failed_Banks;
% load Survived_Banks;
% load '5_fold_CV_top3_feat_FB';
% load '5_fold_CV_Bank_Cells';
% load DATA_5_CV;
load CV_3T_Increased;

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


threshold = 0;
target_col = 4;
original_acc = 0;

A = [];
B = [];
C = [];

final_eer = 0;
final_acc = 0;

for cv_num = 1:1
  disp('');
  formatSpec = 'The current cv used is: %d';
  str = sprintf(formatSpec,cv_num)
  disp(str);

  % D0 = CV1_with{cv_num,1}
  % % D1 = CV2{cv_num,1}
  % % D2 = CV3{cv_num,1}
  % D0 = CV1_with_top_3_features{cv_num,1};
  % D0 = D0(:,[3 7 10 2]);
  % D1 = D1(:,[3 7 10 2]);
  % D2 = D2(:,[3 7 10 2]);

  % D0 = DATA_5_CV{cv_num,1};
  D0 = CV_3T{cv_num,1};
  D0 = D0(:,:);
  % D0 = D0(:,[10 2]);

  start_test = (size(D0, 1) * 0.2) + 1;
  trainData_D0 = D0(1:start_test-1,:);
  testData_D0 = D0(start_test:length(D0), :);

  % trainData_D1 = D1(1:start_test-1,:);
  % testData_D1 = D1(start_test:length(D1), :);
  %
  %
  % trainData_D2 = D2(1:start_test-1,:);
  % testData_D2 = D2(start_test:length(D2), :);

  % network prediction
  % [net_out_0, net_structure_0] = Run_SaFIN_FRIE(1, trainData_D0,testData_D0,IND_a,OUTD_a,Epochs,Eta,Sigma0,Forgetfactor, forget,Lamda, tau,Rate, Omega, Gamma);
  % output_0 = htet_find_optimal_cut_off(testData_D0(:,target_col), net_out_0, threshold);
  % result_0.net_out = net_out_0;
  % result_0.net_structure = net_structure_0;
  % result_0.output = output_0;
  % net_result_for_last_record(cv_num,:) = result_0;
  % final_eer = final_eer + output_0.MIN_EER(1,1);

  best_list = [];
  best_eer = 100;
  comparison = [];

  for l=1:9
    curr_list = [best_list trainData_D0(:,1:l) trainData_D0(:,10)]
    CL(l) = {curr_list};

    max_acc = 0;
    trainData_Neg = [];
    trainData_Pos = [];

    target = size(curr_list,2);

    for j=1:size(curr_list,1)
      if curr_list(j,target) == 0
          trainData_Neg = [trainData_Neg; curr_list(j,:)]
      else
          trainData_Pos = [trainData_Pos; curr_list(j,:)]
      end
    end

    IND_a = size(curr_list,2) - 1;
    OUTD_a = 1;

    % ensemble learning with hcl
    [net_out, net_out_2, final_out, system, system_2] = htet_SaFIN_FRIE_with_HCL(1,trainData_Pos,trainData_Neg,testData_D0,IND_a,OUTD_a,Epochs,Eta,Sigma0,Forgetfactor, forget,Lamda, tau,Rate, Omega, Gamma);
    % [no, ns] = Run_SaFIN_FRIE(1,trainData_D0,testData_D0,IND_a,OUTD_a,Epochs,Eta,Sigma0,Forgetfactor, forget,Lamda, tau,Rate, Omega, Gamma);
    % out_after_cut_off = htet_find_optimal_cut_off(testData_D0(:,target_col), no, 0);
    % ensemble_result = final_out + out_after_cut_off.after_threshold;
    [TP, FP, TN, FN, fnr, fpr, acc] = htet_get_classification_results(testData_D0(:,10), final_out);
    output.fnr = fnr;
    output.fpr = fpr;
    output.eer = (fnr+fpr)/2;

    comparison = [comparison; [fnr fpr output.eer]];

    if output.eer < best_eer
      best_list = curr_list(:,target-1);
      best_eer = output.eer;
      best_acc = 100 - best_eer;
    end
    % class_results(cv_num) = output;
    % comparison(cv_num) = {[net_out net_out_2 final_out testData_D0(:,target)]}
  end

  % final_result = [];
  % for z=1:size(ensemble_result,1)
  %     if ensemble_result(z,1) == 2
  %       final_result = [final_result; 1]
  %     elseif ensemble_result(z,1) == 1
  %       X = randi(2) - 1;
  %       final_result = [final_result; X]
  %     else
  %       final_result = [final_result; 0]
  %     end
  % end
  %
  % [TP, FP, TN, FN, fnr, fpr, acc] = htet_get_classification_results(testData_D0(:,target_col), final_result);

  % output_0 = htet_find_optimal_cut_off(testData_D0(:,target_col), final_out, 0.5);
  % result_0.net_out = net_out;
  % result_0.net_out_2 = net_out_2;
  % result_0.final_out = final_out;
  % result_0.test_data = testData_D0(:,target_col);
  % result_0.net_structure_1 = system;
  % result_0.net_structure_2 = system_2;
  % result_0.output = output_0;
  % net_result_for_last_record(cv_num,:) = result_0;
  % final_eer = final_eer + output_0.MIN_EER(1,1);
  % original_acc = original_acc + output_0.acc;
  %
  % if (final_acc > max_acc)
  %     max_acc = final_acc;
  % end

  % [net_out_1, net_structure_1] = Run_SaFIN_FRIE(1, trainData_D1,testData_D1,IND_a,OUTD_a,Epochs,Eta,Sigma0,Forgetfactor, forget,Lamda, tau,Rate, Omega, Gamma);
  % output_1 = htet_find_optimal_cut_off(testData_D1(:,target_col), net_out_1, threshold);  output_1avg = htet_find_optimal_cut_off(testData_D1(:,target_col), avg_net_out_1, threshold);
  % result_1.net_out = net_out_1;
  % result_1.net_structure = net_structure_1;
  % result_1.output = output_1;  result_1.outputavg = output_1avg;
  % net_result_for_one_year_prior(cv_num,:) = result_1;
  % [net_out_2, net_structure_2] = Run_SaFIN_FRIE(1, trainData_D2,testData_D2,IND_a,OUTD_a,Epochs,Eta,Sigma0,Forgetfactor, forget,Lamda, tau,Rate, Omega, Gamma);
  % output_2 = htet_find_optimal_cut_off(testData_D2(:,target_col), net_out_2, threshold);
  % result_2.net_out = net_out_2;
  % result_2.net_structure = net_structure_2;
  % result_2.output = output_2;
  % net_result_for_two_year_prior(cv_num,:) = result_2;

  disp('Processing of one CV group has completed');
end
