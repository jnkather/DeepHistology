% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this function will concatenate predictions in a cross-
% validated experiment 

function outStats = concatenatePredictions(stats)

if numel(stats) == 1 && isstruct(stats)
    disp('-- there is only one partition, containing the full stats (no crossval)');
    outStats = stats.blockStats;
elseif numel(stats) == 1 && iscell(stats)
    disp('-- there is only one full partition in a multi-partition struct');
    outStats = stats{1}.blockStats;
else
    disp('-- stats from multiple partitions will be concatenated');
    for i = 1:numel(stats) % iterate test sets from each crossval experiment and merge
        disp(['--- parsing partition ',num2str(i)]);
        if i ==1
            outStats.PLabels         = stats{i}.blockStats.PLabels;
            outStats.Scores          = stats{i}.blockStats.Scores;
            outStats.BlockNames      = stats{i}.blockStats.BlockNames;
            outStats.outClasses      = stats{i}.blockStats.outClasses;
        else
            outStats.PLabels     = [outStats.PLabels;stats{i}.blockStats.PLabels];
            outStats.Scores      = [outStats.Scores;stats{i}.blockStats.Scores];
            outStats.BlockNames  = [outStats.BlockNames;stats{i}.blockStats.BlockNames];
            sanityCheck(~any(outStats.outClasses~=stats{i}.blockStats.outClasses),...
                ['output classes in partition ',num2str(i),' match the 1st']);
        end
        outStats.partitions{i} = stats{i}.blockStats.BlockNames;
    end
end
end


