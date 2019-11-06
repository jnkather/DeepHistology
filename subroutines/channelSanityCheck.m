% JN Kather 2019

% this function will check if the index in baseChannel actually refers to
% the widest image (the base)

function channelSanityCheck(cimg,baseChannel)
    
    sq = @(varargin) cell2mat(varargin)';
    infoImg = imfinfo(fullfile(cimg.Path,[cimg.Name,cimg.ext]));
    allWidths = sq(infoImg.Width);
    if max(allWidths)==allWidths(baseChannel)
        disp('--- base channel sanity check OK');
    else
        error('--- base channel sanity check failed');
    end

end

