% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_reconstruct_using_trained_emfis XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   used to predict using pre-trained eMFIS(FRIE)
% Syntax    :   htet_reconstruct_using_trained_emfis(input, net)
% input - input data
% net - pre-trained eMFIS(FRIE) network
% Stars     :
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

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
