function net = SaFIN_FRIE_train(data_point, net, input, output, IND,OUTD, no_InTerms, InTerms, no_OutTerms, OutTerms,Rules, Rules_Weight,Eta,forget, Forgetfactor,Lamda, tau, Rate, Omega, Gamma)
thre_lam = tau*Lamda;
%%%%%%%%%%%%%%%%%%%%%%%%%%%% RULE GENERATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
in_mf = zeros(IND, max(no_InTerms));  %INITIALIZE THE INPUT MEMBERSHIP
for dim = 1 : IND %FOR EACH DIMENSION
    for term = 1 : no_InTerms(dim) %FOR EACH TERM IN EACH DIMENSION
        in_mf(dim,term) = exp(-(input(1,dim) - InTerms(dim, 2*term-1))^2 / (InTerms(dim, 2*term)^2)); %COMPUTE MEMBERSHIP FUNCTION INPUT WITH EACH TERM IN EACH DIMENSION
    end
end
act_rules_forward = zeros(size(Rules,1),1); %ACTIVATION RULE FORWARD OF RULE BASE
forward_activation = zeros(size(Rules,1),1); %FORWARD ACTIVATION OF RULE BASE
for rule = 1 : size(Rules,1) %FOR EACH RULE IN RULEBASE
    tmp_forwad = zeros(IND,1); %TEMPORARY ACTIVATION LEVEL FOR INPUT DIMENSIONS
    for dim = 1 : IND %FOR EACH INPUT DIMENSION
        tmp_forward(dim) = in_mf(dim, Rules(rule,dim)); %GET SIMILARITY OF THE DIMENSION IN EACH RULE
    end
    [c, index] =  min(tmp_forward); %GET MINIMUM VALUE OF MEMBERSHIP VALUE OF ALL INPUT DIMENSIONS
    act_rules_forward(rule,1) = in_mf(index, Rules(rule,index)); %UPDATE ACTIVATION FOR THAT RULE
    forward_activation(rule) = c; %FORWARD ACTIVATION FOR THAT RULE
    %disp('Act_rules_forward:')
    %disp(act_rules_forward);
    clear c, clear index;
end
out_mf = zeros(OUTD, max(no_OutTerms)); %OUTPUT MEMBERSHIP FUNCTION
for dim = 1:OUTD %FOR EACH OUTPUT DIMENSION
    for term = 1 : no_OutTerms(dim) %FOR EACH TERM
        out_mf(dim,term) = exp(-(output(1,dim) - OutTerms(dim,2*term-1))^2 /(OutTerms(dim,2*term)^2)); %COMPUTER MEMBERSHIP FUNCTION OF EACH TERM
    end
end
act_rules_backward = zeros(size(Rules,1),1);
backward_activation = zeros(size(Rules,1),1);
for rule = 1 : size(Rules,1) %FOR EACH RULE
    tmp_backward = zeros(OUTD,1); %BACKWARD ACTIVATION
    for dim = 1:OUTD %FOR EACH OUTPUT DIMENSION
        tmp_backward(dim) = out_mf(dim,Rules(rule,IND+dim)); %GET MEMBERSHIP FUNCTION FOR THAT DIMENSION
    end
    [c,index] = min(tmp_backward); %BACKWARD ACTIVATION FUNCTION IS MINIMUM OF THE MEMBERHSIP VALUE OF EACH DIMENSION
    act_rules_backward(rule,1) = out_mf(index, Rules(rule,IND+index)); %STORE BACKWARD ACTIVATION FUNCTION
    backward_activation(rule) = c; %STORE BACKWARD ACTIVATION FUNCTION
    %disp('Act_rules_backward:')
    %disp(act_rules_backward);
    clear c, clear index;
end
rule_activation = zeros(size(Rules,1),1);
for rule = 1 : size(Rules,1)
    rule_activation(rule) = min([forward_activation(rule); backward_activation(rule)]); %RULE ACTIVATION IS THE MINIMUM OF BACKWARD AND FORWARD ACTIVATION FUNCTION
