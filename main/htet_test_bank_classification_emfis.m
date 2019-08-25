clear;
clc;

load Correct_All_Banks;
load Survived_Banks;
load Failed_Banks;
load Survived;
load Failed;


Failed_Banks_Group_By_Bank_ID = [];
Survived_Banks_Group_By_Bank_ID = [];

backward_offset = 0;
output_1 = htet_filter_bank_data_by_index(Survived_Banks, backward_offset);
output_2 = htet_filter_bank_data_by_index(Failed_Banks, backward_offset);

Survived_Banks_Group_By_Bank_ID = output_1.result;
SB_IDs = output_1.IDs;

Failed_Banks_Group_By_Bank_ID = output_2.result;
FB_IDs = output_2.IDs;

SB = cvpartition(length(SB_IDs),'KFold',5);
FB = cvpartition(length(FB_IDs),'KFold',5);

CV = [];

for i = 1:5
    I = test(SB,i);
    cv_sb = [];
    for j = 1:length(I)
        if I(j,:) == 1
            cv_sb = [cv_sb; Survived_Banks_Group_By_Bank_ID(j, :)];
        end
    end

    I2 = test(FB, i);
    cv_fb = [];
    for k = 1:length(I2)
        if I2(k,:) == 1
            cv_fb = [cv_fb; Failed_Banks_Group_By_Bank_ID(k, :)];
        end
    end

    cv_sb_plus_cv_fb = vertcat(cv_sb,cv_fb);
    final_cv = htet_pre_process_bank_data(cv_sb_plus_cv_fb, 1, 0);
    CV = [CV; {final_cv}];
end
