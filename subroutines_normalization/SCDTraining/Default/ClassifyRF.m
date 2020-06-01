function Probabilities = ClassifyRF( Classifier, Data, ClassificationArgs )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ClassifyRF: Classifies data using a Random Forest Classifier.
% 
%
% Input:
% Classifier         - An object containing the Random Forest Classifier.
% Data               - An nx4 matrix of data to be classified.
% ClassificationArgs - A cell array of additional arguments to the
%                      classifier. (unused)
%
%
% Output:
% Probabilities      - An nxl matrix of classification probabilities, where
%                      l is the number of labels/stains. Each column is a 
%                      probability vector for a given stain, and provides 
%                      the probability of each pixel being classified as 
%                      the associated stain.
%
%
% References:
% [1] L Breiman. "Random forests". Machine learning, vol.45, no.1, pp.5-32,
%     2001.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    [~, Probabilities] = Classifier.predict(Data);
end

