% The SaFIN model is written by Tung Sau Wai.
% Please cite the paper when using this code:
% S.W. Tung, C. Quek and C. Guan, "SaFIN: A Self-Adaptive Fuzzy Inference
% Network," IEEE Trans. on Neural Netw., 22(12), pp. 1928-1940, Dec. 2011.

% This is the main file for running the SaFIN model.
% There are 3 ways of using the SAFIN model:
% 1. Online training, followed by testing, i.e., training once through the train set, then testing on the test set.
% 2. Online training and testing, i.e., training on first data, testing on second data, training on second data, testing on third data, ...
% 3. Offline training, followed by testing, i.e., training n epochs through the train set, then testing on the test set.

% Inputs:-
%   TrainData_IN: the N x IND training set where N is the number of training samples, IND is the input dimensions
%   TrainData_OUT: the N x OUTD training set where N is the number of training samples, OUTD is the output dimensions
%   TestData: the M x IND testing set where M is the number of testing samples
%   Alpha: minimum membership threshold
%   Beta: contrasting threshold
%   Epochs: number of training epochs
%   Eta: training constant
%   Sigma0: first cluster sigma
%   Forgetfactor: forgetting factor
%   Lambda: rule generation threshold
%   Omega: merger threshold
%   Gamma: deletion threshold
%   Rate: Modification rate
%   Epochs: number of training epochs
%   Tau: threshold for interpolation/ extrapolation
% Outputs:-
%   1. Number of fuzzy clusters in each input and output dimensions
%   2. Fuzzy rules
%   3. MSE and R
%   4. Predicted output

