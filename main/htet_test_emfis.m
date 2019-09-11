% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_test_emfis XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   used along with Monte Carlo Evaluative Selection MCES algorithm when testing eMFIS models
% Syntax    :   htet_test_emfis(net, input, current_count)
% net - pretrained network
% input - input data
% current_count - hardcoded to 1, can be any num
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function output = htet_test_emfis(net, input, current_count)
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