end
if(max(rule_activation) > Lamda) %IF ONE OF RULE ACTIVATION LARGER THAN RULE GENERATION THERESHOLD => UPDATE WEIGHT
    [c, index] = max(rule_activation); %FIND THE RULE WITH MAXIMUM RULE ACTIVATION
    for rule = 1 : size(Rules,1)
        if (rule == index)
            Rules_Weight(rule,1) =  Rules_Weight(rule,1) + 1; %INCREASE THE RULE WEIGHT BY ONE UNIT
        else
            Rules_Weight(rule,1) =  max([Forgetfactor*Rules_Weight(rule); rule_activation(rule)]); %UPDATE RULE WEIGHT WITH NEW ACTIVATION LEVEL IF ACTIVATION LEVEL LARGER THAN CURRENT RULE WEIGHT
        end
    end
    clear c; clear index;
end
%%%%%%%%%%%%%%%% INTERPOLATE STEP 1 %%%%%%%%%%%%%%%
for dim = 1 : IND
    for term = 1 : no_InTerms(dim)
        rep_A(dim,term) = InTerms(dim,2*term-1); %representative value is the centre of the fuzzy cluster
        c_A(dim,term) = InTerms(dim, 2*term-1);
        sig_A(dim,term) = InTerms(dim, 2*term);
    end
end
for rule = 1:size(Rules,1)
    for dim = 1 : IND
        rep_A_k_j(rule,dim) = rep_A(dim, Rules(rule,dim));
        c_A_k_j(rule,dim) = c_A(dim, Rules(rule,dim));
        sig_A_k_j(rule,dim) = sig_A(dim, Rules(rule,dim));
    end
end
for dim = 1 : OUTD
    for term = 1 : no_OutTerms(dim)
        c_B(dim,term) = OutTerms(dim, 2*term-1);
        sig_B(dim,term) = OutTerms(dim,2*term);
    end
end
for rule = 1 : size(Rules,1)
    for dim = 1 : OUTD
        c_B_k_j(rule,dim) = c_B(dim, Rules(rule,IND+dim));
        sig_B_k_j(rule,dim) = sig_B(dim, Rules(rule, IND+dim));
    end
