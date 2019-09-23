% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_generate_det_plot_increased_data XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   htet_generate_det_plot_increased_data
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
clc;
clear;

% load safin_cv5_top3_feat_results;
load safin_frie_cv5_top3_feat_increased;
color_str = 'rgbcm'
MEAN_INCREASED = [];
ACC = [];
mean_eer_increased_data = 0;

for j=1:3
    figure;
    bisector = net_result_for_last_record(1).output.bisector;
    plot(bisector, bisector, 'k'); % plot the matrix
    hold on;
    mean_eer_increased_data = 0;
    for i=1:5
        switch j
            case 1
                % the last available record
                fpr = net_result_for_last_record(i).output.all_fpr{1, 1}
                fnr = net_result_for_last_record(i).output.all_fnr{1, 1}
                mean_eer_increased_data = mean_eer_increased_data + net_result_for_last_record(i).output.MIN_EER(1,1);
                plot(fnr, fpr, color_str(i)); % plot the matrix
                title('Bank Failure Detection Error Tradeoff (last avaiable)', 'FontSize', 14); % set title
                colormap('jet'); % set the colorscheme
            case 2
                % one year priror
                fpr = net_result_for_one_year_prior(i).output.all_fpr{1, 1}
                fnr = net_result_for_one_year_prior(i).output.all_fnr{1, 1}
                mean_eer_increased_data = mean_eer_increased_data + net_result_for_one_year_prior(i).output.MIN_EER(1,1);
                plot(fnr, fpr, color_str(i)); % plot the matrix
                title('Bank Failure Detection Error Tradeoff (one year prior)', 'FontSize', 14); % set title
                colormap('jet'); % set the colorscheme
            case 3
                % two year priror
                fpr = net_result_for_two_year_prior(i).output.all_fpr{1, 1}
                fnr = net_result_for_two_year_prior(i).output.all_fnr{1, 1}
                mean_eer_increased_data = mean_eer_increased_data + net_result_for_two_year_prior(i).output.MIN_EER(1,1);
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
    mean_eer_increased_data = mean_eer_increased_data/5;
    MEAN_INCREASED = [MEAN_INCREASED; mean_eer_increased_data];
    acc = 100 - mean_eer_increased_data
    ACC = [ACC; acc];
end
