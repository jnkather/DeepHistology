% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this is an auxiliary function to plot violin charts 

function plotViolinChartSub(currT,cnst,currTitle)

    mylog = @(vin) -log10((vin));

    violin(min(cnst.maxYplotSig,mylog(currT.pFDRglobal)),...
        'facecolor',[.5 .5 .5],'edgecolor',[1 1 1],'bw',0.5);
    hold on
    
    plot(cnst.xlim,repmat((mylog(cnst.sigThreshold)),2,1),...
        'k','LineWidth',cnst.ebline*0.5); 
    hold on
    
    
    
    xlabel('')
    ylabel('p')
    
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
    set(gca,'XTick',[]);
    set(gca,'XTickLabel',[]);
    
    set(gca,'YTick',1:cnst.maxYplotSig);
    set(gca,'YTickLabel',cellstr("1e-"+(1:cnst.maxYplotSig)'));
    axis square

end
