function [ SCDs, SCDKernel ] = ComputeSCDs( Histograms, r )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ComputeSCDs: Compute the Stain Colour Descriptors (SCDs) of a set of 
%              input colour pallet histograms. 
%
%              An SCD describes the global colour distribution of a stained
%              image using just a few values. It can be viewed as a
%              dimensionality reduced representation of the colour pallet
%              histogram, calculated using Principal Component Analysis.
%
%
% Input:
% Histograms   - A cell array of colour pallet histograms. All histograms
%                must be of the same length.
% r            - (optional) The desired length of the SCD. Must not be
%                greater than the length of the input histograms.
%                (default 1)
%
%
% Output:
% SCDs         - A cell array of SCDs, corresponding to the input
%                colour pallet histograms.
% SCDKernel    - A struct containing the information used to compute the
%                SCDs. Contains two pieces of information:
%                   H   - A mean colour pallet histogram. Calculated by
%                         finding the mean value of each entry of the
%                         histogram across all of the input histograms.
%                   E   - The eigenvectors corresponding to the r largest
%                         eigenvalues of the histograms.
%
%
% Notes: SCDKernel can be used to calculate the SCD of a given histogram,
%        Hist, as follows:
%                SCD = (Hist - SCDKernel.H) * SCDKernel.E
%
%        For SCDKernel to produce a reliable SCD all histograms must be
%        computed using the same colour pallet.
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

% If no value of r is given, use the default
if nargin < 2 || isempty(r)
    r = 1;
end

if r > 0
    % Concatenate the histograms together to produce a matrix where each
    % row is a colour pallet histogram.
    rowHistograms = double(cat(1, Histograms{:}));

    % Calculate the components of SCDKernel
    H = mean(rowHistograms, 1);
    [E, ~] = eig(cov(rowHistograms));

    SCDKernel = struct('H', H, 'E', E(:, end:-1:(end-r+1)));

    % Use SCDKernel to compute the SCDs of each histogram
    SCDs = cellfun(@(x) bsxfun(@minus,double(x),SCDKernel.H)*SCDKernel.E, Histograms, 'UniformOutput', false);
else
    SCDs = {};
    SCDKernel = [];
end

end

