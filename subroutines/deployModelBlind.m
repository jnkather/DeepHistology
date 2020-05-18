% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this is similar to DeployModel but is used for cases in 
% which we do not own the target labels of the images (blinded deployment)

function outputSummary = deployModelBlind(hyperprm,finalModel,allBlocksLabeled)

  test_AUG = augmentedImageDatastore(finalModel.Layers(1).InputSize(1:2),allBlocksLabeled); 
  disp('starting prediction...');
  test_AUG.MiniBatchSize = hyperprm.MiniBatchSize;
  %aa = activations(finalModel,test_AUG,'classoutput','ExecutionEnvironment','gpu');
  
  [stats.blockStats.PLabels,stats.blockStats.Scores] = classify(finalModel, ...
            test_AUG, 'ExecutionEnvironment',hyperprm.ExecutionEnvironment);
  disp('finished prediction.');
  
  outputSummary.allAUC = [];
  outputSummary.stats = [];
  outputSummary.stats.blockStats.blockNames = allBlocksLabeled.Files;
  outputSummary.stats.blockStats.PLabels = stats.blockStats.PLabels;
  outputSummary.stats.blockStats.Scores = stats.blockStats.Scores;
  outputSummary.stats.blockStats.TLabels = [];
  outputSummary.stats.blockStats.targetCategories = cellstr(finalModel.Layers(end).Classes);
  
end
