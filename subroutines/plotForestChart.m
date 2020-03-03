% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this is used for visualization of prediction performance

function plotForestChart(currIDs,targets,myT,cnst,myTitle)

    ymax = numel(targets);
    %group = myT.group(ui);
    
    plot([0.5 0.5],[1 ymax],'k','LineWidth',cnst.ebline*0.5);
    hold on
    %plot([0.75 0.75],[1 sum(currMask)],'k-','LineWidth',0.5);
    eb = errorbar(myT.AUROC_avg(targets),1:ymax,...
        myT.AUROC_avg(targets)-myT.AUROC_low(targets),...
        myT.AUROC_hig(targets)-myT.AUROC_avg(targets),'horizontal','k.','LineWidth',cnst.ebline);
    
    sc = scatter(myT.AUROC_avg(targets),1:ymax,cnst.circleSize,myT.meanAUC(targets),'filled');
    colormap([1,1,1;(brewermap(255,'YlGnBu'))]);
    
    stars = strrep(strrep(cellstr(num2str(myT.fdrPval(targets)<1)),'1',' '),'0',' '); % preallocate
    stars(myT.fdrPval(targets)<cnst.sigThreshold) = {'*'};
    ntext = strrep(strcat(repmat({'n='},ymax,1),cellstr(num2str(myT.nPat(targets)))),' ','  ');
    auctext = strrep(strcat(repmat({''},ymax,1),cellstr(num2str(round(myT.AUROC_avg(targets),2)))),' ','');
    % add n numbers
    text(cnst.xlim(1)+0.01+0*(1:ymax),1:ymax,... %myT.AUROC_hig(targets)+0.01
        ntext,'VerticalAlignment','middle','FontSize',cnst.fontSizeAlternate,'FontName',cnst.fontName,'BackgroundColor','w','FontWeight',cnst.fontWeight);
    % add auc
    text(1.01+0*(1:ymax),1:ymax,... %myT.AUROC_hig(targets)+0.01
        strcat(auctext,stars),...
        'VerticalAlignment','middle','HorizontalAlignment','left','FontSize',cnst.fontSize,'FontName',cnst.fontName,'FontWeight',cnst.fontWeight);

    set(gca,'YTick',1:ymax);
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
    caxis([max(0.5,cnst.lowerCutoffAUC-0.01),0.9]);
    %colorbar('eastoutside');
    set(gca,'TickLength',[0 0]);
    xlabel('AUC');


    ylim([0,cnst.maxYCats+1]);
    set(gca,'box','off');
    title(dictionaryReplace(myTitle,getDefaultDictionary('tumor_types')));
    
end