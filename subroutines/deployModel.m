% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this function will use a trained model and deploy 
% it to an imageDatastore 



function stats = deployModel(cnst,hyperprm,finalModel,imdsTST)

  externaltest_AUG = ...
      augmentedImageDatastore(finalModel.Layers(1).InputSize(1:2),imdsTST); 
  externaltest_AUG.MiniBatchSize = hyperprm.MiniBatchSize;
  disp('starting prediction...');
  
  [stats.blockStats.PLabels,stats.blockStats.Scores] = classify(finalModel, ...
            externaltest_AUG, 'ExecutionEnvironment',hyperprm.ExecutionEnvironment,...
            'MiniBatchSize',hyperprm.MiniBatchSize);
        
  disp('finished prediction.');
  stats.blockStats.Accuracy = mean(stats.blockStats.PLabels == imdsTST.Labels);
  stats.blockStats.BlockNames = imdsTST.Files;
  
  if isfield(cnst,'saveTopTiles') && cnst.saveTopTiles>0
        saveTopTiles(stats,cnst,finalModel,imdsTST);
  end

end
