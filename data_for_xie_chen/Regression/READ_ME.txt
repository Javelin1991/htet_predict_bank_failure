X_BANK_DATA_HORIZONTAL under Regression folder consists of the following:
where X = FAILED or SURVIVED

Train data to predict CAPADE using PLAQLY and ROE as inputs
Test data to predict CAPADE using PLAQLY AND ROE as inputs

Train data to predict PLAQLY using CAPADE AND ROE as inputs
Test data to predict PLAQLY using CAPADE AND ROE as inputs

Train data to predict ROE using CAPADE AND PLAQLY as inputs
Test data to predict ROE using CAPADE and PLAQLY as inputs

The format for the above data is :
column1: BankID    column2: x1    column3: x2    column4: x3

USE column 2 and column 3 as input data.
USE column 4 as target data.

REMEMBER to REMOVE the BankID when using the data sets for training and testing.
===============================================================================================================
X_BANK_DATA_VERTICAL under Regression folder consists of the following: where X = FAILED or SURVIVED

// forward
Train data to predict CAPADE@t using CAPADE@t-2 and CAPADE@t-1 as inputs     where t = Year XXXX
Test data to predict CAPADE@t using CAPADE@t-2 AND CAPADE@t-1 as inputs

// backward
Train data to predict CAPADE@t-2 using CAPADE@t and CAPADE@t-1 as inputs
Test data to predict CAPADE@t-2 using CAPADE@t AND CAPADE@t-1 as inputs


// forward
Train data to predict CAPADE@t using CAPADE@t-2 and CAPADE@t-1 as inputs     where t = Year XXXX
Test data to predict CAPADE@t using CAPADE@t-2 AND CAPADE@t-1 as inputs

// backward
Train data to predict PLAQLY@t-2 using PLAQLY@t AND PLAQLY@t-1 as inputs
Test data to predict PLAQLY@t-2 using PLAQLY@t AND PLAQLY@t-1 as inputs

// forward
Train data to predict ROE@t using ROE@t-2 and ROE@t-1 as inputs    where t = Year XXXX
Test data to predict ROE@t using ROE@t AND ROE@t-1 as inputs

// backward
Train data to predict ROE@t-2 using ROE@t AND ROE@t-1 as inputs
Test data to predict ROE@t-2 using ROE@t AND ROE@t-1 as inputs

The format for the above data is :
// forward
column1: BankID    column2: x11    column3: x12    column4: x13

or
// backward
column1: BankID    column2: x13    column3: x12    column4: x11

USE column 2 and column 3 as input data.
USE column 4 as target data.

REMEMBER to REMOVE the BankID when using the data sets for training and testing.
===============================================================================================================
