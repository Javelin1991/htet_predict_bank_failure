clear;
clc;

load Failed_Banks;
load Survived_Banks;

% longitudinal data includes full data for last three records, for CAPADE, PLAQLY and ROE respectively
[longitudinal_data_failed_banks, lateral_data_failed_banks] = htet_prepare_data_for_longitudinal_construction(Failed_Banks);
[longitudinal_data_survived_banks, lateral_data_survived_banks] = htet_prepare_data_for_longitudinal_construction(Survived_Banks);

bank_type = [{longitudinal_data_failed_banks}; {longitudinal_data_survived_banks}];

LONGITUDINAL_SYSTEMS = {};

for i=1:2
  banks = bank_type(i);
  Data = banks{1};
  RESULTS = [];

    for j=1:3
          switch j
                case 1
                    data_input_f = [Data.input_forward_CAPADE, Data.target_forward_CAPADE(:,2)];
                    data_input_b = [Data.input_backward_CAPADE, Data.target_backward_CAPADE(:,2)];

                    RESULTS.pretrained_forward_CAPADE = get_prediction_results(data_input_f);
                    RESULTS.pretrained_backward_CAPADE = get_prediction_results(data_input_b);

                case 2
                    data_input_f = [Data.input_forward_PLAQLY, Data.target_forward_PLAQLY(:,2)];
                    data_input_b = [Data.input_backward_PLAQLY, Data.target_backward_PLAQLY(:,2)];

                    RESULTS.pretrained_forward_PLAQLY = get_prediction_results(data_input_f);
                    RESULTS.pretrained_backward_PLAQLY = get_prediction_results(data_input_b);

                case 3
                    data_input_f = [Data.input_forward_ROE, Data.target_forward_ROE(:,2)];
                    data_input_b = [Data.input_backward_ROE, Data.target_backward_ROE(:,2)];

                    RESULTS.pretrained_forward_ROE = get_prediction_results(data_input_f);
                    RESULTS.pretrained_backward_ROE = get_prediction_results(data_input_b);
         end
    end
    LONGITUDINAL_SYSTEMS = [LONGITUDINAL_SYSTEMS; {RESULTS}];
    clear RESULTS;
end

load handel
sound(y,Fs);


function out = get_prediction_results(D_train)
    algo_type = {'emfis'; 'denfis'; 'anfis'; 'ensemble_anfis_denfis'};
    % D_train = D_train(1:15,:); % dummy_run

    % input data setup
    D_test = htet_pre_process_bank_data(D_train, 0.24, 0); % 24% randomly selected test data

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
        end
    end
    out = [{emfis_system}; {denfis_system}; {anfis_system}; {ensemble_system_sa}; {ensemble_system_bs}];
end
