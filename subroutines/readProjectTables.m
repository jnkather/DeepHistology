% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this function will read clinical and slide tables for the current 
% project 

function [tCLINI,tSLIDE] = readProjectTables(cnst)

    if cnst.multipleCohorts
        for i = 1:numel(cnst.allProjects)
            disp('-- preparing table references for multiple cohorts');
                switch cnst.tableModeClini
                   case 'CSV'
                        cnst.annotation.CliniTable = [cnst.allProjects{i},'_CLINI.csv'];
                        tCLINI_raw{i} = readtable(fullfile(cnst.annotation.Dir,...
                            cnst.annotation.CliniTable),'Delimiter',',','ReadVariableNames',true);
                   case 'XLSX'
                        cnst.annotation.CliniTable = [cnst.allProjects{i},'_CLINI.xlsx'];
                        tCLINI_raw{i} = readtable(...
                            fullfile(cnst.annotation.Dir,cnst.annotation.CliniTable)); 
                   otherwise
                       error('unspecified clinical table mode');
               end
               cnst.annotation.SlideTable = [cnst.allProjects{i},'_SLIDE.csv'];
               slidepath = fullfile(cnst.annotation.Dir,cnst.annotation.SlideTable);
               disp(['--- reading this cohort slide table from ',slidepath]);
               tSLIDE_raw{i} = readtable(slidepath,'Delimiter',',','ReadVariableNames',true);
        end
        cnst.annotation.SlideTable = '';
        cnst.annotation.CliniTable = '';
        % convert all slide names to string
        for iT = 1:numel(tSLIDE_raw)
            if isnumeric(tSLIDE_raw{iT}.FILENAME)
                warning('found numeric FILENAME column in a  slide table. will convert to string');
                tSLIDE_raw{iT}.FILENAME = cellstr(num2str(tSLIDE_raw{iT}.FILENAME));
            end
        end
        tSLIDE = combineTables(tSLIDE_raw,{'PATIENT','FILENAME'});
        if isfield(cnst,'subsetTargetsBy') && ~isempty(cnst.subsetTargetsBy)
            disp('--- combining CLINI tables while keeping subset variable and target variable');
            tCLINI = combineTables(tCLINI_raw,{'PATIENT',cnst.annotation.targetCol,cnst.subsetTargetsBy});
        else
            disp('--- combining CLINI tables, keeping target variable only');
            tCLINI = combineTables(tCLINI_raw,{'PATIENT',cnst.annotation.targetCol});
        end
    else
        disp('-- preparing table reference for single cohort');
        switch cnst.tableModeClini
           case 'CSV'
                cnst.annotation.CliniTable = [cnst.ProjectName,'_CLINI.csv'];
                tCLINI = readtable(fullfile(cnst.annotation.Dir,cnst.annotation.CliniTable),'Delimiter',',','ReadVariableNames',true);
           case 'XLSX'
                cnst.annotation.CliniTable = [cnst.ProjectName,'_CLINI.xlsx'];
                tCLINI = readtable(fullfile(cnst.annotation.Dir,cnst.annotation.CliniTable)); 
           otherwise
               error('unspecified clinical table mode');
       end
       cnst.annotation.SlideTable = [cnst.ProjectName,'_SLIDE.csv'];
       tSLIDE = readtable(fullfile(cnst.annotation.Dir,cnst.annotation.SlideTable),'Delimiter',',','ReadVariableNames',true);
    end

end
