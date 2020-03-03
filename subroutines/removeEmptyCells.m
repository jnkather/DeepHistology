% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this function will find missing values in a cell


function myCell = removeEmptyCells(myCell)
    % remove tiles with missing patient name
    disp('-- detecting empty elements in cell array...')
    emptyCells = cellfun(@isempty,myCell);
    if sum(emptyCells>0)
        disp(['--- detected ',num2str(sum(emptyCells)),' empty cells... ',...
            ' in a total of ',num2str(numel(emptyCells)),' elements.']);
        myCell(emptyCells) = [];
        disp('----- removed empty cells, continue...');
    else
        disp('--- there were no empty cells... continue');
    end

end