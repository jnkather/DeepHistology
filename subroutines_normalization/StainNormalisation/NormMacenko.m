function [ Norm ] = NormMacenko( Source, Target, Io, beta, alpha, verbose )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NormMacenko: Normalise the appearance of a Source Image to a Target 
% image using Macenko's method.
% 
%
% Input:
% Source   - RGB Source image.
% Target   - RGB Reference image.
% Io       - (optional) Transmitted light intensity. (default 255)
% beta     - (optional) OD threshold for transparent pixels. (default 0.15)
% alpha    - (optional) Tolerance for the pseudo-min and pseudo-max.
%                       (default 1)
% verbose  - (optional) Display results. (default 0)
%
%
% Output:
% Norm     - Normalised RGB Source image.
%
%
% References:
% [1] M Macenko, M Niethammer, JS Marron, D Borland, JT Woosley, X Guan, C 
%     Schmitt, NE Thomas. "A method for normalizing histology slides for 
%     quantitative analysis". IEEE International Symposium on Biomedical 
%     Imaging: From Nano to Macro, 2009 vol.9, pp.1107-1110, 2009.
%
%
% Acknowledgements:
% This function is inspired by Mitko Veta's Stain Unmixing and Normalisation 
% code, which is available for download at Amida's Website:
%     http://amida13.isi.uu.nl/?q=node/69
%
%
% Copyright (c) 2013, Adnan Khan
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

% transmitted light intensity
if ~exist('A', 'var') || isempty(Io)
    Io = 255;
end

% OD threshold for transparent pixels
if ~exist('beta', 'var') || isempty(beta)
    beta = 0.15;
end

% tolerance for the pseudo-min and pseudo-max
if ~exist('alpha', 'var') || isempty(alpha)
    alpha = 1;
end

[h, w, ~] = size(Source);

% Estimate Stain Matrix for Taret Image
MTarget = EstUsingMacenko(Target, Io, beta, alpha);

% Perform Color Deconvolution of Target Image to get stain concentration
% matrix
[ C, MTarget ] = Deconvolve( Target, MTarget );

% Vectorize to N x 3 matrix
C = reshape(C, [], 3);

% Find the 99th percentile of stain concentration (for each channel)
maxCTarget = prctile(C, 99, 1);    


%% Repeat the same process for input/source image

% Estimate Stain Matrix for Source Image
MSource = EstUsingMacenko(Source, Io, beta, alpha);

% Perform Color Deconvolution of Source Image to get stain concentration
% matrix
C = Deconvolve( Source, MSource );

% Vectorize to N x 3 matrix
C = reshape(C, [], 3);

% Find the 99th percentile of stain concentration (for each channel)
maxCSource = prctile(C, 99, 1);


%% MAIN NORMALIZATION STUFF
% 
C = bsxfun(@rdivide, C, maxCSource);
C = bsxfun(@times,   C, maxCTarget);


%% Reconstruct the RGB image 
Norm = Io*exp(C * -MTarget);
Norm = reshape(Norm, h, w, 3);
Norm = uint8(Norm);

%% VISUALISATION
% Display results if verbose mode is true
if verbose
    figure;
    subplot(1,3,1); imshow(Source);   title('Source Image');
    subplot(1,3,2); imshow(Target);   title('Target Image');
    subplot(1,3,3); imshow(Norm); title('Normalised (Macenko)');
end

end


