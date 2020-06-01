function [ Norm ] = NormSCD( Source, Target, TrainingStruct, verbose )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NormSCD: Normalise the appearance of a Source Image to a Target 
%          Image using the Non-Linear Spline Mapping Method.
% 
%
% Input:
% Source             - RGB Source image.
% Target             - RGB Reference image.
% TrainingStruct     - (optional) A struct containing the trained stain
%                      classifier. If the structure is not provided then 
%                      the built-in Random Forest Classifier is used.
% verbose            - (optional) Display results.
%                      (default 0) 
%
%
% Output:
% Norm               - Normalised RGB Source image
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
    
if ~exist('verbose', 'var') || isempty(verbose)
   verbose = 0; 
%else
%    warning('Verbose mode for individual normalisation functions is likely to be removed in a future release. Please use Norm.m for Visualisation.');
end

if ~exist('Source', 'var') || isempty(Source)
   error('Please supply a Source Image.');
end

if ~exist('Target', 'var') || isempty(Target)
   error('Please supply a Target Image.');
end


% If no classifier is provided load the default classifier

if ~exist('TrainingStruct', 'var') || isempty(TrainingStruct)
    load('DefaultStainTrainingStruct.mat');
end

Io = 255;

%% Generate Stain Matrices for Source and Target Images
% Also produces label images showing the results of stain
% classification
[SourceMatrix, SourceLabels] = EstUsingSCD(Source, TrainingStruct);
[TargetMatrix, TargetLabels] = EstUsingSCD(Target, TrainingStruct);

%% Separate the Source and Target Images into Stain Images
% Calulated using the previous computed stain matrices.
SourceStains = Deconvolve(Source, SourceMatrix, 0);
TargetStains = Deconvolve(Target, TargetMatrix, 0);

% Convert the Stain Images back from Optical Density space
SourceStains = Io./exp(SourceStains);
TargetStains = Io./exp(TargetStains);

% Convert Label Images into Binary images for each stain Label
sBG = (SourceLabels==0); %Source Background
sS1 = (SourceLabels==2); %Source Haematoxylin
sS2 = (SourceLabels==1); %Source Eosin

tBG = (TargetLabels==0); %Target Background
tS1 = (TargetLabels==2); %Target Haematoxylin
tS2 = (TargetLabels==1); %Target Eosin

maxValue = 1000;

% Threshold any pixels that are over the predefined maximum value
SourceStains(SourceStains > maxValue) = maxValue;
TargetStains(TargetStains > maxValue) = maxValue;

% Calculate the intensity statistics of the two stains in the Source Image
SourceStats1 = DeconvolvedChannelStats(SourceStains(:,:,1), sS1, sBG);
SourceStats2 = DeconvolvedChannelStats(SourceStains(:,:,2), sS2, sBG);

% Calculate the intensity statistics of the two stains in the Target Image
TargetStats1 = DeconvolvedChannelStats(TargetStains(:,:,1), tS1, tBG);
TargetStats2 = DeconvolvedChannelStats(TargetStains(:,:,2), tS2, tBG);


%% Generate Splines from Stain Channel Statistics 
% Resultant splines allow us to map the stain intensity stats from the 
% Source Image to the Target Image
spline1 = FitSpline(SourceStats1, TargetStats1); %Spline for Haematoxylin
spline2 = FitSpline(SourceStats2, TargetStats2); %Spline for Eosin

%% Calculate Adjusted Stain Channels
% Use splines to calculate adjusted intensities for the two stain channels 
AdjustedSourceStain1 = ppual(spline1, double(SourceStains(:,:,1)));
AdjustedSourceStain2 = ppual(spline2, double(SourceStains(:,:,2)));

% The original background channel is not adjusted
SourceBackground = reshape(SourceStains(:,:,3), [], 1);

C = double([AdjustedSourceStain1(:) AdjustedSourceStain2(:) SourceBackground(:)]);   

% Threshold values that do not fall within the expected range
C(C > 255) = 255;
C(C < 0) = 0;

% Convert the stain data back to OD space.
C_OD = log(Io./(C+0.0001));

%% Reconstruct the RGB image 
Norm = Io*exp(C_OD * -TargetMatrix);
Norm = reshape(Norm, size(Source));
Norm = uint8(Norm);

%% VISUALISATION
% Display results if verbose mode is true
if verbose
    figure;
    subplot(1,3,1); imshow(Source);   title('Source Image');
    subplot(1,3,2); imshow(Target);   title('Target Image');
    subplot(1,3,3); imshow(Norm); title('Normalised (SCD)');
end

end

function [ ChannelStats ] = DeconvolvedChannelStats( StainImage, StainMask, BackgroundMask )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DeconvolvedChannelStats: Calculate the statistics (5th percentile, median,
%  and 95th percentile) of each class of pixels in the stain image.
%
% Pixel classes are:
%   Stained Pixels
%   Background Pixels
%   Other Pixels
%
%
% Input:
% StainImage         - Grayscale stain channel with intensity values in the
%                      range 0-255.
% StainMask          - Binary mask showing the region classified as stained
%                      by the stain shown in StainImage. Must be the same
%                      size as StainImage.
% BackgroundMask     - Binary mask showing the region classified as 
%                      background. Must be the same size as StainImage.
%
%
% Output:
% ChannelStats       - The statistics of the stain channel.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Generate the mask for Other Pixels, defined as any pixel not covered by
% the Stain and Background masks.
OtherMask = ~(StainMask|BackgroundMask);

% Collect the sets of pixels covered by each mask.
StainPixels = StainImage(StainMask);
OtherPixels = StainImage(OtherMask);
BackgroundPixels = StainImage(BackgroundMask);

% Calculate the statistics for pixels of each stain class
StainStats = CalculateStats(StainPixels);
OtherStats = CalculateStats(OtherPixels);
BackgroundStats = CalculateStats(BackgroundPixels);

% Combine the individual sets of statistics into a single vector
ChannelStats = [StainStats; OtherStats; BackgroundStats];

end

function [ Stats ] = CalculateStats( Pixels )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CalculateStats: Calculates statistics (5th percentile, median, and 95th
%                 percentile) for an set of pixel values.
%
%
% Input:
% Pixels          - A vector of pixel intensity values.
%
%
% Output:
% Stats           - The statistics of the set of pixels.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isempty(Pixels)
    % If no pixels are provided return NaNs
    Stats = [NaN NaN NaN];
else
    Stats = [double(prctile(Pixels, 5)); median(Pixels); double(prctile(Pixels, 95))];
end

end

function [ Spline ] = FitSpline( SourceStats, TargetStats )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FitSpline: Fits a smoothing spline to the data, mapping the Source Image
%            Statistics to the Target Image Statistics.
%
%
% Input:
% SourceStats     - Source Image Statistics.
% TargetStats     - Target Image Statistics.
%
%
% Output:
% Spline          - A smoothing spline mapping the Source Image Statistics 
%                   to the Target Image Statistics.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Find any rows containing a NaN in either set of stats, and eliminate them
NaNs = isnan(SourceStats) & isnan(TargetStats);
SourceStats = SourceStats(~NaNs);
TargetStats = TargetStats(~NaNs);

% Sort the stats into an ascending order
[SourceStats, I] = sort(SourceStats);
TargetStats = TargetStats(I);

% Append values at the extremes to make sure that the values of pixels with
% very high or low intensity remain unchanged by spline mapping
SourceStats = [-100; SourceStats(:); 1000];
TargetStats = [-100; TargetStats(:); 1000];

% Generate the smoothing spline
Spline = csaps(SourceStats, TargetStats, 0.000009);
    
end