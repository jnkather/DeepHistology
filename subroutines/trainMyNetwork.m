% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this function is used to train the actual neural network 

function [postNet,stats] = trainMyNetwork(preNet,imdsTRN,imdsTST,cnst,hyperprm)          
    rng('default');
    
    if isempty(imdsTST)
    disp([newline,'-- starting the training with ',num2str(numel(imdsTRN.Files)),...
        ' training blocks and  NO test blocks']);
    else
    disp(['-- starting the training with ',num2str(numel(imdsTRN.Files)),...
        ' training blocks and ',num2str(numel(imdsTST.Files)),' test blocks']);
    end
    
    % prepare data augmenter
    trainingAugmenter = imageDataAugmenter('RandXReflection',true,'RandYReflection',true);
    disp(['---- network image input size is: ',num2str(preNet.imageInputSize)]);

    if isfield(cnst,'valSet')&&~isempty(cnst.valSet)&&cnst.valSet<1&&cnst.valSet>0
        disp(['-- will chop off a validation set (',num2str(cnst.valSet),') from training']);
        [imdsVAL,imdsTRN_final] = splitEachLabel(copy(imdsTRN),cnst.valSet,'randomized');
        opts = getTrainingOptions(hyperprm,augmentedImageDatastore(preNet.imageInputSize,imdsVAL));
    else
        disp('-- will NOT use a validation set');
        imdsTRN_final = copy(imdsTRN);
        opts = getTrainingOptions(hyperprm,[]);
    end
    imdsTRN_AUG = augmentedImageDatastore(preNet.imageInputSize,imdsTRN_final,...
        'DataAugmentation',trainingAugmenter,'OutputSizeMode',cnst.blocks.resizeMethod);
    
    t = tic;
    postNet = trainNetwork(imdsTRN_AUG, preNet.lgraph, opts);
    stats.trainTime = toc(t);
    
    if ~isempty(imdsTST) % evaluate test set
        disp('- starting to evaluate test set');
        externalTST_AUG = augmentedImageDatastore(preNet.imageInputSize,imdsTST,...
            'OutputSizeMode',cnst.blocks.resizeMethod); 
        externalTST_AUG.MiniBatchSize = hyperprm.MiniBatchSize;
        [stats.blockStats.PLabels,stats.blockStats.Scores] = classify(postNet, ...
            externalTST_AUG, 'ExecutionEnvironment',hyperprm.ExecutionEnvironment);
        stats.blockStats.Accuracy = mean(stats.blockStats.PLabels == imdsTST.Labels);
        stats.blockStats.BlockNames = imdsTST.Files;
    else % no test set defined, so cannot return any stats
        disp('no test set defined, so cannot return any stats');
        stats.blockStats = [];
    end        
end
