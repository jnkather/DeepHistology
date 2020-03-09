% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this script will load Blocks (Tiles) from the disk

function fileCollection = loadTileFiles(cnst)

disp(['loading blocks for project ',cnst.ProjectName]);

% load blocks (patches, tiles) - this works for one cohort
% (cnst.folderName.Blocks has only one element) or multiple cohorts
% (cnst.folderName.Blocks is a cell with multiple elements)
fileCollection.Blocks = imageDatastore(cnst.folderName.Blocks, ... 
        'IncludeSubfolders',true,'FileExtensions',cnst.fileformatBlocks,'LabelSource','foldernames'); 
    
if cnst.debugMode
    disp('--- will not reset block labels for debug purposes');
else
    disp('--- resetting block labels');
    fileCollection.Blocks.Labels = repmat(categorical({'NA'}),numel(fileCollection.Blocks.Labels),1); % remove labels
end

disp(['I found ',num2str(numel(fileCollection.Blocks.Files)),' blocks (=tiles)']);
end