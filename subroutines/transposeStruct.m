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