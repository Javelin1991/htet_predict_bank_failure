% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_test_bank_classification_safin_frie_with_feature_select XXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% File  :   used to test bank failure prediction/classification using SaFIN_FRIE with HCL
% Running Data Set 1A, 9 features, will take ~ 8-10 min
% Running Data Set 1B, top 3 features, will take ~6.5 min
% Running Data Set 2A, increased top 3 features, will take
% Running Data Set 2B, denfis recon top 3 features, will take
% Running Data Set 3, anfis full recon top 3 features,
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% diary SaFIN_FRIE_Learning_Trace;,:
%

clear;
clc;
close all;

%%% load different data %%%

% load CV1_Classification;
% load CV2_Classification;
% load CV3_Classification;

% load CV1_Classification_Increased;
% load CV2_Classification_Increased;
% load CV3_Classification_Increased;

% load CV1_Classification_Denfis;
% load CV2_Classification_Denfis;
% load CV3_Classification_Denfis;

% load CV1_Classification_Anfis_100;
% load CV2_Classification_Anfis_100;
% load CV3_Classification_Anfis_100;

% load CV1_Classification_Denfis_100;
% load CV2_Classification_Denfis_100;
% load CV3_Classification_Denfis_100;

load CV1_Corrected_Original;
load CV2_Corrected_Original;
load CV3_Corrected_Original;

%%% EXPERIMENT PARAMS SETUP %%%
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
accuracy_threshold = 100;
decrement_step = 10;
val_percent = 0.8

threshold = 0;
best_mean_acc = 0;
SCENARIO = 3;

Last = '(Last available)'
One = '(One-year prior)'
Two =  '(Two-year prior)'

