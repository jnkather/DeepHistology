% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% display all fields of a given struct, for debugging

function dispAllFields(structIn,varargin)

allFields = fieldnames(structIn);
if nargin == 1
    disp('++++++++');
    indent = '';
else
    indent = varargin{1};
end

for i = 1:numel(allFields)
    currField = allFields{i};
    switch class(structIn.(currField))
        case 'double'
            disp([indent,currField,': ',num2str(structIn.(currField))]);
        case 'logical'
            disp([indent,currField,': ',num2str(double(structIn.(currField)))]);
        case 'char'
            disp([indent,currField,': ',structIn.(currField)]);
        case 'cell'
            disp([indent,currField,': <cell>']); 
        case 'struct'
            % recursive call this function
            disp([indent,currField,': ...']); 
            dispAllFields(structIn.(currField),'    ');
        otherwise
            disp([indent,currField,': <',class(structIn.(currField)),'>']);
    end
end

if nargin == 1
    disp('++++++++');
end

end