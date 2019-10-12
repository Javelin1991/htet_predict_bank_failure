% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_playground_test_any_code_snippet XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   dummy file that is used to test any code snippet in matlab
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


% data pre-processing
clear;
clc;
close all;





load CV3_Classification_Anfis_100;

FB_anfis = 0;
SB_anfis = 0;

FB_inc = 0;
SB_inc = 0;

D = CV3{1,1}
T_anfis = size(D,1);

for i=1:size(D,1)
   if D(i,2) == 1
     FB_anfis =FB_anfis + 1;
   else
     SB_anfis =SB_anfis + 1;
   end
end



load CV3_Classification_Increased;
D = CV3{1,1}
T_inc = size(D,1);

for i=1:size(D,1)
   if D(i,2) == 1
     FB_inc =FB_inc + 1;
   else
     SB_inc =SB_inc + 1;
   end
end
