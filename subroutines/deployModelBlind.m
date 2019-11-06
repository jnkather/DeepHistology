
function outputSummary = deployModelBlind(cnst,hyperprm,finalModel,allBlocksLabeled)

  test_AUG = augmentedImageDatastore(finalModel.Layers(1).InputSize(1:2),allBlocksLabeled); 
  disp('starting prediction...');
  test_AUG.MiniBatchSize = hyperprm.MiniBatchSize;
  aa = activations(finalModel,test_AUG,'classoutput','ExecutionEnvironment','gpu');
  
  [stats.blockStats.PLabels,stats.blockStats.Scores] = classify(finalModel, ...
            test_AUG, 'ExecutionEnvironment',hyperprm.ExecutionEnvironment);
  disp('finished prediction.');
  
  if isfield(cnst,'saveTopTiles') & cnst.saveTopTiles>0
       disp('-- will start to save the top tiles');
       for i = 1:size(stats.blockStats.Scores,2) % for each category
           disp(['--- starting category ',num2str(i)]);
           targetDir = fullfile('./output_blocks/',cnst.trainedModelID,'/',cnst.ProjectName,'/',char(cellstr(finalModel.Layers(end).Classes(i))));
           mkdir(targetDir);
           [uu,ui] = sort(stats.blockStats.Scores(:,i),'descend');
           for j = 1:cnst.saveTopTiles
               montageData(:,:,:,j) = imread(char(allBlocksLabeled.Files(ui==j)));
               %copyfile(sourceImage,targetDir);
           end
           m = montage(montageData,'ThumbnailSize',[cnst.blocks.sizeOnImage,cnst.blocks.sizeOnImage]);
           imwrite(m.CData,[targetDir,'/lastMontage_512.png']);
       end
  end
  
  outputSummary.allAUC = [];
  outputSummary.stats = [];
  outputSummary.stats.blockStats.blockNames = allBlocksLabeled.Files;
  outputSummary.stats.blockStats.TLabels = [];
  outputSummary.stats.blockStats.targetCategories = cellstr(finalModel.Layers(end).Classes);
  
end
