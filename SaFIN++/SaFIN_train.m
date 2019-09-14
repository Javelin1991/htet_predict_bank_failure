function [no_InTerms,InTerms,no_OutTerms,OutTerms,Rules,Rules_semantic] = SaFIN_train(TrainData,IND,OUTD,Alpha,Beta,Epochs,Eta,Forgetfactor,numSamples)






[no_InTerms,InTerms,no_OutTerms,OutTerms,Rules,Rules_semantic] = RuleGen(TrainData(:,1:IND),TrainData(:,IND+1:IND+OUTD),Alpha,Beta,Forgetfactor,numSamples); % just passing training data input, training data output, alpha, beta





for i = 1:IND
    colorArray = 'bgrcmyk';
    figure;
    hold;
    str = [sprintf('Input %d',i)];
    title(str);
    for j = 1:no_InTerms(i)
        color = colorArray(mod(j,7)+1);
        x = [min(TrainData(:,i)):0.05:max(TrainData(:,i))];
        plot(x, gaussmf(x, [InTerms(i,2*j)/sqrt(2) InTerms(i,2*j-1)]), color);
        axis([min(TrainData(:,i)) max(TrainData(:,i)) 0 1]);
    end
end

for i = 1:OUTD
    colorArray = 'bgrcmyk';
    figure;
    hold;
    str = [sprintf('Output %d',i)];
    title(str);
    for j = 1:no_OutTerms(i)
        color = colorArray(mod(j,7)+1);
        x = [min(TrainData(:,IND+i)):0.05:max(TrainData(:,IND+i))];
        plot(x, gaussmf(x, [OutTerms(i,2*j)/sqrt(2) OutTerms(i,2*j-1)]), color);
        axis([min(TrainData(:,IND+i)) max(TrainData(:,IND+i)) 0 1]);
    end
end





for no_epoch = 1:Epochs
    for i = 1:size(TrainData,1)
   % Forward propagation: CRI    
       
        % Initialize
        in_mf = zeros(IND,max(no_InTerms));
        act_rules = zeros(size(Rules,1),1);
        inferred = zeros(OUTD,max(no_OutTerms));
        check = zeros(OUTD,max(no_OutTerms));
        net_out = zeros(OUTD,1);
        % Layer 2
        for j = 1:IND
            for k = 1:no_InTerms(j)
                in_mf(j,k) = exp( -(TrainData(i,j)-InTerms(j,2*k-1))^2 / (InTerms(j,2*k)^2) );
            end
        end
        % Layer 3
        for j = 1:size(Rules,1)
            tmp = zeros(IND,1);
            for k = 1:IND
                tmp(k) = in_mf(k,Rules(j,k));
            end
            act_rules(j) = min(tmp);
            clear tmp;
        end
        % Layer 4
        for j = 1:size(Rules,1)
            for k = 1:OUTD
                if inferred(k,Rules(j,IND+k)) < act_rules(j)
                    inferred(k,Rules(j,IND+k)) = act_rules(j);
                end
                check(k,Rules(j,IND+k)) = 1;
            end
        end
        % Layer 5
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
        
      
     
       
       
        % Initialize
        delta_5 = zeros(OUTD,1); 
        delta_4 = zeros(OUTD,max(no_OutTerms));
        delta_3 = zeros(size(Rules,1),1);
        delta_2 = zeros(IND,max(no_InTerms));
        % Layer 5
        for j = 1:OUTD
            delta_5(j) = TrainData(i,IND+j)-net_out(j);
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
                    new_c = OutTerms(j,2*k-1) + Eta*delta_5(j)*OutTerms(j,2*k)*inferred(j,k)/D_m;
                    new_sigma = OutTerms(j,2*k) + Eta*delta_5(j)*inferred(j,k)*(D_m*OutTerms(j,2*k-1)-N_m)/(D_m^2);
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
                    new_c = InTerms(j,2*k-1) + Eta*delta_2(j,k)*in_mf(j,k)*2/(InTerms(j,2*k)^2)*(TrainData(i,j)-InTerms(j,2*k-1));
                    new_sigma = InTerms(j,2*k) + Eta*delta_2(j,k)*in_mf(j,k)*2*(TrainData(i,j)-InTerms(j,2*k-1))^2/(InTerms(j,2*k)^3);
                    InTerms(j,2*k-1) = new_c;
                    InTerms(j,2*k) = new_sigma;
                end
            end
        end
    end   
end
                        
                        
                        