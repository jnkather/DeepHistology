function [ IFV ] = BuildImageFeatureVector( Image, SCD )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BuildImageFeatureVector: Constructs the Image Feature Vector (IFV) of an 
%                          input image for training or classification.
%
%
% Input:
% Image      - RGB input image.
% SCD        - The Stain Colour Descriptor (SCD) for RGB image I.
%
%
% Output:
% IFV        - The Image Feature Vector.
%
% Note: Returns the IFV in the form of a nx4 vector where the first three
%       columns correspond to the pixel values of the red, blue, and green 
%       channels of the image. The forth column corresponds to the SCD 
%       value, which will be the same for every row.
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

IFV = reshape(double(Image), [], 3);
IFV = [IFV repmat(SCD(:)', size(IFV, 1), 1)];

end

