% data pre-processing
load BankSet;
load Survived_Banks;
load Failed_Banks;

All = AllBanks;
Survived = Survived_Banks;
Failed = Failed_Banks;

%calculate Nan Percent for all banks
Total_Banks = size(All, 1);
NaN_Rows = isnan(All);
NaN_Sum = sum(isnan(All(:,(3:12))));
Nan_Sum_Percent = htet_cal_nan_percent(NaN_Sum, 10, Total_Banks);

%calculate Nan Percent for survived banks
Total_Survived_Banks = size(Survived, 1);
NaN_Rows_Survived = isnan(Survived);
NaN_Sum_Survived = sum(isnan(Survived(:,(3:12))));
Nan_Sum_Percent_Survived = htet_cal_nan_percent(NaN_Sum_Survived, 10, Total_Survived_Banks);
[M, I] = max(Nan_Sum_Percent_Survived);
Max_Missing_Cov_All = I;

%calculate Nan Percent for failed banks
Total_Failed_Banks = size(Failed, 1);
NaN_Rows_Failed = isnan(Failed);
NaN_Sum_Failed = sum(isnan(Failed(:,(3:12))));
Nan_Sum_Percent_Failed  = htet_cal_nan_percent(NaN_Sum_Failed, 10, Total_Failed_Banks);
[M1, I1] = max(Nan_Sum_Percent_Survived);
Max_Missing_Cov_Failed = I1;

%preprocess the data
Sample_All_Banks = htet_pre_process_bank_data(All, 0.2, true);
Sample_Survived_Banks = htet_pre_process_bank_data(Survived, 1, true);
Sample_Failed_Banks = htet_pre_process_bank_data(Failed, 0.2, true);
[M2, I2] = max(Nan_Sum_Percent_Survived);
Max_Missing_Cov_Survived = I2;


warning('off');

i = 1;
algo = 'emfis';
spec = 10;
FINAL_RESULT = [];

%start_test = (size(data_input, 1) / 2) + 1;

for Z = 1: 3
    for m = 1 : 1
        switch Z
            case 1
                %%% all banks
                disp('Training 20% random all bank data, sorted by bank and year');
                max_cluster = 40;
                half_life = 10; %half_life = 10 works best
                threshold_mf = 0.9999;
                min_rule_weight = 0.7;
                data_input = Sample_All_Banks(:, 3:12);
                input = data_input;
                data_target = Sample_All_Banks(:, Max_Missing_Cov_All);
                start_test = size(data_input, 1) * 0.8;
                inMF = zeros(size(spec, 2), size(data_input, 2));
                outMF = zeros(size(spec, 2), size(data_target, 2));
            case 2
                %%% survived banks
                disp('Training 20% random survived bank data, sorted by bank and year');
                max_cluster = 40;
                half_life = 10; %half_life = 10 works best
                threshold_mf = 0.9999;
                min_rule_weight = 0.7;
                data_input = Sample_Survived_Banks(:, 3:12);
                input = data_input;
                data_target = Sample_Survived_Banks(:, Max_Missing_Cov_All);
                start_test = size(data_input, 1) * 0.8;
                inMF = zeros(size(spec, 2), size(data_input, 2));
                outMF = zeros(size(spec, 2), size(data_target, 2));
            case 3
                %%% failed banks
                disp('Training 20% random failed bank data, sorted by bank and year');
                max_cluster = 40;
                half_life = 10; %half_life = 10 works best
                threshold_mf = 0.9999;
                min_rule_weight = 0.7;
                data_input = Sample_Failed_Banks(:, 3:12);
                input = data_input;
                data_target = Sample_Failed_Banks(:, Max_Missing_Cov_All);
                start_test = size(data_input, 1) * 0.8;
                inMF = zeros(size(spec, 2), size(data_input, 2));
                outMF = zeros(size(spec, 2), size(data_target, 2));
        end


    %     figure;
    %     plot(1:size(data_input,1),data_input(1:size(data_input,1), 2));
    %     figure;
    %     hold all;
    %     plot(1:size(data_input,1),data_input(1:size(data_input,1), 1));
    %     for l=3:size(data_input,2)
    %         plot(1:size(data_input,1),data_input(1:size(data_input,1), l));
    %     end

        disp(['Running algo : ', algo]);
        ie_rules_no = 2;
        create_ie_rule = 0;
        system = mar_trainOnline(ie_rules_no ,create_ie_rule, data_input, data_target, algo, max_cluster, half_life, threshold_mf, min_rule_weight);

    %    system = mar_trainOnline(data_input, data_target, algo, max_cluster, half_life, threshold_mf, min_rule_weight);
        system = ron_calcErrors(system, data_target(start_test : size(data_target, 1)));
        system.num_rules = mean(system.net.ruleCount(start_test : size(data_target, 1)));

        figure;
        str = [sprintf('Actual VS Predicted <-> '), num2str(max_cluster)];
        title(str);

        for l = 1:size(data_target,2)
            hold on;
            plot(1:size(data_target,1),data_target(1:size(data_target,1)), 'b');
            plot(1:size(system.predicted,1),system.predicted(1:size(data_target,1)), 'r');
        end

        legend('Actual','Predicted');

        comp_result(m).rmse = system.RMSE;
        comp_result(m).num_rules = system.num_rules;

        r = [system.RMSE system.num_rules system.MAE system.MSE system.R];
        FINAL_RESULT = [FINAL_RESULT; r];

    end
    clear data_input data_target;
    disp('Final RMSE and Rules');
    disp(FINAL_RESULT)
end
