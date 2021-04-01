% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% match tiles to WSIs and WSIs to patients
% then return AUC for each class on a patient level
% 
% this function can also, optionally, return block-level prediction scores

function [patientStats, varargout] = predictions2performance(blockPred,AnnData,cnst)

    disp(['-- calculating statistics (AUROC, AUCPR) with mode: ',cnst.aggregateMode]);
    
    % for each block (tile), find the corresponding slide file name
    allFileNames = block2filename(blockPred.BlockNames);    
    
    % iterate all true slide names and find corresponding tiles
    allAnnDataFiles = AnnData.FILENAME;
    for i = 1:numel(allAnnDataFiles)
        matchFile = contains(allFileNames,allAnnDataFiles{i});
        allPatientNames(matchFile) = AnnData.PATIENT(i);
    end

    % get true target value for each patient
    uPats = unique(removeEmptyCells(allPatientNames)); % unique nonempty patients
    netCats = blockPred.outClasses';   % network output categories
    patCats = unique(AnnData.TARGET);  % input patient unique categories
    
    if numel(netCats) == numel(patCats)
        disp('--- number of network output categories = number of unique patient categories');
        sanityCheck(~any(sort(unique(AnnData.TARGET))~=sort(netCats)),'network and patient categories match');
        softSanityCheck(~any(patCats~=netCats),'network and patient category order matches');     
    else
        warning('--- number of network output categories NOT EQUAL number of unique patient categories: ');
        netCats
        patCats
        disp('----- be very careful! only continue if you know what you are doing! ');
    end
    
    for i = 1:numel(uPats) % iterate all patients
        patientPredictions.patientNames(i) = uPats(i);
        % find true category of this patient
        currTrueCategory = AnnData.TARGET(strcmp(AnnData.PATIENT,uPats{i}));
        if numel(currTrueCategory)>1 % if there were >1 slide, check their labels match
            sanityCheck(numel(unique(currTrueCategory))==1,'found >1 slide with matching labels');
        end
        patientPredictions.trueCategory(i) = currTrueCategory(1);
        % which target value has been predicted?
        blocksOfInterest = strcmp(allPatientNames,uPats{i});
        currLabels = blockPred.PLabels(blocksOfInterest);
        currScores = blockPred.Scores(blocksOfInterest,:);
        [~,highestIndexCurrScores] = max(currScores,[],2);
        % which patient does each tile belong to?
        blockPred.parentPatient(blocksOfInterest) = repmat(uPats(i),sum(blocksOfInterest),1);
        for uc = 1:numel(netCats)
            switch(cnst.aggregateMode)
                case 'mean'
                patientPredictions.predictions.(char(netCats(uc)))(i) = ...
                    mean(double(currScores(:,uc)));
                case 'max'
                patientPredictions.predictions.(char(netCats(uc)))(i) = ...
                    max(double(currScores(:,uc)));     
                case 'ignoreClass'
                currLabelsClean = currLabels;
                currLabelsClean(currLabelsClean==categorical(cellstr(cnst.whichIgnoreClass))) = [];
                patientPredictions.predictions.(char(netCats(uc)))(i) = ...
                    sum(currLabels==netCats(uc))/numel(currLabelsClean);
                case 'majorityRobust'
                    patientPredictions.predictions.(char(netCats(uc)))(i) = ...
                    sum(highestIndexCurrScores==uc)/numel(currLabels);
                case 'majority' % default majority vote
                    patientPredictions.predictions.(char(netCats(uc)))(i) = ...
                    sum(currLabels==netCats(uc))/numel(currLabels);
                otherwise
                    error('-- invalid aggregation mode');
            end
        end
    end
    
    
    % go from predictions to stats, DANGER ZONE, do not play around here
    disp('--- calculating statistics for all PATIENT categories (not NETWORK output categories)');
    for uc = 1:numel(patCats) % statistics for each class which is present
        
        patientStats.nPats.(char(patCats(uc))) = ...
            sum(patientPredictions.trueCategory==patCats(uc));
        
        % calculate the AUC under ROC (FPR [fallout] vs. TPR [sens.]) ----
        disp('--- calculating ROC with default behavior');
        [X,Y,T,AUC,OPTROCPT] = perfcurve(patientPredictions.trueCategory,...
               patientPredictions.predictions.(char(patCats(uc))),patCats(uc),...
               'NBoot',cnst.nBootstrapAUC,'XCrit','fpr','YCrit','tpr');
        patientStats.FPR_TPR.AUC.(char(patCats(uc)))      = AUC;
        patientStats.FPR_TPR.Plot.X.(char(patCats(uc)))   = X;
        patientStats.FPR_TPR.Plot.Y.(char(patCats(uc)))   = Y;
        patientStats.FPR_TPR.Plot.T.(char(patCats(uc)))   = T;
        patientStats.FPR_TPR.OPTROCPT.(char(patCats(uc))) = OPTROCPT;
        disp(['--- finished AUROC (x=fpr,y=tpr) for class ',char(patCats(uc)),' (AUROC = ',num2str(AUC),')']);
        
        % calculate AUC of precision-recall curve ------------------------
        disp('--- calculating PRC with default behavior');
        [X,Y,T,AUC,OPTROCPT] = perfcurve(patientPredictions.trueCategory,...
               patientPredictions.predictions.(char(patCats(uc))),patCats(uc),...
               'NBoot',cnst.nBootstrapAUC,'XCrit','reca','YCrit','prec');
        patientStats.PRE_REC.AUC.(char(patCats(uc)))      = AUC;
        patientStats.PRE_REC.Plot.X.(char(patCats(uc)))   = X;
        patientStats.PRE_REC.Plot.Y.(char(patCats(uc)))   = Y;
        patientStats.PRE_REC.Plot.T.(char(patCats(uc)))   = T;
        patientStats.PRE_REC.OPTROCPT.(char(patCats(uc))) = OPTROCPT;
        disp(['--- finished AUCPR (x=reca,y=prec) for class ',char(patCats(uc)),' (AUCPR = ',num2str(AUC),')']);
        
    end
    
    % save patient level predictions
    patientStats.rawData = patientPredictions;
    
    if nargout > 1 % optionally, return modified block-level predictions
        varargout{1} = blockPred; 
    end
    
end
