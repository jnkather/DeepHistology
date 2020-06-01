function Classifier = TrainRF( TrainingData, TrainingLabels, TrainingArgs )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TrainRF: Trains a Random Forest Classifier.
% 
%
% Input:
% TrainingData   - An nx4 matrix of training data.
% TrainingLabels - An nx1 vector of training labels.
% TrainingArgs   - A cell array of additional arguments to the trainer.
%
%
% Output:
% Classifier     - An object containing the Random Forest Classifier.
%
%
% References:
% [1] L Breiman. "Random forests". Machine learning, vol.45, no.1, pp.5-32,
%     2001.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Classifier = TreeBagger(TrainingArgs{1}, TrainingData, TrainingLabels);

end