for d = 1:3
    BEST_SYSTEMS = [];

    if d == 1
      det_title = Last;
    elseif d == 2
      det_title = One;
    else
      det_title = Two;
    end

    for cv_num = 1:5

      % top 3 feat x 3 , combined 3 timeline
      % Labels = ["CAPADE_t", "PLAQLY_t","ROE_t","CAPADE_t_1","PLAQLY_t_1","ROE_t_1","CAPADE_t_2","PLAQLY_t_2","ROE_t_2"]

      % 9 feat t
      % Labels = ["CAPADE", "OLAQLY", "PROBLO","PLAQLY", "NIEOIN", "NINMAR", "ROE", "LIQUID", "GROWLA"];
      % 9 feat t-1
      % Labels = ["CAPADE_t_1", "OLAQLY_t_1", "PROBLO_t_1","PLAQLY_t_1", "NIEOIN_t_1", "NINMAR_t_1", "ROE_t_1", "LIQUID_t_1", "GROWLA_t_1"];
      % 9 feat t-2
      % Labels = ["CAPADE_t_2", "OLAQLY_t_2", "PROBLO_t_2","PLAQLY_t_2", "NIEOIN_t_2", "NINMAR_t_2", "ROE_t_2", "LIQUID_t_2", "GROWLA_t_2"];

      % 27 feat
      % Labels = ["CAPADE_t", "OLAQLY_t", "PROBLO_t","PLAQLY_t", "NIEOIN_t", "NINMAR_t", "ROE_t", "LIQUID_t", "GROWLA_t", "CAPADE_t_1", "OLAQLY_t_1", "PROBLO_t_1","PLAQLY_t_1", "NIEOIN_t_1", "NINMAR_t_1", "ROE_t_1", "LIQUID_t_1", "GROWLA_t_1", "CAPADE_t_2", "OLAQLY_t_2", "PROBLO_t_2","PLAQLY_t_2", "NIEOIN_t_2", "NINMAR_t_2", "ROE_t_2", "LIQUID_t_2", "GROWLA_t_2"];

      % top 3 feat as per FCMAC
      % Labels = ["CAPADE","PLAQLY","ROE"];

      formatSpec = '\nThe current cv used is: %d';
      str = sprintf(formatSpec,cv_num)
      disp(str);

      %%% assign required data %%%

      switch SCENARIO
          case 1
              Labels = ["CAPADE", "OLAQLY", "PROBLO","PLAQLY", "NIEOIN", "NINMAR", "ROE", "LIQUID", "GROWLA"];
              if d == 1
                Data = CV1{cv_num,1} % last available
                Data(:,6) = [];
              elseif d == 2
                Data = CV2{cv_num,1}; % one year prior
                Data(:,6) = [];
              else
                Data = CV3{cv_num,1}; % two year prior
                Data(:,6) = [];
              end

              Data = Data(:,[3:11 2])
          case 2

              Labels = ["CAPADE","PLAQLY","ROE"];

              if d == 1
                Data = CV1{cv_num,1}; % last available
              elseif d == 2
                Data = CV2{cv_num,1}; % one year prior
              else
                Data = CV3{cv_num,1}; % two year prior
              end

              Data = Data(:,[3 7 10 2]); % 3 covariates
          case 3
              Labels = ["CAPADE","PLAQLY","ROE"];

              % top 3 features with increased data set
              if d == 1
                Data = CV1{cv_num,1}; % last available
              elseif d == 2
                Data = CV2{cv_num,1}; % one year prior
              else
                Data = CV3{cv_num,1}; % two year prior
              end

              Data = Data(:,[3:5 2])
          case 4

          case 5

      end



      while (accuracy_threshold > 0)

          epoch = 0; % this epoch is just for a predefined number of iterations
          best_acc = 0;
          best_eer = 100;
          D0 = Data;
          limit = size(D0,2) - 1;

          %%% using feature selection algorithm to rank features %%%
          [idx,scores] = fscmrmr(D0(:,[1:limit]), D0(:,limit+1));
          input = D0(:,[1:limit]);
          input = input(:,idx);
          Labels = Labels(:,idx);
          output = D0(:,limit+1);
          D0 = [input output];

          %%% get train data and validation data %%%
          start_test = (size(Data, 1) * 0.2) + 1;
          trainData_D0 = D0(1:start_test-1,:);
          start_validate = floor((size(trainData_D0, 1) * val_percent) + 1);
          valData_D0 = trainData_D0(start_validate:length(trainData_D0),:);
          trainData_D0 = trainData_D0(1:start_validate-1,:); % reduce train data size to 80%

          best_list = [];
          best_val_list = [];
          best_indices = [];
          best_labels = [];
          filter_indices = [];

          %%% for input dimension 1 to limit %%%
          for l=1:limit

            %%% maintain a list for current iteration %%%
            curr_list = [best_list trainData_D0(:,l) trainData_D0(:,limit+1)]
            curr_valData = [best_val_list valData_D0(:,l) valData_D0(:,limit+1)]
            target = size(curr_list,2);

            %%% input dimension and output dimension %%%
            IND = size(curr_list,2) - 1;
            OUTD = 1;

            % ensemble learning with hcl
            [net_out, system] = Run_SaFIN_FRIE(1,curr_list,curr_valData,IND,OUTD,Epochs,Eta,Sigma0,Forgetfactor, forget,Lamda, tau,Rate, Omega, Gamma);
            output = htet_find_optimal_cut_off(curr_valData(:,IND+OUTD), net_out, 0);

            curr_eer = output.true_eer;
            curr_acc = output.accuracy;

            %%% if the current error is lower than best error, then update the best error %%%
            if curr_acc > accuracy_threshold && curr_acc > best_acc
                best_list = [best_list trainData_D0(:,l)];
                best_val_list = [best_val_list valData_D0(:,l)];

                best_indices = [best_indices, idx(1,l)];
                best_labels = [best_labels, Labels(1,l)];
                filter_indices = [filter_indices, l];

                best_features = best_indices;
                best_eer = curr_eer;
                best_acc = curr_acc;
            end
          end

          have_best_feature_list = true;

          if size(best_indices,1) == 0
            disp('The required accuracy cannot be found! Reducing the step...');
            accuracy_threshold = accuracy_threshold - decrement_step;
            have_best_feature_list = false;

            if SCENARIO == 1
              Labels = ["CAPADE", "OLAQLY", "PROBLO","PLAQLY", "NIEOIN", "NINMAR", "ROE", "LIQUID", "GROWLA"];
            else
              Labels = ["CAPADE","PLAQLY","ROE"];
            end
            continue;
          end



          %%% getting the label dimension %%%
          last_idx = size(Data,2);

          %%% preparing the data for new training + testing %%%
          %%% reuse validation data now for training as well %%%
          Data = Data(:,[best_features last_idx]);
          start_test = (size(Data, 1) * 0.2) + 1;
          train = Data(1:start_test-1,:);
          test = Data(start_test:length(Data), :);
          target = size(train,2);

          limit = target-1;
          IND = limit;
          OUTD = 1;
          [net_out, system] = Run_SaFIN_FRIE(1,train,test,IND,OUTD,Epochs,Eta,Sigma0,Forgetfactor, forget,Lamda, tau,Rate, Omega, Gamma);
          output = htet_find_optimal_cut_off(test(:,IND+OUTD), net_out, 0);

          % summary includes 3 columns
          % column 1 is raw output value,
          % column 2 is the value converted from raw output to either 0 or 1
          % column 3 is the ground truth label
          result.summary = [net_out cell2mat(output.BEST_AFTER_THRESHOLD(1,1)) test(:,IND+OUTD)];
          result.net_structure = system;
          result.output = output;
          result.MME = output.MIN_MME(1,1);
          result.MIN_CUT_OFF = output.MIN_CUT_OFF(1,1);
          result.FNR = output.MIN_FNR(1,1);
          result.FPR = output.MIN_FPR(1,1);
          result.EER = output.true_eer;
          result.ACC = output.accuracy;
          result.Feat = IND;
          result.Rules = system.ruleCount;
          result.best_feat = best_indices;
          result.best_labels = best_labels;

          %%% store the system for each CV group %%%
          BEST_SYSTEMS = [BEST_SYSTEMS; result]

          %%% calculate mean accuracy %%%
          best_mean_acc = best_mean_acc + result.ACC;

          if (have_best_feature_list)
              break;
          end
      end
    end

    best_mean_acc = best_mean_acc/5;
    DET_OUT = htet_generate_det_plot(BEST_SYSTEMS, det_title)


    if d == 1
      net_result_for_last_record(1,:) = BEST_SYSTEMS
      det_out_for_last_record(1,:) = DET_OUT
    elseif d == 2
      net_result_for_one_year_prior(1,:) = BEST_SYSTEMS
      det_out_for_one_year_prior(1,:) = DET_OUT
    else
      net_result_for_two_year_prior(1,:) = BEST_SYSTEMS
      det_out_for_two_year_prior(1,:) = DET_OUT
    end
