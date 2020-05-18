function copyFilesByLabel(myImds,tFolder)

       allLabels = unique(myImds.Labels);
        for i = 1:numel(allLabels)
            currLabel = allLabels(i);
            currTargetFolder = fullfile(tFolder,char(cellstr(currLabel)));
            mkdir(currTargetFolder);
            sourceFiles = myImds.Files(myImds.Labels == currLabel);
            for j = 1:numel(sourceFiles)
                copyfile(sourceFiles{j},currTargetFolder);
            end
        end
        
end


