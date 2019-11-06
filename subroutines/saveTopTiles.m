function saveTopTiles(stats,cnst,finalModel,imdsTST)

       disp('-- will start to save the top tiles');
       for i = 1:size(stats.blockStats.Scores,2) % for each category
           disp(['--- starting category ',num2str(i)]);
           targetDir = fullfile('./output_blocks/',cnst.trainedModelID,'/',...
               cnst.ProjectName,'/',char(cellstr(finalModel.Layers(end).Classes(i))));
           mkdir(targetDir);
           [uu,ui] = sort(stats.blockStats.Scores(:,i),'descend');
           for j = 1:cnst.saveTopTiles
               montageData(:,:,:,j) = imread(char(imdsTST.Files(ui==j)));
               %copyfile(sourceImage,targetDir);
           end
           m = montage(montageData,'ThumbnailSize',[cnst.blocks.sizeOnImage,...
               cnst.blocks.sizeOnImage]);
           imwrite(m.CData,[targetDir,'/lastMontage_512.png']);
       end 
       
end