% XXXXXXXXXXXXXXXXXXXXXXXX RON_CHECK_CONSISTENCY2 XXXXXXXXXXXXXXXXXXXXXXXXX
% 
% Author    :   Ron TD
% Date      :   Feb 09 2010
% Function  :   checks for rule consistency after removing attributes
% Syntax    :   ron_check_consistency2(net, index, varargin)
% 
% net - FIS network structure
% index - attribute number (e.g. 1, 2 for first, second etc.)
% rule_num (optional) - rule number to remove attribute from. leaving it
% blank removes attributes from all rules
% 
% Algorithm -
% 1) Collates rule database and removes attribute by replacing antecedent value of attribute of all rules (or rule_num-th rule) to 0
% 2) If same antecedents point to different consequents, this reduction is inconsistent
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function D = ron_check_consistency2(net, index, varargin)

    disp('Check consistency 2');

    num_attributes = size(net.input, 2);
    num_outputs = size(net.output, 2);
    num_rules = size(net.rule, 2);  

    rule_database = zeros(num_rules, num_attributes + num_outputs);

    % collate rule database
    for i = 1 : num_rules
        rule_database(i, 1 : num_attributes) = net.rule(i).antecedent;
        rule_database(i, num_attributes + 1 : num_attributes + num_outputs) = net.rule(i).consequent;
    end

    % replace antecedent value of attribute with 0
    if isempty(varargin)
        rule_database(:, index) = 0;
    else
        rule_database(varargin{1}, index) = 0;
    end

    % check for rule base consistency
    consistent = 1;
    for i = 1 : num_rules
        for j = 1 : num_rules
            if sum(rule_database(i, 1 : num_attributes) == rule_database(j, 1 : num_attributes)) == num_attributes && ...
                    sum(rule_database(i, num_attributes + 1 : num_attributes + num_outputs) == rule_database(j, num_attributes + 1: num_attributes + num_outputs)) ~= num_outputs && ...
                        i ~= j
                consistent = 0;
                break;
            end
        end
        if consistent == 0
            break;
        end
    end

    D = consistent;
end