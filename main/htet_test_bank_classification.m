% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_test_bank_classification XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   used to test bank failure prediction/classification using denfis or anfis 
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

% clear;
% clc;


% load Failed_Banks;
% load Survived_Banks;
%
% for k = 1:1
%   backward_offset = k-1;
%   Failed_Banks_Group_By_Bank_ID = [];
%   Survived_Banks_Group_By_Bank_ID = [];
%
%   output_1 = htet_filter_bank_data_by_index(Survived_Banks(:,[1:3 7 10]), backward_offset);
%   output_2 = htet_filter_bank_data_by_index(Failed_Banks(:,[1:3 7 10]), backward_offset);
%
%   Survived_Banks_Group_By_Bank_ID = output_1.result;
%   Failed_Banks_Group_By_Bank_ID = output_2.result;
%
%   Survived_Banks_Group_By_Bank_ID_Full_Records = output_1.full_record;
%   Failed_Banks_Group_By_Bank_ID_Full_Records = output_2.full_record;
%
%   if k == 1
%     CV1_with_top_3_features = htet_generate_cross_validation_data(Survived_Banks_Group_By_Bank_ID, Failed_Banks_Group_By_Bank_ID, 5, true);
%   elseif k == 2
%     CV2_with_top_3_features = htet_generate_cross_validation_data(Survived_Banks_Group_By_Bank_ID, Failed_Banks_Group_By_Bank_ID, 5, true);
%   else
%     CV3_with_top_3_features = htet_generate_cross_validation_data(Survived_Banks_Group_By_Bank_ID, Failed_Banks_Group_By_Bank_ID, 5, true);
%   end
% end


%
% % Labels = ["CAPADE", "OLAQLY", "PROBLO", "ADQLLP", "PLAQLY", "NIEOIN", "NINMAR", "ROE", "LIQUID", "GROWLA"];
% % xdatatemp = xdata(:,[77:83 86 end end:-1:end-5])
% % That is, of course, if you wanted columns 77 to 83, then 86, then the last column, then the last 5 columns counted backwards ;)
%
%
Data = CV1_with_top_3_features(1);


data_input = Data{1};
X = randi(length(data_input)) % returns a pseudorandom scalar integer between 1 and imax.

data_input(X,:) = [];

data_target = data_input(:,2);
data_input = data_input(:,3:5);

target_size = length(data_target);

