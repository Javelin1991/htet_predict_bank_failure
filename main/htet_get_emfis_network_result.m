% XXXXXXXXXXXXXXXXXXXXXXXXXXX sus_scale XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :
% Function  :
% Syntax    :
%
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function out = htet_get_emfis_network_result(cv, params, cv_num)

      algo = params.algo;
      max_cluster = params.max_cluster;
      half_life = params.half_life;
      threshold_mf = params.threshold_mf;
      min_rule_weight = params.min_rule_weight;
      spec = params.spec;
      ie_rules_no = params.ie_rules_no;
      create_ie_rule = params.create_ie_rule;

      D = cv;
      data_target = D(:,2);
      data_input = D(:,3:12);
      target_size = size(data_target, 1);
      start_test = (size(data_input, 1) * 0.2) + 1;

      disp(['Running algo : ', algo]);
      system = mar_trainOnline(ie_rules_no ,create_ie_rule, data_input, data_target, algo, max_cluster, half_life, threshold_mf, min_rule_weight);
      system = ron_calcErrors(system, data_target(start_test : target_size));
      system.num_rules = mean(system.net.ruleCount(start_test : target_size));

      after_threshold = zeros(target_size,1);
      for x=1: size(data_target, 1)
          if system.predicted(x) > 0.5
              after_threshold(x) = 1;
          elseif system.predicted(x) < 0.5
              after_threshold(x) = 0;
          else
              after_threshold(x) = 0.5;
          end
      end

      figure;
      str = [sprintf('Actual VS Predicted <-> '), num2str(max_cluster)];
      title(str);

      for l = 1:target_size
          hold on;
          plot(1:size(data_target,1),data_target(1:size(data_target,1)), 'b');
          plot(1:size(system.predicted,1),system.predicted(1:size(data_target,1)), 'r');
          % plot(1:size(after_threshold,1),after_threshold(1:size(data_target,1)), 'r');
      end
      legend('Actual','Prediction');

      comp_result(cv_num).rmse = system.RMSE;
      comp_result(cv_num).num_rules = system.num_rules;
      comp_result(cv_num).R = system.R;
      comp_result(cv_num).predicted = system.predicted;
      comp_result(cv_num).after_threshold = after_threshold;
      correct_predictions = length(find(data_target(start_test : target_size) - after_threshold(start_test :target_size) == 0));
      test_examples = (target_size - start_test) + 1;
      comp_result(cv_num).accuracy = (correct_predictions * 100)/test_examples;

      out = comp_result;
end
