% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this is an auxiliary function to plot volcano charts 

function plotVolcanoChartSub(currT,cnst,currTitle,violincolor)

    

    violin(min(cnst.maxYplotSig,cnst.mylog(currT.pFDRglobal)),...
        'facecolor',violincolor,'edgecolor',[1 1 1],'bw',cnst.violinBW);
    hold on
    
    plot(cnst.xlim,repmat((cnst.mylog(cnst.sigThreshold)),2,1),...
        'k','LineWidth',cnst.ebline*0.5); 
    hold on
    
    sc = scatter(max(min(cnst.xlim),currT.AUROC_avg),...
            min(cnst.maxYplotSig,cnst.mylog(currT.pFDRglobal)),...
        75,currT.meanAUC,'filled','LineWidth',cnst.ebline*0.5,...
        'MarkerEdgeColor','k');
    
    if cnst.plotTextVolcano
    currT.cleanVarN = dictionaryReplace(strrep(currT.varN,'_','-'),getDefaultDictionary('plot'));
    sigs = find(currT.pFDRglobal<=cnst.sigThreshold);
    hold on
    for i=1:numel(sigs)
        text(currT.AUROC_avg(sigs(i)),...
            0.025*randn()+min(cnst.maxYplotSig,cnst.mylog(currT.pFDRglobal(sigs(i)))),...
            currT.cleanVarN(sigs(i)));
    end
    end
    
    xlabel('AUROC')
    ylabel('FDR-corrected p-value')
    
    title(currTitle);
    caxis(cnst.caxis);
    colormap([1,1,1;(brewermap(255,'YlGnBu'))]);
    xlim(cnst.xlim);
    ylim([0,cnst.maxYplotSig+1]);
    
    set(gca,'box','off');
    title(dictionaryReplace(currTitle,getDefaultDictionary('tumor_types')));
    set(gca,'FontSize',cnst.fontSize);
    set(gca,'FontName',cnst.fontName);
    set(gca,'FontWeight',cnst.fontWeight);
    set(gca,'XTick',cnst.xticks);
    set(gca,'XTickLabel',cnst.xticks);
    
    set(gca,'YTick',1:cnst.maxYplotSig);
    set(gca,'YTickLabel',cellstr("1e-"+(1:cnst.maxYplotSig)'));
    axis square
    

end