end
net.rep_A = rep_A;
net.c_A = c_A;
net.sig_A = sig_A;
net.rep_A_k_j = rep_A_k_j;
net.c_A_k_j = c_A_k_j;
net.sig_A_k_j = sig_A_k_j;
net.c_B_k_j = c_B_k_j;
net.sig_B_k_j = sig_B_k_j;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IF RULE ACTIVATION <= RULE GENERATION THERESHOLD => ACTION REQUIRED
% 1 == CREATE NEW FUZZY SET
% 2 == MODIFY THE CURRENT FUZZY SET
% 3 == ADD NEW RULE BASED ON CURRENT FUZZY SET
% 4 == INTERPOLATE/ EXTRAPOLATE BASED ON NEAREST K-RULE
if(max(rule_activation) <= Lamda)
    new_rule = zeros(1, IND+OUTD); %NEW RULE
    new_rule_action = zeros(IND+OUTD,1); %STORE RULE ACTIVE FOR EACH DIMESION
    for dim = 1 : IND %FOR EACH INPUT DIMENSION
        in_mfv = zeros(no_InTerms(dim),1);
        for term = 1 : no_InTerms(dim) %FOR EACH TERM
            in_mfv(term) = in_mf(dim,term); %GET MEMBERSHIP FUCNTION FOR EACH TERM
        end
        [max_antecedent, index_a] = max(in_mfv); %GET MAXIMUM MEMBERSHIP FUNCTION OF EACH TERM FOR THAT DIMENSION OR GET THE NEAREST TERM IN OTHER WORDS
        %INTERPOLATE STEP 1
        net.rep_ob_A(dim) = InTerms(dim, 2*index_a - 1);
        net.ob_A_c(1,dim) = InTerms(dim, 2*index_a - 1);
        net.ob_A_sig(1,dim) = InTerms(dim,2*index_a);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if(max_antecedent > Lamda) %IF MAXIMUM MEMBERSHIP FUNCTION > RULE THERESHOLD
            new_rule(dim) = index_a;
            new_rule_action(dim) = 3; %DO NOTHING FOR THAT DIMENSION
        else
            c = InTerms(dim,2*index_a - 1);  %GET CENTRE OF NEAREST FUZZY
            sigma = InTerms(dim, 2*index_a); %GET SPREAD OF NEAEST FUZZY
            sigma_new = sigma + Rate*(1-max_antecedent)*sigma; %INCREASE SIGMA %RATE IS THE MODIFICATION RATE
            new_membership = exp(-(input(1,dim) - c)^2 / (sigma_new^2)); %COMPUTER NEW MEMBERSHIP
            if(new_membership > Lamda) %IF THE NEW SPREAD CAN COVER INPUT
                new_rule(dim) = index_a; %ADD FUZZY NUMBER TO NEW RULE
                new_rule_action(dim) = 2; %UPDATE EXISTING MEMBERSHIP
            end
            if (max_antecedent > (thre_lam)) && (new_rule_action(dim) == 0) %IF MAX_ATECEDENT > t*RULE GENERATION THRESHOLD
                new_rule(dim) = no_InTerms(dim) + 1; %ADD NEW FUZZY TERM FOR NEW RULE
                new_rule_action(dim) = 4; %RULE ACTION IS 4 - INTERPOLATE/ EXTRAPOLATE
            end
            if new_rule_action(dim) == 0
                new_rule(dim) = no_InTerms(dim)+1; %CREATE NEW FUZZY SET AND CREATE
                new_rule_action(dim) = 1;
            end
            clear centre, clear sigma, clear sigma_new; clear in_mfv, clear max_antecednet, clear index_max; clear new_membership;
        end
    end
    for dim = 1 :  OUTD % FOR EACH OUTPUT DIMENSION
        out_mfv = zeros(no_OutTerms(dim),1);  %OUTPUT MEMBERSHIP FUNCTION
        for term = 1 : no_OutTerms(dim) %FOR EACH TERM
            out_mfv(term) = out_mf(dim,term); %GET MEMBERSHIP FUNCTION EACH TERM IN EACH DIMENSION
        end
        [max_consequent, max_index] = max(out_mfv); %GET MAXIMUM MEMBERSHIP VALUE IN THAT DIMENSION
        if(max_consequent > Lamda) %LARGER THAN RULE GENERATION THRESHOLD
            new_rule(IND+dim) = max_index; %ADD NEW RULE
            new_rule_action(IND+dim) = 3; %RULE ACTION IS DO NOTHING
        else
            c = OutTerms(dim,2*max_index-1); %GET CENTRE OF NEAREST TERM
            sigma = OutTerms(dim, 2*max_index); %GET SPREAD OF NEAREST TERM
            sigma_new = sigma+  Rate*(1-max_consequent)*sigma; %MODIFY THE CURRENT SPREAD
            new_membership = exp(-(output(1,dim) - c)^2 / (sigma_new^2)); %COMPUTE NEW MEMBERSHIP
            if(new_membership > Lamda) %THE NEW FUZZY SET IS ABLE TO COVER THE INPUT DATA POINT
                new_rule(IND+dim) = max_index; %CREATE NEW RULE
                new_rule_action(IND+dim) = 2;
            end
            if(max_consequent > (thre_lam) && new_rule_action(dim) == 0)
                new_rule(IND+dim) = no_OutTerms(dim)+1; %CREATE NEW FUZZY SET ON THE DIMENSION
                new_rule_action(IND+dim) = 4; %INTERPOLATE OR EXTRAPOLATE
            end
            if(new_rule_action(IND+dim) == 0)
                new_rule(IND+dim) = no_OutTerms(dim) + 1;
                new_rule_action(IND+dim) = 1;
            end
            clear c, clear sigma, clear sigma_new, clear out_mfv, clear max_consequent, clear max_index; clear new_membership;
        end
    end
    %%%%%%%%%%CHECK AMBIGUITY s%%%%%%%
    ambiguous = 0;
    for rule = 1 : size(Rules,1)
        if Rules(rule, 1:IND) == new_rule(1, 1:IND)
            for dim = 1 : OUTD
                if(Rules(rule, IND+dim) ~= new_rule(1,IND+dim))
                    ambiguous = 1;
                end
            end
        end
    end
    if ambiguous == 0
        %CHECK NOVELTY
        novel = 1;
        for rule = 1 : size(Rules,1)
            if(Rules(rule,:) == new_rule(1,:))
                novel = 0;
                index_novel = rule;
                break;
            end
        end
        %insert rule if novel
        if novel == 1
            Rules = [Rules; new_rule]; %add new rule
            Rules_Weight = [Rules_Weight; 1]; %add new weight
            index_novel = size(Rules,1);
        end
        %create/ update new mf
        for dim = 1 : IND
            if new_rule_action(dim) == 1 %create new mf
                [left_n, right_n, sigma] = neighbours(InTerms(dim,:),input(1,dim));
                no_InTerms(dim) = no_InTerms(dim)+1;
                [max_labels, index_max] = max(no_InTerms);
                if dim == index_max
                    InTerms = [InTerms, zeros(IND, 2)];
                end
                %update
                InTerms(dim,2*no_InTerms(dim)-1) = input(1,dim);
                InTerms(dim,2*no_InTerms(dim)) = sigma;
                %update neighbours
                if(left_n ~= 0)
                    InTerms(dim,2*left_n) = sigma;
                end
                if (right_n ~= 0)
                    InTerms(dim,2*right_n) = sigma;
                end
            else
                if (new_rule_action(dim,1) == 2)
                    sigma = InTerms(dim,2*new_rule(1,dim));
                    sigma = sigma + Rate*(1 - in_mf(dim, new_rule(dim)))*sigma;
                    InTerms(dim, 2*new_rule(dim)) = sigma;
                    clear sigma;
                else
                    if new_rule_action(dim) == 4
                        %%%%%%%%%%%%% interpolate step 2 intermediate rules %%%%%%%%%%%%
                        net.interpolateCount = net.interpolateCount + 1;
                        net.interpolated(1,data_point) = 1;
                        disp('interpolated.....');
                        [left_n, right_n, sigma] = neighbours(InTerms(dim,:), input(1,dim));
                        %get the left and righ neigbour of observation
                        if left_n == 0
                            rep_left(dim) = 0;
                        else
                            rep_left(dim) = InTerms(dim,2*left_n-1); %centre of the fuzzy
                        end
                        if right_n == 0
                            rep_right(dim) = 0;
                        else
                            rep_right(dim) = InTerms(dim,2*right_n-1);   %centre of the fuzzy
                        end
                        %calculate weight of the closest fuzzy rule
                        net.w = zeros(size(net.Rules,1)-1,IND);
                        for k = 1 : (size(net.Rules,1)-1)
                            %for dim = 1 :IND
                                net.w(k,dim) = 1 - abs( (net.rep_ob_A(1,dim) - rep_A_k_j(k,dim) /(rep_left(dim)-rep_right(dim))));
                            %end
                        end
                        net.weight = zeros(size(net.w,1),1);
                        for rule = 1 : size(net.w,1)
                            net.weight(k,1) = min(net.w(rule,:));
                        end
                        %disp(net.weight);
                        net.sum_w = sum(net.weight(:,1));
                        %disp(net.sum_w);
                        %normalise the rule weight
                        net.nor_weight = zeros(size(net.weight,1),1);
                        for rule = 1 : size(net.weight,1)
                            net.nor_weight(rule,1) = net.weight(rule,1) / net.sum_w;
                        end
                        %disp(net.nor_weight);
                        %%%%%%%%%%%%% interpolate step 3 intermediate rules %%%%%%%%%%%%
                        size_ = min(size(net.nor_weight,1), size(net.c_A_k_j));
                        net.inter_A_centre = net.nor_weight(1:size_,:)'*net.c_A_k_j(1:size_,:);
                        net.inter_A_sigma = net.nor_weight(1:size_,:)'*net.sig_A_k_j(1:size_,:);
                        net.inter_B_centre = net.nor_weight(1:size_,:)'*net.sig_A_k_j(1:size_,:);
                        net.inter_B_sigma = net.nor_weight(1:size_,:)'*net.sig_A_k_j(1:size_,:);
                        %%%%%%%%%%%%intepolate step 4 %%%%%%%%%%%%%%%%%%%%%%%%%%
                        net.ob_B_c = net.inter_B_centre;
                        %disp(net.ob_B_centre);
                        net.ob_B_sig = net.inter_B_sigma* (sum(net.ob_A_sig) / sum(net.inter_A_sigma));
                        %disp(net.ob_B_sigma);
                        %%%%%%%%%%%% add to clusters %%%%%%%%%%%%%%%%%%%%%%%%%%
                        no_InTerms(dim) = no_InTerms(dim) + 1;
                        [max_labels, index_labels] = max(no_InTerms);
                        if dim == index_labels
                            InTerms = [InTerms, zeros(IND,2)];
                        end
                        %add new centre and sigma
                        InTerms(dim, 2*no_InTerms(dim) -1) = net.ob_A_c(1,dim);
                        InTerms(dim, 2*no_InTerms(dim)) = net.ob_A_sig(1,dim);
                        %update neighbour
                        if left_n ~= 0
                            InTerms(dim,2*left_n) = net.ob_A_sig(1,dim);
                        end
                        if right_n ~= 0
                            InTerms(dim,2*right_n) = net.ob_A_sig(1,dim);
                        end
                    end
                end
            end
        end
        for dim = 1 : OUTD
            if new_rule_action(IND+dim) == 1 %create new membership function
                [left_n, right_n, sigma] = neighbours(OutTerms(dim,:),output(1,dim));
                no_OutTerms(dim) = no_OutTerms(dim)+1;
                [max_labels, index_labels] = max(no_OutTerms);
                if(dim == index_labels)
                    OutTerms = [OutTerms, zeros(OUTD,2)];
                end
                OutTerms(dim,2*no_OutTerms(dim)-1) = output(1,dim);
                OutTerms(dim,2*no_OutTerms(dim)) = sigma;
                if(left_n ~= 0)
                    OutTerms(dim,2*left_n) = sigma;
                end
                if(right_n ~= 0)
                    OutTerms(dim, 2*right_n) = sigma;
                end
                clear left_n; clear right_n; clear max_labels; clear index_labels;
            else
                if(new_rule_action(IND+dim) == 2)
                    sigma = OutTerms(dim, 2*new_rule(IND+dim));
                    new_sigma = sigma + Rate*(1 - out_mf(dim,new_rule(IND+dim)))*sigma;
                    OutTerms(dim, 2*new_rule(IND+dim)) = new_sigma;
                    clear sigma;
                else
                    if(new_rule_action(IND+dim) == 4)
                        [left_n, right_n, sigma] = neighbours(OutTerms(dim,:), output(1,dim));
                        no_OutTerms(dim) = no_OutTerms(dim) + 1;
                        [max_labels, index_labels] = max(no_OutTerms);
                        if dim == index_labels
                            OutTerms = [OutTerms, zeros(OUTD, 2)];
                        end
                        %add new interpolated value
                        OutTerms(dim,2*no_OutTerms(dim)-1) = net.ob_B_c(1,dim);
                        OutTerms(dim,2*no_OutTerms(dim)) = net.ob_B_sig(1,dim);
                        %update neigbohbour
                        if left_n ~= 0
                            OutTerms(dim,2*left_n) = net.ob_B_sig(1,dim);
                        end
                        if right_n ~= 0
                            OutTemrs(dim,2*right_n) = net.ob_B_sig(1,dim);
                        end
                        clear left_n, clear right_n, clear max_labels, clear index_labels;
                    end
                end
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% done update clusters%%%%%%%%%%%
    %calculate forward activation again
    in_mf = zeros(IND, max(no_InTerms));
    for dim = 1 : IND
        for term = 1 : no_InTerms(dim)
            in_mf(dim,term) = exp( -(input(1,dim)-InTerms(dim,2*term-1))^2 / (InTerms(dim,2*term)^2) );
        end
    end
    act_rules_forward = zeros(size(Rules,1),1);
    forward_activation = zeros(size(Rules,1),1);
    for rule = 1 : size(Rules,1)
        tmp_forward = zeros(IND,1);
        for dim = 1 : IND
            tmp_forward(dim) = in_mf(dim,Rules(rule,dim));
        end
        [c,index] = min(tmp_forward);
        act_rules_forward(rule,1) = in_mf(index,Rules(rule,index));
        forward_activation(rule) = c;
        clear c, clear index
    end
    clear tmp_forward;
    out_mf = zeros(OUTD, max(no_OutTerms));
    for dim = 1 : OUTD
        for term = 1 : no_OutTerms(dim)
            out_mf(dim, term) = exp( -(output(1,dim)-OutTerms(dim,2*term-1))^2 / (OutTerms(dim,2*term)^2) );
        end
    end
    act_rules_backward = zeros(size(Rules,1),1);
    backward_activation = zeros(size(Rules,1),1);
    for rule = 1 : size(Rules,1)
        tmp_backward = zeros(OUTD,1);
        for dim = 1 : OUTD
            tmp_backward = out_mf(dim, Rules(rule, IND+dim));
        end
        [c, index] = min(tmp_backward);
        act_rules_backward(rule,1) = out_mf(index, Rules(rule, IND+index));
        backward_activation(rule) = c;
        clear c; clear index;
    end
    clear tmp_backward;
    %calcualte rule activation
    rule_activation = zeros(size(Rules,1),1);
    for rule = 1 : size(Rules,1)
        rule_activtion(rule) = min([forward_activation(rule); backward_activation(rule)]);
    end
    for rule = 1 : size(Rules,1)
        if ambiguous == 1
            Rules_Weight(rule) = max([Forgetfactor*Rules_Weight(rule); rule_activation(rule)]);
        else
            if rule ~= index_novel
                Rules_Weight(rule) = max([Forgetfactor*Rules_Weight(rule); rule_activation(rule)]);
            end
        end
    end
