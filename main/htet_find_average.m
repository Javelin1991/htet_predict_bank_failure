% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_find_average XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   find average for experiment results, (used to calculate results for cross validation group)
% Syntax    :   htet_find_average(net, size)
%
% net - a prediction system/model
% size - the size of the cross validation group (e.g. if it's 5-fold CV, then the size is 5)
% Stars     :   *
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function out = htet_find_average(net, size)
  A = 0; B = 0; C = 0; D = 0; E = 0; F = 0;

  for i = 1:size
    A = A + net(i).rmse;
    B = B + net(i).num_rules;
    C = C + net(i).R;
    D = D + net(i).accuracy;
    E = E + net(i).EER;
    F = F + net(i).unclassified;
  end

  out.RMSE = A/size;
  out.Rules = B/size;
  out.R = C/size;
  out.Accuracy = D/size;
  out.EER = E/size;
  out.Unclassified = F/size;

end
