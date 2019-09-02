% XXXXXXXXXXXXXXXXXXXXXXXXXXX sus_nearest_rule XXXXXXXXXXXXXXXXXXXXXXXXXXXX
% 
% Author    :   Susanti
% Date      :   Aug 1 2014
% Function  :   Compute the nearest rule
% Syntax    :   sus_nearest_rule(rule, observation, rules_no)
% 
% Algorithm -
% 1) Compute the distance between each rule
% 2) Sort the rule in descending order
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function s12 = sus_nearest_rule(rule, observation, rules_no)
%disp('sus_two_nearest_rule');

    num_rules =  rule.active_rule_count;
    
    % calculate the distance between each rule and observation
    % by calculating the summation of each antecedent distance
    for i = 1 : num_rules
        num_attributes = rule.rules(i).antecedents.length;
        distance_sum(1,i) = 0;

        for j = 1:1:num_attributes
            a = rule.rules(i).antecedent(j);
            b = observation.antecedent(j);

            min_attribute_value = rule.rules(i).min_antecedent_ranges(1,j);
            max_attribute_value = rule.rules(i).max_antecedent_ranges(1,j);

            distance = (sus_abs_distance_to(a,b))/ (max_attribute_value - min_attribute_value);
            distance_sum(1,i) = distance_sum(1,i) + distance;

        end
        distance_ave(1,i) = distance_sum(1,i)/num_attributes;

    end

    % Sort the rule in descending order
    for j = 1 : rules_no
        nearest_rule(1,j) = 1;
        nearest_rule_distance(1,j) = distance_ave(1,1) ;

        for i = 1 : num_rules
            if nearest_rule_distance(1,j) > distance_ave(1,i)
                repeated_rule(1,j) = false;  
                for k = 1 : j-1
                    if nearest_rule(1,k) == i
                        repeated_rule(1,j) = true;
                    end
                end

                if repeated_rule(1,j) == false
                    nearest_rule(1,j) = i;
                    nearest_rule_distance(1,j) = distance_ave(1,i);
 
                end   
            end   
        end
    end

    s12.nearest_rule = nearest_rule;

end
