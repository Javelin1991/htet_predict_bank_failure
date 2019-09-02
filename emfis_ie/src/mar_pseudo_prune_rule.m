% XXXXXXXXXXXXXXXXXXXXXXXXXXX MAR_PSEUDO_PRUNE_RULE XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Mario Hartanto
% Date      :   Feb 3 2014
% Function  :   Online selection of rules
% Syntax    :   mar_pseudo_prune_rule(net, current_count)
%
% net - FIS network structure
%
% Algorithm - If rule weight is less than threshold, the rule is inactivated
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function D = mar_pseudo_prune_rule(net, current_count)

%    disp('Pseudo Prune Rule');

    min_weight = net.min_rule_weight;
    num_rules = size(net.rule, 2);
    count_rules = 0;

    for i = 1 : num_rules
        if net.rule(i).weight < min_weight
            net.rule(i).active = 0;
            net.rule(i).lastUpdate = current_count;
        else
            net.rule(i).active = 1;
            count_rules = count_rules + 1;
        end
    end

    net.num_active_rules = count_rules;
    D = net;
end
