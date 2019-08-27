% XXXXXXXXXXXXXXXXXXXXXXXXXXX sus_scale XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :
% Function  :
% Syntax    :
%
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

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
