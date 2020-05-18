% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this is the main function to start a deep learning
% experiment (in cross validation or on a full cohort)

function autoDeepLearn(varargin)
addpath(genpath('./subroutines/'));      % add dependencies
iPrs = getDefaultInputParser(varargin);  % get input parser, define default values
gpuDevice(iPrs.Results.gpuDev);          % select GPU device (Windows only)
cnst = loadExperiment(iPrs.Results.experiment); % load experiment from JSON
disp('-- starting job with these input (or default) settings:');
dispAllFields(iPrs.Results); 
cnst = copyfields(cnst,iPrs.Results,fieldnames(iPrs.Results)); % apply input
[cnst,fCollect] = initializeDeepImagePipeline(cnst);  % initialize
hyperprm = getDeepHyperparameters(cnst.hyper);        % load DL hyperparams
dispAllFields(cnst);        % display all constants on console
dispAllFields(hyperprm);    % display all hyperparameters on console
sq = @(varargin) varargin;  % define squeeze function

if cnst.backwards           % optional: work backwards in target list
    disp('- flipping targets (work backwards in target list)');
    cnst.allTargets = flipud(cnst.allTargets);
end
for ti = 1:numel(cnst.allTargets) % iterate target variables in this experiment
    try
    rng('shuffle');               % reset random number generator
    cnst.annotation.targetCol = char(cnst.allTargets{ti}); % current target column in clinical table
    
    skipThisRound = false;
    if cnst.skipExistingTargets % check if target exists, skip if it does
        existingResults = dir(strcat(cnst.folderName.Dump,'*.mat')); 
        existingResultFiles = sq(existingResults.name)'; % check for existing results
        skipThisRound = any(contains(existingResultFiles,cnst.annotation.targetCol));
    end
    
    if skipThisRound % this is optional ... skip this target
        disp(['--- target ',cnst.annotation.targetCol,' exists... skip']);
        continue
    else 
        disp(['-- starting to analyze target ',cnst.annotation.targetCol,'']);
    end
    
    cnst.experimentName = [cnst.baseName,'-',randseq(5,'Alphabet','AA'),'_',cnst.annotation.targetCol];
    disp([newline,'#################',newline,...
        'starting new experiment: ',cnst.annotation.targetCol ]);
    z1 = tic;
    AnnData = getAnnotationData(cnst);  % read data from target column
    if isempty(AnnData)
        warning('invalid annotation data, will skip this target')
    else 
        % load image tiles and match a label to each tile
        allBlocks = copy(fCollect.Blocks);
        [allBlocks, AnnData, ~] = assignTileLabel(allBlocks,AnnData,cnst);
        myNet = getAndModifyNet(cnst,hyperprm,numel(unique(allBlocks.Labels))); % load pretrained net
        % partition the cohort for cross validation, then train the network
        if cnst.foldxval>0
        disp(['-- will start a ',num2str(cnst.foldxval),' fold cross validated experiment']);
        [imdsContainer,AnnData] = splitImdsForXVal(allBlocks,AnnData,cnst);
        if isempty(imdsContainer)
            warning('--- empty imds contaniner... skip this target');
            continue
        end
            for ir = 1:cnst.foldxval
                disp(['--- starting crossval experiment ',num2str(ir)]);            
                % create image datastore for test set in this run
                imdsTST = copy(imdsContainer{ir});
                disp(['--- there are ',num2str(numel(imdsTST.Files)),' tiles in the test set']);
                % create image datastore for training set in this run
                imdsTRN = copy(allBlocks);
                imdsTRN.Files(ismember(imdsTRN.Files,imdsTST.Files)) = []; % remove all test set files from the training set
                disp(['---- there are ',num2str(numel(imdsTRN.Files)),' tiles in the training set']);
                if cnst.undersampleTrainingSet
                    imdsTRN = equalizeClasses(imdsTRN); % undersample training set
                    disp(['---- after undersampling, there are ',num2str(numel(imdsTRN.Files)),' tiles in the training set']);
                end
                % optional: export tiles of first xval run
                if ir==1 && isfield(cnst,'exportTiles') && cnst.exportTiles 
                    exportTiles(cnst,imdsTRN,imdsTST);
                end
                % train the network
                [~,partitionPredictions{ir}] = trainMyNetwork(myNet,imdsTRN,imdsTST,cnst,hyperprm);
                % if holdout mode is active, then stop xval after 1st run
                if ir == 1 && isfield(cnst,'xvalmode') && strcmp(cnst.xvalmode,'holdout')
                    disp('-- train in holdout mode = use only first xval run');
                    break
                end
            end
            % combine stats
            resultCollection.blockStats   = concatenatePredictions(partitionPredictions);
            resultCollection.patientStats = predictions2performance(resultCollection.blockStats,AnnData,cnst);
        else
            resultCollection.blockStats = [];
            resultCollection.patientStats = []; 
            disp('--- 0-fold-xval - will omit xval');
        end
        if cnst.trainFull % re-train on the full image set for deployment
            disp('training on full set for external validation');
            trainFullTrainingSet = equalizeClasses(allBlocks);
            [finalModel,~] = trainMyNetwork(myNet,trainFullTrainingSet,[],cnst,hyperprm);   
        end
        totalTime = toc(z1);
        if isempty(resultCollection)
            warning('training failed, will skip this target');
        else
            disp('training was successful');
            resultCollection.cnst = cnst;
            resultCollection.hyperprm = hyperprm;
            resultCollection.totalTime = totalTime;
            save(fullfile(cnst.folderName.Dump,[cnst.experimentName,'_lastResult_',cnst.saveFormat,'.mat']),'resultCollection');
            if cnst.trainFull
                save(fullfile(cnst.folderName.Dump,[cnst.experimentName,'_lastModel_',cnst.saveFormat,'.mat']),'finalModel'); 
            end
        end
    end
    
    catch exception % catch errors during training and stop or forgive
       if isfield(cnst,'forgiveError') && cnst.forgiveError
           warning('TRAINING FAILED, forgiving error');
       else
           rethrow(exception); % rethrow the error
       end
    end
    
    clear resultCollection allBlocksLabeled AnnData finalModel % clean up
end
end
