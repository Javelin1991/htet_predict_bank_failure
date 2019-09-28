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

function [net_out, net_out_2, final_out, system, system_2] = htet_SaFIN_FRIE_with_HCL(choice,TrainD_Pos,TrainD_Neg,TestData,IND,OUTD, Epochs,Eta,Sigma0,forget, Forgetfactor,Lamda, tau,Rate,Omega,Gamma, varargin)

%IND = size(TrainData_IN,2); OUTD = size(TrainData_OUT,2);
%TrainData = [TrainData_IN TrainData_OUT];
%clear TrainData_IN;
%clear TrainData_OUT;

% ---manan

% if isempty(varargin)
%     numSamples = size(TrainData,1);
% else
%     numSamples = varargin{1};
% end

TrainData = TrainD_Pos;
TrainData_2 = TrainD_Neg;

%INITIALIZE THE SYSTEM
system.total_network = 1;
system.net.name = 'SAFIN++(FRIE)_pos_system';
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


%INITIALIZE THE SYSTEM
system_2.total_network = 1;
system_2.net.name = 'SAFIN++(FRIE)_neg_system';
system_2.net.Epochs = Epochs;
system_2.net.Eta = Eta;
system_2.net.Sigma0 = Sigma0; %SMALL PERTURBATION
system_2.net.Rate = Rate; %LEARNING RATE
system_2.net.Forgetfactor = Forgetfactor; %FORGETTING FACTOR
system_2.net.Lamda = Lamda; %THRESHOLD FOR INTERPOLATION
system_2.net.Omega = Omega;
system_2.net.Gamma = Gamma;
system_2.net.interpolated = zeros(1,size(TrainData_2,1));
system_2.net.ruleCount = zeros(size(TrainData_2,1),1);
net_2 = system_2.net;
net_2 = SAFIN_FRIE_init(net_2, TrainData_2(1,1:IND), TrainData_2(1,IND+1:IND+OUTD), Sigma0);

%%%% 3 WAYS TO USE MODEL
% 1. ONLINE TRAINING FOLLOWED BY TESTING - TRAIN ONCE THROUGH TRAINING SET FOLLOWED BY TESTING
% 2. ONLINE TRAINING AND TESTING - TRAIN ON THE FIRST DATA AND TEST ON SECOND DATA, TRAIN ON SECOND DATA, TEST ON THIRD DATA
% 3. OFFLINE TRAINING FOLLOWED BY TESTING - TRAIN EPOCH TIMES THROUGH TRAIN DATA AND TEST ON TESTING DATA

% positive data set
for i = 1 : size(TrainData, 1)
    disp('Progress: ');
    disp(i/size(TrainData,1)*100); %DISPLAY PROGRESS OF TRAINING
    %TRAINING THE NET
    net = SaFIN_FRIE_train(i, net, TrainData(i,1:IND), TrainData(i,IND+1:IND+OUTD),IND, OUTD, net.no_InTerms, net.InTerms, net.no_OutTerms, net.OutTerms,net.Rules, net.Rules_Weight, Eta, forget, Forgetfactor,Lamda,tau, Rate, Omega, Gamma);
    disp('Number of rules: ');
    disp(size(net.Rules,1));
    ruleCount(i,1) = size(net.Rules,1);
end

% negative data set
for i = 1 : size(TrainData_2, 1)
    disp('Progress: ');
    disp(i/size(TrainData_2,1)*100); %DISPLAY PROGRESS OF TRAINING
    %TRAINING THE NET
    net_2 = SaFIN_FRIE_train(i, net_2, TrainData_2(i,1:IND), TrainData_2(i,IND+1:IND+OUTD),IND, OUTD, net_2.no_InTerms, net_2.InTerms, net_2.no_OutTerms, net_2.OutTerms,net_2.Rules, net_2.Rules_Weight, Eta, forget, Forgetfactor,Lamda,tau, Rate, Omega, Gamma);
    disp('Number of rules: ');
    disp(size(net_2.Rules,1));
    ruleCount(i,1) = size(net_2.Rules,1);
end
net_out = zeros(size(TestData,1), OUTD);
net_out_2 = zeros(size(TestData,1), OUTD);
% net.rule_importance = zeros(size(net.Rules,1),1);
for i = 1 : size(TestData,1)
    net_out(i,:) = SaFIN_FRIE_test(TestData(i, 1:IND),IND,OUTD,net.no_InTerms,net.InTerms,net.no_OutTerms,net.OutTerms,net.Rules, true);
    net_out_2(i,:) = SaFIN_FRIE_test(TestData(i, 1:IND),IND,OUTD,net_2.no_InTerms,net_2.InTerms,net_2.no_OutTerms,net_2.OutTerms,net_2.Rules, true);

    disp('net_out(i,:)'); disp(net_out(i,:));
    disp('net_out_2(i,:)'); disp(net_out_2(i,:));
    if (net_out(i,:) >= net_out_2(i,:))
      final_out(i,:) = 1;
    else
      final_out(i,:) = 0;
    end
    disp('final_out(i,:)'); disp(final_out(i,:));
end

[net.Rules_semantic net.Rule_importance] = interpret(net, IND, OUTD);
[net_2.Rules_semantic net_2.Rule_importance] = interpret(net_2, IND, OUTD);

system.net = net;
system_2.net = net_2;
