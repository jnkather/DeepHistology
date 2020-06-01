function [ M ] = EstUsingMacenko( I, Io, beta, alpha )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EstUsingMacenko: Estimate the stain separation matrix using
% Macenko's method
%
%
% Input:
% I                 - RGB input image
% beta              - OD threshold for transparent pixels
% alpha             - tolerance for the pseudo-min and pseudo-max
%
%
% Output:
% M                 - Stain separation matrix with columns corresponding to
%                     stain vectors
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

% Run in DEMO Mode
if nargin<1
    I = imread('hestain.png');
end



% OD threshold for transparent pixels
if  ~exist('beta', 'var') || isempty(beta)
    beta = 0.15;
end

% tolerance for the pseudo-min and pseudo-max
if ~exist('alpha', 'var') || isempty(alpha)
    alpha = 1;
end

% transmitted light intensity
if  ~exist('Io', 'var') || isempty(Io)
    Io = 255;
end

if size(I,3)<3
    error('Image must be RGB');
end

I = reshape(double(I), [], 3);

% calculate optical density
OD = -log((I+1)/Io);

% remove transparent pixels
ODhat = OD(~any(OD < beta, 2), :);

% calculate eigenvectors
[V, ~] = eig(cov(ODhat));

% project on the plane spanned by the eigenvectors corresponding to the two
% largest eigenvalues
THETA = ODhat*V(:,2:3);

PHI = atan2(THETA(:,2), THETA(:,1));

% find the robust extremees (min and max angles) 
minPhi = prctile(PHI, alpha);
maxPhi = prctile(PHI, 100-alpha);

% Bring the extreme angles back to OD Space
VEC1 = V(:,2:3)*[cos(minPhi); sin(minPhi)];
VEC2 = V(:,2:3)*[cos(maxPhi); sin(maxPhi)];

% Make sure that Hematoxylin is first and Eosin is second vector
if VEC1(1) > VEC2(1)
    M = [VEC1 VEC2]';
else
    M = [VEC2 VEC1]';
end

end

