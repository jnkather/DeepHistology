% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this function parses prediction statistics and
% provides a summary

function res = parseStatistics(currStats) 

    res.varN = currStats.cnst.annotation.targetCol;
    
    if isfield(currStats.cnst,'subsetTargets')
        res.proj = strcat(currStats.cnst.subsetTargets.by,'-',currStats.cnst.subsetTargets.level);
    else
        res.proj = {'noSubsetTargets'};
    end
    
    if isfield(currStats.cnst,'filterBlocks')
        res.filterBlocks = strcat(currStats.cnst.filterBlocks);
    else
        res.filterBlocks = {'noFilterBlocks'};
    end
    
    levelNames = fieldnames(currStats.patientStats.FPR_TPR.AUC)';
    
    for nl = 1:numel(levelNames) % iterate levels (categories)
        outTable.levelNames{nl} = levelNames{nl};
        outTable.nPat(nl) = currStats.patientStats.nPats.(levelNames{nl});

        % extract AUC of standard ROC (FPR vs TPR)
        outTable.AUROC_avg(nl) = round(currStats.patientStats.FPR_TPR.AUC.(levelNames{nl})(1),3);
        outTable.AUROC_low(nl) = round(currStats.patientStats.FPR_TPR.AUC.(levelNames{nl})(2),3);
        outTable.AUROC_hig(nl) = round(currStats.patientStats.FPR_TPR.AUC.(levelNames{nl})(3),3);

        % extract AUC of precision-recall curve
        outTable.AUCPR_avg(nl) = round(currStats.patientStats.PRE_REC.AUC.(levelNames{nl})(1),3);
        outTable.AUCPR_low(nl) = round(currStats.patientStats.PRE_REC.AUC.(levelNames{nl})(2),3);
        outTable.AUCPR_hig(nl) = round(currStats.patientStats.PRE_REC.AUC.(levelNames{nl})(3),3);
        
        % calculate P value for patient-level prediction between categories
        [outTable.meanCat(nl),outTable.meanOth(nl),outTable.pVal(nl)] =  ...
            calcPrediPval(currStats.patientStats.rawData.trueCategory,...
                          currStats.patientStats.rawData.predictions,...
                          levelNames(nl));
                      
    end 
    outTable.fracPat = outTable.nPat / sum(outTable.nPat);
    res.outT = struct2table(transposeStruct(outTable));
    disp([newline,'this is the result table ',newline]);
    disp(res.outT)
    disp([newline,'*********',newline]);

end