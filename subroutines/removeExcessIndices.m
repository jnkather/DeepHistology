% JN Kather 2019

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
       warning('could not remove excess indices because there is no excess');
       pause(1);
    end

end