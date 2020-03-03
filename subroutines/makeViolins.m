% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this is an auxiliary visualization script
% assumes that orchestraData and cnst is in the workspace



fn1 = fieldnames(orchestraData);
figure
tiledlayout('flow','TileSpacing','compact');
for i1 = 1:numel(fn1)
    
    nexttile
    xlim([0.4,1.8])
    hold on
    
    currData1 = orchestraData.(fn1{i1});
    title(dictionaryReplace(strrep(fn1{i1},'_','-'),getDefaultDictionary('tumor_types')));
    %title(strrep(fn1{i1},'_','-'));
    fn2 = fieldnames(currData1);
    for i2 = 1:numel(fn2)
        currData2 = currData1.(fn2{i2});
        violin(currData2,'mx',0.3*i2,'facecolor',cnst.colrz(i2,:),...
            'edgecolor',[1 1 1],'bw',cnst.violinBW);
    end
    axis square 
    ylim([0,cnst.maxYplotSig+1]);
    ylabel('FDR-corrected p-value')
    plot(xlim(),repmat((cnst.mylog(cnst.sigThreshold)),2,1),...
        'k','LineWidth',cnst.ebline*0.5); 
    
    set(gcf,'Color','w')
    set(gca,'FontSize',cnst.fontSize);
    set(gca,'FontName',cnst.fontName);
    set(gca,'FontWeight',cnst.fontWeight);
    set(gca,'XTick',[]);
    set(gca,'YTick',1:cnst.maxYplotSig);
    set(gca,'YTickLabel',cellstr("1e-"+(1:cnst.maxYplotSig)'));
    
end
   