end

% sys1(1,:).output.all_fpr = {(net_result_for_last_record(1).output.all_fpr{1, 1} + net_result_for_last_record(2).output.all_fpr{1, 1} + net_result_for_last_record(3).output.all_fpr{1, 1} + net_result_for_last_record(4).output.all_fpr{1, 1} +net_result_for_last_record(5).output.all_fpr{1, 1})/5};
% sys1(1,:).output.all_fnr = {(net_result_for_last_record(1).output.all_fnr{1, 1} + net_result_for_last_record(2).output.all_fnr{1, 1} + net_result_for_last_record(3).output.all_fnr{1, 1} + net_result_for_last_record(4).output.all_fnr{1, 1} +net_result_for_last_record(5).output.all_fnr{1, 1})/5}
% sys1(1,:).output.bisector = net_result_for_last_record(1).output.bisector;
%
% sys1(2,:).output.all_fpr = {(net_result_for_one_year_prior(1).output.all_fpr{1, 1} + net_result_for_one_year_prior(2).output.all_fpr{1, 1} + net_result_for_one_year_prior(3).output.all_fpr{1, 1} + net_result_for_one_year_prior(4).output.all_fpr{1, 1} +net_result_for_one_year_prior(5).output.all_fpr{1, 1})/5};
% sys1(2,:).output.all_fnr = {(net_result_for_one_year_prior(1).output.all_fnr{1, 1} + net_result_for_one_year_prior(2).output.all_fnr{1, 1} + net_result_for_one_year_prior(3).output.all_fnr{1, 1} + net_result_for_one_year_prior(4).output.all_fnr{1, 1} +net_result_for_one_year_prior(5).output.all_fnr{1, 1})/5}
% sys1(2,:).output.bisector = net_result_for_one_year_prior(1).output.bisector;
%
% sys1(3,:).output.all_fpr = {(net_result_for_two_year_prior(1).output.all_fpr{1, 1} + net_result_for_two_year_prior(2).output.all_fpr{1, 1} + net_result_for_two_year_prior(3).output.all_fpr{1, 1} + net_result_for_two_year_prior(4).output.all_fpr{1, 1} +net_result_for_two_year_prior(5).output.all_fpr{1, 1})/5};
% sys1(3,:).output.all_fnr = {(net_result_for_two_year_prior(1).output.all_fnr{1, 1} + net_result_for_two_year_prior(2).output.all_fnr{1, 1} + net_result_for_two_year_prior(3).output.all_fnr{1, 1} + net_result_for_two_year_prior(4).output.all_fnr{1, 1} +net_result_for_two_year_prior(5).output.all_fnr{1, 1})/5}
% sys1(3,:).output.bisector = net_result_for_two_year_prior(1).output.bisector;
%
% DET_OUT = htet_generate_det_plot(sys1, 'Overall results')
% det_out_for_overall(1,:) = DET_OUT

% alarm sound to alert that the program has ended
load handel;
sound(y,Fs);
