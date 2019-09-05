5_Fold_CVs_with_top_3_features consists of the followings:

1) CV1_with_top_3_features - the last available record to do "t" bank failure prediciton 
2) CV2_with_top_3_features - the record for previous one year (i.e. one year prior) to do "t-1" bank failure prediction 
3) CV3_with_top_3_features - the record for previous two year (i.3. two year prior) to do "t-2" bank failure prediction 


Since in each CV group, the train data and test data are concatenated together, 
Ratio for train data is 20%, (i.e. to reduce memorization) 
Ratio for test data is 80% 

Hence, we can start testing the predicted value as the formula below: 
start_test = (size(data_input, 1) * 0.2) + 1;


The format is: 

column1: Bank ID    column2: Fail/Survived    column3: x1    column4: x2    column5: x3


For column2: 1 means Failed and 0 means Survived
Use column 3, column 4 and column 5 as input data. 
Use column 2 as the target data. 

For classification, please use the threshold, 0.5 

if predicted value > 0.5 , then set to 1
if predicted value < 0.5 , then set to 0 
if predicted value = 0.5 , then leave it at 0.5 (Unclassified) 

