% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_playground_test_any_code_snippet XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   dummy file that is used to test any code snippet in matlab
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


% data pre-processing
clear;
clc;

load Correct_All_Banks;
load Survived_Banks;
load Failed_Banks;

o1 = htet_filter_bank_data_by_index(Correct_All_Banks, 0,'1T')
o2 = htet_filter_bank_data_by_index(Survived_Banks, 0,'1T')
o3 = htet_filter_bank_data_by_index(Failed_Banks, 0,'1T')
