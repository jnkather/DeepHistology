% JN Kather 2018
% this script will prepare everything for the deep image pipeline
% all constants will be set, subfolders included etc.

function [cnst,fCollect] = initializeDeepImagePipeline(cnst)

rng('default'); % reset random number generator for reproducibility

%  some more settings
cnst.saveUnmatchedBlocks = false; % save list of unmatchable blocks, may blow up output file size
cnst.nBootstrapAUC          = 10; % bootstrap for AUC confidence interval, default 10
cnst.undersampleTrainingSet = true; % equalize training set labels by undersampling
sq = @(varargin) varargin;      % helper function

% how to make the blocks fit the neural network input size
% options: 'resize', 'randcrop', 'centercrop'; default 'resize'
cnst.blocks.resizeMethod = 'resize'; 

% do a GPU workaround on Linux
if ~isfield(cnst,'nogpu') && ~ismac() && ~ispc()
    doGPUworkaround(); % this is needed on Linux :-/
else
    disp('GPU workaround not needed');
end

% check if multiple cohorts should be merged
if isa(cnst.ProjectName,'cell') && numel(cnst.ProjectName)>1
    disp('-- this is a *merged* cohort');
    cnst.multipleCohorts = true;
    cnst.allProjects = cnst.ProjectName;
    cnst.ProjectName = strjoin(sq(cnst.ProjectName{:}),'--');
    for i = 1:numel(cnst.allProjects)
        disp(['-- adding block folder of cohort: ',cnst.allProjects{i}]);
        cnst.folderName.Blocks{i} = fullfile(cnst.folderName.Temp,cnst.allProjects{i},'/BLOCKS/'); % abs. path to block save folder
    end
else
    cnst.multipleCohorts = false;
    cnst.folderName.Blocks = fullfile(cnst.folderName.Temp,cnst.ProjectName,'/BLOCKS/'); % abs. path to block folder
    disp('-- only one cohort specified');
end

% prepare path names and create folders if needed
cnst.folderName.Dump = fullfile(cnst.folderName.Temp,cnst.ProjectName,'/DUMP/'); % abs. path to block save folder
    [~,~,~] = mkdir(cnst.folderName.Dump);

% check if settings have been made - if not, set default
if ~isfield(cnst.fileformat,'Blocks')
    cnst.fileformat.Blocks ='.jpg';     % define format for Blocks
end
if ~isfield(cnst.blocks,'maxBlockNum')
    cnst.blocks.maxBlockNum     = 1000; % maximum number of blocks per whole slide image, default 1000
end
if ~isfield(cnst,'aggregateMode')
    cnst.aggregateMode = 'majority';   % how to pool block predictions per patient, 'majority', 'mean' or 'max'
end
if ~isfield(cnst,'tableModeClini')
    cnst.tableModeClini = 'XLSX'; % which file format is the clinical table?
end
if ~isfield(cnst,'foldxval')
    cnst.foldxval               = 3;   % if cross validation is used, this is the fold, default 3
end
if ~isfield(cnst,'saveTileTable')
    cnst.saveTileTable = 0; % save a table for all tile predictions for viz
end

% define SLIDE table and CLINI table
% the SLIDE table needs to have the columns FILENAME and PATIENT
% the CLINI table needs to have the column PATIENT plus an target column
cnst.annotation.Dir = './cliniData/';
if cnst.multipleCohorts
    for i = 1:numel(cnst.allProjects)
        disp('-- preparing table references for multiple cohorts');
        currProj = cnst.allProjects{i};
        cnst.annotation.SlideTable{i} = [currProj,'_SLIDE.csv'];
        cnst.annotation.CliniTable{i} = [currProj,'_CLINI.csv'];
    end
else
    disp('-- preparing table reference for single cohort');
    cnst.annotation.SlideTable = [cnst.ProjectName,'_SLIDE.csv'];
    cnst.annotation.CliniTable = [cnst.ProjectName,'_CLINI.csv'];
end
cnst.baseName = cnst.experimentName; % backup the current experiment name

if ~isfield(cnst,'skipLoadingBlocks') || ~cnst.skipLoadingBlocks
    disp('--- starting to load blocks');
    fCollect = loadTileFiles(cnst); % load tile (block) files
else
    disp('--- will not load blocks');
    fCollect = [];
end

end
