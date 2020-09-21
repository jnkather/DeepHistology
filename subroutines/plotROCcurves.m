% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this script will plot the ROC curve 

function resultCollection = plotROCcurves(resultCollection,cnst,currE)
        figure
           % tiledlayout('flow','tilespacing','compact')
           if numel(resultCollection.patientStats)>1
               warning('dirty workaround for learning curve experiment');
               resultCollection.patientStats = resultCollection.patientStats{end};
           end
            allvars = fieldnames(resultCollection.patientStats.FPR_TPR.Plot.X);  
            for ja = 1:numel(allvars)
                X = resultCollection.patientStats.FPR_TPR.Plot.X.(allvars{ja});
                Y = resultCollection.patientStats.FPR_TPR.Plot.Y.(allvars{ja});
                
                try
                T = resultCollection.patientStats.FPR_TPR.Plot.T.(allvars{ja});
                catch
                    warning('undefined threshold in ROC');
                    T = 0*X(:,1);
                end
            
                xconf = [X(:,1);flipud(X(:,1))];
                yconf = [Y(:,2);flipud(Y(:,3))];
                
                if cnst.firstAsLargePlot   
                    hold on
                    grid on
                    %pat = patch(xconf,yconf,[.6 .6 .6]);
                    %pat.EdgeColor = 'w';
                    %plot([0 1],[0,1],'LineWidth',1,'Color',[0.5 0 0]);
                    pp = plot(X(:,1),Y(:,1),'LineWidth',1,'Color','k');
                    axis equal
                     xlim([0,1])
                     ylim([0,1])
                     title([dictionaryReplace(strrep(allvars{ja},'_','-'),{'nonMSIH','MSS/MMRp';'MSIH','MSI/MMRd'}),newline]);
                     xlabel('FPR (1-specificity)');
                     ylabel('TPR (sensitivity)');
                      pp.Color = [0 0 0]; %pp(2).Color = [.4 .4 .4];pp(3).Color = [.4 .4 .4];
                    set(gca,'FontSize',cnst.plotFontSize);
                    set(gca,'XTick',cnst.axTicksFine);
                    set(gca,'YTick',cnst.axTicksFine);
                     set(gcf,'Color','w');
                    drawnow
                    if cnst.doPrint
                        print(['./output_figure/',strrep(char(currE),'_','-'),'_PANEL001.pdf'],'-dpdf','-bestfit');
                    end
                    
                     figure % go to next
                    cnst.firstAsLargePlot = false; 
                end
                
                if cnst.plotSpec
                fpr = getROCstats(X(:,1),Y(:,1),2,0.99);
                disp(['-- ',resultCollection.cnst.baseName,' - ',strrep(allvars{ja},'_','-'),newline,...
                      'at 0.99 SENS, SPEC is ',num2str(1-fpr(1))]);
                fpr = getROCstats(X(:,1),Y(:,1),2,0.98);
                disp(['-- ',resultCollection.cnst.baseName,' - ',strrep(allvars{ja},'_','-'),newline,...
                      'at 0.98 SENS, SPEC is ',num2str(1-fpr(1))]);  
                fpr = getROCstats(X(:,1),Y(:,1),2,0.95);
                disp(['-- ',resultCollection.cnst.baseName,' - ',strrep(allvars{ja},'_','-'),newline,...
                      'at 0.95 SENS, SPEC is ',num2str(1-fpr(1))]);
                end
                
                subplot(2,numel(allvars),ja)
                %nexttile
                hold on
                grid on
               
                %errorbar(X(:,1),Y(:,1),Y(:,1)-Y(:,2),Y(:,3)-Y(:,1),'Color',[.4 .4 .4]);

                pat = patch(xconf,yconf,[.6 .6 .6]);
                pat.EdgeColor = 'w';
                plot([0 1],[0,1],'LineWidth',1,'Color',[0.5 0 0]);
                pp = plot(X(:,1),Y(:,1),'LineWidth',1,'Color','k');
                
                if cnst.plotThreshold
                    plot(X(:,1),T(:,1),'LineWidth',1.3,'Color','b');
                end
                
                if cnst.plotGoldStandardMSI
                    plot(1-0.88,0.94,'rx','MarkerSize',8,'LineWidth',2)
                    drawnow
                end
                
                axis equal
                 xlim([0,1])
                 ylim([0,1])
                 title(dictionaryReplace(strrep(allvars{ja},'_','-'),{'nonMSIH','MSS/MMRp';'MSIH','MSI/MMRd'}));
                 xlabel('FPR (1-specificity)');
                 ylabel('TPR (sensitivity)');
                  pp.Color = [0 0 0]; %pp(2).Color = [.4 .4 .4];pp(3).Color = [.4 .4 .4];
                set(gca,'FontSize',cnst.plotFontSize);
                set(gca,'XTick',cnst.axTicks);
                set(gca,'YTick',cnst.axTicks);
                subplot(2,numel(allvars),ja+numel(allvars))
                %nexttile
                % calculate the prevalence of this level
                try
                    prevalence = resultCollection.patientStats.nPats.(allvars{ja})/sum(struct2array(resultCollection.patientStats.nPats));
                catch
                    warning('struct2array bug... workaround...');
                    struct2array = @(temp) myStruct2array(temp);  
                    prevalence = resultCollection.patientStats.nPats.(allvars{ja})/sum(struct2array(resultCollection.patientStats.nPats));
                end
                
                hold on
                X = resultCollection.patientStats.PRE_REC.Plot.X.(allvars{ja});
                Y = resultCollection.patientStats.PRE_REC.Plot.Y.(allvars{ja});
                try
                T = resultCollection.patientStats.PRE_REC.Plot.T.(allvars{ja});
                catch
                    warning('undefined threshold in ROC');
                    T = 0*X(:,1);
                end
                %errorbar(X(:,1),Y(:,1),Y(:,1)-Y(:,2),Y(:,3)-Y(:,1),'Color',[.4 .4 .4]);
                xconf = [X(:,1);flipud(X(:,1))];
                yconf = [Y(:,2);flipud(Y(:,3))];
                yconf(isnan(yconf)) = mean(yconf,'omitnan');
                
                pat = patch(xconf,yconf,[.6 .6 .6]);
                pat.EdgeColor = 'none';
                plot([0 1],[prevalence,prevalence],'LineWidth',1,'Color',[0.5 0 0]);
                pp = plot(X(:,1),Y(:,1),'LineWidth',1,'Color','k');
                if cnst.plotThreshold
                    plot(X(:,1),T(:,1),'LineWidth',1.3,'Color','b');
                end
                %pp = plot(X(:,1),Y(:,2),'LineWidth',1,'Color',[.4 .4 .4]);
                %pp = plot(X(:,1),Y(:,3),'LineWidth',1,'Color',[.4 .4 .4]);
                axis square
                grid on
                set(gca,'XTick',cnst.axTicks);
                if cnst.scaleYprerec
                    axis tight;
                    xx = axis;
                    linspace(min(xx),max(xx),numel(get(gca,'XTick')))
                   set(gca,'YTick',round(linspace(round(xx(3),2),round(xx(4),2),3),2));
                else
                 xlim([0,1])
                 ylim([0,1])
                 set(gca,'YTick',cnst.axTicks);
                end
                 title('');%dictionaryReplace(strrep(allvars{ja},'_','-'),{'nonMSIH','MSS/MMRp';'MSIH','MSI/MMRd'}));
                 xlabel('Recall');       % FIXED on 13 Jun 2020
                 ylabel('Precision');    % FIXED on 13 Jun 2020qw
                %   pp.Color = [0 0 0]; %pp(2).Color = [.4 .4 .4];pp(3).Color = [.4 .4 .4];
                set(gca,'FontSize',cnst.plotFontSize);
                
            end
             set(gcf,'Color','w');
             suptitle(strrep(char(currE),'_','-'));
             drawnow
             
             if cnst.doPrint
                print(['./output_figure/',strrep(char(currE),'_','-'),'.pdf'],'-dpdf','-bestfit');
             end

end