end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%% 2. Merging of MFs
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for dim = 1:OUTD
%     [index_1, index_2, similarity] = most_similar(no_OutTerms(dim), OutTerms(dim,:));
%     if(similarity >= Omega)
%         for rule = 1 : size(Rules,1)
%             %update rule
%             if( Rules(rule, IND+dim) == index_2 )
%                 Rules(rule, IND+dim) = index_1;
%             end
%             if( Rules(rule, IND+dim) > index_2 )
%                 Rules(rule, IND+dim) = Rules(rule, IND+dim) - 1;
%             end
%         end
%         [Rules, Rules_Weight] = check_repeat_rules(Rules, Rules_Weight); %check repeat rule
%         [no_OutTerms, OutTerms] = merge_MF(no_OutTerms, OutTerms, dim, index_1, index_2); %merge clusters
%     end
%     clear index_1; clear index_2; clear similarity;
% end
% for dim = 1 : IND
%     [index_1, index_2, similarity] = most_similar(no_InTerms(dim), InTerms(dim,:));
%     if similarity >= Omega
%         for rule = 1 : size(Rules,1)
%             if( Rules(rule,dim) == index_2 )
%                 Rules(rule,dim) = index_1;
%             end
%             if( Rules(rule,dim) > index_2 )
%                 Rules(rule,dim) = Rules(rule,dim) - 1;
%             end
%         end
%         [Rules, Rules_Weight] = check_repeat_rules(Rules, Rules_Weight);
%         [no_InTerms, InTerms] = merge_MF(no_InTerms, InTerms, dim, index_1, index_2);
%     end
%     clear index_1; clear index_2; clear similarity;
% end
% [Rules, Rules_Weight] = check_ambiguous_rules(Rules, Rules_Weight, IND, OUTD);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%% 3. Delete obsolete rule (max one rule per epoch)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(forget == 1)
    new_Rules = []; new_Rules_Weight = [];
    %delete rule with rule weight < 0.1
    for rule = 1 : size(Rules,1)
        if Rules_Weight(rule) >= Gamma
            new_Rules = [new_Rules; Rules(rule,:)];
            new_Rules_Weight = [new_Rules_Weight; Rules_Weight(rule)];
        end
    end
    Rules = new_Rules;
    Rules_Weight = new_Rules_Weight;
    clear new_Rules; clear new_Rules_Weight;
    %delete orphan fuzzy label
    new_InTerms = [];
    for dim = 1 : IND
        %delete orphan fuzzy label
        [Rules, Terms] = delete_orphan(Rules, InTerms(dim,:),dim);
        %initialise new_InTerms if this is the first dimension
        if dim == 1
            new_InTerms = [new_InTerms; Terms];
            no_InTerms(dim) = size(Terms,2)/2;
        else %for other dimension
            if(size(Terms,2) > size(new_InTerms,2))
                no_InTerms(dim) = size(Terms,2)/2;
                s = size(Terms,2) - size(new_InTerms,2);
                l = size(new_InTerms,2);
                for j = 1 : size(new_InTerms,1)
                    for k = 1 : s
                        new_InTerms(j,l+k) = 0;
                    end
                end
                new_InTerms = [new_InTerms; Terms];
            else
                no_InTerms(dim) = size(Terms,2)/2;
                s = size(new_InTerms,2) - size(Terms,2);
                l = size(Terms,2);
                for j = 1 : s
                    Terms(1,l+j) = 0;
                end
                new_InTerms = [new_InTerms; Terms];
            end
        end
        clear s; clear l; clear Terms;
    end
    InTerms = new_InTerms;
    clear new_InTerms;
    new_OutTerms = [];
    for dim = 1 : OUTD
        [Rules, Terms] = delete_orphan(Rules, OutTerms(dim,:),IND+dim);
        if dim == 1
            new_OutTerms = [new_OutTerms; Terms];
            no_OutTerms(dim) = size(Terms,2)/2;
        else
            if(size(Terms,2) > size(new_OutTerms,2))
                no_OutTerms(dim) = size(Terms,2)/2;
                s = size(Terms,2) - size(new_OutTerms,2);
                l = size(new_OutTerms,2);
                for j = 1 : size(new_OutTerms,1)
                    for k = 1 : s
                        new_OutTerms(j,l+k) = 0;
                    end
                end
                new_OutTerms = [new_OutTerms, Terms];
            else
                no_OutTerms(dim) = size(Terms,2)/2;
                s = size(new_OutTerms,2) - size(Terms,2);
                l = size(Terms,2);
                for j = 1 : s
                    Terms(1,l+j) = 0;
                end
                new_OutTerms = [new_OutTerms, Terms];
            end
        end
        clear s; clear l; clear Terms;
    end
    OutTerms = new_OutTerms;
    clear new_OutTerms;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% 4. Forward propagation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize
