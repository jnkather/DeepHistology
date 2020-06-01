function [ ProbabilityMaps, ClassifiedLabels ] = ClassifyStainRegions( Image, TrainingStruct, ClassificationArgs )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ClassifyStainRegions: Classify an input image into regions corresponding
%                       to each stain (and background).
%
%
% Input:
% Image                 - RGB input image.
% TrainingStruct        - (optional) A struct containing the trained stain
%                         classifier. If the structure is not provided then 
%                         the built-in Random Forest Classifier is used.
% ClassificationArgs    - (optional) A cell array of additional arguments
%                         to the classifier.
%
% Output:
% ProbabilityMaps       - An nxmxl matrix of classification probabilities, 
%                         where l is the number of labels/stains. Each 
%                         channel is a probability map for a given stain,
%                         and provides the probability of each pixel being
%                         classified as the associated stain.
% ClassifiedLabels      - An nxm label matrix, showing the stain with the
%                         highest classification probability at each pixel
%                         of the input image.
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

% If no classifier is provided load the default classifier
if nargin < 2 || isempty(TrainingStruct)
    load('DefaultStainTrainingStruct.mat');
end

if nargin < 3 || isempty(ClassificationArgs)
    ClassificationArgs = {};
end

%% Preprocessing
% Convert the input image to uint8, if not already in that form
Image = im2uint8(Image);

% Find the histogram of pallet values for the input image, using the
% precalculated pallet from training
Histogram = GenerateHistogram(Image, TrainingStruct.Pallet);

% Normalise the histogram so that its values sum to 1
Histogram = double(Histogram)/sum(double(Histogram));

% Compute the SCD of the input images, using the precalculated
% Principal Component Histogram (PCH) from training
SCD = bsxfun(@minus, Histogram, TrainingStruct.PCH.H)*TrainingStruct.PCH.E;

% Convert the input image to double
Image = im2double(Image);


%% Prepare the Image Feature Vector
% This is the input for classification
X = BuildImageFeatureVector(Image, SCD);

%% Classify Input Image
% Classifier returns probability maps for each possible stain (and
% background).
ProbabilityMaps = TrainingStruct.ClassificationFunction(TrainingStruct.Classifier, X, ClassificationArgs);

% Create a label image, taking the stain with the highest probability at 
% each pixel as the label for that pixel
[~, ClassifiedLabels] = max(ProbabilityMaps, [], 2);
ClassifiedLabels = TrainingStruct.Labels(ClassifiedLabels);

% Reshape the output to the dimensions of the input image
ProbabilityMaps = reshape(ProbabilityMaps, size(Image, 1), size(Image, 2), []);
ClassifiedLabels = reshape(ClassifiedLabels, size(Image, 1), size(Image, 2));

end