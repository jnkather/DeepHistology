% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this function is for batch-replacing substrings in 
% a list of strings

function myText = dictionaryReplace(myText,dict)

for i = 1:size(dict,1)
   
    myText = strrep(myText,dict{i,1},dict{i,2});
    
end

end