in_mf = zeros(IND,max(no_InTerms)); %IND x Number of Fuzzy Terms
act_rules = zeros(size(Rules,1),1);
inferred = zeros(OUTD,max(no_OutTerms));
check = zeros(OUTD,max(no_OutTerms));
net_out = zeros(OUTD,1);
% Layer 2
for j = 1:IND %for each dimension
    for k = 1:no_InTerms(j) %for each term in the dimension
        in_mf(j,k) = exp( -(input(1,j)-InTerms(j,2*k-1))^2 / (InTerms(j,2*k)^2) ); %compute membership function for that term
    end
end
% Layer 3
for j = 1:size(Rules,1) %for each rule
    tmp = zeros(IND,1);
    for k = 1:IND %get membership function of every antecedent
        tmp(k) = in_mf(k,Rules(j,k));
    end
    act_rules(j) = min(tmp); %get firing rate of the rule = MIN of antecedent
    clear tmp;
end
% Layer 4
for j = 1:size(Rules,1) %for each rule
    for k = 1:OUTD %for each dimension
        if inferred(k,Rules(j,IND+k)) < act_rules(j)
            inferred(k,Rules(j,IND+k)) = act_rules(j); %get maximum activation for term
        end
        check(k,Rules(j,IND+k)) = 1;
    end
