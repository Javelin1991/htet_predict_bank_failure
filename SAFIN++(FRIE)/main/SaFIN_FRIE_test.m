function net_out = SaFIN_FRIE_test(input,IND,OUTD,no_InTerms,InTerms,no_OutTerms,OutTerms,Rules, isHcl)
    net.rule_importance = zeros(size(Rules,1),1);
    % Initialize
    in_mf = zeros(IND,max(no_InTerms));
    act_rules = zeros(size(Rules,1),1);  % 1 i for each rule (each i has 1 col)
    inferred = zeros(OUTD,max(no_OutTerms));
    check = zeros(OUTD,max(no_OutTerms));
    max_mfv = zeros(1,IND);
    max_mfv_index = zeros(1,IND);
    % Layer 2
    for dim = 1:IND    %for each input dimension
        for k = 1:no_InTerms(dim) %for each input term in that dimension
            in_mf(dim,k) = exp( -(input(1,dim)-InTerms(dim,2*k-1))^2 / (InTerms(dim,2*k)^2) ); %compute membership function of input with the term - similarity value
        end
    end

    total_rule_strength = 0;
    rule_counter = 0;
    % Layer 3
    for j = 1:size(Rules,1) %for each rule
        tmp = zeros(IND,1);
        for k = 1:IND %for each dimension
            tmp(k) = in_mf(k,Rules(j,k)); %get similarity of the input with the antecedent in that dimension in the rule
        end
        act_rules(j) = min(tmp); % get the activation value of the rule by min-operation
        clear tmp;               % act_rules stores importance of each role with respect to the particular input data instance
    end

    % Layer 4
    for j = 1:size(Rules,1) %for each rule
        for k = 1:OUTD %for each output dimension
            if inferred(k,Rules(j,IND+k)) < act_rules(j)
                inferred(k,Rules(j,IND+k)) = act_rules(j);       %get the maximum activation value of the term for each output dimension
                total_rule_strength = total_rule_strength + inferred(k,Rules(j,IND+k));
                rule_counter = rule_counter + 1;
            end
            check(k,Rules(j,IND+k)) = 1;  % Rules(j,IND+k) will give you the output cluster for the output variable/dimension k.
        end
    end
    % Layer 5
    for j = 1:OUTD
        top = 0; bottom = 0;
        for k = 1:no_OutTerms(j)  % iterating over all clusters in output
            if check(j,k) == 1
                top = top + inferred(j,k)*OutTerms(j,2*k-1)*OutTerms(j,2*k); %defuzzification
                % manan
                for m = 1:size(Rules,1)
                    if( inferred(j,k) == act_rules(m))
                        net.rule_importance(m) = net.rule_importance(m) + 1;
                    end
                end
                % manan

                bottom = bottom + inferred(j,k)*OutTerms(j,2*k);
            end
        end
    end
    net_out = top/bottom;

    if isHcl
      if rule_counter == 0
        rule_counter = 1;
      end
      net_out = total_rule_strength/rule_counter;
    end
end
