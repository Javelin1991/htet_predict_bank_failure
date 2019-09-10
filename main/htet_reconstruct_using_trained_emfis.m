

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
    % predict result of each component network individually
    net.predicted(current_count, :) = mar_cri(input, net);

    if isnan(net.predicted(current_count, :))
        net.predicted(current_count, :) = 0;
        predicted(current_count, :) = 0;
    else
        % system prediction is weighted average of individual prediction
        predicted(current_count, :) =  net.predicted(current_count, :);
    end
    output = predicted(current_count, :);
end
