% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_playground_test_any_code_snippet XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   dummy file that is used to test any code snippet in matlab
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


% data pre-processing
clear;
clc;

load Correct_All_Banks;
load Survived_Banks;
load Failed_Banks;

All = Correct_All_Banks;
Survived = Survived_Banks;
Failed = Failed_Banks;
Labels = ["CAPADE", "OLAQLY", "PROBLO", "ADQLLP", "PLAQLY", "NIEOIN", "NINMAR", "ROE", "LIQUID", "GROWLA"];


%calculate mising rows Percent for all banks
Total_Banks = size(All, 1);
NaN_Rows = isnan(All);
NaN_Sum = sum(isnan(All(:,(3:12))));
Nan_Sum_Percent = htet_cal_nan_percent(NaN_Sum, 10, Total_Banks);

%calculate mising rows for survived banks
Total_Survived_Banks = size(Survived, 1);
NaN_Rows_Survived = isnan(Survived);
NaN_Sum_Survived = sum(isnan(Survived(:,(3:12))));
Nan_Sum_Percent_Survived = htet_cal_nan_percent(NaN_Sum_Survived, 10, Total_Survived_Banks);
[M, I] = max(Nan_Sum_Percent_Survived);
Max_Missing_Cov_All = I;

%calculate mising rows for failed banks
Total_Failed_Banks = size(Failed, 1);
NaN_Rows_Failed = isnan(Failed);
NaN_Sum_Failed = sum(isnan(Failed(:,(3:12))));
Nan_Sum_Percent_Failed  = htet_cal_nan_percent(NaN_Sum_Failed, 10, Total_Failed_Banks);
[M1, I1] = max(Nan_Sum_Percent_Survived);
Max_Missing_Cov_Failed = I1;


figure;
bar([Nan_Sum_Percent; Nan_Sum_Percent_Survived; Nan_Sum_Percent_Failed]');
legend('All Banks','Survived Banks', 'Failed Banks');
set(gca, 'XTick', 1:10); % center x-axis ticks on bins
set(gca, 'XTickLabel', Labels); % set x-axis labels
title('Missing data percentage of covariates for all banks (Survived and Failed)', 'FontSize', 14); % set title
colormap('jet'); % set the colorscheme
%
% figure;
% bar(Nan_Sum_Percent_Survived);
% set(gca, 'XTick', 1:10); % center x-axis ticks on bins
% set(gca, 'XTickLabel', Labels); % set x-axis labels
% title('Missing data percentage of covariates for Survived Banks', 'FontSize', 14); % set title
% colormap('jet'); % set the colorscheme
%
% figure;
% bar(Nan_Sum_Percent_Failed);
% set(gca, 'XTick', 1:10); % center x-axis ticks on bins
% set(gca, 'XTickLabel', Labels); % set x-axis labels
% title('Missing data percentage of covariates for Failed Banks', 'FontSize', 14); % set title
% colormap('jet'); % set the colorscheme
