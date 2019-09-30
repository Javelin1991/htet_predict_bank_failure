% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_playground_test_any_code_snippet XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   dummy file that is used to test any code snippet in matlab
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
clear;
clc;

load Failed_Banks;
load Survived_Banks;

output = htet_filter_bank_data_by_index(Failed_Banks(:,[1 2 3 7 10 13]),0,'1T');
Failed_Banks = output.full_record;

output = htet_filter_bank_data_by_index(Survived_Banks(:,[1 2 3 7 10 13]),0,'1T');
Survived_Banks = output.full_record;

clear output;
