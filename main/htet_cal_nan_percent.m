% XXXXXXXXXXXXXXXXXXXXXXXXXXX htet_cal_nan_percent XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   to calculate percentage of missing data in one feature(column)
% Syntax    :   htet_cal_nan_percent(input, len, total)
%
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function result = htet_cal_nan_percent(input, len, total)
  result = [];
  for k = 1:len
    curVal = input(1,k);
    calPercent = round((curVal * 100)/total, 2);
    result = [result; calPercent];
  end
  result = result.';
end
