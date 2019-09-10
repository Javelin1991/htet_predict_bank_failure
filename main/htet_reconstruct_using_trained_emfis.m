

% XXXXXXXXXXXXXXXXXXXXXXXXXXX HTET_TEST_EMFIS XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :
% Date      :
% Function  :
% Syntax    :
%
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function output = htet_reconstruct_using_trained_emfis(input, net)

    current_count = 1; % hardcoded to 1, can be any num

    system = net;
    % predict result of each component network individually
    system.net.predicted(current_count, :) = mar_cri(input, system.net);

    if isnan(system.net.predicted(current_count, :))
        system.net.predicted(current_count, :) = 0;
        system.predicted(current_count, :) = 0;
    else
        % system prediction is weighted average of individual prediction
        system.predicted(current_count, :) =  system.net.predicted(current_count, :);
    end
    output = system.predicted(current_count, :);
end
