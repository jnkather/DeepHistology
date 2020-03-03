% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this funcion defines the input arguments for the main scripts

function p = getDefaultInputParser(myVargs)

    p = inputParser;            % prepare to parse user input
    p.CaseSensitive = false;    % input is not case sensitive
    p.PartialMatching = false;  % strict input parser options
    p.KeepUnmatched = false;    % strict input parser options
    
    %% training of deep learning models
    addParameter(p,'experiment','',@ischar);   % which experiment to load
    addParameter(p,'gpuDev',1,@isnumeric);         % GPU Device (1 or greater)
    addParameter(p,'maxBlockNum',1000,@isnumeric); % number of blocks
    addParameter(p,'trainFull',false,@islogical);  % train on full dataset after xval
    addParameter(p,'modelTemplate','shufflenet512',@ischar); % which pretrained model
    addParameter(p,'backwards',false,@islogical); % for each experiments, work backwards
    addParameter(p,'binarizeQuantile',[]); % split HI LO at this quantile (between 0 and 0.5)
    addParameter(p,'foldxval',3,@isnumeric); % if cross validation is used, this is the fold, default 3
    addParameter(p,'aggregateMode','majority',@ischar); % how to pool block predictions per patient, 'majority', 'mean' or 'max'
    addParameter(p,'saveTileTable',false,@islogical); % save a table for all tile predictions for viz
    addParameter(p,'tableModeClini','XLSX',@ischar); % file format of clinical table, XLSX or CSV
    addParameter(p,'hyper','default',@ischar); % set of hyperparameters
    addParameter(p,'valSet',[],@isnumeric); % validation set proportion of training set, default no validation (recommend 0.05)
    addParameter(p,'filterBlocks','',@ischar); %
    addParameter(p,'subsetTargetsBy',[]); % subset the patients by a variable
    addParameter(p,'subsetTargetsLevel',[]); % subset the patients by this level in the variable
    addParameter(p,'skipExistingTargets',false,@islogical); % skip target prediction if result file exists
    addParameter(p,'forgiveError',false,@islogical); % ignore errors during training and go on to the next task
    
    %% deployment of pre-trained models
    addParameter(p,'trainedModelID',[]); % use a previously trained model for deployment
    addParameter(p,'trainedModelFolder',[]); % path to previously trained model for deployment
    addParameter(p,'saveTopTiles',false,@islogical); % save the top tiles after deployment
    
    %% visualization of results
    addParameter(p,'doPlot',false,@islogical); % show the ROC on screen
    addParameter(p,'doPrint',false,@islogical); % save the ROC to PDF and Imgs to PNG
    addParameter(p,'plotThreshold',false,@islogical); % plot the operating threshold on top
    addParameter(p,'exportBlockPred',false,@islogical); % save CSV file for maps
    addParameter(p,'exportTopTiles',0,@isnumeric); % save showcase tiles 
    addParameter(p,'topPatients',3,@isnumeric); % showcase tiles from these patients
    addParameter(p,'plotFontSize',12,@isnumeric); % font size for plots    
    addParameter(p,'saveFormat','v6',@ischar); % version of results file    
    addParameter(p,'plotAUCthreshold',0.75,@isnumeric); % detailed visualization only for high performance targets
    addParameter(p,'onlyExplicitTargets',true,@islogical); % visualize only targets specified in experiment file
    addParameter(p,'debugMode',false,@islogical); % debug mode
       
    parse(p,myVargs{:});        % parse input arguments
end
    
    