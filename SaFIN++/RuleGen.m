

function [no_InTerms,InTerms,no_OutTerms,OutTerms,Rules,Rules_semantic] = RuleGen(TrainData_IN,TrainData_OUT,Alpha,Beta,Forgetfactor,numSamples)


disp('CLIP process Iteration one has begun....');
% Partitioning using CLIP
InTerms = CLIP(TrainData_IN(1:numSamples,1),Alpha,Beta); %%% % passes col 1 of TrainData_IN (values of 1st input variable)Interms stores the centre,sigma values of the membership functions for each input variable (row by row); so in row1, we store c,sigma values of the MF of input variable1
no_InTerms = size(InTerms,2)/2;

disp('CLIP process Iteration one has ended.....');


for i = 2:size(TrainData_IN,2)

    formatSpec = 'The current iteration is: %d';
    str = sprintf(formatSpec,i)
    disp(str);

    disp('TrainData looks like'); disp(TrainData_IN(1:numSamples,i));

    Terms = CLIP(TrainData_IN(1:numSamples,i),Alpha,Beta);

    disp('Terms after CLIP'); disp(Terms);

    no_InTerms = [no_InTerms; size(Terms,2)/2];
    if size(Terms,2) < size(InTerms,2)
        s = size(Terms,2);
        for j = 1:size(InTerms,2)-size(Terms,2)
            Terms(s+j) = 0;
        end
    else
        s = size(InTerms,2);
        for j = 1:size(Terms,2)-size(InTerms,2)
            for k = 1:size(InTerms,1)
                InTerms(k,s+j) = 0;
            end
        end
    end
    InTerms = [InTerms; Terms];
    disp('InTerms look like'); disp(InTerms)
    clear Terms; clear s;
end


OutTerms = CLIP(TrainData_OUT(1:numSamples,1),Alpha,Beta);
no_OutTerms = size(OutTerms,2)/2;
for i = 2:size(TrainData_OUT,2)

    disp('TrainData_OUT looks like'); disp(TrainData_OUT(1:numSamples,i));

    Terms = CLIP(TrainData_OUT(1:numSamples,i),Alpha,Beta);

    disp('Terms after CLIP'); disp(Terms);

    no_OutTerms = [no_OutTerms; size(Terms,2)/2];
    if size(Terms,2) < size(OutTerms,2)
        s = size(Terms,2);
        for j = 1:size(OutTerms,2)-size(Terms,2)
            Terms(s+j) = 0;
        end
    else
        s = size(OutTerms,2);
        for j = 1:size(Terms,2)-size(OutTerms,2)
            for k = 1:size(OutTerms,1)
                OutTerms(k,s+j) = 0;
            end
        end
    end
    OutTerms = [OutTerms; Terms];
    disp('OutTerms look like'); disp(OutTerms)

    clear Terms; clear s;
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% rule generation
disp('Rule generation process has begun')
Rules = zeros(1,size(TrainData_IN,2)+size(TrainData_OUT,2)); Weight = zeros(1);   % finally Rules will store all the created rules

max_mf = zeros(0);  % an empty matrix which will store the max. membership values of each input variables among their respective clusters

for i = 1:size(TrainData_IN,2)    % iterates over the no. of columns


    mfv = zeros(no_InTerms(i),1);
    for j = 1:no_InTerms(i)
        disp('TrainData_IN(i)'); disp(TrainData_IN(i));
        disp('InTerms(i,2*j-1))'); disp(InTerms(i,2*j-1))
        disp('InTerms(i,2*j)'); disp(InTerms(i,2*j));
        mfv(j) = exp( -(TrainData_IN(i)-InTerms(i,2*j-1))^2 / (InTerms(i,2*j)^2) );   % mfv - membership value of the training data with all its respective clusters
    end
    disp('mfv InTerms'); disp(mfv)
    [max_mfv,index_mfv] = max(mfv);   % max(mfv) is the membership value of the training data with the cluster, which has the highest membership value
    Rules(1,i) = index_mfv;
    disp('Rules(a,i)'); disp(Rules)

    max_mf = [max_mf; max(mfv)];

    clear mfv;
end

disp('Max mf after iterating through InTerms columns/features')
disp(max_mf)

f = min(max_mf);

max_mf = zeros(0);

for i = 1:size(TrainData_OUT,2)
    mfv = zeros(no_OutTerms(i),1);
    for j = 1:no_OutTerms(i)
        mfv(j) = exp( -(TrainData_OUT(i)-OutTerms(i,2*j-1))^2 / (OutTerms(i,2*j)^2) );
    end
    [max_mfv,index_mfv] = max(mfv);
    Rules(1,size(TrainData_IN,2)+i) = index_mfv;

    max_mf = [max_mf; max(mfv)];

    clear mfv;
end

disp('Max mf after iterating through OutTerms columns/features')
disp(max_mf)

u = min(max_mf);

Weight(1) = f * u;

disp('f'); disp(f);
disp('u'); disp(u);
disp('First Weight looks like'); disp(Weight(1))

