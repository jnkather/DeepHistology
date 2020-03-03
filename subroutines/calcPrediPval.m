% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this function claculates a p value for tile-level
% preditions of a given category

function [meanVal,meanOther,Pval] =  ...
            calcPrediPval(trueClasses,rawPredictions,currCategory)
        
        maskThis = (trueClasses == categorical(currCategory));
        
        allPred   = rawPredictions.(char(currCategory));
        predThis  = (allPred(maskThis));
        predOther = (allPred(~maskThis));
        
        meanVal   = mean(predThis);
        meanOther = mean(predOther);
        [~,Pval]  = ttest2(predThis,predOther);
end
