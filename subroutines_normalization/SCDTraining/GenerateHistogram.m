function [ Hist ] = GenerateHistogram( Image, Pallet )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GenerateHistogram: Generates a histogram of colours, with respect to 
%                    the input colour pallet.
%
% Input:
% Image                 - RGB input image.
% Pallet                - An nx6 matrix, where each row defines a colour in
%                         the pallet.
%
%
% Output:
% Hist                  - The colour pallet histogram. An nx1 vector, where
%                         each entry is the count for the number of pixels
%                         from the input Image that correspond to the given 
%                         colour in Pallet.
%
%
% Notes: Both Image and Pallet must be uint8s.
%
%        The format of a row (or colour) in Pallet is:
%        [R_Start R_End G_Start G_End B_Start B_End]
%        Where R_Start is the smallest value in the red channel accepted as
%        this colour, and R_End is the largest, the remaining entries are
%        the same for the green and blue channels, respectively.
%        These define the range of RGB values that are considered to be the
%        same colour in the pallet.
%
%
% Copyright (c) 2015, Nicholas Trahearn
% Department of Computer Science,
% University of Warwick, UK.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Generate a lookup table for the pallet colours
% The value of lookup(R, G, B) will be the index of the colour in Pallet
% that a pixel of value [R G B] belongs to
lookup = zeros(256, 256, 256);

% Increment each entry in Pallet to account for Matlab's 1-based
% indexing of the lookup table
Pallet = uint16(Pallet)+1;

% Fill the lookup table
for i=1:size(Pallet, 1)
    lookup(Pallet(i, 1):Pallet(i, 2), Pallet(i, 3):Pallet(i, 4), Pallet(i, 5):Pallet(i, 6)) = i;
end

columnImage = reshape(uint32(Image), [], 3);

% Increment each pixel of Image to account for Matlab's 1-based
% indexing of the lookup table
columnImage = columnImage+1;

% Convert the pixel's RGB values to Pallet indices using the lookup table
PalletIndices = lookup(sub2ind(size(lookup), columnImage(:, 1), columnImage(:, 2), columnImage(:, 3)));

% Compute the histogram from the Pallet indices
Hist = histc(PalletIndices(PalletIndices~=0), 1:size(Pallet, 1))';

end