% XXXXXXXXXXXXXXXXXXXXXXXXXXX sus_move XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% 
% Author    :   Susanti
% Date      :   Aug 1 2014
% Function  :   Compute the points based on move_ratio
% Syntax    :   sus_move(fuzzy_number, move_ratio)   
% 
% fuzzy_number - It has 3 points
% 
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function s11 = sus_move(fuzzy_number, move_ratio)   
%disp('sus_move');

    if(move_ratio >= 0)
        move_rate = move_ratio * (fuzzy_number.point(2) - fuzzy_number.point(1)) / 3 ;
    else
        move_rate = move_ratio * (fuzzy_number.point(3) - fuzzy_number.point(2)) / 3;
    end

    newLeftShoulder = fuzzy_number.point(1) + move_rate;
    newCentroid = fuzzy_number.point(2) - 2 * move_rate;        
    newRightShoulder = fuzzy_number.point(3) + move_rate;

    s11.point(1) = newLeftShoulder;
    s11.point(2) = newCentroid;
    s11.point(3) = newRightShoulder;

end