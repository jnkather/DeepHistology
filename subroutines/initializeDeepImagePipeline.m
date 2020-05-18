% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this script will prepare everything for the deep image pipeline
% all constants will be set, subfolders included etc.

function [cnst,fCollect] = initializeDeepImagePipeline(cnst)

rng('default'); % reset random number generator for reproducibility
sq = @(varargin) varargin;      % helper function

% do a GPU workaround on Linux
if ~isfield(cnst,'nogpu') && ~ismac() && ~ispc()
    doGPUworkaround(); % this is needed on Linux :-/
else
    disp('- GPU workaround not needed');
end

% check if multiple cohorts should be merged
if isa(cnst.ProjectName,'cell') && numel(cnst.ProjectName)>1 % multi cohorts
    disp('-- this is a *merged* cohort (made up of multiple cohorts)');
    cnst.multipleCohorts = true;
    cnst.allProjects = cnst.ProjectName;
    cnst.ProjectName = strjoin(sq(cnst.ProjectName{:}),'--');
    for i = 1:numel(cnst.allProjects)
        disp(['-- adding block folder of cohort: ',cnst.allProjects{i}]);
        if isfield(cnst,'filterBlocks') && ~isempty(cnst.filterBlocks) && ~strcmp(cnst.filterBlocks,'') % non-standard block dir
            disp('-- will modify experiment name to account for non-standard block dir');
            cnst.experimentName = matlab.lang.makeValidName(...
                [cnst.experimentName,'-',cnst.filterBlocks]);
            cnst.folderName.Blocks{i} = modifyBlockDir(cnst,fullfile(cnst.folderName.Temp,cnst.allProjects{i})); % abs. path to block save folder
        else % standard block dir
            disp('-- load blocks from standard block dir');
            cnst.folderName.Blocks{i} = fullfile(cnst.folderName.Temp,cnst.allProjects{i},'/BLOCKS/'); % abs. path to block save folder
        end
    end
else % standard single cohort
    cnst.multipleCohorts = false;
    disp('-- preparing single cohort');
    
    % check for subset tile folder (e.g. stroma only; defined on command line)
    if isfield(cnst,'filterBlocks') && ~isempty(cnst.filterBlocks) && ~strcmp(cnst.filterBlocks,'') % non-standard block dir
        disp('-- will modify experiment name to account for non-standard block dir');
        cnst.experimentName = matlab.lang.makeValidName(...
            [cnst.experimentName,'-',cnst.filterBlocks]);
        cnst.folderName.Blocks = modifyBlockDir(cnst,fullfile(cnst.folderName.Temp,cnst.ProjectName));  % abs. path to block save folder
    else % standard block dir
        cnst.folderName.Blocks = fullfile(cnst.folderName.Temp,cnst.ProjectName,'/BLOCKS/');  % abs. path to block save folder
    end
    
    % check for overridden tile folder (defined in experiment file)
    if isfield(cnst,'overrideFolder') && ~isempty(cnst.overrideFolder)
        disp(['-- manual OVERRIDE of tile (blocks) folder from [',cnst.ProjectName,...
             '] to [',cnst.overrideFolder,'] /BLOCKS/']);
        cnst.folderName.Blocks = fullfile(cnst.folderName.Temp,cnst.overrideFolder,'/BLOCKS/');  % abs. path to block save folder
    else
        disp('-- no manual override of tile folder');
    end
        
end

% prepare path names and create folders if needed
cnst.folderName.Dump = fullfile(cnst.folderName.Temp,cnst.ProjectName,'/DUMP/'); % abs. path to block save folder
    [~,~,~] = mkdir(char(cnst.folderName.Dump));

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
    disp('--- will SKIP loading blocks');
    fCollect = [];
end

end
