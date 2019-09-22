% XXXXXXXXXXXXXXXXXXXXXXXXXXXX RON_CHECK_BOM XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% 
% Author    :   Ron TD
% Date      :   Feb 09 2010
% Function  :   calculates baseline objective measure for every historical data, for every rule
% Syntax    :   ron_check_bom(net, stored_input)
% 
% net - FIS network structure
% stored_input - historical input data
% 
% Algorithm -
% 1) Get firing strength of each rule for every historical dataset
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function D = ron_check_bom(net, stored_input)

    num_rules = size(net.rule, 2);
    % for stored_input, rows are DATASETS, columns are ATTRIBUTES
    num_stored = size(stored_input, 1);
    num_attributes = size(stored_input, 2);
    
    % for D, rows are RULES, columns are DATASETS
    D = zeros(num_rules, num_stored);
    antecedent_values = zeros(1, num_attributes);
    
    % calculate firing strength of each rule for every historical dataset
    for i = 1 : num_rules
        for j = 1 : num_stored
            for k = 1 : num_attributes
                % if membership function is 0, means attribute is reduced.
                % since firing strength is min operator, set some random
                % high number will 'ignore' this attribute
                if net.rule(i).antecedent(k) == 0
                    antecedent_values(j, k) = 100;
                else
                    if( net.input(k).mf(net.rule(i).antecedent(k)).params(1)~=0 &&  net.input(k).mf(net.rule(i).antecedent(k)).params(3) ~=0)
                    antecedent_values(j, k) = gauss2mf(stored_input(j, k), net.input(k).mf(net.rule(i).antecedent(k)).params);
                    end
                end
            end
        end
        D(i, :) = min(antecedent_values, [], 2);
    end
                
end