% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this function contains hard-coded default hyperparameters 
% for neural network training and deployment 

function hyperprm = getHyperparameters(paramset)

% hard-code our default deep learning hyperparameters 
hyperprm.ValidationFrequency = 50;  % check validation performance every N iterations, 500 is 3x per epoch
hyperprm.ValidationPatience = 5;    % wait N times before abort
hyperprm.L2Regularization = 1e-4;   % optimization L2 constraint
hyperprm.MiniBatchSize = 512;    	% mini batch size, limited by GPU RAM, default 256 on P6000
hyperprm.MaxEpochs = 4;             % max. epochs for training, default 4
hyperprm.learnRateFactor = 2;       % learning rate factor for rewired layers
hyperprm.ExecutionEnvironment = 'gpu'; % environment for training and classification
hyperprm.InitialLearnRate =  5e-5;  % linear learning rate, default 5e-5
hyperprm.hotLayers = 30;            % number of hot layers in the network (count from end, default 30)
hyperprm.GradientDecayFactor = 0.9; % adam's default (explicit is better than implicit)
hyperprm.Epsilon = 1e-8;            % offset to avoid zero division (adam's default)
hyperprm.DispatchInBackground = false; % asynchronous prefetch queuing of datastore (insane RAM explosion)
hyperprm.MBSclassify = 128;         % mini batch size for classification in xval mode

% hyperparameter sets allow to mandate changes with command line options
disp(['- loading hyperparameter set: ',paramset]);
switch lower(paramset)
    case 'default'
        disp('-- no hyperparam modification needed');
    case 'px224_60'
        disp('-- large mini batch size and a lot of trainable layers');
        hyperprm.MiniBatchSize = 1024;
        hyperprm.MBSclassify = 1024;
        hyperprm.hotLayers = 60;
    case 'megaproject'
        hyperprm.MaxEpochs = 8;
        hyperprm.ValidationPatience = 5;
        hyperprm.ValidationFrequency = 200;
        disp('-- colorectal megaproject');
    case 'subflexi'
        disp('-- enabled semi flexible learning');
        hyperprm.hotLayers = 30;
        hyperprm.MaxEpochs = 8;  
        hyperprm.MiniBatchSize = 512;
    case 'vram48'
        disp('-- hyperparameters for VRAM 48 GB');
        hyperprm.MiniBatchSize = 1024;    
    case 'flexi'
        disp('-- enabled flexible learning (40 hot layers) & long training (careful, overfitting!)');
        hyperprm.hotLayers = 40;
        hyperprm.MaxEpochs = 25;  
        hyperprm.MiniBatchSize = 256;
    case 'ganmode'
        disp('-- enabled GAN mode learning');
        hyperprm.hotLayers = 40;
        hyperprm.MaxEpochs = 10;  
        hyperprm.MiniBatchSize = 128;
    case 'lowresource'
        disp('--- low resource hyperparams');
        hyperprm.MiniBatchSize = 256;
    case 'deploy'
        disp('--- deploy hyperparams');
        hyperprm.MiniBatchSize = 1024;
    case 'verylowresource'
        disp('--- low resource hyperparams');
        hyperprm.MiniBatchSize = 128;
    case 'mega'
        disp('--- mega block hyperparams');
        hyperprm.hotLayers = 10;
        hyperprm.MiniBatchSize = 32;
        hyperprm.MaxEpochs = 6;  
        hyperprm.MBSclassify =   32;
        hyperprm.InitialLearnRate =  1e-4;
       
    otherwise
        error('-- invalid hyperparameter set selected');
end

end
