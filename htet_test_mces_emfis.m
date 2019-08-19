% Monte-Carlo Evaluative Selection method.
% Copy these DLLs and .m files into a Matlab accessible directory and using Matlab to invoke the method, evalsel(.).

% weight = evalsel(train_data,train_output,ite,induction);
% weight = the middle column is the output result, the higher the weight is, the more important is the feature.
% train_data = input dataset.
% train_output = self-explain.
% ite = number of iteration of MCES to run, the larger the bette, but slow.
% induction = what type of induction algorithm, currently supporting 'MLP' or 'ANFIS'.
% example: for 34 features and 1 output dataset, with 2:35 as input, 1 as output, then run MCES by,

load 'audiotrained.mat'

% parameter setup
train_data = x
train_output = y
ite = 2
induction = 'eMFIS'

% weight ranking of the features
weight = evalsel(train_data,train_output,ite,induction);

% plot bar graph for weight ranking
bar(weight(:,2))
