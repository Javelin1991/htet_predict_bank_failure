% XXXXXXXXXXXXXXXXXXXXXXXXXXX sus_scale XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Mar 3 2019
% Function  :
% Syntax    :   pre_process_bank_data(input, data_percent, total)
%
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

clc;
clear;

load Failed_Banks;
load Survived_Banks;

bank_type = [{Failed_Banks}; {Survived_Banks}];
bank_type_name = {'Failed_Banks'; 'Survived_Bans'};
algo_type = {'emfis'; 'denfis'; 'anfis'; 'ensemble_anfis_denfis'};
target_feature_name = {'CAPADE', 'PLAQLY', 'ROE'};
target_feature_col_no = [1; 5; 8];
extract_all_features = [3:12];

for i=1:length(bank_type)
  disp(['Processing Bank Type : ', bank_type_name(i)]);
  % input data setup
  input = cell2mat(bank_type(i));
  input_with_NaN = input(any(isnan(input), 2), :)
  input(any(isnan(input), 2), :) = [];
  input_without_NaN = input;

  D_train = input_without_NaN(:,extract_all_features); % 100 percent train data
  D_test = htet_pre_process_bank_data(D_train, 0.24, 0); % 24% randomly selected test data

  % D_train = input_without_NaN(1:15,extract_all_features); % for dummy run
  % D_test = htet_pre_process_bank_data(D_train, 0.24, 0); % randomly selected test data

  D = vertcat(D_train, D_test);

  for j=1:length(target_feature_col_no)

    disp('Feature prediction starts...')
    feature_name = target_feature_name{j};
    y = target_feature_col_no(j);
    if y == 1
      x1 = 5; x2 = 8;
    elseif y == 5
      x1 = 1; x2 = 8;
    else
      x1 = 1; x2 = 5;
    end

    data_input = D(:,[x1 x2]);
    data_target = D(:,y);

    for k=1:length(algo_type)

      algo = algo_type{k};
      disp(' ');

      switch algo
          case 'emfis'
              disp('Processing eMFIS(I/E).....')

              % parameter setup
              algo = 'emfis';
              spec = 10;
              max_cluster = 40;
              half_life = 10;
              threshold_mf = 0.9999;
              min_rule_weight = 0.7;
              trnData = data_input;
              tstData = data_target;
              ie_rules_no = 2;
              create_ie_rule = 0;
              start_test = size(D_train, 1) + 1;

              emfis_system = mar_trainOnline(ie_rules_no ,create_ie_rule, trnData, tstData, algo, max_cluster, half_life, threshold_mf, min_rule_weight);
              emfis_system = ron_calcErrors(emfis_system, data_target(start_test : size(data_target, 1)));

              emfis_system.num_rules = mean(emfis_system.net.ruleCount(start_test : size(data_target, 1)));
              emfis_system.input = data_input;
              emfis_system.target = data_target;
              emfis_system.target_feature_name = feature_name;
              emfis_system.name = algo;

          case 'denfis'
              disp('Processing DENFIS.....')

              % parameter setup
              algo = 'denfis';
              C.trainmode = 2; % activating offline learning , first order
              start_test = size(D_train, 1) + 1;
              trnData = [data_input(1 : start_test - 1, :), data_target(1 : start_test - 1, :)];
              tstData = [data_input(start_test : size(data_target, 1), :), data_target(start_test : size(data_target, 1), :)];

              denfis_system_trained = denfis(trnData, C);
              t_denfis = denfiss(trnData, denfis_system_trained);
              c_denfis = denfiss(tstData, denfis_system_trained);

              denfis_system.net = denfis_system_trained;
              denfis_system.num_rules = t_denfis.rn + c_denfis.rn;
              denfis_system.predicted = [t_denfis.Out'; c_denfis.Out'];
              denfis_system = ron_calcErrors(denfis_system, data_target(start_test : size(data_target, 1)));
              denfis_system.input = data_input;
              denfis_system.target = data_target;
              denfis_system.target_feature_name = feature_name;
              denfis_system.name = algo;

          case 'anfis'
              disp('Processing ANFIS.....')

              % parameter setup
              algo = 'anfis';
              start_test = size(D_train, 1) + 1;

              trnData = [data_input(1 : start_test - 1, :), data_target(1 : start_test - 1, :)];
              epoch_n = 100;
              opt = anfisOptions('InitialFIS',4,'EpochNumber',epoch_n);
              anfis_system_trained = anfis(trnData, opt);
              [t_anfis,at_fuzzifiedIn,at_ruleOut,at_aggregatedOut,at_ruleFiring] = evalfis(data_input(1 : start_test - 1, :)', anfis_system_trained);
              [c_anfis,ac_fuzzifiedIn,ac_ruleOut,ac_aggregatedOut,ac_ruleFiring] = evalfis(data_input(start_test : size(data_target, 1), :)', anfis_system_trained);

              anfis_system.net = anfis_system_trained;
              anfis_system.predicted = [t_anfis; c_anfis];
              anfis_system.num_rules = length(at_fuzzifiedIn) + length(ac_fuzzifiedIn);
              anfis_system = ron_calcErrors(anfis_system, data_target(start_test : size(data_target, 1)));
              anfis_system.input = data_input;
              anfis_system.target = data_target;
              anfis_system.target_feature_name = feature_name;
              anfis_system.name = algo;

         case 'ensemble_anfis_denfis'
               disp('Processing ENSEMBLE LEARNING.....')

               % parameter setup
              start_test = size(D_train, 1) + 1;

              anfis_rules_generated = anfis_system.num_rules;
              denfis_rules_generated = denfis_system.num_rules;
              total_predicted = [anfis_system.predicted, denfis_system.predicted];
              total_rules = [anfis_rules_generated denfis_rules_generated];

              % Simple Averaging
              ensemble_system_sa.predicted = mean(total_predicted, 2); % simple averaging
              ensemble_system_sa = ron_calcErrors(ensemble_system_sa, data_target(start_test : size(data_target, 1)));

              ensemble_system_bs.predicted = [];
              % Best Selection
              for z=1:length(anfis_system.predicted)
                y1 = anfis_system.predicted(z);
                y2 = denfis_system.predicted(z);
                y3 = ensemble_system_sa.predicted(z);

                y = data_target(z);

                switch min([abs(y3-y), abs(y2-y), abs(y1-y)])
                  case abs(y1-y)
                    ensemble_system_bs.predicted(z,:) = y1;

                  case abs(y2-y)
                    ensemble_system_bs.predicted(z,:) = y2;

                  case abs(y3-y)
                    ensemble_system_bs.predicted(z,:) = y3;
                end
              end


              ensemble_system_bs = ron_calcErrors(ensemble_system_bs, data_target(start_test : size(data_target, 1)));

              ensemble_system_sa.rules = mean(total_rules,2);
              ensemble_system_sa.input = data_input;
              ensemble_system_sa.target = data_target;
              ensemble_system_sa.target_feature_name = feature_name;
              ensemble_system_sa.name = 'SA';

              ensemble_system_bs.rules = mean(total_rules,2);
              ensemble_system_bs.input = data_input;
              ensemble_system_bs.target = data_target;
              ensemble_system_bs.target_feature_name = feature_name;
              ensemble_system_bs.name = 'BS';
      end
      disp('Processing of the algorithm completed.....')
    end

    disp('Feature prediction has ended...')
    RESULTS(j,:) = [{emfis_system}; {denfis_system}; {anfis_system}; {ensemble_system_sa}; {ensemble_system_bs}];

    clear data_input; clear data_target;
    clear emfis_system; clear denfis_system; clear anfis_system; clear ensemble_system_sa; clear ensemble_system_bs;
  end
  disp('Storing the results...')
  clear D; clear input;
  % Storing each feature prediction results, SYSTEMS will have two rows,
  % the first row is for Failed Failed_Banks
  % the second row is for Survived_Banks


  % final data structure for items in SYSTEMS
  % col = eMFIS(I/E)  DENFIS  ANFIS ENSEMBLE_ANFIS_DENFIS_SIMPLE_AVERAGING  ENSEMBLE_ANFIS_DENFIS_BEST_SELECTION
  % row_1 = Target_CAPADE
  % row_2 = Target_PLAQLY
  % row_3 = Target_ROE
  SYSTEMS(i,:) = {RESULTS};
end
