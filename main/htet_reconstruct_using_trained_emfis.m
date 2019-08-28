

% XXXXXXXXXXXXXXXXXXXXXXXXXXX HTET_TEST_EMFIS XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :
% Date      :
% Function  :
% Syntax    :
%
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function output = htet_reconstruct_using_trained_emfis(net, input, current_count)

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
    disp('HN DEBUG predicted value');
    disp('HN DEBUG current_count value'); disp(current_count);
    output = system.predicted(current_count, :);
    disp(output);
end
