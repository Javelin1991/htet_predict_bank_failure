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

params.dummy_run = false;

params.do_not_use_cv = true;

% Labels = ["CAPADE", "OLAQLY", "PROBLO", "ADQLLP", "PLAQLY", "NIEOIN", "NINMAR", "ROE", "LIQUID", "GROWLA"];
% xdatatemp = xdata(:,[77:83 86 end end:-1:end-5])
% That is, of course, if you wanted columns 77 to 83, then 86, then the last column, then the last 5 columns counted backwards ;)

D = CV1{5};

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

ranking = weight(:,2);
% plot bar graph for weight ranking
figure;
bar(ranking); % plot the matrix
set(gca, 'XTick', 1:10); % center x-axis ticks on bins
set(gca, 'XTickLabel', Labels); % set x-axis labels
title('Bank Failure Classification Features Weight Ranking', 'FontSize', 14); % set title
colormap('jet'); % set the colorscheme


[~,inx]=sort(ranking, 'descend');
sorted_data_input = data_input(:,inx);
sorted_labels = Labels(:, inx);
ACC = [];

% iterate through each feature starting from the higest rank to lowest rank
for itr = 1: size(ranking, 1)
  x = sorted_data_input(:, 1:itr);
  y = train_output;
  net_result_for_last_record(itr) = htet_get_emfis_network_result(CV1{5}, params, x, y);
  ACC = [ACC; net_result_for_last_record(itr).accuracy];
end

figure;
plot(ACC');
set(gca, 'XTick', 1:10); % center x-axis ticks on bins
set(gca, 'XTickLabel', sorted_labels); % set x-axis labels
title('Accuracy produced by ranked features (highest-lowest)', 'FontSize', 14); % set title
colormap('jet'); % set the colorscheme
