% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this is a general auxiliary function to remove randomly
% chosen entries from a list  

function myBoolMatOut = removeExcessIndices(myBoolMat,numTrue)
    rng('default');
    myBoolMat = logical(myBoolMat); % ensure that bool is bool
    myBoolMatOut = false(size(myBoolMat));
    excess = sum(myBoolMat)-numTrue;
    if excess>0
       myHits = find(myBoolMat);
       myHits = myHits(randperm(numel(myHits))); % shuffle hits
       myBoolMatOut(myHits(1:numTrue)) = true; 
    else
       error('this should never happen (there is no excess)');
    end

end