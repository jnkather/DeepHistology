% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this is used to create a montage of image tilse and save it 

function writeTopTiles(dcollect,cnst,currE)
    
    figure;
    pause(0.00001);
    frame_h = get(handle(gcf),'JavaFrame');
    set(frame_h,'Maximized',1);
    
    allClass = fieldnames(dcollect);
    for i=1:numel(allClass)
        subplot(1,numel(allClass),i)
        currClass = allClass{i};
        imgname = fullfile(cnst.folderName.Dump,[char(currE),'---',currClass,'_lastMontage.png']);
        img = montage(dcollect.(currClass).TileNames,'BorderSize',[5 5],'BackgroundColor','w');
        set(gcf,'Color','w');
        title(strrep([char(currE),'---',currClass],'_','-'));
        drawnow
        
        if cnst.doPrint
            disp(['-- writing montage to ',imgname]);
           imwrite(img.CData,imgname);
        end
    end

end