% JN Kather 2019

function sanityCheck(criterion,message)

if criterion
    disp(['-- sanity check PASSED for: ',char(message)]);
else
    error(['-- sanity check FAILED for: ',char(message)]);
end
end
