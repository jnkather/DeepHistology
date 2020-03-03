% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this function converts continuous numeric values to categories
% input is numeric, output is cellstring

function targetDataOut = binarizeNumerical(targetData,binarizeQuantile)
       removeMe = isnan(targetData);

       if ~isempty(binarizeQuantile) 
           if isnumeric(binarizeQuantile)
               disp('-- detected numerical binarizeQuantile argument');
               if binarizeQuantile>0.5 
                    warning('inverted binarizeQuantile (should be between 0 and 0.5)');
                    binarizeQuantile = 1-binarizeQuantile;
               end
               disp(['--- binarized at ',num2str(binarizeQuantile)]);

               targetDataOut = strrep(strrep(cellstr(num2str(double(targetData>=...
                   quantile(targetData, 1-binarizeQuantile)))),...
                   '0','NA'),'1',['TOP_',num2str(binarizeQuantile)]); % top percentile
               targetDataOut(targetData<=quantile(targetData, binarizeQuantile)) = ...
                   {['BOT_',num2str(binarizeQuantile)]}; % bottom percentile
           else
               disp('-- detected NON-numerical binarizeQuantile argument');
               if ischar(binarizeQuantile) && strcmp(binarizeQuantile,'grzero')
                    disp('---- binarizing at ZERO (argument nonzero)');
                   targetDataOut = strrep(strrep(cellstr(num2str(double(targetData>...
                       0))),'0','_zero'),'1','_grzero');  
               end
           end
       else
           disp('--- binarize quantile is empty ... will binarize at the mean (omit NaN)');
           targetDataOut = strrep(strrep(cellstr(num2str(double(targetData>=...
           mean(targetData,'omitnan')))),'0','LOmean'),'1','HImean');  
       end
       targetDataOut(removeMe) = {'undef'};
end