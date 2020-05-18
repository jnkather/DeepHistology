% JN Kather 2020
%
% this function converts tile(block)-level predictions into patient-level
% predictions. It is used only for deployOnValidation_blind (predicting on
% a validation dataset with blinded ground truth labels)


% CAUTION THIS FUNCTION ASSUMES THE PATIENT NAME IS PART OF THE TILE NAME

function [patients,meanScore] = stat2pat(blockPredictionsIn,slideTable)

    disp('-- iterating all patients');
    uPats = unique(slideTable.PATIENT);
    
    for i = 1:numel(uPats)
        
        currPat  = uPats{i};
        disp(['---- iterating patient ', currPat]);
        patients{i} = currPat;
        matchingTiles = contains(blockPredictionsIn.blockNames,currPat);
        currScores = blockPredictionsIn.Scores(matchingTiles);
        % predictionOut.matchingScores{i}
        meanScore(i) = mean(currScores,'omitnan');
        %histogram(log10(currScores));
        %drawnow
        %pause
    end
    
    
end