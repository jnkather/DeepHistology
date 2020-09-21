% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this is used for visualization of prediction performance

function forest(IDs,vmed,vlow,vhigh,mytitle,fontSi)

    % flip all values
    IDs = flipud(IDs);
    vmed = flipud(vmed);
    vlow = flipud(vlow);
    vhigh = flipud(vhigh);
    
    ebline = 1;         % base line width
    circsize = 120;     % base circle size
    xlow = 0;        % x axis lower limit
   % fontSi = 18;      % font size
    fontNa = 'Arial'; % font name
    fontWe = 'normal'; % font weight
    
    ymax = numel(IDs);
    
    hold on
    
    plot([0.5 0.5],[0 ymax+1],'k','LineWidth',ebline);
    
    % x grid
    xes = xlow:0.05:1;
    plot([xes;xes],[0 ymax+1],'color',0.85*[1 1 1],'LineWidth',ebline*0.75);
    
    % y grid
    yes = 1:ymax;
    plot([xlow-0.05,1],[yes;yes],'color',0.85*[1 1 1],'LineWidth',ebline*0.75);
    
    eb = errorbar(vmed,1:ymax,...
        vmed-vlow,...
        vhigh-vmed,'horizontal','k.','LineWidth',ebline*1.2);
    
    sc = scatter(vmed,1:ymax,circsize,'k','filled');
    
    %ntext = strrep(strcat(repmat({'n='},ymax,1),cellstr(num2str(vnum))),' ','  ');
    tx = @(vin) cellstr(num2str(vin,'%.3f'));
    auctext = strcat(repmat({''},ymax,1),tx(vmed),{' ['},tx(vlow),{','},tx(vhigh),{']'});
    % add n numbers
%     text(xlow+0.01+0*(1:ymax),1:ymax,... %myT.AUROC_hig(targets)+0.01
%         ntext,'VerticalAlignment','middle','FontSize',fontSi,'FontName',fontNa,...
%         'BackgroundColor','w','FontWeight',fontWe);
    % add auc
    text(1.01+0*(1:ymax),1:ymax,... 
        auctext,...
        'VerticalAlignment','middle','HorizontalAlignment','left','FontSize',fontSi,...
            'FontName',fontNa,'FontWeight',fontWe);

    set(gca,'YTick',1:ymax);
    set(gca,'YTickLabel',IDs);

    set(gca,'XTick',xlow:0.1:1);
    set(gca,'XTickLabel',(num2str((xlow:0.1:1)','%.1f')));
    set(gca,'FontSize',fontSi);
    set(gca,'FontName',fontNa);
    set(gca,'FontWeight',fontWe);
    xlim([xlow-0.05,1.2]);
    eb.LineWidth = ebline;

    sc.MarkerEdgeColor = 'k';
   
    set(gca,'TickLength',[0 0]);
    xlabel(['AUROC +/- confidence interval']);

    ylim([0,ymax+1]);
    set(gca,'box','off');
    
    set(gcf,'Color','w');
    
    title(mytitle);
    %grid('on');
    
    
end
