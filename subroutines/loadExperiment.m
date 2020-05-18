% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this function will load an experiment file, specifying
% the name of the cohort, the location of the tiles and the
% target variables to be predicted

function cnst = loadExperiment(codename)

    try % load source data
        currentData = fileread(fullfile('./experiments/',[codename,'.txt']));
    catch
        error(['did not find this source file: ',codename]);
    end

    try % decode data and dump to cnst (thereby overwriting previous params)
        cnst = jsondecode(currentData); 
    catch
        error(['could not decode source data for: ',codename]);
    end   

    % ensure consistent file names
    cnst.folderName.Temp = fullfile(cnst.folderName.Temp); 

    % create random experiment ID
    rng('shuffle');
    cnst.experimentName = randseq(12,'Alphabet','AA');
    disp(['--- this is the unique experiment name: ',cnst.experimentName]);

    % save file name as codename
    cnst.codename = codename;

    % output status
    disp(['successfully loaded source file: ',codename]);

    % add holy parameters, do not change
    cnst.blocks.resizeMethod = 'resize';      % how to make the blocks fit the neural network input size
                                              % options: 'resize', 'randcrop', 'centercrop'; default 'resize'

end