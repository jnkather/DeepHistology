function Norm = Norm( Source, Target, Method, varargin )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Norm: Normalise the appearance of a Source Image to a Target Image using 
%       the specified method.
%
%
% Input:
% Source         - RGB Source image.
% Target         - RGB Reference image.
% Method         - Stain Normalisation method.
% varargin       - Any additional arguments for the target Normalisation
%                  method. The order of the arguments must match that of 
%                  the target function.
%
%
% Output:
% Norm           - Normalised RGB Source image.
%
%
% Notes: Valid values for Method and their associated normalisation 
%        function are as follows:
%            'SCD'      - Non-Linear SCD-based Normalisation.
%                         (Matlab Implementation)
%            'SCDLeeds' - Non-Linear SCD-based Normalisation.
%                         (Windows Executable)
%            'Macenko'  - Macenko Linear Stain Channel Normalisation.
%            'Reinhard' - Reinhard Colour Normalisation.
%            'RGBHist'  - RGB Histogram Specification.
%            'Custom'   - An external Stain Normalisation method.
%
%        If you wish to use your own Stain Normalisation function, please
%        select the 'Custom' option for Method and provide a function 
%        handle to your custom function as the forth argument.
%
%        A valid custom Normalisation function must take the following input 
%        arguments, in this order:
%            Source         - RGB Source image.
%            Target         - RGB Reference image.
%            varargin       - Any additional arguments for the custom Normalisation
%                             method.
%        And output the following:
%            Norm           - Normalised RGB Source image.
%
%        If your existing Stain Normalisation function is not of this form: 
%            Please create a new function that accepts these arguments and 
%            then calls the existing function as appropriate. 
%            This new function can then be used here instead. 
%
%
% References:
% See each normalisation function for its associated references.
%
%
% Copyright (c) 2015, Nicholas Trahearn
% Department of Computer Science,
% University of Warwick, UK.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('Source', 'var') || isempty(Source)
   error('Please supply a Source Image.');
end

if ~exist('Target', 'var') || isempty(Target)
   error('Please supply a Target Image.');
end

if ~exist('Method', 'var') || isempty(Method)
   error('Please supply a Stain Normalisation Method.');
end

switch Method
    case 'SCD'
        % Call the Non-Linear SCD-based method.
        Norm = NormSCD(Source, Target, varargin{:});
    case 'SCDLeeds'
        % Call the Leeds Implementation of the Non-Linear SCD-based method.
        Norm = NormSCDLeeds(Source, Target, varargin{:});
    case 'Macenko'
        % Call Macenko's Method.
        Norm = NormMacenko(Source, Target, varargin{:});
    case 'Reinhard'
        % Call Reinhard's method.
        Norm = NormReinhard(Source, Target, varargin{:});
    case 'RGBHist'
        % Call the RGB Histogram Specification method.
        Norm = NormRGBHist(Source, Target, varargin{:});
    case 'Custom'
        % Call a Custom Stain Normalisation Method.
        normfun = varargin{1};
        Norm = normfun(Source, Target, varargin{2:end});
    otherwise
        error('Unknown Stain Normalisation Method.');
end

%{
if verbose
    figure;
    subplot(1,3,1); imshow(Source);   title('Source Image');
    subplot(1,3,2); imshow(Target);   title('Target Image');
    subplot(1,3,3); imshow(Norm); title(['Normalised (' Method ')']);
end
%}

end

