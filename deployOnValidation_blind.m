% JN Kather Aachen / Chicago 2019-2020
% this script is part of the digital pathology deep learning project
% caution, this script is highly experimental and not recommended for productive use
%
%         Step 1: open all SVS images and draw regions
%         Step 2: cut the ROIs into blocks
%         Step 3: load blocks, train/test OR crossvalidate then train on all
% THIS IS Step 4: deploy a trained model on an external image set
%
% we need two tables:
% the SLIDE table associates SLIDES (images) to PATIENTS
% the CLINI table associates PATIENTS to outcome
% 
% this is the *BLIND* version of our script which will be used whenever we
% want to predict a validation cohort but stay blinded to the ground truth

%% Header
clear variables, format compact, close all; clc % clean up
%setenv CUDA_VISIBLE_DEVICES 1 % use only first GPU
gpuDevice(1)
addpath(genpath('./subroutines/'));  % add dependencies
cnst = loadExperiment('romanmsi-rtx'); % yorknorm-rtx
cnst.fileformatBlocks = {'.jpg'};

% load deep learning hyperparameters and initialize deep learning model
hyperprm = getDeepHyperparameters('default');
hyperprm.ExecutionEnvironment = 'gpu';
hyperprm.MiniBatchSize = 32; 
cnst.debugMode = false;

[cnst,fCollect] = initializeDeepImagePipeline(cnst); % initialize

cnst.verbose  = false;    % show intermediary steps?
cnst.simulate = false;   % simulate only? default false (-> do it!)

% load the trained model
cnst.trainedModelFolder = fullfile('E:\RAINBOW-CRC-DX--DACHS-CRCFULL-DX--TCGA-CRC-DX--QUASAR-CRC-DX\DUMP\'); %'E:\RAINBOW-CRC-DX--DACHS-CRCFULL-DX--TCGA-CRC-DX--QUASAR-CRC-DX\DUMP\';%'E:\ALLBLOCKS\TCGA-BRCA-DX\DUMP\'; %fullfile('..\..\2019-Virus_from_HE\ALLVIRUS\DUMP');
cnst.trainedModelID = 'HLVDDREQHWQK-WPDRE_isMSIH'; %'PQAYQMYAPRWG-QWWHP_isMSIH'; % trained model ID

load(fullfile(cnst.trainedModelFolder,[cnst.trainedModelID,'_lastModel_v6.mat']));

% define SLIDE table and CLINI table
% the SLIDE table needs to have the columns FILENAME and PATIENT
% the CLINI table needs to have the column PATIENT plus an target column
cnst.annotation.Dir = './cliniData/';
cnst.annotation.SlideTable = [cnst.ProjectName,'_SLIDE.csv'];
cnst.annotation.CliniTable = [cnst.ProjectName,'_CLINI.xlsx'];

% -------- START DEBUG --------
cnst.blocks.maxBlockNum = 1000;
cnst.aggregateMode = 'majority';
cnst.saveTopTiles = 0; % save the N highest scoring tiles
cnst.saveTileTable = 0; % save a table for all tile predictions for viz
% -------- END DEBUG --------

z1 = tic;
allBlocksLabeled = copy(fCollect.Blocks);
cnst.annotation.targetCol = ''; % no target in blind mode

resultCollection = deployModelBlind(hyperprm,finalModel,allBlocksLabeled);
disp('finished deploy function');
% add some more results
resultCollection.unmatchedBlocks = [];
totalTime = toc(z1);
resultCollection.cnst = cnst;
resultCollection.hyperprm = hyperprm;
resultCollection.totalTime = totalTime;
save(fullfile(cnst.folderName.Dump,[cnst.experimentName,...
    '_from_',cnst.trainedModelID,'_lastResult_v6.mat']),'resultCollection');

% convert tile level predictions to patient level predictions
slideTable = readtable(fullfile(cnst.annotation.Dir,cnst.annotation.SlideTable),'Delimiter',',');

tic
[patients,meanScore] = stat2pat(resultCollection.stats.blockStats,slideTable);
toc

tout = table(patients',meanScore')

