% JN Kather 2019
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