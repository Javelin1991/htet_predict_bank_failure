% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_generate_det_plot XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   htet_generate_det_plot(systems, timeline)
% systems - bank failure prediction systems
% timeline - last avaiable, One-year prior, Two-year prior
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function DET_OUT = htet_generate_det_plot(systems, timeline)
    color_str = 'rgbcm'
    MEAN = [];
    ACC = [];
    EER = [];
    ALL_EER = [];
    ALL_ACC = [];
    mean_eer = 0;
    mean_acc = 0;
    P = [];


    figure;
    bisector = systems(1).output.bisector  ;
    plot(bisector, bisector, 'k'); % plot the matrix
    hold on;

    for i=1:size(systems,1)
        % the last available record
        fpr = systems(i).output.all_fpr{1, 1}
        fnr = systems(i).output.all_fnr{1, 1}
        FNR = FNR + fnr;
        FPR = FPR + fpr;
        curve = [fpr, fnr];
        %       P = InterX([x1;y1],[x2;y2]);
        inX = InterX([fpr;fnr],[bisector;bisector]);
        P = [P; inX'];
        mean_eer = mean_eer + inX(1,1);
        mean_acc = mean_acc + (100 - inX(1,1));
        EER = [EER; inX(1,1)]
        ACC = [ACC; (100 - inX(1,1))]
        xlabel('Error II (%)');
        ylabel('Error I (%)');
        plot(fpr, fnr, color_str(i)); % plot the matrix
        formatSpec = 'Bank Failure Detection Error Tradeoff %s';
        str = sprintf(formatSpec,timeline);
        title(str, 'FontSize', 14); % set title
        colormap('jet'); % set the colorscheme

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
    DET_OUT.mean_eer = mean_eer/5;
    DET_OUT.mean_acc = mean_acc/5;
    DET_OUT.ALL_EER = {[EER; mean_eer]}
    DET_OUT.ALL_ACC = {[ACC; mean_acc]};
end
