% XXXXXXXXXXXXXXXXXXXXXXXXXXX sus_scale XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Mar 3 2019
% Function  :
% Syntax    :   htet_cal_nan_percent(input, len, total)
%
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function result = htet_cal_nan_percent(input, len, total)
  result = [];
  for k = 1:len
    curVal = input(1,k);
    calPercent = round((curVal * 100)/total, 2);
    result = [result; calPercent];
  end
  result = result.';
end
