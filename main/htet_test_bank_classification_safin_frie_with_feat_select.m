% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_test_bank_classification_safin_frie_with_feature_select XXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% File  :   used to test bank failure prediction/classification using SaFIN_FRIE with HCL
% Running Data Set 1A, 9 features, will take ~ 8-10 min
% Running Data Set 1B, top 3 features, will take ~6.5 min
% Running Data Set 2A, increased top 3 features, will take
% Running Data Set 2B, denfis recon top 3 features, will take
% Running Data Set 3, denfis full recon top 3 features,
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% diary SaFIN_FRIE_Learning_Trace;,:
%

clear;
clc;
close all;

%%% load different data %%%
load CV1_Classification;
load CV2_Classification;
load CV3_Classification;

% load CV1_Corrected_Original;
% load CV2_Corrected_Original;
% load CV3_Corrected_Original;

% load CV1_Corrected_Denfis_Recon_20;
% load CV2_Corrected_Denfis_Recon_20;
% load CV3_Corrected_Denfis_Recon_20;
%
% load CV1_Corrected_Denfis_Recon_100;
% load CV2_Corrected_Denfis_Recon_100;
% load CV3_Corrected_Denfis_Recon_100;

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
SCENARIO = 2;

Last = '(Last available)'
One = '(One-year prior)'
Two =  '(Two-year prior)'

for d = 1:1
    BEST_SYSTEMS = [];

    if d == 1
      det_title = Last;
    elseif d == 2
      det_title = One;
    else
      det_title = Two;
    end

    for cv_num = 5:5

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

            curr_eer = output.MIN_MME;
            curr_acc = 100 - curr_eer;

            %%% if the current error is lower than best error, then update the best error %%%
            if (curr_acc > accuracy_threshold && curr_acc > best_acc) || (curr_acc == 100)
                best_list = [best_list trainData_D0(:,l)];
                best_val_list = [best_val_list valData_D0(:,l)];

                best_indices = [best_indices, idx(1,l)];
                best_labels = [best_labels, Labels(1,l)];
                filter_indices = [filter_indices, l];

                best_features = best_indices;
                best_eer = curr_eer;
                best_acc = curr_acc;

                optimal_cut_off_point = output.MIN_CUT_OFF(1,1);
                best_train_data = curr_list;
                % all_fpr = output.all_fpr;
                % all_fnr = output.all_fnr;
                % bisector = output.bisector;
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

          %%% getting the best feature subset %%%
          Data = Data(:,[best_features last_idx]);

          %%% train 20%, test 80% %%%
          start_test = (size(Data, 1) * 0.2) + 1;
          train_end = Data(1:start_test-1,:);

          % however, we use the best train data set, found in the previous step
          train = best_train_data;

          % unseen test data 80% remains the same
          test = Data(start_test:length(Data), :);

          target = size(train_end,2);
          limit = target-1;
          IND = limit;
          OUTD = 1;
          [net_out, system] = Run_SaFIN_FRIE(1,train,test,IND,OUTD,Epochs,Eta,Sigma0,Forgetfactor, forget,Lamda, tau,Rate, Omega, Gamma);
          output = htet_find_optimal_cut_off(test(:,IND+OUTD), net_out, optimal_cut_off_point);

          % output.all_fnr = all_fnr; % validation fnrs to plot det graph
          % output.all_fpr = all_fpr; % validation fpr to plot det graph
          % output.bisector = bisector; % validation bisector to plot det graph

          % summary includes 3 columns
          % column 1 is raw output value,
          % column 2 is the value converted from raw output to either 0 or 1
          % column 3 is the ground truth label
          result.summary = [net_out output.after_threshold test(:,IND+OUTD)];
          result.net_structure = system;
          result.output = output;
          result.FNR = output.MIN_FNR(1,1);
          result.FPR = output.MIN_FPR(1,1);
          result.EER = output.MIN_MME(1,1);
          result.ACC =  100 - output.MIN_MME(1,1);
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

    % htet_generate_det_plot(BEST_SYSTEMS, det_title)

    if d == 1
      net_result_for_last_record(1,:) = BEST_SYSTEMS
      % det_out_for_last_record(1,:) = DET_OUT
    elseif d == 2
      net_result_for_one_year_prior(1,:) = BEST_SYSTEMS
      % det_out_for_one_year_prior(1,:) = DET_OUT
    else
      net_result_for_two_year_prior(1,:) = BEST_SYSTEMS
      % det_out_for_two_year_prior(1,:) = DET_OUT
    end
end

% alarm sound to alert that the program has ended
load handel;
sound(y,Fs);
