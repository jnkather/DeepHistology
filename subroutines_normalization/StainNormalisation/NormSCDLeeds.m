function [ Norm ] = NormSCDLeeds( Source, Target, verbose )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NormSCDLeeds: Normalise the appearance of a Source Image to a Target 
%               Image using the Leeds implementation of the Non-Linear
%               Spline Mapping Method with a built-in colour model.
% 
%
% Input:
% Source             - RGB Source image.
% Target             - RGB Reference image.
% verbose            - (optional) Display results.
%                      (default 0) 
%
%
% Output:
% Norm               - Normalised RGB Source image
%
%
% Notes: Only available on Windows platforms.
%        This version of the algorithm cannot be retrained. 
%
% References:
% [1] AM Khan, NM Rajpoot, D Treanor, D Magee. "A Non-Linear Mapping 
%     Approach to Stain Normalisation in Digital Histopathology Images
%     using Image-Specific Colour Deconvolution". IEEE Transactions on
%     Biomedical Engineering, vol.61, no.6, pp.1729-1738, 2014. 
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

if ~ispc
   error('This function is only available on Windows platforms.');
end

currentDir = pwd;
functionDir = mfilename('fullpath');
functionDir = functionDir(1:(end-length(mfilename)));
cd(functionDir);

mkdir('.temp');
mkdir('.temp/normalised');

cd('./.temp');

imwrite(Source, './source.png', 'PNG');
imwrite(Target, './target.png', 'PNG');

fileID = fopen('./filename.txt','w');
fprintf(fileID, 'source.png\n');
fclose(fileID);

dos('..\..\bin\LeedsSCD\ColourNormalisation.exe BimodalDeconvRVM filename.txt target.png ..\..\bin\LeedsSCD\HE.colourmodel');

Norm = imread('./normalised/source.png');

cd('./..')
rmdir('.temp','s');
cd(currentDir);

if verbose
    figure;
    subplot(1,3,1); imshow(Source);   title('Source Image');
    subplot(1,3,2); imshow(Target);   title('Target Image');
    subplot(1,3,3); imshow(Norm); title('Normalised (SCD-Leeds)');
end

end