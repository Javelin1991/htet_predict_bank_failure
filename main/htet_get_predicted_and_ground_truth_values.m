% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_get_predicted_and_ground_truth_values XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   get predicted values and ground truth values for the reconstruction process
% Syntax    :   htet_get_predicted_and_ground_truth_values(unseen_testData, A, B, C, IDs)
% unseen_testData - data set that is not used in the training and strictly used for testing
% A - unseen test records with randomly chosen column/feature number and their ground truth value
% B - data set with reconstructed values
% C - the original data set that has full records
% IDs - Bank IDs
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function Z = htet_get_predicted_and_ground_truth_values(unseen_testData, A, B, C, IDs)
  Z = [];
  for i = 1:size(unseen_testData, 1)
      bID = A(i,1);
      ran = A(i, 5);
      target = A(i, 6);

      idx = find(bID == IDs);
      % C has the original full records
      t = C(idx,:);
      d = t{1,1};

      % after reconstruction, B should has no NaN
      % B has the already reconstructed values
      t1 = B(idx,:);
      d1 = t1{1,1};

      for j = 1:size(d,1)
          sum = d(j,[1 3 4 5]);
          sum1 = unseen_testData(i,:);

          if sum == sum1
              ran_offset = ran + 1;
              val = d1(j, ran_offset);
              Z = [Z; [bID, val, target]];
          end
      end
  end
end
