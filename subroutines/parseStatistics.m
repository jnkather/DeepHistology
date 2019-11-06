function res = parseStatistics(currStats) 

    res.varN = currStats.cnst.annotation.targetCol;
    if isfield(currStats.cnst,'subsetTargets')
        res.proj = strcat(currStats.cnst.subsetTargets.by,'-',currStats.cnst.subsetTargets.level);
    else
        res.proj = 'all';
    end
    
    levelNames = fieldnames(currStats.patientStats.FPR_TPR.AUC)';
    
    for nl = 1:numel(levelNames) % iterate levels (categories)
        outTable.levelNames{nl} = levelNames{nl};
        outTable.nPat(nl) = currStats.patientStats.nPats.(levelNames{nl});

        % extract AUC of standard ROC (FPR vs TPR)
        outTable.AUROC_avg(nl) = round(currStats.patientStats.FPR_TPR.AUC.(levelNames{nl})(1),3);
        outTable.AUROC_low(nl) = round(currStats.patientStats.FPR_TPR.AUC.(levelNames{nl})(2),3);
        outTable.AUROC_hig(nl) = round(currStats.patientStats.FPR_TPR.AUC.(levelNames{nl})(3),3);

        % extract AUC of precision-recall curve
        outTable.AUCPR_avg(nl) = round(currStats.patientStats.PRE_REC.AUC.(levelNames{nl})(1),3);
        outTable.AUCPR_low(nl) = round(currStats.patientStats.PRE_REC.AUC.(levelNames{nl})(2),3);
        outTable.AUCPR_hig(nl) = round(currStats.patientStats.PRE_REC.AUC.(levelNames{nl})(3),3);
    end 
    outTable.fracPat = outTable.nPat / sum(outTable.nPat);
    res.outT = struct2table(transposeStruct(outTable));
    disp([newline,'this is the result table ',newline]);
    disp(res.outT)
    disp([newline,'*********',newline]);
    
%     % plot ROCs
%     if cnst.doPlot
%         figure
%         for itx = 1:nXval 
%             allLevNames = fieldnames(currResultCollection.stats{itx}.patientStats.AUC);
%             for ity = 1:nLev
%                 subplot(1,nLev,ity)
%                 hold on
%                 plot([0 1],[0,1],'k')
%                 plot(plotData(itx,ity).X,plotData(itx,ity).Y,'LineWidth',2);
%                 axis equal square
%                 set(gca,'FontSize',20);
%                 set(gca,'FontName','Calibri');
%                 title(strrep([allLevNames{ity},' N=',num2str(res.outT.Npats(ity)),newline],'_','-'));
%             end           
%         end
%         set(gcf,'Color','w')
%         suptitle(strrep([experimentName,' ' , res.proj],'_','-'));
%     end
     
end