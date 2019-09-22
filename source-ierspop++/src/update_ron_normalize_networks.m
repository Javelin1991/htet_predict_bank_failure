% XXXXXXXXXXXXXXXXXXXXXXX RON_NORMALIZE_NETWORKS XXXXXXXXXXXXXXXXXXXXXXXXXX
% 
% Author    :   Ron TD
% Date      :   Feb 10 2010
% Function  :   normalize weights of all networks
% Syntax    :   ron_normalize_weights(ensemble)
% 
% ensemble - FIS ensemble struct
% 
% Algorithm -
% 1) Normalizes weights of all rules in rule base to be proportional to
%    their accuracy, which is inversely proportional to their cumulative
%    errors
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function D = ron_normalize_networks(ensemble)

    disp('Normalize Networks');
    num_networks = size(ensemble.net_struct, 2);
    current_count = ensemble.dataProcessed;
    
    if num_networks == 1
        D = ensemble;
        return;
    end

    stored_input = ensemble.stored_input;
    stored_targets = ensemble.stored_targets;
    num_data = size(stored_input, 1);
    
    error = zeros(num_networks, 1);
    norm_error = zeros(num_networks, 1);
    
    weight = zeros(num_networks, 1);
    norm_weight = zeros(num_networks, 1);
    
    % get error
    for i = 1 : num_networks
        error(i, 1) = ron_mse(ensemble.net_struct(i).net.predicted(current_count - num_data + 1 : current_count, :), stored_targets);
        % weighted error - older networks get higher weight on errors
        error(i, 1) = (num_networks - i + 1) * (error(i, 1) / num_data);
    end
    
    total_error = sum(error(:, 1));
    
    % get norm_error
    for i = 1 : num_networks
        norm_error(i, 1) = error(i, 1) / total_error;
        weight(i, 1) = log(1 / norm_error(i, 1));
    end
    
    pre_total = sum(weight(:, 1));
    [maxWeight, winner] = max(weight);
    
    if(num_networks > 1)
    for i = 1 : num_networks-1
        if(i==winner)
            forgot = 1;
            ensemble.net_struct(i).net.lastLearned = current_count;
            ensemble.net_struct(i).net.winner = ensemble.net_struct(i).net.winner + 1;
        else
            forgot = (1-exp(-(((i)*(current_count-ensemble.net_struct(i).net.lastLearned+1)*(ensemble.net_struct(i).net.winner))/ (weight(i, 1)/pre_total))));
        end;
        factor = forgot*0.99;
        weight(i, 1) = factor*weight(i,1);
    end
    end
       
       
    total_weight = sum(weight(:, 1));
    
    % get norm weight
    for i = 1 : num_networks
        norm_weight(i, 1) = weight(i, 1) / total_weight;  
        ensemble.net_struct(i).net.weight = norm_weight(i, 1);
    end

    
    D = ensemble;
end
