function [ M, Labels ] = EstUsingSCD( I, TrainingStruct )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EstUsingSCD: Estimate the stain separation matrix using the Stain Colour
%              Descriptor method
% 
%
% Input:
% I                  - RGB input image.
% TrainingStruct     - (optional) A struct containing the trained stain
%                      classifier. If the structure is not provided then 
%                      the built-in Random Forest Classifier is used.
%
%
% Output:
% M                  - Stain separation matrix with columns corresponding
%                      to stain vectors.
% Labels             - A label image showing the results of classification.
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

%% Generate Stain Probability Maps
ProbabilityMaps = ClassifyStainRegions( I, TrainingStruct );

% Vectorise Image
ColumnImage = reshape(im2double(I(:,:,1:3)), [], 3);

% List of potential Stain Labels from Classifier
StainLabels = cat(1, TrainingStruct.Labels);

% Vectorise Probability Maps
ProbabilityMaps = reshape(ProbabilityMaps, [], length(StainLabels));

% Background probability threshold
Tbg = 0.75;

% Stain probability threshold
Tfg = 0.75;

% Label used by classifier for background pixels, should always be zero
bgLabel = 0;
bgIdx = -1;

%% Generate the Stain Label image
Labels = -ones(size(ColumnImage, 1), 1);

for i=1:length(StainLabels)
    if StainLabels(i)==bgLabel
        bgIdx = i;
    else
        % Set the label to the current stain's label for all pixels with a
        % classification probability above the stain threshold
        Labels(ProbabilityMaps(:, i) > Tfg) = StainLabels(i);
    end
end

% Remove the background label from the list of stain labels
StainLabels = StainLabels(StainLabels~=bgLabel);

% Set the label for all pixels with a background classification probability 
% above the background threshold to the background's label
if bgIdx ~= -1
    Labels(ProbabilityMaps(:, bgIdx) > Tbg) = bgLabel;
end

%% Generate the Stain Separation Matrix
% Takes the mean of the OD values of the pixels classified as a given stain 
% To compute its stain vector
M = zeros(3);
M(1, :) = -log(mean(ColumnImage(Labels==StainLabels(2), 1:3))+(1/256));
M(2, :) = -log(mean(ColumnImage(Labels==StainLabels(1), 1:3))+(1/256));

% Third stain vector is computed as a cross product of the first two
M(3, :) = cross(M(1, :), M(2, :));

% Normalise the matrix such that each stain vector has a Euclidean Norm of 1
M = M./repmat(sqrt(sum(M.^2, 2)), [1 3]);

% Reshape Label image to have the width and height of the original image
Labels = reshape(Labels, size(I, 1), size(I, 2));

end
