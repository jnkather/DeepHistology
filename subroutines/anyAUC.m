% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this is an auxiliary function to parse the classification results 

function ishigh = anyAUC(resultCollection,thresh)

    classes = fieldnames(resultCollection.patientStats.FPR_TPR.AUC);
    for i = 1:numel(classes)
        AUC(i) = resultCollection.patientStats.FPR_TPR.AUC.(classes{i})(1);
    end

    ishigh = any(AUC>=thresh);
    
end