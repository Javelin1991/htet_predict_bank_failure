% XXXXXXXXXXXXXXXXXXXXXXXX RON_NORMALIZE_WEIGHTS XXXXXXXXXXXXXXXXXXXXXXXXXX
% 
% Author    :   Ron TD
% Date      :   Feb 03 2010
% Function  :   normalize weights of rule base
% Syntax    :   ron_normalize_weights(net)
% 
% net - FIS network struct
% 
% Algorithm -
% 1) Normalizes weights of all rules in rule base to be between 0 and 1
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function D = ron_normalize_weights(net)

   disp('Normalize weights'); 
    num_rules = size(net.rule, 2);
    weight_database = zeros(num_rules, 1);
    
    for i = 1 : num_rules
        weight_database(i, 1) = net.rule(i).weight;
    end

    weight_database = mapminmax(weight_database', 0.01, 1)';

    for i = 1 : num_rules
        net.rule(i).weight = weight_database(i, 1);
    end
    
    D = net;
end