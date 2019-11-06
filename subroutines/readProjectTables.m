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
               tSLIDE_raw{i} = readtable(fullfile(cnst.annotation.Dir,cnst.annotation.SlideTable),'Delimiter',',','ReadVariableNames',true);
        end
        cnst.annotation.SlideTable = '';
        cnst.annotation.CliniTable = '';
        tSLIDE = combineTables(tSLIDE_raw,[]);
        tCLINI = combineTables(tCLINI_raw,{'PATIENT',cnst.annotation.targetCol});
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