for i = 2:numSamples              % starting from row 2 onwards


    formatSpec = 'The current iteration is: %d';
    str = sprintf(formatSpec,i)
    disp(str);
  % normailze weights of all the existing rules in the rulebase

       max_wt = max(Weight);
       min_wt = min(Weight);

    for h= 1:size(Weight, 2)

        disp('(Weight(h) - min_wt)'); disp((Weight(h) - min_wt))

        disp('(max_wt - min_wt)'); disp((max_wt - min_wt))

       Weight(h) = (Weight(h) - min_wt) / (max_wt - min_wt);


    end

    rule = zeros(1,size(TrainData_IN,2)+size(TrainData_OUT,2));

    max_mf = zeros(0);

    % Finding best-matched input label
    for j = 1:size(TrainData_IN,2)
        mfv = zeros(no_InTerms(j),1);
        for k = 1:no_InTerms(j)
            mfv(k) = exp( -(TrainData_IN(i,j)-InTerms(j,2*k-1))^2 / (InTerms(j,2*k)^2) );
        end
        [max_mfv,index_mfv] = max(mfv);
        rule(1,j) = index_mfv;

        max_mf = [max_mf; max(mfv)];

        clear mfv; clear max_mfv, clear index_mfv;
    end

    disp('Max mf after iterating through InTerms columns/features')
    disp(max_mf)

    f = min(max_mf);

    disp('Value of f')
    disp(f)

   % f

    max_mf = zeros(0);

    % Finding best-matched output label
    for j = 1:size(TrainData_OUT,2)
        mfv = zeros(no_OutTerms(j),1);
        for k = 1:no_OutTerms(j)
            mfv(k) = exp( -(TrainData_OUT(i,j)-OutTerms(j,2*k-1))^2 / (OutTerms(j,2*k)^2) );
        end
        [max_mfv,index_mfv] = max(mfv);
        rule(1,size(TrainData_IN,2)+j) = index_mfv;



        max_mf = [max_mf; max(mfv)];

         clear mfv; clear max_mfv, clear index_mfv;

    end

    disp('Max mf after iterating through OutTerms columns/features')
    disp(max_mf)

    u = min(max_mf);

    disp('Value of u')
    disp(u)

    same = 0; inconsistent = 0; index_same = 0; index_inconsistent = 0;

    disp('Rules');
    disp(Rules)

    for j = 1:size(Rules,1)


      %same rules
        if Rules(j,:) == rule(1,:)    % rule(1, :) is the new rule created for each input output tuple


            same = 1;


            index_same = j;

        end

        %inconsistent rule
        if (Rules(j,1:size(TrainData_IN, 2)) == rule(1, 1:size(TrainData_IN, 2))) & (Rules(j,(size(TrainData_IN, 2) + 1) : ( size(TrainData_IN, 2) + size(TrainData_OUT, 2)))  ~= rule(1,(size(TrainData_IN, 2) + 1) : ( size(TrainData_IN, 2) + size(TrainData_OUT, 2))))

            inconsistent = 1;
            index_inconsistent = j;

        end

    end

    if same == 1
        Weight(index_same) = Weight(index_same)+ (f*u);

    elseif inconsistent==1

        if (Weight(index_inconsistent) > (f*u))

 % do nothing - basically, just dont add this new rule into the Rulebase

        else


            Rules(index_inconsistent, :) = rule; % replace that with the new rule(got from the latest training tuple)
            Weight(index_inconsistent) = (f*u);

        end


    else

        % the rule is novel
      Rules = [Rules; rule];    % a new 'rule' is returned under variable rule, which is added to the variable, Rules, which stores all the rules generated
        Weight = [Weight; f*u];

    end




    clear novel; clear index_novel; clear rule;


    for k = 1:size(Rules,1)
        Weight(k) = Weight(k) * Forgetfactor; % forgetting
    end
    disp('Weight after forgetting factor')
    disp(Weight)


end


%--------------------changing rules notation into semantic meaning-------



semantic_list = {'M  ';'H  ';'VH ';'VVH ';'L  ';'VL ';'VVL '}; % is a cell array



Rules_semantic = Rules;

if (max(no_InTerms) <=7 & max(no_OutTerms) <=7)  % only if max. no of clusters for any variable is <=7

Rules_semantic = cell(size(Rules,1), (size(TrainData_IN,2)+size(TrainData_OUT,2))); % is a cell array

for p = 1:size(Rules,1)

    for q = 1:size(TrainData_IN,2)

        diff = Rules(p,q) - ceil((no_InTerms(q))/2);   % ceil rounds towards higher no.
                                                     % we wanted 5 / 2 = 3
                                                      % and also 6 / 2 = 3

        disp('Rules(p,q)')
        disp(Rules(p,q));

        disp('ceil((no_InTerms(q))/2)')
        disp(ceil((no_InTerms(q))/2));

        disp('diff'); disp(diff);

      if (diff > 0)

          Rules_semantic{p,q} = semantic_list{(diff+1)};


      elseif (diff < 0)

          diff2 = 0 - diff; % changing diff to positive

          Rules_semantic{p,q} = semantic_list{(4 + diff2)};


      else   % diff is 0

          Rules_semantic{p,q} = semantic_list{1};



      end

    end



    for r = 1:size(TrainData_OUT,2)

        diff = Rules(p,r+(size(TrainData_IN,2))) - ceil((no_OutTerms(r))/2);


        disp('Rules(p,r+(size(TrainData_IN,2)))')
        disp(Rules(p,r+(size(TrainData_IN,2))));

        disp('ceil((no_OutTerms(r))/2)')
        disp(ceil((no_OutTerms(r))/2));

     if (diff > 0)

          Rules_semantic{p,r+(size(TrainData_IN,2))} = semantic_list{(diff+1)};


      elseif (diff < 0)

          diff2 = 0 - diff; % changing diff to positive

          Rules_semantic{p,r+(size(TrainData_IN,2))} = semantic_list{(4 + diff2)};



     else

          Rules_semantic{p,r+(size(TrainData_IN,2))} = semantic_list{1};



      end


    end

end

end
