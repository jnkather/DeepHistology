% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this function is a general auxiliary function 
% copy field values from struct B to struct A

function A = copyfields(A,B,flds)

     for i = 1:numel(flds)
         A.(flds{i}) = B.(flds{i});
     end

end