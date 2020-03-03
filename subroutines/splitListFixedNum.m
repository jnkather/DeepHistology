% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this is the same function as splitList, but enforce a fixed number of elements for
% the first N-1 partitions.... all remaining items will be allocated to
% partition N

function ids = splitListFixedNum(listLength,numParts,randSeed,numItems)

    if numParts<=listLength
        disp('--- there are more patients than partitions in this group... good.');
        % create group ID list
        ids = repmat(1:numParts,1,min(numItems,ceil(listLength/numParts)));
        if length(ids)<listLength
            ids(length(ids)+1:listLength) = numParts; % remaining items go in the last partition
        end
        % shuffle list
        rng(randSeed);
        ids = ids(randperm(numel(ids)));
        ids = ids(1:listLength); % crop list to target length
    else
        disp(['--- there are ',num2str(numParts),' partitions and ',num2str(listLength),...
            ' patients in this group :-(']);
        warning('there are fewer patients than partitions in this group ... aborting');
        ids = [];
    end
    
    % debug
    figure
    subplot(1,2,1)
    hold on
    histogram(ids)
    title('items per partition');
    subplot(1,2,2)
    hold on
    plot(ids)
    title('randomness');
    drawnow

end