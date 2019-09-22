% XXXXXXXXXXXXXXXXXXXXXXXXXXXXX RON_CLEAN_MF XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% 
% Author    :   Ron TD
% Date      :   Jan 30 2010
% Function  :   cleans MFs by merging very near MFs together
% Syntax    :   ron_clean_mf(net)
% 
% net - FIS network structure
% 
% Algorithm -
% 1.1) Merges input MFs and output MFs with small centroid differences (see ron_merge_mf)
% 1.2) Merges input MFs and output MFs using rough set reduction (see ron_rsmerge_mf)
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function [D mm] = ron_clean_mf(net)
    
    disp('Cleaning MF');
    num_attributes = size(net.input, 2);
    num_outputs = size(net.output, 2);
    mm = 0;
    
    % merge membership functions
    
    for i = 1 : num_outputs
        [net m] = ron_merge_mf(net, 'output', i);
        % m = 1 means some mfs were merged
        if m
            % if any mfs were merged, return 1 to caller
            mm = 1;
        end
    end 
    
    for i = 1 : num_attributes
        [net m] = ron_merge_mf(net, 'input', i);
        if m
            mm = 1;
        end
    end      
    
    D = net;

end