end
% Layer 5 %compute the centroid of the system
for j = 1:OUTD
    top = 0; bottom = 0;
    for k = 1:no_OutTerms(j)
        if check(j,k) == 1
            top = top + inferred(j,k)*OutTerms(j,2*k-1)*OutTerms(j,2*k);
            bottom = bottom + inferred(j,k)*OutTerms(j,2*k);
        end
    end
    net_out(j) = top/bottom;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 5.Backward propagation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize
delta_5 = zeros(OUTD,1);
delta_4 = zeros(OUTD,max(no_OutTerms));
delta_3 = zeros(size(Rules,1),1);
delta_2 = zeros(IND,max(no_InTerms));
% Layer 5
for j = 1:OUTD
    delta_5(j) = output(1,j)-net_out(j); %compute error of each term
end
% Layer 4
for j = 1:OUTD
    N_m = 0; D_m = 0;
    for k = 1:no_OutTerms(j)
        if check(j,k) == 1
            N_m = N_m + inferred(j,k)*OutTerms(j,2*k-1)*OutTerms(j,2*k);
            D_m = D_m + inferred(j,k)*OutTerms(j,2*k);
        end
    end
    for k = 1:no_OutTerms(j)
        if check(j,k) == 1
            delta_4(j,k) = delta_5(j)*OutTerms(j,2*k)*(D_m*OutTerms(j,2*k-1)-N_m)/(D_m^2);
            new_c = OutTerms(j,2*k-1) + Eta*delta_5(j)*OutTerms(j,2*k)*inferred(j,k)/D_m; %compute new centre
            new_sigma = OutTerms(j,2*k) + Eta*delta_5(j)*inferred(j,k)*(D_m*OutTerms(j,2*k-1)-N_m)/(D_m^2); %compute new sigma
            OutTerms(j,2*k-1) = new_c;
            OutTerms(j,2*k) = new_sigma;
        end
    end
