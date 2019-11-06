function tCombined = combineTables(tRaw,colnames)

if isempty(colnames)
    disp('-- will concatenate tables, assume identical column names');
    for i = 1:numel(tRaw)
        if i == 1
            tCombined = tRaw{i};
        else
            tCombined = [tCombined;tRaw{i}];
        end
    end
else
    disp(['-- will concatenate tables using these column names: ',...
        strjoin(colnames,', ')]);
    for cc = 1:numel(colnames)
        currCol = colnames{cc};
        for i = 1:numel(tRaw)
            if i == 1
                tCombined.(currCol) = tRaw{i}.(currCol);
            else
                tCombined.(currCol) = [tCombined.(currCol);tRaw{i}.(currCol)];
            end
        end
    end
    tCombined = struct2table(tCombined);
end