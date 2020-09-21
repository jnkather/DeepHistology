% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this is used to visualize predictions as forest plots
% 
% this function will be deprecated in future releases,
% please use forest() which is more generic

function plotForestChartSub(currT,cnst,currTitle)

    ymax = size(currT,1);
    
    plot([0.5 0.5],[1 ymax],'k','LineWidth',cnst.ebline*0.5);
    hold on
    eb = errorbar(currT.AUROC_avg,1:ymax,...
        currT.AUROC_avg-currT.AUROC_low,...
        currT.AUROC_hig-currT.AUROC_avg,'horizontal','k.','LineWidth',cnst.ebline);
    
    sc = scatter(currT.AUROC_avg,1:ymax,cnst.circleSize,currT.meanAUC,'filled');
    colormap([1,1,1;(brewermap(255,'YlGnBu'))]);
    
    stars = cellstr(num2str(currT.pFDRglobal)); % preallocate
    stars(currT.pFDRglobal<=cnst.sigThreshold) = {'*'};
    stars(currT.pFDRglobal> cnst.sigThreshold) = {' '};
    ntext = strrep(strcat(repmat({'n='},ymax,1),cellstr(num2str(currT.nPat))),' ','  ');
    auctext = strrep(strcat(repmat({''},ymax,1),cellstr(num2str(round(currT.AUROC_avg,2)))),' ','');
    % add n numbers
    text(cnst.xlim(1)+0.01+0*(1:ymax),1:ymax,... %currT.AUROC_hig+0.01
        ntext,'VerticalAlignment','middle','FontSize',cnst.fontSizeAlternate,'FontName',cnst.fontName,'BackgroundColor','w','FontWeight',cnst.fontWeight);
    % add auc
    text(1.01+0*(1:ymax),1:ymax,... %currT.AUROC_hig+0.01
        strcat(auctext,stars),...
        'VerticalAlignment','middle','HorizontalAlignment','left','FontSize',cnst.fontSize,'FontName',cnst.fontName,'FontWeight',cnst.fontWeight);

    set(gca,'YTick',1:ymax);
    
    % prepare IDs
    currIDs = strrep(strcat(currT.varN,'-',currT.levelNames),'_','-');
    currIDs = dictionaryReplace(currIDs, getDefaultDictionary('plot'));
    
    set(gca,'YTickLabel',currIDs);

    set(gca,'XTick',cnst.xticks);
    set(gca,'XTickLabel',cnst.xticks);
    set(gca,'FontSize',cnst.fontSize);
    set(gca,'FontName',cnst.fontName);
    set(gca,'FontWeight',cnst.fontWeight);
    xlim(cnst.xlim);
    eb.LineWidth = 1;
    %sc.CData = [0 0 0];
    sc.MarkerEdgeColor = 'k';
    caxis(cnst.caxis);
    %colorbar('eastoutside');
    set(gca,'TickLength',[0 0]);
    xlabel('AUROC');

    ylim([0,cnst.maxYCats+1]);
    set(gca,'box','off');
    title(dictionaryReplace(currTitle,getDefaultDictionary('tumor_types')));
    
    
    
end