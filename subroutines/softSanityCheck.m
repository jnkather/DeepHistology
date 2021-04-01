% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this is a general auxiliary function 
% for performing data checks

function softSanityCheck(criterion,message)

if criterion
    disp(['-- soft sanity check PASSED for: ',char(message)]);
else
    warning(['-- soft sanity check FAILED for: ',char(message)]);
end
end
