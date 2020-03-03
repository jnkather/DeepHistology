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
        currentData = fileread(fullfile('./experiments/',[lower(codename),'.txt']));
    catch
        error(['did not find this source file: ',[lower(codename),'.txt']]);
    end

    try % decode data and dump to cnst (thereby overwriting previous params)
        cnst = jsondecode(currentData); 
    catch
        error(['could not decode source data for: ',[lower(codename),'.txt']]);
    end   

    % ensure consistent file names
    cnst.folderName.Temp = fullfile(cnst.folderName.Temp); 

    % create random experiment ID
    rng('shuffle');
    cnst.experimentName = randseq(12,'Alphabet','AA');
    disp(['--- this is the current experiment name: ',cnst.experimentName]);

    % save code name
    cnst.codenameFile = cnst.codename;
    cnst.codename = codename;

    % output status
    disp(['successfully loaded source file: ',[lower(codename),'.txt']]);
    
    % add some holy default settings
    cnst.saveUnmatchedBlocks = false;   % save list of unmatchable blocks, may blow up output file size
    cnst.nBootstrapAUC          = 10;   % bootstrap for AUC confidence interval, default 10
    cnst.undersampleTrainingSet = true; % equalize training set labels by undersampling
    cnst.binarizeThresh         = 5;    % convert num targets with more than N levels to HI / LO
    cnst.blocks.resizeMethod = 'resize';      % how to make the blocks fit the neural network input size
                                              % options: 'resize', 'randcrop', 'centercrop'; default 'resize'
    cnst.fileformatBlocks ='.jpg';  % define format for Blocks

end