clear all, close all, clc

folder = 'K:\MUCBERN-CRCDX\SVS only\H&E\'; % 'J:\LEEDS-SMALLBOWEL-DX\SVSonly'; % 'N:\DUESSEL-CRC-DX'
outdir = 'J:\ThumbsOutMUCBERN\';
mkdir(outdir)

allFiles = dir(folder);


for i=3:numel(allFiles)
    if i==3 || mod(i,15)==0
        drawnow
        figure
        set(gcf,'Color','w')
        tiledlayout('flow','TileSpacing','compact')
    end
    try
    currFile = allFiles(i).name;
    currInfo = imfinfo(fullfile(folder,currFile));
    numChannels = numel(currInfo);
    thumbImg = histeq(imread(fullfile(folder,currFile),numChannels-1));
    imagesc(thumbImg);
    axis equal tight off
    title(currFile)
    nexttile
    imwrite(thumbImg,fullfile(outdir,[currFile,'.png']));
    end
    
end
