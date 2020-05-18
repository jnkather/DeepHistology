% JN Kather 2020
%
% this function converts tile(block)-level predictions into patient-level
% predictions. It is used only for deployOnValidation_blind (predicting on
% a validation dataset with blinded ground truth labels)

function [patients,meanScore] = stat2slide(blockPredictionsIn,slideTable)

    disp('-- iterating all patients');
    allFiles = slideTable.FILENAME;
    [uFiles,ui] = unique(allFiles);
    uPats = slideTable.PATIENT(ui);
    
    for i = 1:numel(uFiles)
        
        currFile = uFiles{i};
        currPat  = uPats{i};
        disp(['---- iterating file ', currFile,' of patient ', currPat]);
        patients{i} = currPat;
        matchingTiles = contains(blockPredictionsIn.blockNames,currFile);
        currScores = blockPredictionsIn.Scores(matchingTiles);
        % predictionOut.matchingScores{i}
        meanScore(i) = mean(currScores,'omitnan');
        %histogram(log10(currScores));
        %drawnow
        %pause
    end
    
    
end