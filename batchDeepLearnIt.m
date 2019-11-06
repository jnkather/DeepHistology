% JN Kather Aachen / Chicago 2019
% main script, see readme

%% Header
clear variables, format compact, close all; clc % clean up
setenv CUDA_VISIBLE_DEVICES 0 % use only first GPU
gpuDevice(1);
addpath(genpath('./subroutines/'));  % add dependencies

% prepare all hyperparameters and load input files
cnst = loadExperiment('hnsc-hpv-6000');
hyperprm = getDeepHyperparameters('default');
[cnst,fCollect] = initializeDeepImagePipeline(cnst); % initialize

% overwrite some settings
cnst.trainFull = false; % after xval, train on the full set for ext validation
cnst.modelTemplate = 'shufflenet512'; % choose model template

% DEBUG
cnst.blocks.maxBlockNum = 500;
hyperprm.MaxEpochs = 4;
% cnst.subsetTargets.by = 'Country'; 
% cnst.subsetTargets.level = 'Germany';

% start to iterate all targets
for ti = 1:numel(cnst.allTargets)
    
    rng('shuffle');
    cnst.annotation.targetCol = char(cnst.allTargets{ti}); 
    cnst.experimentName = [cnst.baseName,'-',randseq(5,'alphabet','AA'),'_',cnst.annotation.targetCol];
    
    disp([newline,newline,'#################',newline,newline,...
        'starting new experiment: ',cnst.annotation.targetCol ]);
    
    z1 = tic;
    % read target data for this variable
    AnnData = getAnnotationData(cnst); 
    if isempty(AnnData)
        warning('invalid annotation data, will skip this target')
    else 
        % load image tiles and assign a label to each tile
        allBlocks = copy(fCollect.Blocks);
        [allBlocks, AnnData, unmatchedBlocks] = assignTileLabel(allBlocks,AnnData,cnst);
        % load the pretrained network
        myNet = getAndModifyNet(cnst,hyperprm,numel(unique(allBlocks.Labels))); 
        % partition the cohort for cross validation, then train the network! 
        % split dataset in train-test and do the training
        disp(['-- will start a ',num2str(cnst.foldxval),' fold cross validated experiment']);
        [imdsContainer,AnnData] = splitImdsForXVal(allBlocks,AnnData,cnst);
        if ~isempty(imdsContainer)
            for ir = 1:cnst.foldxval
                disp(['--- starting crossval experiment ',num2str(ir)]);            
                % create image datastore for test set in this run
                imdsTST = copy(imdsContainer{ir});
                disp(['--- there are ',num2str(numel(imdsTST.Files)),' blocks in the test set']);
                % create image datastore for training set in this run
                imdsTRN = copy(allBlocks);
                imdsTRN.Files(ismember(imdsTRN.Files,imdsTST.Files)) = []; % remove all test set files from the training set
                disp(['---- there are ',num2str(numel(imdsTRN.Files)),' blocks in the training set']);
                if cnst.undersampleTrainingSet
                    imdsTRN = equalizeClasses(imdsTRN); % undersample training set
                    disp(['---- after undersampling, there are ',num2str(numel(imdsTRN.Files)),' blocks in the training set']);
                end
                [~,partitionPredictions{ir}] = trainMyNetwork(myNet,imdsTRN,imdsTST,cnst,hyperprm);  
            end

            % combine stats
            resultCollection.blockStats = concatenatePredictions(partitionPredictions);
            resultCollection.patientStats = predictions2performance(resultCollection.blockStats,AnnData,cnst);

            % now re-train the classifier on the full image set so that it can
            % be deployed on another validation data set
            if cnst.trainFull
                disp('training on full set for external validation');
                [finalModel,~] = trainMyNetwork(myNet,equalizeClasses(allBlocks),[],cnst,hyperprm);   
            end
        else
            warning('empty imds container');
            resultCollection = [];
        end
        totalTime = toc(z1);
        if isempty(resultCollection)
            warning('training failed, will skip this target');
        else
            disp('training was successful');
            resultCollection.cnst = cnst;
            resultCollection.hyperprm = hyperprm;
            resultCollection.totalTime = totalTime;
            save(fullfile(cnst.folderName.Dump,[cnst.experimentName,'_lastResult_v6.mat']),'resultCollection');
            if exist('finalModel','var')
                save(fullfile(cnst.folderName.Dump,[cnst.experimentName,'_lastModel_v6.mat']),'finalModel'); 
            end
        end
    end
    clear resultCollection allBlocksLabeled AnnData % clean up
end