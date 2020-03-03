% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this auxiliary script can plot a confusion matrix

% JN Kather 2018, plot confusion matrix for image classifier

function plotMyConfusion(trueLabels,predictedLabels)

allgroups = cellstr(unique(trueLabels));
figure(),imagesc(confusionmat(trueLabels,predictedLabels));
xlabel('true'),ylabel('predicted');
set(gca,'XTick',1:numel(allgroups)); % add decorations
set(gca,'YTick',1:numel(allgroups));
set(gca,'XTickLabel',allgroups); % add decorations
set(gca,'YTickLabel',allgroups);
axis square, set(gcf,'Color','w'); 
colorbar    
colz = caxis;
caxis([0,colz(2)])
drawnow
end