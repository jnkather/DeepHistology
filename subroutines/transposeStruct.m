% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this is a general function similar to the 
% transpose operator that works on structs 

function structOut = transposeStruct(structIn)

allNames = fieldnames(structIn);

for i = 1:numel(allNames)
    currName = allNames{i};
    structOut.(currName) = structIn.(currName)';
    if iscell(structOut.(currName)) & isnumeric(structOut.(currName){1})
        structOut.(currName) = cell2mat(structOut.(currName));
    end
end

end