% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_find_outlier_banks XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   find banks that do not have financial data in the consecutive years
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
clear;
clc;
%
load Failed_Banks;
load Survived_Banks;

GROUP = [];
OUTLIER = [];

Failed_Banks(any(isnan(Failed_Banks), 2), :) = [];
[v,ic,id]= unique(Failed_Banks(:,1))
for i=1:length(v)
    A = Failed_Banks(id==i,:);
    GROUP = [GROUP; {A}];
end

for i=1:size(GROUP,1)
  tmp = cell2mat(GROUP(i));
  last_col = size(tmp,2);
  j = size(tmp,1)-1;
  last_row = size(tmp,1);
  while j > 0
    last_col_v = tmp(j,last_col);
    diff = tmp(last_row,last_col) - last_col_v;

    if (diff > 1)
      OUTLIER = [OUTLIER; {tmp}];
    end

    last_row = last_row - 1;
    j = j - 1;
  end
end