function [net_out, system] = Run_SaFIN_FRIE(choice, TrainData,TestData,IND,OUTD, Epochs,Eta,Sigma0,forget, Forgetfactor,Lamda, tau,Rate,Omega,Gamma, varargin)

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
%INITIALIZE THE SYSTEM
system.total_network = 1;
system.net.name = 'SAFIN++(FRIE)';
system.net.Epochs = Epochs;
system.net.Eta = Eta;
system.net.Sigma0 = Sigma0; %SMALL PERTURBATION
system.net.Rate = Rate; %LEARNING RATE
system.net.Forgetfactor = Forgetfactor; %FORGETTING FACTOR
system.net.Lamda = Lamda; %THRESHOLD FOR INTERPOLATION
system.net.Omega = Omega;
system.net.Gamma = Gamma;
system.net.interpolated = zeros(1,size(TrainData,1));
system.net.ruleCount = zeros(size(TrainData,1),1);
net = system.net;
%INITIALIZE NEURAL NET WITH FIRST ROW OF DATA
net = SAFIN_FRIE_init(net, TrainData(1,1:IND), TrainData(1,IND+1:IND+OUTD), Sigma0);
%%%% 3 WAYS TO USE MODEL
% 1. ONLINE TRAINING FOLLOWED BY TESTING - TRAIN ONCE THROUGH TRAINING SET FOLLOWED BY TESTING
% 2. ONLINE TRAINING AND TESTING - TRAIN ON THE FIRST DATA AND TEST ON SECOND DATA, TRAIN ON SECOND DATA, TEST ON THIRD DATA
% 3. OFFLINE TRAINING FOLLOWED BY TESTING - TRAIN EPOCH TIMES THROUGH TRAIN DATA AND TEST ON TESTING DATA
switch choice
    case 1
        for i = 1 : size(TrainData, 1)
            disp('Progress: ');
            disp(i/size(TrainData,1)*100); %DISPLAY PROGRESS OF TRAINING
            %TRAINING THE NET
            net = SaFIN_FRIE_train(i, net, TrainData(i,1:IND), TrainData(i,IND+1:IND+OUTD),IND, OUTD, net.no_InTerms, net.InTerms, net.no_OutTerms, net.OutTerms,net.Rules, net.Rules_Weight, Eta, forget, Forgetfactor,Lamda,tau, Rate, Omega, Gamma);
            disp('Number of rules: ');
            disp(size(net.Rules,1));
            ruleCount(i,1) = size(net.Rules,1);
        end
        net_out = zeros(size(TestData,1), OUTD);
        % net.rule_importance = zeros(size(net.Rules,1),1);
        for i = 1 : size(TestData,1)
            net_out(i,:) = SaFIN_FRIE_test(TestData(i, 1:IND),IND,OUTD,net.no_InTerms,net.InTerms,net.no_OutTerms,net.OutTerms,net.Rules);
        end
    case 2
        net_out = zeros(size(TestData,1), OUTD);  %PREDICTED VALUES
        %net.interpolation_results = zeros(size(TestData,1),1); %INTERPOLATED POINTS
        for i = 1 : size(TrainData,1)
            disp('Progress: ');
            disp(i/size(TrainData,1)*100);  %DISPLAY PROGRESS OF TRAINING
            %PASS I-TH ROW TO TRAIN
            net = SaFIN_FRIE_train(i, net, TrainData(i,1:IND), TrainData(i,IND+1:IND+OUTD), IND,OUTD, net.no_InTerms, net.InTerms, net.no_OutTerms, net.OutTerms,net.Rules, net.Rules_Weight, Eta, forget, Forgetfactor,Lamda,tau, Rate, Omega, Gamma);
            disp('Number of rules: ');
            disp(size(net.Rules,1));
            ruleCount(i,1) = size(net.Rules,1);
            if (i+1) <= size(TestData,1)
                %PASS (I+1)-TH ROW TO TEST
                net_out(i+1,:) = SaFIN_FRIE_test(TestData(i+1,1:IND), IND, OUTD, net.no_InTerms,net.InTerms,net.no_OutTerms,net.OutTerms,net.Rules);
            end
        end
        net_out = net_out(2:size(net_out,1),:); %PASSING NET_OUT TO PLOT
        TestData = TestData(2:size(TestData,1),:); %PASSING TEST DATA TO PLOT
    case 3
        train = [];
        for n = 1 : Epochs
            train = [train; TrainData];
        end
        TrainData = train; %epoch * train_data
        clear train;
        for i = 1 : size(TrainData,1)
            disp('Progress: ');
            disp(i/size(TrainData,1)*100); %DISPLAY TRAINING PROGRESS
            net = SaFIN_FRIE_train(i, net, TrainData(i,1:IND), TrainData(i,IND+1:IND+OUTD), IND, OUTD, net.no_InTerms, net.InTerms, net.no_OutTerms, net.OutTerms,net.Rules, net.Rules_Weight,Eta, forget, Forgetfactor,Lamda,tau, Rate, Omega, Gamma);
            disp('Number of rules: ');
            disp(size(net.Rules,1));
            ruleCount(i,1) = size(net.Rules,1);
        end
        net_out = zeros(size(TestData,1), OUTD); %
        for i = 1:size(TestData,1)
            net_out(i,:) = SaFIN_FRIE_test(TestData(i,1:IND), IND, OUTD, net.no_InTerms,net.InTerms,net.no_OutTerms,net.OutTerms,net.Rules);
        end
end
system.ruleCountVariant = ruleCount;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DISPLAY INPUT AND OUTPUT CLUSTERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:IND
    colorArray = 'bgrcmyk';
    figure;
    hold;
    str = [sprintf('Input %d',i)];
    title(str);
    for j = 1:net.no_InTerms(i)
        color = colorArray(mod(j,7)+1);
        x = [min(TrainData(:,i)):0.05:max(TrainData(:,i))];
        plot(x, gaussmf(x, [net.InTerms(i,2*j)/sqrt(2) net.InTerms(i,2*j-1)]), color);
        axis([min(TrainData(:,i)) max(TrainData(:,i)) 0 1]);
    end
