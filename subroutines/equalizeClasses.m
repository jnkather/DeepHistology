% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this script will equalize the clases in an image datastore object so that
% there is the same number of training instances for each label

function imds = equalizeClasses(imds,maxBlockNum)
    
    disp('-- starting to equalize the classes on TILE level just before training');
    numLabels = countEachLabel(imds); % count each label
    % the minimum number of tiles per label is EITHER the number of the
    % lowest prevalent label OR a fixed number maxTargetNum, whichever is
    % smaller
    
    disp([' -- number of Tiles in the least abundant class is ',num2str(min(numLabels.Count))]);
    disp([' -- the hard upper limit for tiles per class is ',num2str(maxBlockNum)]);
    
    targetNum = min(maxBlockNum,min(numLabels.Count)); 
    
    disp([' -- therefore I will limit tiles per class to ',num2str(targetNum)]);
    
    ulabels = numLabels.Label(:);
    
    for iu = 1:numel(ulabels)
        disp(['... equalizing label ',char(cellstr(ulabels(iu)))]);
        classIndices = (imds.Labels == ulabels(iu));
        if sum(classIndices) > targetNum % have to delete some labels
            allInstances = find(classIndices);
            rng('default'); % for reproducibility
            allInstances = allInstances(randperm(numel(allInstances))); % shuffle elements
            imds.Files(allInstances((targetNum+1):end)) = []; % fixed the missing +1 bug
        end
    end
    
end