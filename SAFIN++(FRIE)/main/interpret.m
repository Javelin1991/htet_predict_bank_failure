function [Rules_semantic Rule_importance] = interpret(net, IND, OUTD)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DISPLAY RULE BASE %%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('RULE BASE');
    disp(net.Rules);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DISPLAY RULE SEMANTIC %%%%%%%%%%%%%%%%%%%%%%%%%%
    semantic_list = {'M  ';'H  ';'VH ';'VVH ';'L  ';'VL ';'VVL '}; %
    Rule_importance = [];
    %Rules_semantic = Rules;
    if (max(net.no_InTerms) <=7 && max(net.no_OutTerms) <=7)  % only if max. no of clusters for any variable is <=7
        net.Rules_semantic = cell(size(net.Rules,1), IND+OUTD);  %a cell array equal to rule base
        for p = 1:size(net.Rules,1) %for each rule
            for q = 1:IND %for each input dimension
                diff = net.Rules(p,q) - ceil((net.no_InTerms(q))/2);   % ceil rounds towards higher no.
                % we wanted 5 / 2 = 3 % and also 6 / 2 = 3
                if (diff > 0)

                    net.Rules_semantic{p,q} = semantic_list{(diff+1)};


                elseif (diff < 0)

                    diff2 = 0 - diff; % changing diff to positive

                    net.Rules_semantic{p,q} = semantic_list{(4 + diff2)};


                else   % diff is 0

                    net.Rules_semantic{p,q} = semantic_list{1};

                end

            end
            for r = 1:OUTD

                diff = net.Rules(p,r+(IND)) - ceil((net.no_OutTerms(r))/2);

                if (diff > 0)

                    net.Rules_semantic{p,r+(IND)} = semantic_list{(diff+1)};

                elseif (diff < 0)

                    diff2 = 0 - diff; % changing diff to positive

                    net.Rules_semantic{p,r+(IND)} = semantic_list{(4 + diff2)};

                else

                    net.Rules_semantic{p,r+(IND)} = semantic_list{1};
                end
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FIND IMPORTANT RULES %%%%%%%%%%%%%%%%%%%%%%%%%%
    if (max(net.no_InTerms) <=7 & max(net.no_OutTerms) <=7)

        disp('The semantic rules are:');
        disp(' ');
        for u = 1:size(net.Rules,1)
            str = sprintf('%s', net.Rules_semantic{u,:});
            disp(str);
            disp(' ');
        end
        Rules_semantic = net.Rules_semantic;
    end

    rule_imp = net.Rules_Weight; % creating a copy of rule_importance
    rule_sort = sort(rule_imp,'descend');

    disp('The important rules are:');
    disp(' ');

    if size(net.Rules,1) > 10

        imp_ruleCount = ceil(size(net.Rules,1) * 0.3);

    else

        imp_ruleCount = 1;

    end

    for a = 1:imp_ruleCount

        for b = 1:size(net.Rules,1)

            if(rule_sort(a) == rule_imp(b))

                s = sprintf('Rule %d', b);
                disp(s);
                disp(' ');

                if (max(net.no_InTerms) <=7 & max(net.no_OutTerms) <=7)
                    st = sprintf('%s', net.Rules_semantic{b,:});
                    disp(st);
                    disp('HN DEBUG comes here condition 1');
                    Rule_importance = [Rule_importance; {net.Rules_semantic{b,:}}]
                else
                    disp('HN DEBUG comes here condition 2');
                    disp(net.Rules(b,:));
                end
                disp(' '); % printing a line break
                rule_imp(b) = -1; % so that this is not considered for comparison again, as there could be other rules with the same importance number
                break
            end
        end
    end
end
