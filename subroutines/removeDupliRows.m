% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this is an auxiliary function to remove 
% rows with duplicate entries from a table

function myT = removeDupliRows(myT,varIn)

[urows,uu] = unique(myT.(varIn));
myDupliT = myT;
myDupliT(uu,:) = [];

if numel(myT.(varIn)) == numel(urows)
    disp(' no duplicates detected in table');
else
    disp(' detected duplicate rows as follows:');
    myDupliT
    myT = myT(uu,:);
end

end