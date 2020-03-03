% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this is an auxiliary function to remove columns from a table

function tableIn = removeCols(tableIn,ColNames)

for i = 1:numel(ColNames)
    try
        tableIn.(ColNames{i}) = [];
    catch
        warning(['could not remove column ',ColNames{i}]);
    end
end

end