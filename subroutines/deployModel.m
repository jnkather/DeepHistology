
function stats = deployModel(cnst,hyperprm,finalModel,imdsTST,AnnData)

  externaltest_AUG = ...
      augmentedImageDatastore(finalModel.Layers(1).InputSize(1:2),imdsTST); 
  externaltest_AUG.MiniBatchSize = hyperprm.MiniBatchSize;
  disp('starting prediction...');
  
  [stats.blockStats.PLabels,stats.blockStats.Scores] = classify(finalModel, ...
            externaltest_AUG, 'ExecutionEnvironment',hyperprm.ExecutionEnvironment);
  disp('finished prediction.');
  stats.blockStats.Accuracy = mean(stats.blockStats.PLabels == imdsTST.Labels);
  stats.blockStats.BlockNames = imdsTST.Files;
  
  if isfield(cnst,'saveTopTiles') & cnst.saveTopTiles>0
        saveTopTiles(stats,cnst,finalModel,imdsTST);
  end

end
