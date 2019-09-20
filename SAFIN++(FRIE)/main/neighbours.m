function [left_index,right_index,spread] = neighbours(Terms,input)

% See SaFIN for definition of alpha:
% S. W. Tung, C. Quek and C. Guan, "SaFIN: A Self-Adaptive Fuzzy Inference
% Network," IEEE Trans. on Neural Netw., 22(12), pp. 1928-1940, Dec. 2011.
Alpha = 0.25;
no_Terms = size(Terms,2)/2;
c = zeros(no_Terms,1);
for term = 1:no_Terms
    c(term) = Terms(1,2*term-1);
end
left_index = 0; right_index = 0;
for term = 1:no_Terms  %for each term in input terms
    if Terms(1,2*term-1)-input < 0
        if left_index == 0
            left_index = term;
        else
            if abs(Terms(1,2*term-1)-input) < abs(Terms(1,2*left_index-1)-input)
                left_index = term; %get the nearest left term
            end
        end
    else
        if right_index == 0
            right_index = term;
        else
            if (Terms(1,2*term-1)-input) < (Terms(1,2*right_index-1)-input)
                right_index = term; %get the nearest right term
            end
        end
    end
end
% Create new cluster
Terms = [Terms input];    % here its add input as center of the new MF
if left_index == 0
    spread = 0.5*( sqrt( -(Terms(1,2*right_index-1)-input)^2 / (log(Alpha)) ) + Terms(1,2*right_index) );
    %Terms = [Terms spread];   % subsequently it adds the signma of the new MF
    % Update right neighbour spread
    %Terms(1,2*right_index) = spread;
else if right_index == 0
        spread = 0.5*( sqrt( -(Terms(1,2*left_index-1)-input)^2 / (log(Alpha)) ) + Terms(1,2*left_index) );
        %Terms = [Terms spread];
        % Update left neighbours spread
        %Terms(1,2*left_index) = spread; %update the spread of left index
    else
        spread = 0.25*( sqrt( -(Terms(1,2*right_index-1)-input)^2 / (log(Alpha)) ) + Terms(1,2*right_index) + sqrt( -(Terms(1,2*left_index-1)-input)^2 / (log(Alpha)) ) + Terms(1,2*left_index) );
        %Terms = [Terms spread];
        % Update neighbours
        %Terms(1,2*right_index) = spread; %update both left and right neibours
        %Terms(1,2*left_index) = spread; %update the spread of right index
    end
end
