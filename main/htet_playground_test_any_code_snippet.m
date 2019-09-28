% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_playground_test_any_code_snippet XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   dummy file that is used to test any code snippet in matlab
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
clear;
clc;
%
% load Failed_Banks;
% load Survived_Banks;
%
% Failed_Banks(any(isnan(Failed_Banks), 2), :) = [];
% Survived_Banks(any(isnan(Survived_Banks), 2), :) = [];
%
% Xf = Failed_Banks(:,[3:12])
% Yf = Failed_Banks(:,2)
% Xs = Survived_Banks(:,[3:12])
% Ys = Survived_Banks(:,2)
%
% [idx_f,scores_f] = fscmrmr(Xf,Yf)
% [idx_s,scores_s] = fscmrmr(Xs,Ys)

load CV1_Classification;

final_score = zeros(1,10);;
SCORES = [];

for cv=1:5
  D0 = CV1{cv,1};
  input = D0(:,[3:12]);
  target = D0(:,2);
  X = input;
  Y = target;
  [idx,scores] = fscmrmr(X,Y);
  SCORES = [SCORES; scores]
  final_score = final_score + scores;
end
