% XXXXXXXXXXXXXXXXXXXXXXXXXXX sus_move_ratio XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% 
% Author    :   Susanti
% Date      :   Aug 1 2014
% Function  :   Compute Move Ratio
% Syntax    :   sus_move_ratio(a_dash_scaled, a_star)
% 
% a_dash_scaled, a_star - Both has 3 points
% 
% Algorithm -
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function s10 = sus_move_ratio(a_dash_scaled, a_star)
%disp('sus_move_ratio');


    move_ratio = 0;

    if (a_star.point(1) >= a_dash_scaled.point(1))

        move_ratio = (a_star.point(1) - a_dash_scaled.point(1)) * 3 /(a_dash_scaled.point(2) - a_dash_scaled.point(1));
    else
        % System.out.println("aStar.getPoints()[0] is "+aStar.getPoints()[0]);
        % System.out.println("aDashScaled.getPoints()[0] is "+aDashScaled.getPoints()[0]);
        % System.out.println("aDashScaled.getPoints()[2] is "+aDashScaled.getPoints()[2]);
        % System.out.println("aDashScaled.getPoints()[1] is "+aDashScaled.getPoints()[1]);

        move_ratio = (a_star.point(1) - a_dash_scaled.point(1)) * 3 /(a_dash_scaled.point(3) - a_dash_scaled.point(2));
        % if ((moveRatio > 0) || (moveRatio < -1))
        %   throw new Exception("Move Ratio (" + moveRatio + ") cannot exceed [-1,0]");

    end

    s10.move_ratio = move_ratio;

end
