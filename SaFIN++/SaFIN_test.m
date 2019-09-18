function [net_out,rule_importance] = SaFIN_test(TestData, system)


IND = system.IND;
OUTD = system.OUTD;
no_InTerms = system.no_InTerms;
InTerms = system.InTerms;
no_OutTerms = system.no_OutTerms;
OutTerms = system.OutTerms;
Rules = system.Rules;

net_out = zeros(size(TestData,1),OUTD);   % will store output of the test data


rule_importance = zeros(size(Rules,1),1);

disp('During testing phase....')
for i = 1:size(TestData,1)

    % Initialize
    in_mf = zeros(IND,max(no_InTerms));
    act_rules = zeros(size(Rules,1),1);  % 1 row for each rule (each row has 1 col)
    inferred = zeros(OUTD,max(no_OutTerms));
    check = zeros(OUTD,max(no_OutTerms));


    disp('During testing phase....')


    % Layer 2
    for j = 1:IND    %for each input dim, we evalute mfv with all its clusters
        for k = 1:no_InTerms(j)
            in_mf(j,k) = exp( -(TestData(i,j)-InTerms(j,2*k-1))^2 / (InTerms(j,2*k)^2) );
        end
    end
    disp('in_mf'); disp(in_mf)
    % Layer 3
    for j = 1:size(Rules,1)
        tmp = zeros(IND,1);
        for k = 1:IND
            tmp(k) = in_mf(k,Rules(j,k));
        end
        disp('tmp'); disp(tmp);
        act_rules(j) = min(tmp); % for each rule, this stores the min. value of mfv between any input data variable value and the corresponding cluster in the rule.
        clear tmp;               % act_rules stores importance of each role with respect to the particular input data instance
    end
    disp('act_rules'); disp(act_rules);
    % Layer 4
    disp('inferred'); disp(inferred)

    for j = 1:size(Rules,1)
        for k = 1:OUTD
            if inferred(k,Rules(j,IND+k)) < act_rules(j)
                disp('inferred'); disp(inferred(k,Rules(j,IND+k)))
                disp('act_rules(j)'); disp(act_rules(j));
                inferred(k,Rules(j,IND+k)) = act_rules(j);
            end
            check(k,Rules(j,IND+k)) = 1;  % Rules(j,IND+k) will give you the output cluster for the output variable/dimension k.
        end
    end
    % Layer 5
    for j = 1:OUTD
        top = 0; bottom = 0;
        for k = 1:no_OutTerms(j)  % iterating over all clusters in output
            if check(j,k) == 1
                top = top + inferred(j,k)*OutTerms(j,2*k-1)*OutTerms(j,2*k);
          % manan
                for m = 1:size(Rules,1)
                   if( inferred(j,k) == act_rules(m))
                       rule_importance(m) = rule_importance(m) + 1;

                   end
                end

                % manan
                disp('top'); disp(top);

                bottom = bottom + inferred(j,k)*OutTerms(j,2*k);
                disp('bottom'); disp(bottom);
            end
        end
        disp('top/bottom'); disp(top/bottom);
        net_out(i,j) = top/bottom;
    end
end
