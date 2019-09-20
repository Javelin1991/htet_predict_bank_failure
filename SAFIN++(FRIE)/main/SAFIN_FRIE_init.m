function net = SAFIN_FRIE_init(net,input,output,sigma) %
%%%%%%%%%%%%%%%%%%%%%%% 1.intialisation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
IND = size(input,2);  %SIZE OF INPUT
OUTD = size(output,2); %SIZE OF OUTPUT
no_InTerms = zeros(IND,1);  %IND x 1 MATRIX
InTerms = zeros(IND,2); %IND X 2 MATRIX: 1ST FOR CENTRE, 2ND FOR SPREAD
no_OutTerms = zeros(OUTD,1); %OUTD X 1 MATRIX
OutTerms = zeros(OUTD, 2); %OUTD X 2 MATRIX: 1ST FOR CENTRE, 2ND FOR SPREAD
Rules = zeros(1,IND+OUTD); % 1 x (IND + OUTD) MATRIX
Rules_Weight = zeros(1,1); % 1 X 1 MATRIX
for dim = 1 : IND          %FOR EACH DIMENSION
    no_InTerms(dim,1) = 1; %INITIALIZE FIRST CLUSTER NAME
    InTerms(dim ,1) = input(1,dim); %FIRST CENTRE = FIRST DATA POINT
    InTerms(dim,2) = sigma; %FIRST SPREAD = SIGMA = SMALL PERTURBATION
end
for dim = 1 : OUTD
    no_OutTerms(dim,1) = 1;          %INTIALIZE FIRST CLUSTER NAME
    OutTerms(dim,1) = output(1,dim); %FIRST CENTRE = FIRST DATA POINT
    OutTerms(dim,2) = sigma;         %SPREAD = SMALL PERTURBATION
end
for dim = 1 : (IND+OUTD)
    Rules(1,dim) = 1;               %INITIALIZE FIRST RULE WITH FIRST CLUSTERS
end
%INITIALIZE RULES WEIGHT
Rules_Weight(1,1) = 1;
%STORE INITIALIZED SYSTEM INTO SYSTEM IMAGE
net.no_InTerms = no_InTerms;
net.InTerms = InTerms;
net.no_OutTerms = no_OutTerms;
net.OutTerms = OutTerms;
net.Rules = Rules;
net.Rules_Weight = Rules_Weight;
net.interpolateCount = 0;
net.ruleNumber = 1;
end
