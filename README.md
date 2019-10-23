# Final Year Project (FYP) : Application of Fuzzy Neural Networks (FNNs) for bank failure prediction and missing data reconstruction
## Learning Outcome
I have learnt how a Fuzzy Neural Network (FNN) works as well as how aritifical neural networks and fuzzy logic systems complement each other in FNNs. In this FYP, I have applied a Mamdani-type FNN, namely "SaFIN(FRI/E)++", to bank failure prediction. To further improve its prediction accuracy, I have extended the original model with a novel hierarchical feature selection. I have also invented a missing data reconstruction algorithm in order to rebuild missing values in the given data set. The extended prediction model combined with the proposed missing data reconstruction method, can serve as a powerful hybrid tool for bank failure prediction. 

<br/>
<br/>
- Extended  a deep five-layer fuzzy neural, SAFIN(FRIE)++, with hierarchical feature selection to improve its prediction accuracy <br/>
- Analyzed the data set that includes financial statements of banks in the United States over the course of 20 years <br/>
- Performed online learning to train the model and used 5-fold Cross Validation (CV) for training and testing in bank failure prediction <br/>
- Achieved over 94% accuracy with the new extended model on an imbalanced data set with very low type I and type II error <br/>
- Implemented a missing data reconstruction algorithm based on a combination of longitudinal and lateral
reconstruction by using DENFIS, i.e. known for its regression accuracy <br/>
- Successfully reconstructed missing data with relatively low mean absolute error (MAE) and decent correlation accuracy (R) <br/>
- Tested the quality of the reconstructed data by predicting bank failure using the extended model <br/>
- Achieved about 1-2% better accuracy with the reconstructed data set than with the original data set for one-year ahead prediction <br/> 

To find out more details about: <br/>
SAFIN(FRIE)++: https://repository.ntu.edu.sg/handle/10356/72908 <br/>
HCL: https://ieeexplore.ieee.org/abstract/document/4359859?section=abstract <br/>
DENFIS: https://ieeexplore.ieee.org/document/995117 <br/>

(Note: The FYP is still in progress and expected to be completed in October 21st, 2019)

### Note: This FYP paper is currently in progress to be submitted to the following journal papers for publishing with the supervision of Assoc Prof Quek Hiok Chai (SCSE, NTU): 
1) Expert systems with applications
2) Applied soft computing
3) Information sciences 
4) IEE Transactions






