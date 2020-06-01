-------------------------------------------------------------
Non-Linear Stain Mapping: Training & Classification Instructions
Nicholas Trahearn
BIALab, Department of Computer Science, University of Warwick
-------------------------------------------------------------

-------------------------------------------------------------
0. Contents
-------------------------------------------------------------

    1. Introduction
    2. Built-in H&E Classifier
    3. Training Your Own Classifier


-------------------------------------------------------------
1. Introduction
-------------------------------------------------------------

    The Non-Linear Stain Mapping method of Stain Normalisation is a supervised method. As such it requires a classifier to be trained before use.
    Please refer to the following paper for further details on the approach:
        Khan, A.M., Rajpoot, N., Treanor, D., Magee, D., A Non-Linear Mapping Approach to Stain Normalisation in Digital Histopathology Images using Image-Specific Colour Deconvolution, IEEE Transactions on Biomedical Engineering, 2014. 


-------------------------------------------------------------
2. Built-in H&E Classifier
-------------------------------------------------------------

    Provided is a pre-trained classifier struct for Haematoxylin and Eosin (H&E) stained images of varying stain intensity. 
    The classifier can be found at SCDTraining/Default/DefaultStainTrainingStruct.mat in the toolbox. 
    This pre-trained classifier is suitable for general purpose Non-Linear Normalisation of H&E stained images.


-------------------------------------------------------------
2. Training Your Own Classifier
-------------------------------------------------------------

    If you would like to train your own classifier please refer to the MakeClassifier function, found at SCDTraining/MakeClassifier.m.
    By default MakeClassifier uses Matlab's implementation of Random Forest for training and classificiation, using the functions TrainRF and ClassifyRF (found at SCDTraining/Default/TrainRF.m and SCDTraining/Default/ClassifyRF.m, respectively), please refer to these files for further details. 
    If you would like to use a different training and classification functions you may create your own custom functions for this purpose and provide handles to them as input to the MakeClassifier function, please refer to SCDTraining/Default/MakeClassifier.m for more details on the formatting of the custom functions.