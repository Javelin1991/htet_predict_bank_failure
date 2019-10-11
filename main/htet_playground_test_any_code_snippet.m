% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_playground_test_any_code_snippet XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   dummy file that is used to test any code snippet in matlab
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


% data pre-processing
clear;
clc;

t = linspace(0,2*pi);
r1 = sin(4*t)+2; x1 = r1.*cos(t); y1 = r1.*sin(t);
r2 = sin(8*t)+2; x2 = r2.*cos(t); y2 = r2.*sin(t);
P = InterX([x1;y1],[x2;y2]);

plot(x1,y1,x2,y2,P(1,:),P(2,:),'ro')
