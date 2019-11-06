% JN Kather 2019

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
    disp(['default network image input size is: ',num2str(preNet.imageInputSize)]);
    disp(['--- I will make the images this size by: ',cnst.blocks.resizeMethod]);
    internalTRN_AUG = augmentedImageDatastore(preNet.imageInputSize,imdsTRN,...
        'DataAugmentation',trainingAugmenter,'OutputSizeMode',cnst.blocks.resizeMethod);
    opts = getTrainingOptions(hyperprm,[]);
    
    t = tic;
    postNet = trainNetwork(internalTRN_AUG, preNet.lgraph, opts);
    stats.trainTime = toc(t);
    
    if ~isempty(imdsTST) % evaluate test set
        disp('starting to evaluate test set');
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
