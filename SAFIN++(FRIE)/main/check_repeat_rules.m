function [Rules,Rules_Weight] = check_repeat_rules(Rules,Rules_Weight)

repeat_rule = 0;
number_of_rules = size(Rules,1);
i = 1; %start with i = 1
while i < number_of_rules %for each rule in rulebase
    rule = Rules(i,:);
    j = i+1;
    while j <= number_of_rules
        if Rules(j,:) == rule(1,:)
            repeat_rule = 1;
            % Delete away rule j
            number_of_rules = number_of_rules-1;
            Rules(j:number_of_rules,:) = Rules(j+1:number_of_rules+1,:); %delete rule j
            if Rules_Weight(i) > Rules_Weight(j) %remain the larger certainty
                Rules_Weight(i) = Rules_Weight(j); 
            end
            Rules_Weight(j:number_of_rules) = Rules_Weight(j+1:number_of_rules+1); %delete certainty of rule j
        end
        if repeat_rule == 0
            j = j+1;  %increase for next rule
        else
            repeat_rule = 0;
        end
    end
    i = i + 1; %increase to next rule
end
Rules = Rules(1:number_of_rules,:);
Rules_Weight = Rules_Weight(1:number_of_rules);     