% JN Kather 2019
% return AUC for each class on a patient level

function patientStats = predictions2performance(blockPred,AnnData,cnst)

    disp('-- starting to calculate statistics (AUROC, AUCPR)');
    
    % for each block (tile), find the corresponding slide file name
    allFileNames = block2filename(blockPred.BlockNames);
    
    % iterate all true slide names and find corresponding tiles
    allAnnDataFiles = AnnData.FILENAME;
    for i = 1:numel(allAnnDataFiles)
        matchFile = contains(allFileNames,allAnnDataFiles{i});
        allPatientNames(matchFile) = AnnData.PATIENT(i);
    end
        
    % get true target value for each patient
    uPats = unique(allPatientNames); % unique patients
    uCats = unique(AnnData.TARGET);  % unique target categories
    for i = 1:numel(uPats)
        patientPredictions.patientNames(i) = uPats(i);
        % find true category of this patient
        currTrueCategory = AnnData.TARGET(strcmp(AnnData.PATIENT,uPats{i}));
        if numel(currTrueCategory)>1 % if there were >1 slide, check their labels match
            sanityCheck(numel(unique(currTrueCategory))==1,'>1 slide with matching labels');
        end
        patientPredictions.trueCategory(i) = currTrueCategory(1);
        % which target value has been predicted?
        currLabels = blockPred.PLabels(strcmp(allPatientNames,uPats{i}));
        currScores = blockPred.Scores(strcmp(allPatientNames,uPats{i}),:);
        for uc = 1:numel(uCats)
            if isfield(cnst,'aggregateMode') & strcmp(cnst.aggregateMode,'mean')
                patientPredictions.predictions.(char(uCats(uc)))(i) = ...
                    mean(double(currScores(:,uc)));
            elseif isfield(cnst,'aggregateMode') & strcmp(cnst.aggregateMode,'max')
                patientPredictions.predictions.(char(uCats(uc)))(i) = ...
                    max(double(currScores(:,uc)));     
            else % majority vote
                patientPredictions.predictions.(char(uCats(uc)))(i) = ...
                    sum(currLabels==uCats(uc))/numel(currLabels);
            end
        end
    end
    
    % go from predictions to statistics
    for uc = 1:numel(uCats) % statistics for each class
        
        patientStats.nPats.(char(uCats(uc))) = ...
            sum(patientPredictions.trueCategory==uCats(uc));
        
        % calculate the AUC under ROC (FPR [fallout] vs. TPR [sens.])
        [X,Y,~,AUC,OPTROCPT] = perfcurve(patientPredictions.trueCategory,...
               patientPredictions.predictions.(char(uCats(uc))),uCats(uc),...
               'NBoot',cnst.nBootstrapAUC,'XCrit','fpr','YCrit','tpr');
        patientStats.FPR_TPR.AUC.(char(uCats(uc)))      = AUC;
        patientStats.FPR_TPR.Plot.X.(char(uCats(uc)))   = X;
        patientStats.FPR_TPR.Plot.Y.(char(uCats(uc)))   = Y;
        patientStats.FPR_TPR.OPTROCPT.(char(uCats(uc))) = OPTROCPT;
        disp(['--- finished AUROC for class ',char(uCats(uc))]);
        
        % calculate AUC of precision-recall curve 
        [X,Y,~,AUC,OPTROCPT] = perfcurve(patientPredictions.trueCategory,...
               patientPredictions.predictions.(char(uCats(uc))),uCats(uc),...
               'NBoot',cnst.nBootstrapAUC,'XCrit','reca','YCrit','prec');
        patientStats.PRE_REC.AUC.(char(uCats(uc)))      = AUC;
        patientStats.PRE_REC.Plot.X.(char(uCats(uc)))   = X;
        patientStats.PRE_REC.Plot.Y.(char(uCats(uc)))   = Y;
        patientStats.PRE_REC.OPTROCPT.(char(uCats(uc))) = OPTROCPT;
        disp(['--- finished AUCPR for class ',char(uCats(uc))]);
        
    end
    
    % save patient level predictions
    patientStats.rawData = patientPredictions;
    
end
