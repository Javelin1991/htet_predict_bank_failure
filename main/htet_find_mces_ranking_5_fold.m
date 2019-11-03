% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_find_mces_ranking_5_fold XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   to find the weight ranking for each feature using MCES (Monte Carolo Evaluative Selection algorithm)
% WARNING   :   running the code below may take very long since the weight ranking is calculated based on the 5-fold CV
% Stars     :   *
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

clear;
clc;

load CV1_Classification;

warning('off');


Labels = ["CAPADE", "OLAQLY", "PROBLO", "ADQLLP", "PLAQLY", "NIEOIN", "NINMAR", "ROE", "LIQUID", "GROWLA"];

params.algo = 'emfis';
params.max_cluster = 40;
params.half_life = inf;
params.threshold_mf = 0.9999;
params.min_rule_weight = 0.7;
params.spec = 10;
params.ie_rules_no = 2;
params.create_ie_rule = 0;

params.use_top_features = false;

params.dummy_run = true;

params.do_not_use_cv = false;

% Labels = ["CAPADE", "OLAQLY", "PROBLO", "ADQLLP", "PLAQLY", "NIEOIN", "NINMAR", "ROE", "LIQUID", "GROWLA"];
% xdatatemp = xdata(:,[77:83 86 end end:-1:end-5])
% That is, of course, if you wanted columns 77 to 83, then 86, then the last column, then the last 5 columns counted backwards ;)
total_weight = [];

for i = 1:5
  D = CV1{i};

  if params.dummy_run
    data_target = D(1:100,2);
    data_input = D(1:100,3:12);
  else
    data_target = D(:,2);
    data_input = D(:,3:12);
  end

  train_data = data_input;
  train_output = data_target;
  ite = 2;
  induction = 'eMFIS_classification';

  % weight ranking of the features
  weight = evalsel(train_data,train_output,ite,induction, params);

  total_weight = [total_weight weight(:,2)];
end

total_weight = total_weight';
ranking = mean(total_weight);

% plot bar graph for weight ranking
figure;
bar(ranking); % plot the matrix
set(gca, 'XTick', 1:10); % center x-axis ticks on bins
set(gca, 'XTickLabel', Labels); % set x-axis labels
title('Bank Failure Classification Features Weight Ranking', 'FontSize', 14); % set title
colormap('jet'); % set the colorscheme