for cv_num = 1:1
        disp('Processing DENFIS.....')

        % parameter setup
        algo = 'denfis';
        C.trainmode = 2; % activating offline learning , first order
        start_test = (size(data_input, 1) * 0.2) + 1;
        last_idx = start_test;
        trnData = [data_input(1 : last_idx, :), data_target(1 : last_idx, :)];
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

        eer_count = 0;
        unclassified_count = 0;

        after_threshold = zeros(target_size,1);
        for x=1: size(data_target, 1)
            if denfis_system.predicted(x) > 0.5
                after_threshold(x) = 1;
            elseif denfis_system.predicted(x) < 0.5
                after_threshold(x) = 0;
            elseif denfis_system.predicted(x) == 0.5
                after_threshold(x) = 0.5;
                eer_count = eer_count + 1;
            else
                unclassified_count = unclassified_count + 1;
            end
        end

        correct_predictions = length(find(data_target(start_test : target_size) - after_threshold(start_test :target_size) == 0));
        test_examples = (target_size - start_test) + 1;
        denfis_system.accuracy = (correct_predictions * 100)/test_examples;
        denfis_system.unclassified = (unclassified_count * 100)/test_examples;
        denfis_system.EER = (eer_count * 100)/test_examples;


        disp('Processing ANFIS.....')

        % parameter setup
        algo = 'anfis';
        start_test = size(data_input, 1) * 0.2 + 1;

        trnData = [data_input(1 : last_idx, :), data_target(1 : last_idx, :)];
        epoch_n = 100;
        opt = anfisOptions('InitialFIS',4,'EpochNumber',epoch_n);
        anfis_system_trained = anfis(trnData, opt);
        [t_anfis,at_fuzzifiedIn,at_ruleOut,at_aggregatedOut,at_ruleFiring] = evalfis(data_input(1 : last_idx, :)', anfis_system_trained);
        [c_anfis,ac_fuzzifiedIn,ac_ruleOut,ac_aggregatedOut,ac_ruleFiring] = evalfis(data_input(start_test : size(data_target, 1), :)', anfis_system_trained);

        anfis_system.net = anfis_system_trained;
        anfis_system.predicted = [t_anfis; c_anfis];
        anfis_system.num_rules = length(at_fuzzifiedIn) + length(ac_fuzzifiedIn);
        anfis_system = ron_calcErrors(anfis_system, data_target(start_test : size(data_target, 1)));
        anfis_system.input = data_input;
        anfis_system.target = data_target;
        anfis_system.name = algo;

        eer_count = 0;
        unclassified_count = 0;

        after_threshold = zeros(target_size,1);
        for x=1: size(data_target, 1)
            if anfis_system.predicted(x) > 0.5
                after_threshold(x) = 1;
            elseif anfis_system.predicted(x) < 0.5
                after_threshold(x) = 0;
            elseif anfis_system.predicted(x) == 0.5
                after_threshold(x) = 0.5;
                eer_count = eer_count + 1;
            else
                unclassified_count = unclassified_count + 1;
            end
        end
        correct_predictions = length(find(data_target(start_test : target_size) - after_threshold(start_test :target_size) == 0));
        test_examples = (target_size - start_test) + 1;
        anfis_system.accuracy = (correct_predictions * 100)/test_examples;
        anfis_system.unclassified = (unclassified_count * 100)/test_examples;
        anfis_system.EER = (eer_count * 100)/test_examples;


        disp('Processing ENSEMBLE LEARNING.....')

        start_test = size(data_input, 1)*0.2 + 1;

        anfis_rules_generated = anfis_system.num_rules;
        denfis_rules_generated = denfis_system.num_rules;
        total_predicted = [anfis_system.predicted, denfis_system.predicted];
        total_rules = [anfis_rules_generated denfis_rules_generated];

        % Simple Averaging
        ensemble_system_sa.predicted = mean(total_predicted, 2); % simple averaging

        eer_count = 0;
        unclassified_count = 0;

        after_threshold = zeros(target_size,1);
        for x=1: size(data_target, 1)
            if ensemble_system_sa.predicted(x) > 0.5
                after_threshold(x) = 1;
            elseif ensemble_system_sa.predicted(x) < 0.5
                after_threshold(x) = 0;
            elseif ensemble_system_sa.predicted(x) == 0.5
                after_threshold(x) = 0.5;
                eer_count = eer_count + 1;
            else
                unclassified_count = unclassified_count + 1;
            end
        end
        correct_predictions = length(find(data_target(start_test : target_size) - after_threshold(start_test :target_size) == 0));
        test_examples = (target_size - start_test) + 1;
        ensemble_system_sa.accuracy = (correct_predictions * 100)/test_examples;
        ensemble_system_sa.unclassified = (unclassified_count * 100)/test_examples;
        ensemble_system_sa.EER = (eer_count * 100)/test_examples;
        ensemble_system_sa = ron_calcErrors(ensemble_system_sa, data_target(start_test : size(data_target, 1)));

        % start_test = size(data_input, 1) + 1;
        %
        % anfis_rules_generated = anfis_system.num_rules;
        % denfis_rules_generated = denfis_system.num_rules;
        % total_predicted = [anfis_system.predicted, denfis_system.predicted, emfis_system.predicted];
        % total_rules = emfis_system.num_rules;
        %
        % % Simple Averaging
        % ensemble_system_sa.predicted = mean(total_predicted, 2); % simple averaging
        % ensemble_system_sa = ron_calcErrors(ensemble_system_sa, data_target(start_test : size(data_target, 1)));
end

% RESULT_0 = htet_find_average(net_result_for_last_record, 5);
% RESULT_1 = htet_find_average(net_result_for_one_year_prior, 5);
% RESULT_2 = htet_find_average(net_result_for_two_year_prior, 5);
%
% Labels = ["Last Available", "One Year Prior", "Two Year Prior"];
% Acc = [RESULT_0.Accuracy; RESULT_1.Accuracy; RESULT_2.Accuracy];
%
% figure;
% bar(Acc); % plot the matrix
% set(gca, 'XTick', 1:3); % center x-axis ticks on bins
% set(gca, 'XTickLabel', Labels); % set x-axis labels
% title('Bank Failure Classification Accuracy', 'FontSize', 14); % set title
% colormap('jet'); % set the colorscheme
%
% load handel
% sound(y,Fs)
