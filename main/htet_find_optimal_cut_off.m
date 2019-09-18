% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_test_bank_classification_safin_frie XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   used to find optimal cut off point and other results for classificaiton problems
% Syntax    :   htet_find_optimal_cut_off(testData, net_out)
% testData - target data, the output label
% net_out - predicted values
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


function output = htet_find_optimal_cut_off(testData, net_out, threshold)

    unclassified_count = 0;
    after_threshold = zeros(length(testData),1);
    RESOLUTION = 0.001;
    cut_off = RESOLUTION;
    min_mean_cost = intmax;
    best_acc = intmin;
    eer_count = 0;

    fpr_penalized_cost = 1;
    fnr_penalized_cost = [1; 5; 10; 15; 20; 25; 30];
    MIN_EER = [];
    MIN_FPR = [];
    MIN_FNR = [];
    MIN_CUT_OFF = [];

    % initialize varaiables
    Acc = [];
    FPR = [];
    FNR = [];

    % to plot EER bisector line
    Bisector = [];
    for k=0:99
      Bisector = [Bisector, k];
    end

    if threshold ~= 0

      for i=1: length(testData)
          if net_out(i) > threshold
              after_threshold(i) = 1;
          elseif net_out(i) < threshold
              after_threshold(i) = 0;
          elseif net_out(i) == threshold
              after_threshold(i) = threshold;
              eer_count = eer_count + 1;
          else
              unclassified_count = unclassified_count + 1;
          end
      end
      net_result.predicted = {net_out};
      net_result.after_threshold = {after_threshold};
      net_result.unclassified = (unclassified_count * 100)/length(testData);

      [TP, FP, TN, FN, fnr, fpr, acc] = htet_get_classification_results(testData, after_threshold(:,1))


      output.MIN_EER = (fpr + fnr)/2;
      output.MIN_CUT_OFF = threshold;
      output.MIN_FPR = fpr;
      output.MIN_FNR = fnr;
      return;
    end

    out_fpr = [];
    out_fnr = [];

    %%%%%%%%%%%%%% to find out the best cut-off point or EER value %%%%%%%%%%%%%%%%%
    for z=1:length(fnr_penalized_cost)
      while(cut_off <= 1)
          for i=1: length(testData)
              if net_out(i) > cut_off
                  after_threshold(i) = 1;
              elseif net_out(i) < cut_off
                  after_threshold(i) = 0;
              elseif net_out(i) == cut_off
                  after_threshold(i) = cut_off;
                  eer_count = eer_count + 1;
              else
                  unclassified_count = unclassified_count + 1;
              end
          end
          net_result.predicted = {net_out};
          net_result.after_threshold = {after_threshold};
          net_result.unclassified = (unclassified_count * 100)/length(testData);

          [TP, FP, TN, FN, fnr, fpr, acc] = htet_get_classification_results(testData, after_threshold(:,1))

          FPR = [FPR, fpr];
          FNR = [FNR, fnr];

          fpr_cost = fpr * fpr_penalized_cost;
          fnr_cost = fnr * fnr_penalized_cost(z,:);

          curr_cost = (fpr_cost + fnr_cost)/2;
          eer = (fpr + fnr)/2;
          % if the current cost is less than the minimum value, update the minimum cost
          if curr_cost < min_mean_cost
            optimal_cut_off = round(cut_off, 4);
            min_mean_cost = (round(curr_cost, 4)); % it is also the EER
            best_eer = round(eer, 2);
            best_fpr = round(fpr, 2);
            best_fnr = round(fnr, 2);
          end

          if acc > best_acc
            best_acc = acc;
            best_acc_cutoff = cut_off;
            best_acc_fpr = fpr;
            best_acc_fnr = fnr;
          end

          Acc = [Acc; acc];
          cut_off = cut_off + RESOLUTION;
          unclassified_count = 0;
          eer_count = 0;
          after_threshold = zeros(length(testData),1);
      end

      MIN_EER = [MIN_EER; best_eer];
      MIN_CUT_OFF = [MIN_CUT_OFF; optimal_cut_off]
      MIN_FPR = [MIN_FPR; best_fpr];
      MIN_FNR = [MIN_FNR; best_fnr];

      out_fpr = [out_fpr; {FPR}];
      out_fnr = [out_fnr; {FNR}];

      % reset all values
      unclassified_count = 0;
      after_threshold = zeros(length(testData),1);
      cut_off = RESOLUTION;
      min_mean_cost = intmax;
      best_acc = intmin;
    end

    % figure;
    % plot(FPR, FNR, 'b'); % plot the matrix
    % hold on;
    % plot(Bisector, Bisector, 'r'); % plot the matrix
    % title('Bank Failure Detection Error Tradeoff', 'FontSize', 14); % set title
    % colormap('jet'); % set the colorscheme
    % hold off;
    %
    % % plot accuracy chart
    % figure;
    % bar(Acc); % plot the matrix
    % title('Bank Failure Classification Accuracy', 'FontSize', 14); % set title
    % colormap('jet'); % set the colorscheme
    output.MIN_EER = MIN_EER;
    output.MIN_CUT_OFF = MIN_CUT_OFF;
    output.MIN_FPR = MIN_FPR;
    output.MIN_FNR = MIN_FNR;
    output.all_fpr = out_fpr;
    output.all_fnr = out_fnr;
    output.bisector = Bisector;
end
