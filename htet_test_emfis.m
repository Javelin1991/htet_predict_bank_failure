

% XXXXXXXXXXXXXXXXXXXXXXXXXXX HTET_TEST_EMFIS XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :
% Date      :
% Function  :
% Syntax    :
%
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function output = htet_test_emfis(net, input, current_count)

    system = net;

    if current_count == 1
        system.net.predicted(current_count, :) = 0;
        system.predicted(current_count, :) = 0;
    else
        % predict result of each component network individually
        system.net.predicted(current_count, :) = mar_cri(input, system.net);

        if isnan(system.net.predicted(current_count, :))
            system.net.predicted(current_count, :) = 0;
            system.predicted(current_count, :) = 0;
        else
            % system prediction is weighted average of individual prediction
            system.predicted(current_count, :) =  system.net.predicted(current_count, :);
        end
    end

    output = system.predicted(current_count, :);
end
