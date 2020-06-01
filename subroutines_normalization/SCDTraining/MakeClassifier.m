function [ TrainingStruct ] = MakeClassifier( TrainingImages, TrainingLabels, TrainingFun, TFargs, ClassificationFun )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MakeClassifier: Create a custom stain classifier
%
%
% Input:
% TrainingImages         - A cell array of RGB training images.
% TrainingLabels         - A cell array of training label images.
% TrainingFun            - (optional) A function handle to the desired
%                          training method. (default: @TrainRF)
% TFargs                 - (optional) A cell array of additional arguments
%                          for the training function. (default: {50})
% ClassificationFun      - (optional) A function handle to the desired
%                          classification method. (default: @ClassifyRF)
%
% Output:
% TrainingStruct         - A struct containing the trained classifier and
%                          other auxillary information needed for
%                          classification.
%
%
% Notes: If a custom training method is used then all optional arguments
%        must be provided.
%
%        A valid training function must take the following input arguments,
%        in this order:
%            TrainingData   - An nx4 matrix of training data.
%            TrainingLabels - An nx1 vector of training labels.
%            TrainingArgs   - A cell array of additional arguments to the
%                             trainer.
%        And output the following:
%            Classifier     - An object containing the stain classifier. The
%                             exact form of the object is not strict and
%                             may vary between different training methods.
%
%        A valid classification function must take the following arguments
%        in this order:
%            Classifier         - An object containing the stain classifier.
%            Data               - An nx4 matrix of data to be classified.
%            ClassificationArgs - A cell array of additional arguments to
%                                 the classifier.
%        And output the following:
%            Probabilities      - An nxl matrix of classification
%                                 probabilities, where l is the number of
%                                 labels/stains. Each column is a 
%                                 probability vector for a given stain, and
%                                 provides the probability of each pixel
%                                 being classified as the associated stain.
%
%        If your existing training or classification function is not of
%        this form: 
%            Please create a new function that accepts these arguments and 
%            then calls the existing function as appropriate.
%            This new function can then be used here instead. 
%
%        See the provided TrainRF and ClassifyRF functions for more details.
%
%
% References:
% [1] AM Khan, NM Rajpoot, D Treanor, D Magee. "A Non-Linear Mapping 
%     Approach to Stain Normalisation in Digital Histopathology Images
%     using Image-Specific Colour Deconvolution". IEEE Transactions on
%     Biomedical Engineering, vol.61, no.6, pp.1729-1738, 2014. 
%
%
% Copyright (c) 2015, Nicholas Trahearn
% Department of Computer Science,
% University of Warwick, UK.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% If no (or incomplete) classifier details are given use the default Random
% Forest classifier
if nargin < 5
    TrainingStruct.ClassifierType = 'RandomForest';
    TrainingFun = @TrainRF;
    TFargs = {20};
    ClassificationFun = @ClassifyRF;
else
    TrainingStruct.ClassifierType = 'CustomClassifier';
end

%% Preprocessing
% Convert the training images to uint8s, if not already in that form
TrainingImages = cellfun(@(x) im2uint8(x), TrainingImages, 'UniformOutput', false);

% Calculate a 256 colour pallet of the training images using Octree
% quantisation
TrainingStruct.Pallet = otq(cell2mat(cellfun(@(x) reshape(x, 1, [], 3), TrainingImages, 'UniformOutput', false)));

% Find the histogram of pallet values for each training image
TrainingHistograms = cellfun(@(x) GenerateHistogram(x, TrainingStruct.Pallet), TrainingImages, 'UniformOutput', false);

% Normalise the histograms so that each histogram sums to 1
TrainingHistograms = cellfun(@(x) double(x)/sum(double(x)), TrainingHistograms, 'UniformOutput', false);

% Find the SCDs of the training images and store the Principal Component
% Histogram (PCH)
[TrainingSCDs, TrainingStruct.PCH] = ComputeSCDs(TrainingHistograms, 1);

% Convert the training images to doubles
TrainingImages = cellfun(@(x) im2double(x), TrainingImages, 'UniformOutput', false);

%% Prepare the Image Feature Vector
% This is the input for training
X = cellfun(@BuildImageFeatureVector, TrainingImages, TrainingSCDs, 'UniformOutput', false);
X = cat(1, X{:});

%% Prepare the labels for training
Y = cellfun(@(x) double(x(:)), TrainingLabels, 'UniformOutput', false);
Y = cat(1, Y{:});

Y = Y-min(Y(:));

%% Train the classifier
TrainingStruct.Classifier = TrainingFun(X, Y, TFargs);
TrainingStruct.ClassificationFunction = ClassificationFun;
TrainingStruct.Labels = unique(Y(:));

end

