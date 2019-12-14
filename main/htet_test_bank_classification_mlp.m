% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_test_bank_classification_mlp XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% File      :   used to test bank failure prediction/classification using MLP
% Running Data Set 1A, 9 features, will take ~ 8-10 min
% Running Data Set 1B, top 3 features, will take ~6.5 min
% Running Data Set 2A, increased top 3 features, will take
% Running Data Set 2B, denfis recon top 3 features, will take
% Running Data Set 3, denfis full recon top 3 features,
% Stars     :   *****
% this file is used for bank failure classificaiton experiment conducted for journal paper publications
% this file is not used in the experiments for FYP
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%

clear;
clc;
close all;

%%% load different data %%%
% load CV1_Classification;
% load CV2_Classification;
% load CV3_Classification;

% load CV1_Corrected_Original;
% load CV2_Corrected_Original;
% load CV3_Corrected_Original;

load CV1_Corrected_Denfis_Recon_20;
load CV2_Corrected_Denfis_Recon_20;
load CV3_Corrected_Denfis_Recon_20;
%
% load CV1_Corrected_Denfis_Recon_100;
% load CV2_Corrected_Denfis_Recon_100;
% load CV3_Corrected_Denfis_Recon_100;

%%% EXPERIMENT PARAMS SETUP %%%
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


      %%% get train data and validation data %%%
      start_test = (size(Data, 1) * 0.2) + 1;
      trainData_D0 = Data(1:start_test-1,:);
      start_validate = floor((size(trainData_D0, 1) * 0.8) + 1);
      valData_D0 = trainData_D0(start_validate:length(trainData_D0),:);
      trainData_D0 = trainData_D0(1:start_validate-1,:); % reduce train data size to 80%

      % Train the underlying induction model first.
      net = train_mlp(trainData_D0(:,1:3),trainData_D0(:,4), 3000);
      valData_D0_input = valData_D0(:,1:3);
      net_out_val = sim(net,valData_D0_input')';
      output = htet_find_optimal_cut_off(valData_D0(:,4), net_out_val, 0);

      % unseen test data 80% remains the same
      test = Data(start_test:length(Data), :);

      % Train the underlying induction model first.
      test_input = test(:,1:3);
      net_out = sim(net,test_input')';
      optimal_cut_off_point = output.MIN_CUT_OFF;
      output = htet_find_optimal_cut_off(test(:,4), net_out, optimal_cut_off_point);
      BEST_SYSTEMS = [BEST_SYSTEMS; output]

    end
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
