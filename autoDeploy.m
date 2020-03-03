% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this is the main function to apply a trained deep 
% neural network to another cohort 

function autoDeploy(varargin)
addpath(genpath('./subroutines/'));      % add dependencies
iPrs = getDefaultInputParser(varargin);  % get input parser, define default values
gpuDevice(iPrs.Results.gpuDev);          % select GPU device (Windows only)
cnst = loadExperiment(iPrs.Results.experiment); % load experiment from JSON

disp('-- starting DEPLOYMENT job with these input (or default) settings:');
dispAllFields(iPrs.Results);
cnst = copyfields(cnst,iPrs.Results,fieldnames(iPrs.Results)); % apply input
[cnst,fCollect] = initializeDeepImagePipeline(cnst);  % initialize
hyperprm = getDeepHyperparameters(cnst.hyper);        % load DL hyperparams
dispAllFields(cnst);        % display all constants on console
dispAllFields(hyperprm);    % display all hyperparameters on console

disp('-- loading the trained model');
if ~isempty(cnst.trainedModelFolder) && ~isempty(cnst.trainedModelID)
    load(fullfile(cnst.trainedModelFolder,[cnst.trainedModelID,'_lastModel_v6.mat']),'finalModel');
else
    error(['for deployment, please specify a trained model ',...
        'using options trainedModelFolder and trainedModelID']);
end

disp('--- done. starting prediction');

for ti = 1:numel(cnst.allTargets) 
     rng('shuffle');
    cnst.annotation.targetCol = char(cnst.allTargets{ti}); 
    cnst.experimentName = [cnst.baseName,'-',randseq(5,'alphabet','AA'),'_',cnst.annotation.targetCol];
    
    disp([newline,newline,'#################',newline,newline,...
        'starting new experiment: ',cnst.annotation.targetCol ]);
    
    z1 = tic;
     % load image tiles and assign a label to each tile
     allBlocks = copy(fCollect.Blocks);
     AnnData = getAnnotationData(cnst); 
     [allBlocks, AnnData, ~] = assignTileLabel(allBlocks,AnnData,cnst);
          
    partitionPredictions = deployModel(cnst,hyperprm,finalModel,allBlocks);
    
    % combine stats
    resultCollection{ti}.blockStats = concatenatePredictions(partitionPredictions);
    resultCollection{ti}.patientStats = predictions2performance(...
        resultCollection{ti}.blockStats,AnnData,cnst);

    disp('finished deploy function');
    % add some more results
    totalTime = toc(z1);
    resultCollection{ti}.cnst = cnst;
    resultCollection{ti}.hyperprm = hyperprm;
    resultCollection{ti}.totalTime = totalTime;

    save(fullfile(cnst.folderName.Dump,[cnst.experimentName,'_lastResult_v6.mat']),'resultCollection');

end
end
