% XXXXXXXXXXXXXXXXXXXXXXXXXXX htet_calculate_bank_data_correlation_matrix XXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   to generate correlation matrix for 10 features
% Syntax    :
%
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
clc;
clear;
% load Prepared_Data_For_Correlation;
B = [];

% load Failed_Banks;
% load Survived_Banks;
%
% for k = 1:3
%   backward_offset = k-1;
%   Failed_Banks_Group_By_Bank_ID = [];
%   Survived_Banks_Group_By_Bank_ID = [];
%
%   output_1 = htet_filter_bank_data_by_index(Survived_Banks, backward_offset);
%   output_2 = htet_filter_bank_data_by_index(Failed_Banks, backward_offset);
%
%   output_3 = htet_filter_bank_data_by_index(Survived_Banks(:,[3 7 10]), backward_offset);
%   output_4 = htet_filter_bank_data_by_index(Failed_Banks(:,[3 7 10]), backward_offset);
%
%   Survived_Banks_Group_By_Bank_ID = output_1.result;
%   Failed_Banks_Group_By_Bank_ID = output_2.result;
%
%   Survived_Banks_Group_By_Bank_ID_1 = output_3.result;
%   Failed_Banks_Group_By_Bank_ID_1 = output_4.result;
%
%   if k == 1
%     SB_last_available_original = Survived_Banks_Group_By_Bank_ID;
%     FB_last_available_original = Failed_Banks_Group_By_Bank_ID;
%
%     SB_last_available_increased = Survived_Banks_Group_By_Bank_ID_1;
%     FB_last_available_increased = Failed_Banks_Group_By_Bank_ID_1;
%
%     B = [{SB_last_available_original(:,[3 7 10])}; {FB_last_available_original(:,[3 7 10])}; {SB_last_available_increased}; {FB_last_available_increased}];
%   elseif k == 2
%     SB_one_year_prior_original = Survived_Banks_Group_By_Bank_ID;
%     FB_one_year_prior_original = Failed_Banks_Group_By_Bank_ID;
%
%     SB_one_year_prior_increased = Survived_Banks_Group_By_Bank_ID_1;
%     FB_one_year_prior_increased = Failed_Banks_Group_By_Bank_ID_1;
%     B = [B; {SB_one_year_prior_original(:,[3 7 10])}; {FB_one_year_prior_original(:,[3 7 10])}; {SB_one_year_prior_increased}; {FB_one_year_prior_increased}];
%   else
%     SB_two_year_prior_original = Survived_Banks_Group_By_Bank_ID;
%     FB_two_year_prior_original = Failed_Banks_Group_By_Bank_ID;
%
%     SB_two_year_prior_increased = Survived_Banks_Group_By_Bank_ID_1;
%     FB_two_year_prior_increased = Failed_Banks_Group_By_Bank_ID_1;
%
%     B = [B; {SB_two_year_prior_original(:,[3 7 10])}; {FB_two_year_prior_original(:,[3 7 10])}; {SB_two_year_prior_increased}; {FB_two_year_prior_increased}];
%   end
% end

B = [{SB_last_available_original(:,[3 7 10])}; {FB_last_available_original(:,[3 7 10])}; {SB_last_available_increased}; {FB_last_available_increased}];
B = [B; {SB_one_year_prior_original(:,[3 7 10])}; {FB_one_year_prior_original(:,[3 7 10])}; {SB_one_year_prior_increased}; {FB_one_year_prior_increased}];
B = [B; {SB_two_year_prior_original(:,[3 7 10])}; {FB_two_year_prior_original(:,[3 7 10])}; {SB_two_year_prior_increased}; {FB_two_year_prior_increased}];


Labels = ["CAPADE", "OLAQLY", "PROBLO", "ADQLLP", "PLAQLY", "NIEOIN", "NINMAR", "ROE", "LIQUID", "GROWLA"];
TOTAL_R = [];
TOTAL_SIGMA = [];

