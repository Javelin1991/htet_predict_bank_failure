
% A has unseen test records with randomly chosen col no, ground truth value
% B has the reconstructed values
% C has the original full records
function Z = get_predicted_and_ground_truth_values(unseen_testData, A, B, C, IDs)
  Z = [];
  for i = 1:size(unseen_testData, 1)
      bID = A(i,1);
      ran = A(i, 5);
      target = A(i, 6);

      idx = find(bID == IDs);
      % C has the original full records
      disp('HN DEBUG idx'); disp(idx)
      t = C(idx,:);
      d = t{1,1};

      % after reconstruction, B should has no NaN
      % B has the already reconstructed values
      t1 = B(idx,:);
      d1 = t1{1,1};

      for j = 1:size(d,1)
          sum = d(j,[1 3 4 5]);
          sum1 = unseen_testData(i,:);
          disp('HN DEBUG sum'); disp(sum)
          disp('HN DEBUG sum1'); disp(sum1)

          if sum == sum1
              val = d1(j, ran);
              disp('HN DEBUG val'); disp(val)

              Z = [Z; [val, target]];
              disp('HN DEBUG Z'); disp(Z)
          end
      end
  end
end