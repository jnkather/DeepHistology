% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this function is a general auxiliary function:
%       containsmember is to ismember
%   as  contains       is to strcmp

function maskOut = containsmember(A,B)

maskOut = zeros(size(A));

for i=1:numel(B)
    maskOut = maskOut | contains(A,B{i});
    if mod(i,round(numel(B)/5))==0
        disp(['... parsed ',num2str(i/numel(B)*100,2),'%']);
    end
end
    
end