% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_test_longitudinal_data_reconstruction XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   used to test reconstruction performance for longitudinal reconstruction
% five different types of algorithms are tested
% 1) eMFIS(IRE)
% 2) DENFIS
% 3) ANFIS
% 4) SA - Simple Averaging Ensemble Learning using ANFIS and DENFIS
% 5) BS - Best Selection between ANFIS, DENFIS, and SA
% 6) SaFIN++ - offline model
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

clear;
clc;

load FAILED_BANK_DATA_VERTICAL;
load SURVIVED_BANK_DATA_VERTICAL;

warning off;

% % longitudinal data includes full data for last three records, for CAPADE, PLAQLY and ROE respectively
% [longitudinal_data_failed_banks, lateral_data_failed_banks] = htet_prepare_data_for_longitudinal_construction(Failed_Banks);
% [longitudinal_data_survived_banks, lateral_data_survived_banks] = htet_prepare_data_for_longitudinal_construction(Survived_Banks);

bank_type = [{FAILED_BANK_DATA_VERTICAL}; {SURVIVED_BANK_DATA_VERTICAL}];

LONGITUDINAL_SYSTEMS = {};

for i=1:2
  if i == 1
    BANK = FAILED_BANK_DATA_VERTICAL{1, 1};
  else
    BANK = SURVIVED_BANK_DATA_VERTICAL{1, 1};
  end
  RESULTS = [];

    for j=1:3
          switch j
                case 1
                    train_f = BANK.train_data_forward_CAPADE;
                    test_f = BANK.test_data_forward_CAPADE;

                    train_b = BANK.train_data_backward_CAPADE;
                    test_b = BANK.test_data_backward_CAPADE;

                    RESULTS.pretrained_forward_CAPADE = get_prediction_results(train_f, test_f);
                    RESULTS.pretrained_backward_CAPADE = get_prediction_results(train_b, test_b);

                case 2
                    train_f = BANK.train_data_forward_PLAQLY;
                    test_f = BANK.test_data_forward_PLAQLY;

                    train_b = BANK.train_data_backward_PLAQLY;
                    test_b = BANK.test_data_backward_PLAQLY;

                    RESULTS.pretrained_forward_PLAQLY = get_prediction_results(train_f, test_f);
                    RESULTS.pretrained_backward_PLAQLY = get_prediction_results(train_b, test_b);

                case 3
                    train_f = BANK.train_data_forward_ROE;
                    test_f = BANK.test_data_forward_ROE;

                    train_b = BANK.train_data_backward_ROE;
                    test_b = BANK.test_data_backward_ROE;

                    RESULTS.pretrained_forward_ROE = get_prediction_results(train_f, test_f);
                    RESULTS.pretrained_backward_ROE = get_prediction_results(train_b, test_b);
         end
    end
    LONGITUDINAL_SYSTEMS = [LONGITUDINAL_SYSTEMS; {RESULTS}];
    clear RESULTS;
end

htet_export_results_to_excel_files(LONGITUDINAL_SYSTEMS, false);

load handel
sound(y,Fs);

function out = get_prediction_results(D_train, D_test)
    algo_type = {'denfis'; 'anfis'; 'ensemble_anfis_denfis'};
    % algo_type = {'denfis'};
    % % for dummy run
%     D_train = D_train(1:50, :);
%     D_test = D_train(1:50, :);

    % input data setup
    % D_test = htet_pre_process_bank_data(D_train, 0.24, 0); % 24% randomly selected test data

    % D_train = input_without_NaN(1:15,extract_all_features); % for dummy run
    % D_test = htet_pre_process_bank_data(D_train, 0.24, 0); % randomly selected test data

    D = vertcat(D_train, D_test);

    data_input = D(:,[2 3]);
    data_target = D(:,4);

    for k=1:length(algo_type)

        algo = algo_type{k};

        switch algo
            case 'emfis'
                disp('Processing eMFIS(I/E).....')

                % parameter setup
                algo = 'emfis';
                % spec = 10;
                % max_cluster = 40;
                % half_life = 10;
                % threshold_mf = 0.9999;
                % min_rule_weight = 0.7;

                spec = 10;
                max_cluster = 40;
                half_life = Inf;
                threshold_mf = 0.5;
                min_rule_weight = 0.6;

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
                ensemble_system_sa.name = 'SA';

                ensemble_system_bs.rules = mean(total_rules,2);
                ensemble_system_bs.input = data_input;
                ensemble_system_bs.target = data_target;
                ensemble_system_bs.name = 'BS';

            case 'safin++'
                disp('Processing SaFIN++.....')

                start_test = size(D_train, 1) + 1;
                trnData = [data_input(1 : start_test - 1, :), data_target(1 : start_test - 1, :)];
                tstData = [data_input(start_test : size(data_target, 1), :), data_target(start_test : size(data_target, 1), :)];

                IND = 2;
                OUTD = 1;
                Alpha = 0.25;
                Beta = 0.65;
                Eta = 0.05;
                Forgetfactor = 0.99;
                Epochs = 300;

                % network prediction
                [net_out, net_structure] = Run_SaFIN(trnData,tstData,IND,OUTD,Alpha,Beta,Epochs,Eta,Forgetfactor);

                safin_pp_system = htet_calculate_errors(net_out, data_target(start_test : size(data_target, 1)));
                safin_pp_system.input = data_input;
                safin_pp_system.target = data_target;
                safin_pp_system.name = algo;
                safin_pp_system.net = net_structure;
                safin_pp_system.predicted = net_out;
                safin_pp_system.num_rules = length(net_structure.Rules);
        end
    end
    out = [{denfis_system}; {anfis_system}; {ensemble_system_sa}];
    % out = [{denfis_system}];
end
