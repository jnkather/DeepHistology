% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this will train a network on a fixed folder

function autoTrainOnFixed(varargin)
addpath(genpath('./subroutines/'));      % add dependencies
iPrs = getInputParser(varargin);  % get input parser, define default values
gpuDevice(iPrs.Results.gpuDev);          % select GPU device (Windows only)
cnst.ProjectName = 'autoTrainOn';
cnst.baseName = 'autoTrainOn';
cnst.blocks.resizeMethod = 'resize';

disp('-- starting job with these input (or default) settings:');
dispAllFields(iPrs.Results); 
cnst = copyfields(cnst,iPrs.Results,fieldnames(iPrs.Results)); % apply input

cnst.folderName.Temp = cnst.trainOnFolder;

cnst.folderName.Dump = fullfile(cnst.folderName.Temp,cnst.ProjectName,'/DUMP/'); % abs. path to block save folder
    [~,~,~] = mkdir(char(cnst.folderName.Dump));

hyperprm = getHyperparameters(cnst.hyper);        % load DL hyperparams
rng('shuffle');
cnst.experimentName = [cnst.baseName,'-',randseq(5,'Alphabet','AA')];
disp([newline,'#################',newline,...
        'starting new experiment: autoTrainOn' ]);

inpImds = imageDatastore(fullfile(cnst.trainOnFolder),'IncludeSubfolders',true,'LabelSource','foldernames');

inpImds %# ok

z1 = tic;
myNet = getAndModifyNet(cnst,hyperprm,numel(unique(inpImds.Labels))); % load pretrained net

[finalModel,~] = trainMyNetwork(myNet,inpImds,[],cnst,hyperprm);   

totalTime = toc(z1);
disp('training was successful');
resultCollection.cnst = cnst;
resultCollection.hyperprm = hyperprm;
resultCollection.totalTime = totalTime;

save(fullfile(cnst.folderName.Dump,[cnst.experimentName,'_lastResult_',cnst.saveFormat,'.mat']),'resultCollection');
save(fullfile(cnst.folderName.Dump,[cnst.experimentName,'_lastModel_',cnst.saveFormat,'.mat']),'finalModel'); 

end
