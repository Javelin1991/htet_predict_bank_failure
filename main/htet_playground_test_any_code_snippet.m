clc;
clear;

load Failed_Banks;
load Survived_Banks;

load FAILED_BANK_DATA_HORIZONTAL;
load SURVIVED_BANK_DATA_HORIZONTAL;


Failed_Banks_Group_By_Bank_ID = [];
Survived_Banks_Group_By_Bank_ID = [];

unseen_testData = FAILED_BANK_DATA_HORIZONTAL{1, 1}.TEST_DATA_TO_PREDICT_ROE

% Survived_Banks = htet_pre_process_bank_data(Survived_Banks, 1, 0);
Failed_Banks(any(isnan(Failed_Banks), 2), :) = [];

% output_1 = htet_filter_bank_data_by_index(Survived_Banks(:,[1:3 7 10]), 0);
output_2 = htet_filter_bank_data_by_index(Failed_Banks(:,[1:3 7 10 13]), 0);

% Survived_Banks_Group_By_Bank_ID = output_1.result;
Failed_Banks_Group_By_Bank_ID = output_2.result;

% Survived_Banks_Group_By_Bank_ID_Full_Records = output_1.id_full_record;
Failed_Banks_Group_By_Bank_ID_Full_Records = output_2.full_record;

Failed_IDs = output_2.id;
unseen_testData = FAILED_BANK_DATA_HORIZONTAL{1, 1}.TEST_DATA_TO_PREDICT_ROE

A = [];
B = Failed_Banks_Group_By_Bank_ID_Full_Records;

for i=1:length(unseen_testData)
    record = unseen_testData(i,:);
    ran_num = randi(3) + 1;
    val_at_ran_num = unseen_testData(i,ran_num);
    record(1, ran_num) = NaN;
    A = [A; [record, ran_num, val_at_ran_num]];
end

for i = 1:length(unseen_testData)
    bID = unseen_testData(i,1);
    idx = find(bID == Failed_IDs);
    t = B(idx,:);
    d = t{1,1};
    for j = 1:size(d,1)
        sum = d(j,[1 3 4 5]);
        sum1 = unseen_testData(i,:);
        if sum == sum1
            d(j, 3:5) = A(i, 2:4)
            B(idx,:) = {d};
        end
    end
end