end
for i = 1:OUTD
    colorArray = 'bgrcmyk';
    figure;
    hold;
    str = [sprintf('Output %d',i)];
    title(str);
    for j = 1:net.no_OutTerms(i)
        color = colorArray(mod(j,7)+1);
        x = [min(TrainData(:,IND+i)):0.05:max(TrainData(:,IND+i))];
        plot(x, gaussmf(x, [net.OutTerms(i,2*j)/sqrt(2) net.OutTerms(i,2*j-1)]), color);
        axis([min(TrainData(:,IND+i)) max(TrainData(:,IND+i)) 0 1]);
    end
end
%%%%%%%%%%%%%%% INTERPRET FEATURES%%%%%%%%%%%%%%%%%
[net.Rules_semantic net.Rule_importance] = interpret(net, IND, OUTD);

%%%%%%%%%DISPLAY PREDICTION VS ACTUAL DATA %%%%%%%%%%%%%%%%%%%
for i = 1:OUTD
   max_output = max(TestData(:,IND+i));
   min_output = min(TestData(:,IND+i));
   unit = (max_output - min_output) / 5; %UNIT FOR PLOTTING INTERPOLATION INDICATOR
   figure; hold;
   str = [sprintf('Actual VS Predicted Data',i)]; title(str);
   plot(1:1:size(TestData,1),TestData(:,i+IND),'b'); %PLOT ACTUAL DATA
   plot(1:1:size(TestData,1),net_out(:,i),'r');      %PLOT PREDICTED DATA
   plot(1:1:size(TrainData,1), unit*net.interpolated(1,:),'g'); %INDICATE INTERPOLATED POINTS
   %plot(1:1:size(TrainData,1), ruleCount(:,1),'m')
   legend('Actual','Predicted', 'I/E Points', '#Rules');
end
% %%%%%%%%% DISPLAY NUMBER OF RULES GENERATED %%%%%%%%%%%%%%%%%%%
for i = 1:OUTD
   figure; hold;
   str = [sprintf('Number of rules generated',i)]; title(str);
   plot(1:1:size(TrainData,1), ruleCount(:,1),'m')
   legend('Actual','Predicted', 'Interpolated/Extrapolated Points', '# Rules Generated');
end
%%%%%%%%%%%%%%%%%% MEAN SQUARE ERROR COMPUTATION %%%%%%%%%%
MSE = 0;
for i = 1:size(TestData,1)
    MSE = MSE+(TestData(i,IND+1)-net_out(i))^2;
end
MSE = 1/size(TestData,1)*MSE;
X = ['MSE = ', num2str(MSE)];
disp(X);
RMSE = sqrt(MSE);
Y = ['RMSE = ', num2str(RMSE)];
disp(Y);
%%%%%%%%%%%%%%%%%%% PEARSON CORRELATION COEFFECIENT R %%%%%%%%
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
R = (top_R2)/(sqrt(bottom_R2_1)*sqrt(bottom_R2_2));
X = ['R= ', num2str(R)];
disp(X);
%%%%%%%NUMBER OF RULES GENERATED%%%%%%%%
X = ['Number of rules generated = ', num2str(size(net.Rules,1))];
disp(X);
%%%%%%%NUMBER OF INTERPOLATED/ EXTRAPOLATED POINTS%%%%%%%%
X = ['Number of interpolated/ extrapolated points = ', num2str(net.interpolateCount)];
disp(X);
%%%%%%%NUMBER OF INPUT/OUTPUT CLUSTER POINTS%%%%%%%%
X = 'Number of input clusters = ';
disp(X);
disp(net.no_InTerms);
X = 'Number of output clusters = ';
disp(X);
disp(net.no_OutTerms);
%STORE TO SYSTEM

system.MSE = MSE;
system.RMSE = sqrt(MSE);
system.R = R;
system.interpolateCount = net.interpolateCount;
system.ruleCountDiary = ruleCount;
system.ruleCount = size(net.Rules,1);
system.interpolated = net.interpolated;
system.net = net;
