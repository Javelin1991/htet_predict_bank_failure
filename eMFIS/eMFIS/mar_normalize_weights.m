% XXXXXXXXXXXXXXXXXXXXXXXX MAR_NORMALIZE_WEIGHTS XXXXXXXXXXXXXXXXXXXXXXXXXX
% 
% Author    :   Mario Hartanto
% Date      :   Feb 05 2014
% Function  :   normalize weights of rule base
% Syntax    :   mar_normalize_weights(net)
% 
% net - FIS network struct
% 
% Algorithm -
% 1) Normalizes weights of all rules in rule base to be between 0 and 1
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function D = mar_normalize_weights(net)

%    disp('Normalize weights'); 
    num_rules = size(net.rule, 2);
    weight_database = zeros(num_rules, 1);
    
    for i = 1 : num_rules
        weight_database(i, 1) = net.rule(i).weight;
    end
    
    max_weight = max(weight_database); 

    for i = 1 : num_rules
        net.rule(i).weight = net.rule(i).weight / max_weight;
    end
    
    D = net;
end