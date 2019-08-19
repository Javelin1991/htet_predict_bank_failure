% XXXXXXXXXXXXXXXXXXXXXXXXXXX sus_scale XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% 
% Author    :   Susanti
% Date      :   Aug 1 2014
% Function  :   Compute the points based on scale_rate
% Syntax    :   sus_scale(fuzzy_number, scale_rate)
% 
% fuzzy_number  - it has 3 points
% 
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function s9 = sus_scale(fuzzy_number, scale_rate)
%disp('sus_scale');

    newLeftShoulder = (fuzzy_number.point(1) * (1 + 2 * scale_rate) + fuzzy_number.point(2) * (1 - scale_rate) + fuzzy_number.point(3) * (1 - scale_rate)) / 3;
    newCentroid = (fuzzy_number.point(1) * (1 - scale_rate) + fuzzy_number.point(2) * (1 + 2 * scale_rate) + fuzzy_number.point(3) * (1 - scale_rate)) / 3;          
    newRightShoulder = (fuzzy_number.point(1) * (1 - scale_rate) + fuzzy_number.point(2) * (1 - scale_rate) + fuzzy_number.point(3) * (1 + 2 * scale_rate)) / 3;            

    s9.point(1) = newLeftShoulder;
    s9.point(2) = newCentroid;
    s9.point(3) = newRightShoulder;
end      