end
% Layer 3
for j = 1:size(Rules,1)
    for k = 1:OUTD
        if act_rules(j) == inferred(k,Rules(j,IND+k))
            delta_3(j) = delta_3(j) + delta_4(k,Rules(j,IND+k));
        end
    end
end
clear check;
check = zeros(IND,max(no_InTerms));
% Layer 2
for j = 1:size(Rules,1)
    for k = 1:IND
        check(k,Rules(j,k)) = 1;
        if act_rules(j) == in_mf(k,Rules(j,k))
            delta_2(k,Rules(j,k)) = delta_2(k,Rules(j,k)) + delta_3(j);
        end
    end
end
for j = 1:IND
    for k = 1:no_InTerms(j)
        if check(j,k) == 1
            new_c = InTerms(j,2*k-1) + Eta*delta_2(j,k)*in_mf(j,k)*2/(InTerms(j,2*k)^2)*(input(1,j)-InTerms(j,2*k-1));
            new_sigma = InTerms(j,2*k) + Eta*delta_2(j,k)*in_mf(j,k)*2*(input(1,j)-InTerms(j,2*k-1))^2/(InTerms(j,2*k)^3);
            InTerms(j,2*k-1) = new_c;
            InTerms(j,2*k) = new_sigma;
        end
    end
end
net.no_InTerms = no_InTerms;
net.InTerms = InTerms;
net.no_OutTerms = no_OutTerms;
net.OutTerms = OutTerms;
net.Rules = Rules;
net.Rules_Weight = Rules_Weight;
net.in_mf = in_mf;
net.out_mf = out_mf;
net.act_rules_forward = act_rules_forward;
net.act_rules_backward = act_rules_backward;
net.inferred = inferred;
end
