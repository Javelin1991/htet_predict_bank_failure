function [Rules,Rules_Weight] = check_ambiguous_rules(Rules,Rules_Weight,inputD,outputD)

di = 0; dj = 0;
number_of_rules = size(Rules,1);
i = 1;
while i < number_of_rules %for each rule 
    rule = Rules(i,:); %get rule i
    j = i+1; %next rule
    while j <= number_of_rules
        if Rules(j,1:inputD) == rule(1,1:inputD)  %antecedent
            if Rules(j,inputD+1:inputD+outputD) ~= rule(1,inputD+1:inputD+outputD) %consequent
                % ambiguity detected
                if Rules_Weight(i) < Rules_Weight(j)
                    di = 1;  %delete rule i
                else
                    dj = 1;  %delete rule j
                end
                if di == 1
                    Rules(i,:) = Rules(j,:);  %delete rule i, store rule j to rule i
                    Rules_Weight(i) = Rules_Weight(j);
                    rule = Rules(i,:);  %get new rule i
                    number_of_rules = number_of_rules - 1;
                    Rules(j:number_of_rules,:) = Rules(j+1:number_of_rules+1,:);
                    Rules_Weight(j:number_of_rules) = Rules_Weight(j+1:number_of_rules+1);
                    di = 0;
                    j = i+1;
                end
                if dj == 1
                    number_of_rules = number_of_rules - 1;
                    Rules(j:number_of_rules,:) = Rules(j+1:number_of_rules+1,:);
                    Rules_Weight(j:number_of_rules) = Rules_Weight(j+1:number_of_rules+1);
                    dj = 0;
                end
            else
                j = j+1;
            end
        else
            j = j+1;
        end
    end
    i = i+1;
end
Rules = Rules(1:number_of_rules,:);
Rules_Weight = Rules_Weight(1:number_of_rules);
        