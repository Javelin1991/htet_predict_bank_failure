% XXXXXXXXXXXXXXXXXXXXXXXXXXX sus_scale XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :
% Function  :
% Syntax    :
%
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function out = htet_generate_cross_validation_data(input1, input2, num_of_fold)

  SB = cvpartition(length(input1),'KFold',num_of_fold);
  FB = cvpartition(length(input2),'KFold',num_of_fold);

  CV = [];

  for i = 1:5
      cv_sb_test = htet_get_cv_data(test(SB,i), input1);
      cv_fb_test = htet_get_cv_data(test(FB,i), input2);

      cv_sb_train = htet_get_cv_data(training(SB, i), input1);
      cv_fb_train = htet_get_cv_data(training(FB, i), input2);

      cv_train = vertcat(cv_sb_train,cv_fb_train);
      cv_test = vertcat(cv_sb_test,cv_fb_test);

      train_cv = htet_pre_process_bank_data(cv_train, 1, 0);
      test_cv = htet_pre_process_bank_data(cv_test, 1, 0);

      % final_cv = vertcat(train_cv, test_cv);
      % by appending the train_cv behind, we can use the test set that consists of 20% data as the training data
      % and the train_cv that consists of 80% as the testing data
      % opposite ratio from the usual 80/20 split
      final_cv = vertcat(test_cv, train_cv);
      CV = [CV; {final_cv}];
  end
  out = CV;
end
