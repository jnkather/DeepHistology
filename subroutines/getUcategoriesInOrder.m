function outCats = getUcategoriesInOrder(uPatCat,blockStats)
    % this function will return the HARD prediction categories in the right
    % order (same order as columns for soft predictions)
    
    % for EACH category, find the first block that has this cat as a hard
    % pred, then find the corresponding soft pred dimension
    
    for i=1:numel(uPatCat)
        currCat = uPatCat(i);
        firstBlockInCat = find(blockStats.PLabels==currCat,1);
        [~,thisCatDim] = max(blockStats.Scores(firstBlockInCat,:)); % first block larger soft pred
        
        outDims(i) = thisCatDim;
        outCats(i) = currCat;
    end

    [~,xi] = sort(outDims); % bring dims in right order
    outCats = outCats(xi); % reorder out cats
    
    warning('reordered categories for highly predictive tiles, be careful');
    disp('-- old order was');
    uPatCat %#ok
    disp('-- new order is');
    outCats %#ok
    disp('--- (in previous versions of the script, this could lead to label switching in visualization maps in rare cases)');
    
end