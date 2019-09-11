% XXXXXXXXXXXXXXXXXXXXXXXXXXX htet_calculate_bank_data_correlation_matrix XXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   to generate correlation matrix for 10 features
% Syntax    :
%
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

% data pre-processing
load BankSet;
load Survived_Banks;
load Failed_Banks;

All = AllBanks;
Survived = Survived_Banks;
Failed = Failed_Banks;

%preprocess the data
All(any(isnan(All), 2), :) = [];
Sample_All_Banks = All;

Survived(any(isnan(Survived), 2), :) = [];
Sample_Survived_Banks = Survived;

Failed(any(isnan(Failed), 2), :) = [];
Sample_Failed_Banks = Failed;

Labels = ["CAPADE", "OLAQLY", "PROBLO", "ADQLLP", "PLAQLY", "NIEOIN", "NINMAR", "ROE", "LIQUID", "GROWLA"];

warning('off');

%%% survived banks
data_input = Sample_Survived_Banks(:, 3:12);
%correlation matrix
data_input_cov = cov(data_input);
[R_Survived, R_Survived_Sigma] = corrcov(data_input_cov);
figure;imagesc(R_Survived); % plot the matrix
set(gca, 'XTick', 1:10); % center x-axis ticks on bins
set(gca, 'YTick', 1:10); % center y-axis ticks on bins
set(gca, 'XTickLabel', Labels); % set x-axis labels
set(gca, 'YTickLabel', Labels); % set y-axis labels
title('Survived Bank Data Correlation Matrix', 'FontSize', 14); % set title
colormap('jet'); % set the colorscheme

%%% failed banks
data_input = Sample_Failed_Banks(:, 3:12);
%correlation matrix
data_input_cov = cov(data_input);
[R_Failed, R_Failed_Sigma] = corrcov(data_input_cov);
figure;imagesc(R_Failed); % plot the matrix
set(gca, 'XTick', 1:10); % center x-axis ticks on bins
set(gca, 'YTick', 1:10); % center y-axis ticks on bins
set(gca, 'XTickLabel', Labels); % set x-axis labels
set(gca, 'YTickLabel', Labels); % set y-axis labels
title('Failed Bank Data Correlation Matrix', 'FontSize', 14); % set title
colormap('jet'); % set the colorscheme
