Important files:

ron_test.m - Main script that performs benchmark tests. Individual experiments are in their own respective scripts

update_ron_trainOnline.m - Main function that performs ieRSPOP network generation and learning. Refer to any experiment script to see how this function is invoked. Generally, it can 
be invoked as ensemble = update_ron_trainOnline(input, targets, algorithm, ensemble).
Output is stored as ensemble.predicted.

Individual m files pertaining to each seperate function in the algorithm e.g. online membership function generation, is easily identified within ron_trainOnline.m.

All .m files are well commented.

Datasets:

Experiment datasets have been extracted and saved as .mat files. Check each experiment script to find file name (e.g. ron_test_trafic has "load ron_traffic.mat").
The .mat files can be found in /data.