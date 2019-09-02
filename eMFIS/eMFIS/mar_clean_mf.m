% XXXXXXXXXXXXXXXXXXXXXXXXXXXXX MAR_CLEAN_MF XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% 
% Author    :   Mario Hartanto
% Date      :   Jan 27 2014
% Function  :   cleans MFs by merging very near MFs together
% Syntax    :   mar_clean_mf(net)
% 
% net - FIS network structure
% 
% Algorithm -
% 1.1) Merges input MFs and output MFs with based on reducibility condition (see mar_merge_mf)
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function [D, mm] = mar_clean_mf(net)
    
%    disp('Cleaning MF');
    num_attributes = size(net.input, 2);
    num_outputs = size(net.output, 2);
    mm = 0;
    
    % merge membership functions
    
    for i = 1 : num_outputs
        [net, m] = mar_merge_mf(net, 'output', i);
        % m = 1 means some mfs were merged
        if m
            % if any mfs were merged, return 1 to caller
            mm = 1;
                    
            % Update variance
            num_mf = size(net.output(i).mf, 2);
            for j = 1 : (num_mf - 1)
                stability_gap = abs(net.output(i).mf(j+1).params(2) - net.output(i).mf(j).params(4)) / (net.output(i).mf(j).stability + net.output(i).mf(j+1).stability);
                net.output(i).mf(j).params(3) = stability_gap * net.output(i).mf(j+1).stability;
                net.output(i).mf(j+1).params(1) = stability_gap * net.output(i).mf(j).stability;
            end
            net.output(i).mf(1).params(1) = net.output(i).mf(1).params(3);
            net.output(i).mf(num_mf).params(3) = net.output(i).mf(num_mf).params(1);
        end
    end 
    
    for i = 1 : num_attributes
        [net, m] = mar_merge_mf(net, 'input', i);
        if m
            mm = 1;
            % Update variance
            num_mf = size(net.input(i).mf, 2);
            for j = 1 : (num_mf - 1)
                stability_gap = abs(net.input(i).mf(j+1).params(2) - net.input(i).mf(j).params(4)) / (net.input(i).mf(j).stability + net.input(i).mf(j+1).stability);
                net.input(i).mf(j).params(3) = stability_gap * net.input(i).mf(j+1).stability;
                net.input(i).mf(j+1).params(1) = stability_gap * net.input(i).mf(j).stability;
            end
            net.input(i).mf(1).params(1) = net.input(i).mf(1).params(3);
            net.input(i).mf(num_mf).params(3) = net.input(i).mf(num_mf).params(1);
        end
    end      
    
    D = net;

end