% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this funcion defines the input arguments for the main scripts

function p = getInputParser(myVargs)

    p = inputParser;            % prepare to parse user input
    p.CaseSensitive = false;    % input is not case sensitive
    p.PartialMatching = false;  % strict input parser options
    p.KeepUnmatched = false;    % strict input parser options
    
    %% general parameters
    addParameter(p,'saveFormat','v6',@ischar); % version of results file    
    
    %% training of deep learning models
    addParameter(p,'experiment','',@ischar);   % which experiment to load
    addParameter(p,'gpuDev',1,@isnumeric);         % GPU Device (1 or greater)
    addParameter(p,'maxBlockNum',1000,@isnumeric); % number of blocks
    addParameter(p,'trainFull',false,@islogical);  % train on full dataset after xval
    addParameter(p,'modelTemplate','shufflenet512',@ischar); % which pretrained model
    addParameter(p,'backwards',false,@islogical); % for each experiments, work backwards
    addParameter(p,'binarizeQuantile',[]); % split HI LO at this quantile (between 0 and 0.5)
    addParameter(p,'foldxval',3,@isnumeric); % if cross validation is used, this is the fold, default 3
    addParameter(p,'xvalmode','xval',@ischar); % can be 'xval' or 'holdout' (= only first run)
    addParameter(p,'aggregateMode','majority',@ischar); % how to pool block predictions per patient, 'majority', 'ignoreClass', 'mean' or 'max'
    addParameter(p,'tableModeClini','XLSX',@ischar); % file format of clinical table, XLSX or CSV
    addParameter(p,'hyper','default',@ischar); % set of hyperparameters
    addParameter(p,'valSet',[],@isnumeric); % validation set proportion of training set, default no validation (recommend 0.05)
    addParameter(p,'filterBlocks','',@ischar); % use an alternative set of tiles, such as normalized tiles
    addParameter(p,'subsetTargetsBy',[]); % subset the patients by a variable
    addParameter(p,'subsetTargetsLevel',[]); % subset the patients by this level in the variable
    addParameter(p,'skipExistingTargets',false,@islogical); % skip target prediction if result file exists
    addParameter(p,'forgiveError',false,@islogical); % ignore errors during training and go on to the next task
    addParameter(p,'maxBlocksPerClass',1e9,@isnumeric); % hard limit to the number of tiles per class in xval mode
    addParameter(p,'nBootstrapAUC',10,@isnumeric);   % bootstrap for AUC confidence interval, default 10
    addParameter(p,'whichIgnoreClass','',@ischar); % ignore this class for statistics, only works if aggregateMode is ignoreClass
    
    % holy input parameters, do not change
    addParameter(p,'saveUnmatchedBlocks',false,@islogical);   % save list of unmatchable blocks, may blow up output file size
    addParameter(p,'undersampleTrainingSet',true,@islogical); % equalize training set just before training
    addParameter(p,'binarizeThresh',5,@isnumeric);    % convert num targets with more than N levels to HI / LO
    addParameter(p,'fileformatBlocks','.jpg',@ischar);  % define format for Blocks
    
    % experimental parameters, do not change in production mode
    addParameter(p,'exportTiles',false,@islogical); % export tiles of first 'xval' experiment just before training
    
    %% deployment of pre-trained models
    addParameter(p,'trainedModelID',[]); % use a previously trained model for deployment
    addParameter(p,'trainedModelFolder',[]); % path to previously trained model for deployment
    addParameter(p,'saveTopTiles',false,@islogical); % save the top tiles after deployment
    
    %% visualization of results
    addParameter(p,'doPlot',false,@islogical); % show the ROC on screen
    addParameter(p,'doPrint',false,@islogical); % save the ROC to PDF and Imgs to PNG
    addParameter(p,'plotThreshold',false,@islogical); % plot the operating threshold on top
    addParameter(p,'exportBlockPred',false,@islogical); % save tile-level table for maps
    addParameter(p,'exportBlockFormat','csv',@ischar); % must be csv or xlsx
    addParameter(p,'exportTopTiles',0,@isnumeric); % save showcase tiles 
    addParameter(p,'topPatients',3,@isnumeric); % showcase tiles from these patients
    addParameter(p,'visualizeBaselineTiles',false,@islogical); % for visualization of top tiles, fall back to BLOCKS 
    addParameter(p,'plotFontSize',12,@isnumeric); % font size for plots    
    addParameter(p,'plotAUCthreshold',0.75,@isnumeric); % detailed visualization only for high performance targets
    addParameter(p,'onlyExplicitTargets',true,@islogical); % visualize only targets specified in experiment file
    addParameter(p,'plotForest',false,@islogical); % plot a forest chart
    addParameter(p,'forestLevels','',@ischar); % restrict forest plot names to these levels
    addParameter(p,'debugMode',false,@islogical); % debug mode
    addParameter(p,'overrideTileDrive',false,@islogical); % override the drive letter for tiles for vis
    addParameter(p,'overrideDriveFrom',' ',@ischar); % override the drive letter from this
    addParameter(p,'overrideDriveTo',' ',@ischar); % override the drive letter to this

    %% fixed visualization parameters, do not change
    addParameter(p,'axTicks',0:0.2:1);     % primary axis tick labels for ROC curves
    addParameter(p,'axTicksFine',0:0.1:1); % secondary axis tick labels for ROC curves
    addParameter(p,'scaleYprerec',false,@islogical); % scale y axis of pre rec curve, default false

    %% train on previously exported dataset
    addParameter(p,'trainOnFolder','',@ischar); % scale y axis of pre rec curve, default false

    %% normalization of tiles (blocks)
    addParameter(p,'numParWorkers',0,@isnumeric); % default: do not use parallel workers
       
    parse(p,myVargs{:});        % parse input arguments
end
    
    