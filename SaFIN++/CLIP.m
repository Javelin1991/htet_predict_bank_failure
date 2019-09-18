function [Terms] = CLIP(Data,Alpha,Beta)

% function [Terms] = CLIP(Data,Alpha,Beta,z)
disp('During CLIP process.....')

Data = Data(:);

Data_Max = max(Data);
Data_Min = min(Data);

disp('Data Max'); disp(Data_Max)
disp('Data Min'); disp(Data_Min)

% Initialization
Terms = zeros(1,2);

Terms(1,1) = Data(1); % 1st element of Data
Terms(1,2) = 0.5*( sqrt( -(Data_Min-Data(1))^2 / (log(Alpha)) ) + sqrt( -(Data_Max-Data(1))^2 / (log(Alpha)) ) );

disp('Terms after initialization')
disp(Terms)

no_Terms = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Clustering
disp('Clustering process has begun')

for i = 2:size(Data,1)   % iterating from 1st row to the last row
    % Determine maximum activation in the set of clusters
    mfv = zeros(no_Terms,1);
    disp('Terms looks like'); disp(Terms)
    disp('NO of terms'); disp(no_Terms);
    for j = 1:no_Terms

        disp('Terms j-1 , centre'); disp(Terms(1,2*j-1))
        disp('Terms j width'); disp(Terms(1,2*j))
        disp('Data i'); disp(Data(i));
        mfv(j) = exp( -(Data(i)-Terms(1,2*j-1))^2 / (Terms(1,2*j)^2) );
    end
    disp('mfv'); disp(mfv)
    [max_mfv,index_mfv] = max(mfv);
    disp('max_mfv'); disp(max_mfv);

    if mfv(index_mfv) < Beta
        % If maximum activation is less than Beta, i.e., the clusters are unable to cover the current input value
        disp('it is less than contrasting threshold beta, so needs to create new cluster');

        % Find left and right neighbours
        left_index = 0; right_index = 0;
        for j = 1:no_Terms
            if Terms(1,2*j-1)-Data(i) < 0
                if left_index == 0
                    left_index = j;
                    disp('left neighbour index is zero hence updated to'); disp(j)
                else
                    if abs(Terms(1,2*j-1)-Data(i)) < abs(Terms(1,2*left_index-1)-Data(i))
                        disp('Left Condition has met');
                        disp('Terms(1,2*j-1)'); disp(Terms(1,2*j-1));
                        disp('Data(i)'); disp(Data(i));
                        disp('after subtraction'); disp(abs(Terms(1,2*j-1)-Data(i)))

                        disp('Terms(1,2*left_index-1)'); disp(Terms(1,2*left_index-1));
                        disp('Data(i)'); disp(Data(i))
                        disp('after subtraction'); disp(abs(Terms(1,2*left_index-1)-Data(i)))

                        left_index = j;
                    end
                end
            else
                if right_index == 0;
                    right_index = j;
                    disp('right neighbour index is zero hence updated to'); disp(j)
                else
                    if (Terms(1,2*j-1)-Data(i)) < (Terms(1,2*right_index-1)-Data(i))
                        right_index = j;

                        disp('Right Condition has met');
                        disp('Terms(1,2*j-1)'); disp(Terms(1,2*j-1));
                        disp('Data(i)'); disp(Data(i));
                        disp('after subtraction'); disp(abs(Terms(1,2*j-1)-Data(i)))

                        disp('Terms(1,2*left_index-1)'); disp(Terms(1,2*right_index-1));
                        disp('Data(i)'); disp(Data(i))
                        disp('after subtraction'); disp(abs(Terms(1,2*right_index-1)-Data(i)))

                    end
                end
            end
        end

        % Create new cluster
        Terms = [Terms Data(i)];    % here its add data(i) as center of the new MF
        if left_index == 0
            spread = 0.5*( sqrt( -(Terms(1,2*right_index-1)-Data(i))^2 / (log(Alpha)) ) + Terms(1,2*right_index) );
            Terms = [Terms spread];   % subsequently it adds the signma of the new MF
            % Update neighbours
            Terms(1,2*right_index) = spread;
        else if right_index == 0
                spread = 0.5*( sqrt( -(Terms(1,2*left_index-1)-Data(i))^2 / (log(Alpha)) ) + Terms(1,2*left_index) );
                Terms = [Terms spread];
                % Update neighbours
                Terms(1,2*left_index) = spread;
            else
                spread = 0.25*( sqrt( -(Terms(1,2*right_index-1)-Data(i))^2 / (log(Alpha)) ) + Terms(1,2*right_index) + sqrt( -(Terms(1,2*left_index-1)-Data(i))^2 / (log(Alpha)) ) + Terms(1,2*left_index) );
                Terms = [Terms spread];
                % Update neighbours
                disp('Terms(1,2*right_index)');disp(Terms(1,2*right_index))
                disp('Terms(1,2*left_index)');disp(Terms(1,2*left_index))
                disp('spread'); disp(spread);
                Terms(1,2*right_index) = spread;
                Terms(1,2*left_index) = spread;
            end
        end
        no_Terms = no_Terms + 1;
    end
end

centres = [Terms(1,1)];
for i = 2:no_Terms
    centres = [centres;Terms(1,2*i-1)];
end
disp('centres'); disp(centres)

[centres_sorted,index] = sort(centres);
Terms2 = [Terms(1,2*index(1)-1) Terms(1,2*index(1))];
for i = 2:no_Terms
    Terms2 = [Terms2 Terms(1,2*index(i)-1) Terms(1,2*index(i))];
end
disp('Final Terms'); disp(Terms2);
Terms = Terms2;
clear Terms2;
