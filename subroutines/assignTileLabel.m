% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this script will assign a label to each block (tile)
% the label is inherited from the parent patient

function [allBlocks,AnnData,unmatchedBlockNames] = assignTileLabel(allBlocks,AnnData,cnst)

    disp('-- starting to parse all whole slide image names, overwriting block labels... ');
    
    allBlockFileNames = allBlocks.Files;  % extract all block names 
    allBlocks.Labels = repmat(categorical(cellstr('UNDEF')),1,numel(allBlocks.Labels));   % reset all block labels
    numImages = numel(AnnData.FILENAME);
    
    sanityCheck(numel(AnnData.FILENAME)==numel(AnnData.TARGET),'each image has a target label');
    
    for ci = 1:numImages
        dispOn = (mod(ci,round(numImages/5))==0); % display some results
        currImageName = AnnData.FILENAME{ci};
        matchingBlocks = contains(allBlockFileNames,currImageName);
        if sum(matchingBlocks)>cnst.maxBlockNum
            if dispOn
            disp(['---- will remove ',num2str(sum(matchingBlocks)-cnst.maxBlockNum),' excess blocks']);
            end
            matchingBlocks = removeExcessIndices(matchingBlocks,cnst.maxBlockNum);
        end
            if dispOn
            disp(['--- matched ',num2str(sum(matchingBlocks)),' blocks to ', currImageName]);
            disp(['--- progress: ',num2str(100*ci/numImages,2),'%']);
            end
            AnnData.NUMBLOCKS(ci) = sum(matchingBlocks);
        if any(matchingBlocks) % overwrite block labels
            allBlocks.Labels(matchingBlocks) = AnnData.TARGET(ci);
        end
    end
    disp([newline,'-- found ', num2str(sum(AnnData.NUMBLOCKS==0)),' whole slide image(s) without any matching blocks']);
    
    removeMe = (AnnData.NUMBLOCKS==0);
    for cfn = fieldnames(AnnData)'
        AnnData.(char(cfn))(removeMe) = [];
    end
    
    disp(['---- (I have removed these whole slide images,',...
        ' remaining whole slide images with >0 blocks: ',num2str(numel(AnnData.FILENAME))]);
    
    % remove all Blocks without a label
    disp(['--- there are ',num2str(numel(allBlocks.Files)),' blocks in total']);
    disp('--- removing unlabeled blocks');
    unmatched = (allBlocks.Labels==categorical(cellstr('UNDEF'))) | isundefined(allBlocks.Labels);
    if ~isfield(cnst,'saveUnmatchedBlocks') || cnst.saveUnmatchedBlocks
        unmatchedBlockNames = allBlocks.Files(unmatched);
    else 
        unmatchedBlockNames = [];
    end
    allBlocks.Files(unmatched) = [];
    disp(['--- after cleanup, there are ',num2str(numel(allBlocks.Files)),' blocks in total']);
    
    % --- fix a Matlab bug by which the UNDEF category is preserved even if
    % no element is undef (convert back and forth)
    allBlocks.Labels = categorical(cellstr(allBlocks.Labels));
    
end