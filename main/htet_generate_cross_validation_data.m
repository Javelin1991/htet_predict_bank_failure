% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_generate_cross_validation_data XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   generate 5-fold cross validation data that consist of failed banks and survived banks
% Syntax    :   htet_generate_cross_validation_data(input1, input2, num_of_fold, train_20_percent)
% input1 - either failed/survived bank data
% input2 - either failed/survived bank data
% num_of_fold - the number of fold for cross validation
% train_20_percent - flag to determine whether to use 20% to train and 80% to test , or 80% to train and 20% to test
%
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function out = htet_generate_cross_validation_data(input1, input2, num_of_fold, train_20_percent)

  SB = cvpartition(length(input1),'KFold',num_of_fold);
  FB = cvpartition(length(input2),'KFold',num_of_fold);

  CV = [];

  for i = 1:num_of_fold
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
      final_cv = vertcat(train_cv, test_cv);

      if train_20_percent
        final_cv = vertcat(test_cv, train_cv);
      end

      CV = [CV; {final_cv}];
  end
  out = CV;
end
