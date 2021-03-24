% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this function will color-normalize all tiles of a given project
% requires color normalization subroutines (third party License)

function autoNormalize(varargin)

addpath(genpath('./subroutines/'));      % add dependencies
addpath(genpath('./subroutines_normalization/')); % add normalization dependencies
iPrs = getInputParser(varargin);  % get input parser, define default values
cnst = loadExperiment(iPrs.Results.experiment); % load experiment from JSON
cnst.skipLoadingBlocks = true; % never load tiles for visualization
disp('-- starting VISUALIZE job with these input (or default) settings:');
dispAllFields(iPrs.Results);
cnst = copyfields(cnst,iPrs.Results,fieldnames(iPrs.Results)); % apply input
[cnst,~] = initializeDeepImagePipeline(cnst);  % initialize

warning ('on','all');
ref_image = imread('./subroutines_normalization/Ref.png'); % reference image for image color normalization

if ~isfield(cnst,'overrideFolder') || isempty(cnst.overrideFolder) % this is the default
cnst.folderName.BlocksNorm = strrep(cnst.folderName.Blocks,fullfile(cnst.ProjectName,'BLOCKS'),fullfile(cnst.ProjectName,'BLOCKS_NORM'));
cnst.folderName.BlocksFail = strrep(cnst.folderName.Blocks,fullfile(cnst.ProjectName,'BLOCKS'),fullfile(cnst.ProjectName,'BLOCKS_NORM_FAIL'));
else % this is needed to maintain compatibility if overrideFolder is non-empty
cnst.folderName.BlocksNorm = strrep(cnst.folderName.Blocks,fullfile(cnst.overrideFolder,'BLOCKS'),fullfile(cnst.overrideFolder,'BLOCKS_NORM'));
cnst.folderName.BlocksFail = strrep(cnst.folderName.Blocks,fullfile(cnst.overrideFolder,'BLOCKS'),fullfile(cnst.overrideFolder,'BLOCKS_NORM_FAIL'));  
end

disp(['--- will save normalized blocks (tiles) to ',cnst.folderName.BlocksNorm]);
mkdir(cnst.folderName.BlocksNorm);
mkdir(cnst.folderName.BlocksFail);

% read all source files 
disp('-- reading all source files');
tic
allSourceFiles = imageDatastore(cnst.folderName.Blocks,'FileExtensions',cnst.fileformatBlocks,'IncludeSubfolders',true);
[~,snames,~] = cellfun(@fileparts,allSourceFiles.Files,'UniformOutput',false);
toc
disp('-- reading all target files');
tic
preLoadTarget  = dir(cnst.folderName.BlocksNorm);
if numel(preLoadTarget)==2
    disp('-- target dir is empty');
    tnames = [];
    overlapnames = [];
else
    allTargetFiles = imageDatastore(cnst.folderName.BlocksNorm,'FileExtensions',cnst.fileformatBlocks,'IncludeSubfolders',true);
    % find out which files have been already processed
    [~,tnames,~] = cellfun(@fileparts,allTargetFiles.Files,'UniformOutput',false);
    [overlapnames,ia,~] = intersect(snames,tnames);
end
toc

disp(['--- files in the source directory: ',num2str(numel(snames))]);
disp(['--- files in the target directory: ',num2str(numel(tnames))]);
disp(['--- overlapping files            : ',num2str(numel(overlapnames))]);
disp(['--- remaining files              : ',num2str(numel(snames)-numel(overlapnames))]);
disp('... will process all remaining files');

if numel(overlapnames)>0
    disp('--- removed processed files from source list');
    allSourceFiles.Files(ia) = [];
end

allFnames = allSourceFiles.Files;
maxFn = numel(allFnames);

if cnst.numParWorkers>0
    % restart the parallel pool to enforce settings
    delete(gcp('nocreate'))
    parpool(cnst.numParWorkers);
end

parfor (i=1:maxFn,cnst.numParWorkers)
    currFn = allFnames{i};
    currFolder = fullfile(fileparts(cnst.folderName.BlocksNorm),getDeepestFolder(currFn));
    try
                currIm = imread(currFn);
                [~,cimname,cimtype] = fileparts(currFn);
                currIm = Norm(currIm, ref_image, 'Macenko', 255, 0.15, 1, false);
                mkdir(currFolder);
                imwrite(currIm,fullfile(currFolder,[cimname,cimtype]));
    catch
                warning('fail')
                mkdir(fileparts(cnst.folderName.BlocksFail));
                copyfile(currFn,cnst.folderName.BlocksFail);
    end

    if mod(i,500)==1
        disp(['finished file ',num2str(i),' of ',num2str(maxFn)]);
    end
end

disp('-- FINISHED ALL --');
end