for i=1:size(B,1)

  CB = cell2mat(B(i));

  type = 'Original';
  bank = 'Survived';

  if mod(i,3) == 0 || mod(i,4) == 0
    type = 'Increased'
  end

  if mod(i,2) == 0
    bank = 'Failed'
  end

  if i >= 1 && i <= 4
    record = '(Last Available)'
  elseif i >= 5 && i <= 8
    record = '(One year prior)'
  else
    record = '(Two year prior)'
  end


  formatSpec = '%s Bank Data Correlation Matrix %s Data Set %s';
  str = sprintf(formatSpec,bank,type,record);

  data_input = CB(:,[1 5 8]);
  %correlation matrix
  data_input_cov = cov(data_input);
  [R, Sigma] = corrcov(data_input_cov);
  TOTAL_R = [TOTAL_R; {R}];
  TOTAL_SIGMA = [TOTAL_SIGMA; {Sigma}];

  figure;imagesc(R); % plot the matrix
  set(gca, 'XTick', 1:3); % center x-axis ticks on bins
  set(gca, 'YTick', 1:3); % center y-axis ticks on bins
  set(gca, 'XTickLabel', Labels(:,[1 5 8])); % set x-axis labels
  set(gca, 'YTickLabel', Labels(:,[1 5 8])); % set y-axis labels
  title(str, 'FontSize', 14); % set title
  colormap('jet'); % set the colorscheme
end

%%% survived banks
% data_input = Sample_Survived_Banks(:,[1 5 8]);
% %correlation matrix
% data_input_cov = cov(data_input);
% [R_Survived, R_Survived_Sigma] = corrcov(data_input_cov);
% figure;imagesc(R_Survived); % plot the matrix
% set(gca, 'XTick', 1:3); % center x-axis ticks on bins
% set(gca, 'YTick', 1:3); % center y-axis ticks on bins
% set(gca, 'XTickLabel', Labels(:,[1 5 8])); % set x-axis labels
% set(gca, 'YTickLabel', Labels(:,[1 5 8])); % set y-axis labels
% title('Survived Bank Data Correlation Matrix Original Data Set', 'FontSize', 14); % set title
% colormap('jet'); % set the colorscheme

% %%% failed banks
% data_input = Sample_Failed_Banks(:,[1 5 8]);
% %correlation matrix
% data_input_cov = cov(data_input);
% [R_Failed, R_Failed_Sigma] = corrcov(data_input_cov);
% figure;imagesc(R_Failed); % plot the matrix
% set(gca, 'XTick', 1:3); % center x-axis ticks on bins
% set(gca, 'YTick', 1:3); % center y-axis ticks on bins
% set(gca, 'XTickLabel', Labels(:,[1 5 8])); % set x-axis labels
% set(gca, 'YTickLabel', Labels(:,[1 5 8])); % set y-axis labels
% title('Failed Bank Data Correlation Matrix Original Data Set', 'FontSize', 14); % set title
% colormap('jet'); % set the colorscheme
%
%
%
% Sample_Survived_Banks = Survived(:,[3 7 10]);
% Sample_Survived_Banks(any(isnan(Sample_Survived_Banks), 2), :) = [];
%
% Sample_Failed_Banks = Failed(:,[3 7 10]);
% Sample_Failed_Banks(any(isnan(Sample_Failed_Banks), 2), :) = [];
%
%
% %%% survived banks
% data_input = Sample_Survived_Banks(:, [1:3]);
% %correlation matrix
% data_input_cov = cov(data_input);
% [R_Survived_Increased_Data, R_Survived_Sigma_Increased_Data] = corrcov(data_input_cov);
% figure;imagesc(R_Survived); % plot the matrix
% set(gca, 'XTick', 1:3); % center x-axis ticks on bins
% set(gca, 'YTick', 1:3); % center y-axis ticks on bins
% set(gca, 'XTickLabel', Labels(:,[1 5 8])); % set x-axis labels
% set(gca, 'YTickLabel', Labels(:,[1 5 8])); % set y-axis labels
% title('Survived Bank Data Correlation Matrix Increased Data Set', 'FontSize', 14); % set title
% colormap('jet'); % set the colorscheme
%
% %%% failed banks
% data_input = Sample_Failed_Banks(:, [1:3]);
% %correlation matrix
% data_input_cov = cov(data_input);
% [R_Failed_Increased_Data, R_Failed_Sigma_Increased_Data] = corrcov(data_input_cov);
% figure;imagesc(R_Failed); % plot the matrix
% set(gca, 'XTick', 1:3); % center x-axis ticks on bins
% set(gca, 'YTick', 1:3); % center y-axis ticks on bins
% set(gca, 'XTickLabel', Labels(:,[1 5 8])); % set x-axis labels
% set(gca, 'YTickLabel', Labels(:,[1 5 8])); % set y-axis labels
% title('Failed Bank Data Correlation Matrix Increased Data Set', 'FontSize', 14); % set title
% colormap('jet'); % set the colorscheme
