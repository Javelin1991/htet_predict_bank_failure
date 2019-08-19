% XXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% 
% Author    :   Susanti
% Date      :   Aug 1 2014 
% Function  :   Calculate the distance between rule and
%               observation
% Syntax    :   sus_distance_to(rule,observation)
% 
% rule          - it has 3 points
% observation   - it has 3 points
% 
% Algorithm -
% 1) Compute Representative value of 'rule' and 'observation'
% 2) Calculate the difference 
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function s4 = sus_distance_to(rule,observation)
%disp('sus_distance_to');

    rep_rule = ( rule.point(1) + rule.point(2) + rule.point(3) )/3;
    rep_observation = ( observation.point(1) + observation.point(2) + observation.point(3) )/3;

    distance_to = rep_rule - rep_observation;

    s4 = distance_to;
end
