% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this is a parsing function for ROC statistics

function out = getROCstats(xin,yin,precision,yval)
    
    y2 = round(yin,precision);
    yval = round(yval,precision);
    yhit = min(find(y2==yval));
    if ~isempty(yhit)
        out = [round(xin(yhit),precision),round(yin(yhit),precision),yhit];
    else
        out = [];
    end    

end