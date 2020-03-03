% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this is a general auxiliary function 
% for performing data checks

function sanityCheck(criterion,message)

if criterion
    disp(['-- sanity check PASSED for: ',char(message)]);
else
    error(['-- sanity check FAILED for: ',char(message)]);
end
end
