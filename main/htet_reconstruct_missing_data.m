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


input = Failed_Banks;

input_with_NaN = input(any(isnan(input), 2), :)
input(any(isnan(input), 2), :) = [];
input_without_NaN = input;



D = input_without_NaN(:,3:12);
data_to_train_system = D(:,[1 5]);

% CAPADE = 1, PLAQLY = 5,  ROE = 8
col_to_predict = 8;

data_to_predict = D(:,col_to_predict);

if col_to_predict == 1
    col_to_input = [5 8];
elseif col_to_predict == 5
    col_to_input = [1 8];
else
    col_to_input = [1 5];
end

% algo = 'emfis';
%
%
% switch algo
%     case 'emfis'
        algo = 'emfis';
        spec = 10;
        max_cluster = 40;
        half_life = 10;
        threshold_mf = 0.9999;
        min_rule_weight = 0.7;
        x = data_to_train_system;
        y = data_to_predict;
        start_test = size(x, 1) * 0.8;

        disp(['Running algo : ', algo]);
        ie_rules_no = 2;
        create_ie_rule = 0;
        trained_system = mar_trainOnline(ie_rules_no ,create_ie_rule, x, y, algo, max_cluster, half_life, threshold_mf, min_rule_weight);
        trained_system = ron_calcErrors(trained_system, y(start_test : size(y, 1)));
        trained_system.num_rules = mean(trained_system.net.ruleCount(start_test : size(y, 1)));

        % E = input_with_NaN(5,3:12);
        % E = [E; input_with_NaN(10,3:12)];
        % E = [E; input_with_NaN(20,3:12)];
        %
        % x = E(:,[1 5]);
        % y = E(:,8);

        for i = 1:length(x)
            y(i) = htet_reconstruct_using_trained_emfis(trained_system, x(i), i);
        end

        E = input_without_NaN(1:10, 3:12);
        x = E(:,col_to_input);
        y = E(:,col_to_predict);

        for i = 1:length(x)
            reconstructed_data_1(i,:) = htet_reconstruct_using_trained_emfis(trained_system, x(i), i);
        end

        emfis_system.predicted = reconstructed_data_1;
        emfis_system.results = ron_calcErrors(emfis_system, y);

    % case 'denfis'
        algo = 'denfis'
        C.trainmode = 2;

        data_input = data_to_train_system;
        data_target = data_to_predict;
        start_test = size(data_input, 1) * 0.8;

        trnData = [data_input(1 : start_test - 1, :), data_target(1 : start_test - 1, :)];
        tstData = [data_input(start_test : size(data_target, 1), :), data_target(start_test : size(data_target, 1), :)];
        trained_system_2 = denfis(trnData, C);
        tfis = denfiss(trnData, trained_system_2);
        cfis = denfiss(tstData, trained_system_2);

        train_predicted = tfis.Out';
        test_predicted = cfis.Out';

        trained_system_2.predicted = test_predicted;
        trained_system_2 = ron_calcErrors(trained_system_2, data_target(start_test : size(data_target, 1)));
        r2(1, 1) = trained_system_2.R2;
        rmse(1, 1) = sqrt(trained_system_2.MSE);
        rules(1, 1) = trained_system_2.num_rules;

        % E = input_with_NaN(5,3:12); % row 5 of failed banks with NaN
        % E = [E; input_with_NaN(10,3:12)]; % row 10 of failed banks with NaN
        % E = [E; input_with_NaN(20,3:12)]; % row 20 of failed banks with NaN
        %
        % x = E(:,[1 5]);
        % y = E(:,8);
        % x = [x y];

        E = input_without_NaN(1:10, 3:12);
        x = E(:,col_to_input);
        y = E(:,col_to_predict);
        x = [x y];
        net_struct = denfiss(x, trained_system_2);
        reconstructed_data_2 = net_struct.Out';
        denfis_system.predicted = reconstructed_data_2;
        denfis_system.results = ron_calcErrors(denfis_system, y);

    % case 'anfis'
        algo = 'anfis';
        data_input = data_to_train_system;
        data_target = data_to_predict;
        start_test = size(data_input, 1) * 0.8;

        trnData = [data_input(1 : start_test - 1, :), data_target(1 : start_test - 1, :)];
        epoch_n = 100;
        % Parameters fixed at 0.3
        % infis = genfis2(data_input(1 : start_test - 1, :), data_target(1 : start_test - 1, :), 0.3);
        % net = anfis(trnData, infis, epoch_n);
        opt = anfisOptions('InitialFIS',4,'EpochNumber',epoch_n);
        trained_system_3 = anfis(trnData, opt);
        train_predicted = evalfis(data_input(1 : start_test - 1, :)', trained_system_3);
        test_predicted = evalfis(data_input(start_test : size(data_target, 1), :)', trained_system_3);

        anfis_system.predicted = test_predicted;
        anfis_system.results = ron_calcErrors(anfis_system, data_target(start_test : size(data_target, 1)));

        E = input_without_NaN(1:10, 3:12);
        x = E(:,col_to_input);
        y = E(:,col_to_predict);
        % x = [x y];
        reconstructed_data_3 = evalfis(x', trained_system_3);
        anfis_system.predicted = reconstructed_data_3;
        anfis_system.results = ron_calcErrors(anfis_system, y);
% end

        for i = 1:10
            final_reconstructed_data(i,:) = (reconstructed_data_2(i) + reconstructed_data_3(i))/2;
        end

        ensemble_system.predicted = final_reconstructed_data;
        ensemble_system.results = ron_calcErrors(ensemble_system, y);
