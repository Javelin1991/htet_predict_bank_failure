function [net_out, structure] = Run_SaFIN(TrainData,TestData,IND,OUTD,Alpha,Beta,Epochs,Eta,Forgetfactor,varargin)

%IND = size(TrainData_IN,2); OUTD = size(TrainData_OUT,2);
%TrainData = [TrainData_IN TrainData_OUT];
%clear TrainData_IN;
%clear TrainData_OUT;

% ---manan

if isempty(varargin)
    numSamples = size(TrainData,1);
else
    numSamples = varargin{1};
end

global abc def ru rmse_gui mse_gui r_gui no_in no_out runningmode

disp('SaFIN++ training has started........')
[no_InTerms,InTerms,no_OutTerms,OutTerms,Rules,Rules_semantic] = SaFIN_train(TrainData,IND,OUTD,Alpha,Beta,Epochs,Eta,Forgetfactor,numSamples);  % SAFIN_train is called

structure.IND = IND;
structure.OUTD = OUTD;
structure.no_InTerms = no_InTerms;
structure.InTerms = InTerms;
structure.no_OutTerms = no_OutTerms;
structure.OutTerms = OutTerms;
structure.Rules = Rules;
structure.Rules_semantic = Rules_semantic;

disp('SaFIN++ training has ended........')
disp('')
disp('SaFIN++ testing has started')
[net_out,rule_importance] = SaFIN_test(TestData,structure);   % SAFIN_test is called
disp('SaFIN++ testing has ended')

structure.rule_importance = rule_importance;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%global abc def ru mse_gui r_gui no_in no_out Rules_semantic

%diary

no_InTerms
no_OutTerms
Rules
%Rules_semantic
%Rules_semantic{1,:}

if (max(no_InTerms) <=7 & max(no_OutTerms) <=7)

disp('The semantic rules are:');
disp(' ');

for u = 1:size(Rules,1)

str = sprintf('%s', Rules_semantic{u,:});
disp(str);
disp(' ');
end

end

rule_imp = rule_importance; % creating a copy of rule_importance
rule_sort = sort(rule_imp,'descend');

disp('The important rules are:');
disp(' ');

if size(Rules,1) > 10

  imp_ruleCount = ceil(size(Rules,1) * 0.1);

else

  imp_ruleCount = 2;

end

for a = 1:imp_ruleCount

    for b = 1:size(Rules,1)

        if(rule_sort(a) == rule_imp(b))

            s = sprintf('Rule %d', b);
            disp(s);
            disp(' ');

            if (max(no_InTerms) <=7 & max(no_OutTerms) <=7)

            st = sprintf('%s', Rules_semantic{b,:});
            disp(st);

            else
                disp(Rules(b,:));

            end

            disp(' '); % printing a line break
            rule_imp(b) = -1; % so that this is not considered for comparison again, as there could be other rules with the same importance number
            break
        end


    end

end







%disp(Rules_semantic);

%size(Rules,1)


%InTerms
%OutTerms




abc = no_InTerms;
def = no_OutTerms;
ru = Rules;
no_in = IND;
no_out = OUTD;



% InTerms       ----- manan

%%%%manan



% figure plotting
for i = 1:OUTD
   figure;
   hold;
   str = [sprintf('Actual VS Predicted',i)];
   title(str);
   plot(1:1:size(TestData,1),TestData(:,i+IND),'b');
   plot(1:1:size(net_out,1),net_out(:,i),'r');
   legend('Actual','Predicted');
end

MSE = 0;
for i = 1:size(TestData,1)
    MSE = MSE+(TestData(i,IND+1)-net_out(i))^2;
end
MSE = 1/size(TestData,1)*MSE;

mse_gui = MSE
rmse_gui = sqrt(MSE)

R = 0;
mean_desired = mean(TestData(:,IND+1));
mean_computed = mean(net_out(:));
top_R2 = 0;
bottom_R2_1 = 0;
bottom_R2_2 = 0;
for i = 1:size(TestData,1)
    top_R2 = top_R2 + (TestData(i,IND+1) - mean_desired)*(net_out(i) - mean_computed);
    bottom_R2_1 = bottom_R2_1 + (TestData(i,IND+1) - mean_desired)^2;
    bottom_R2_2 = bottom_R2_2 + (net_out(i) - mean_computed)^2;
end
R = (top_R2)/(sqrt(bottom_R2_1)*sqrt(bottom_R2_2))

r_gui = R;



%%%%manan
