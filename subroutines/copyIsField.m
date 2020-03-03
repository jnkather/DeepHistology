% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this function is a general auxiliary function
% it will copy a field from structure A to structure B
% if the field exists

function out = copyIsField(fin,tfield,defvalue)

    if isfield(fin,tfield) && ~isempty(fin.(tfield))
            out = fin.(tfield);
        else
            out = defvalue;
    end

end