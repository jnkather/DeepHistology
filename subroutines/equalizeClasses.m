% JN Kather 2019
% this script will equalize the clases in an image datastore object so that
% there is the same number of training instances for each label

function imds = equalizeClasses(imds)
    
    disp('-- starting to equalize the classes in this image set');
    numLabels = countEachLabel(imds); % count each label
    targetNum = min(numLabels.Count); % minimum label count
    ulabels = numLabels.Label(:);
    
    for iu = 1:numel(ulabels)
        disp(['... equalizing label ',char(cellstr(ulabels(iu)))]);
        classIndices = (imds.Labels == ulabels(iu));
        if sum(classIndices) > targetNum % have to delete some labels
            allInstances = find(classIndices);
            rng('default'); % for reproducibility
            allInstances = allInstances(randperm(numel(allInstances))); % shuffle elements
            imds.Files(allInstances(targetNum:end)) = [];
        end
    end
    
end