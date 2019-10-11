% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_playground_test_any_code_snippet XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   htet_generate_det_plot
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
clc;
clear;
close all;

color_str = 'rgbcm'
MEAN_ORIGINAL = [];
ACC = [];
EER = [];
mean_eer_original_data = 0;
mean_eer_increased_data = 0;

% load feat_select_safin_frie_cv5_9_feat_original_last_avail
load feat_select_safin_frie_cv5_top3_feat_original_last_avail

tmp = BEST_SYSTEMS

for j=1:3
    figure;
    bisector = tmp(1).output.bisector;
    plot(bisector, bisector, 'k'); % plot the matrix
    hold on;
    mean_eer_original_data = 0;
    P = [];
    FINAL_RESULT = [];

    switch j
      case 1
        % load feat_select_safin_frie_cv5_9_feat_original_last_avail
        load feat_select_safin_frie_cv5_top3_feat_original_last_avail

        net_result_for_last_record = BEST_SYSTEMS
      case 2
        % load feat_select_safin_frie_cv5_9_feat_original_one_year
        load feat_select_safin_frie_cv5_top3_feat_original_one_year

        net_result_for_one_year_prior = BEST_SYSTEMS
      case 3
        % load feat_select_safin_frie_cv5_9_feat_original_two_year
        load feat_select_safin_frie_cv5_top3_feat_original_two_year
        4
        net_result_for_two_year_prior = BEST_SYSTEMS
    end

    for i=1:5
        switch j
            case 1
                % the last available record
                fpr = net_result_for_last_record(i).output.all_fpr{1, 1}
                fnr = net_result_for_last_record(i).output.all_fnr{1, 1}
                curve = [fpr, fnr];
                %       P = InterX([x1;y1],[x2;y2]);
                inX = InterX([fpr;fnr],[bisector;bisector]);
                P = [P; inX'];
                mean_eer_original_data = mean_eer_original_data + inX(1,1);
                FINAL_RESULT = [FINAL_RESULT; inX(1,1)]
                plot(fnr, fpr, color_str(i)); % plot the matrix
                title('Bank Failure Detection Error Tradeoff (last avaiable)', 'FontSize', 14); % set title
                colormap('jet'); % set the colorscheme
            case 2
                % one year priror
                fpr = net_result_for_one_year_prior(i).output.all_fpr{1, 1}
                fnr = net_result_for_one_year_prior(i).output.all_fnr{1, 1}
                curve = [fpr, fnr];
                %       P = InterX([x1;y1],[x2;y2]);
                inX = InterX([fpr;fnr],[bisector;bisector]);
                P = [P; inX'];
                mean_eer_original_data = mean_eer_original_data + inX(1,1);
                FINAL_RESULT = [FINAL_RESULT; inX(1,1)]
                plot(fnr, fpr, color_str(i)); % plot the matrix
                title('Bank Failure Detection Error Tradeoff (one year prior)', 'FontSize', 14); % set title
                colormap('jet'); % set the colorscheme
            case 3
                % two year priror
                fpr = net_result_for_two_year_prior(i).output.all_fpr{1, 1}
                fnr = net_result_for_two_year_prior(i).output.all_fnr{1, 1}
                curve = [fpr, fnr];
                %       P = InterX([x1;y1],[x2;y2]);
                inX = InterX([fpr;fnr],[bisector;bisector]);
                P = [P; inX'];
                mean_eer_original_data = mean_eer_original_data + inX(1,1);
                FINAL_RESULT = [FINAL_RESULT; inX(1,1)]
                plot(fnr, fpr, color_str(i)); % plot the matrix
                title('Bank Failure Detection Error Tradeoff (two year prior)', 'FontSize', 14); % set title
                colormap('jet'); % set the colorscheme
        end

        % '-'
        % Solid line (default)
        %
        % '--'
        % Dashed line
        %
        % ':'
        % Dotted line
        %
        % '-.'
    end
    legend('EER','CV1','CV2', 'CV3', 'CV4', 'CV5');
    hold off;
    mean_eer_original_data = mean_eer_original_data/5;
    RESULT(j) = {[FINAL_RESULT; mean_eer_original_data]}
    MEAN_ORIGINAL = [MEAN_ORIGINAL; mean_eer_original_data];
    acc = 100 - mean_eer_original_data;
    ACC = [ACC; acc];
    EER = [EER; {P}]
    clear BEST_SYSTEMS;
end
