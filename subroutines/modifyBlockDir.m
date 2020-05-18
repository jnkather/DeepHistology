% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this script modifies the standard tile directory for 
% projects using only a subset of tiles 

function outdir = modifyBlockDir(cnst,basedir)

disp('-- will modify block directory (load non-standard set of blocks=tiles)');
        switch upper(cnst.filterBlocks)
            case 'TUMOR'
                disp(['--- will only load TUMOR blocks',newline,...
                    '(automatically defined pure tumor tiles)']);
                outdir = fullfile(basedir,'/BLOCKS_TUSTRO/TUMOR/');    
            case 'STROMA'
                disp(['--- will only load STROMA blocks',newline,...
                    '(automatically defined pure stroma tiles)']);
                outdir = fullfile(basedir,'/BLOCKS_TUSTRO/STROMA/');
            case 'STROMA128'
                disp(['--- will only load STROMA128 blocks',newline,...
                    '(manually outlined pure stroma areas)']);
                outdir = fullfile(basedir,'/BLOCKS_STROMA128/');
            case 'BIOPSY'
                disp(['--- will only load BIOPSY blocks',newline,...
                    '(manually outlined luminal approx 2 mm region)']);
                outdir = fullfile(basedir,'/BLOCKS-BIOPSY/');                
            case 'NORMALIZED'
                disp(['--- will only load NORMALIZED blocks',newline]);
                outdir = fullfile(basedir,'/BLOCKS_NORM/');       
            otherwise
                disp(['trying to set non-standard alternative block dir: ',newline]);
                outdir = fullfile(basedir,cnst.filterBlocks);
                disp(outdir);
        end
end