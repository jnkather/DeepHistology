% JN Kather 2018
% this script will load Blocks (Tiles)

function fileCollection = loadTileFiles(cnst)

disp(['loading blocks for project ',cnst.ProjectName]);

% load blocks (patches, tiles) - this works for one cohort
% (cnst.folderName.Blocks has only one element) or multiple cohorts
% (cnst.folderName.Blocks is a cell with multiple elements)
fileCollection.Blocks = imageDatastore(cnst.folderName.Blocks, ... 
        'IncludeSubfolders',true,'FileExtensions',cnst.fileformat.Blocks,'LabelSource','foldernames'); 
fileCollection.Blocks.Labels = repmat(categorical({'NA'}),numel(fileCollection.Blocks.Labels),1); % remove labels
disp(['I found ',num2str(numel(fileCollection.Blocks.Files)),' blocks/tiles/patches']);
end