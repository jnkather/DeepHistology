% JN Kather Aachen / Chicago 2019
% this script is part of the digital pathology deep learning project
% MELANIE = seMiautomatic dEep LeArniNg pIplinE
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
% --- caution this function is not yet properly embedded in the whole pipeline and
% may need some manual babysitting

%% Header
clear variables, format compact, close all; clc % clean up
%setenv CUDA_VISIBLE_DEVICES 1 % use only first GPU
gpuDevice(1)
addpath(genpath('./subroutines/'));  % add dependencies
cnst = loadExperiment('romanmsi-rtx'); 
cnst.fileformatBlocks = {'.jpg'};

% load deep learning hyperparameters and initialize deep learning model
hyperprm = getHyperparameters('default');
hyperprm.ExecutionEnvironment = 'gpu';
hyperprm.MiniBatchSize = 2048; 
cnst.debugMode = false;

[cnst,fCollect] = initializeDeepImagePipeline(cnst); % initialize

cnst.verbose  = false;    % show intermediary steps?
cnst.simulate = false;   % simulate only? default false (-> do it!)

% load the trained model
cnst.trainedModelFolder = fullfile('E:\RAINBOW-CRC-DX--DACHS-CRCFULL-DX--TCGA-CRC-DX--QUASAR-CRC-DX\DUMP\'); 
cnst.trainedModelID = 'HLVDDREQHWQK-WPDRE_isMSIH'; 

load(fullfile(cnst.trainedModelFolder,[cnst.trainedModelID,'_lastModel_v6.mat']));

% define SLIDE table and CLINI table
% the SLIDE table needs to have the columns FILENAME and PATIENT
% the CLINI table needs to have the column PATIENT plus an target column
cnst.annotation.Dir = './cliniData/';
cnst.annotation.SlideTable = [cnst.ProjectName,'_SLIDE.csv'];
cnst.annotation.CliniTable = [cnst.ProjectName,'_CLINI.xlsx'];
cnst.blocks.maxBlockNum = 1000;
cnst.aggregateMode = 'majority';

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

