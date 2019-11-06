
function hyperprm = getDeepHyperparameters(codename)

switch lower(codename)
    case 'default'
        % specify learning parameters 
        hyperprm.InitialLearnRate = 1e-5; % initial learning rate
        hyperprm.ValidationFrequency = 256; % check validation performance every N iterations, 500 is 3x per epoch
        hyperprm.ValidationPatience = 3; % wait N times before abort
        hyperprm.L2Regularization = 1e-4; % optimization L2 constraint
        hyperprm.MiniBatchSize = 512;    % mini batch size, limited by GPU RAM, default 256 on P6000
        hyperprm.MaxEpochs = 4;           % max. epochs for training, default 4
        hyperprm.hotLayers = 10;        % how many layers from the end are not frozen
        hyperprm.learnRateFactor = 2; % learning rate factor for rewired layers
        hyperprm.ExecutionEnvironment = 'gpu'; % environment for training and classification
        hyperprm.PixelRangeShear = 5;  % max. shear (in pixels) for image augmenter
        hyperprm.ValidationFrequency = 48;
        hyperprm.ValidationPatience = 2;
        hyperprm.InitialLearnRate =  5e-5; % linear learning rate, default 5e-5
        hyperprm.hotLayers = 30;        % number of hot layers in the network
    otherwise
        error('invalid codename');
end

disp('-- successfully assigned deep hyperparameters');
end
