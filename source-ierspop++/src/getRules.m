function setRules = getRules(rule, inputSize, outputSize, boolean)

if boolean
    setRules = zeros( size(rule,2), inputSize + outputSize);

    for i=1: size(rule,2)
        for j=1:size(rule(i).antecedent, 2)
            setRules(i, j) = rule(i).antecedent(j);
        end

        for j=1:size(rule(i).consequent, 2)
            setRules(i,j+inputSize) = rule(i).consequent(j);
        end

    end
else
    %setRules = zeros( size(rule,2), inputSize + outputSize);
    for i=1: size(rule,2)
        for j=1:size(rule(i).antecedent, 2)
            setRules(i, j) = rule(i).antecedent(j);
        end

        for j=1:size(rule(i).consequent, 2)
            setRules(i,j+inputSize) = rule(i).consequent(j);
        end

    end
    
end

end