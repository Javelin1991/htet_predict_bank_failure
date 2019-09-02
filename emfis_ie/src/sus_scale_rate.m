% XXXXXXXXXXXXXXXXXXXXXXXXXXX sus_scale_rate XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% 
% Author    :   Susanti
% Date      :   Aug 1 2014
% Function  :   Compute the Scale Rate
% Syntax    :   sus_scale_rate(a_dash, a_star)
% 
% a_dash, a_star    - Both have 3 points
% 
% Algorithm -
% 
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function s8 = sus_scale_rate(a_dash, a_star)
%disp('sus_scale_rate');

    % System.out.println("aDash.getPoints()[2] is "+aDash.getPoints()[2]+" aDash.getPoints()[0] is "+aDash.getPoints()[0]);
    % System.out.println("aStar.getPoints()[2] is "+aStar.getPoints()[2]+" aStar.getPoints()[0] is "+aStar.getPoints()[0]);
    scale_rate = (a_star.point(3) - a_star.point(1))/(a_dash.point(3) - a_dash.point(1));
    s8.scale_rate = scale_rate;
end