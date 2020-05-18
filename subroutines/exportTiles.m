% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this function is used to export the training set just before training.
% That means that class balancing by undersampling has been performed.
% Thus, the training set can be re-used for other tasks. This is an
% experimental function and is not part of production-ready pipelines

function exportTiles(cnst,trainSet,testSet)
    
    disp('will copy train set and test set to export folders...');
    
    targetFolder = strrep(cnst.folderName.Dump,'DUMP',['EXPORT_',cnst.baseName]);
    
    if ~isempty(trainSet)
        copyFilesByLabel(trainSet,[targetFolder,'TRAIN']);
        disp('... finished copying training files');
    end
    
            
    if ~isempty(testSet)
        copyFilesByLabel(testSet,[targetFolder,'TEST']);
        disp('... finished copying training files');
    end
    
end