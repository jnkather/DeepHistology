% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this function will concatenate predictions in a cross-
% validated experiment 

function outStats = concatenatePredictions(stats)

if numel(stats) == 1
    disp('-- there is only one partition, containing the full stats (no crossval)');
    outStats = stats.blockStats;
else
    disp('-- stats from multiple partitions will be concatenated');
    for i = 1:numel(stats) % iterate test sets from each crossval experiment and merge
        disp(['--- parsing partition ',num2str(i)]);
        if i ==1
            outStats.PLabels     = stats{i}.blockStats.PLabels;
            outStats.Scores      = stats{i}.blockStats.Scores;
            outStats.BlockNames  = stats{i}.blockStats.BlockNames;
        else
            outStats.PLabels     = [outStats.PLabels;stats{i}.blockStats.PLabels];
            outStats.Scores      = [outStats.Scores;stats{i}.blockStats.Scores];
            outStats.BlockNames  = [outStats.BlockNames;stats{i}.blockStats.BlockNames];
        end
        outStats.partitions{i} = stats{i}.blockStats.BlockNames;
    end
end
end


