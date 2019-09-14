This contains the SaFIN++ model source files.

SaFIN_gui.m - run this script to get the GUI. 

Press the 'Configure' button to assign default values to the input fields. Change inputs if required. Press the 'Run' button to run the model.

Default mode - Cross Validation
For running the model with separate training and testing data (can be used for benchmarking), change the mode to 1 and provide training, testing data files under the Mode 1 fields.

Example 

Training file : Nakanishi2_train.txt
Testing file : Nakanishi2_test.txt   

The above two files can be changed to the desired data.



Other files

RuleGen.m - generates the rules in the model
CLIP.m - performs fuzzy partitioning
SaFIN_train.m - trains the model
SaFIN_test.m - performs testing

Datasets

The .txt files are the experiment datasets. 
Files such as Nakanishi1data.txt and Nakanishi2data.txt are used for the Cross validation.

Separate training and testing files are put for mode 1.
Excel files are also provided along with the results under Experimental Setup - Benchmarking.



