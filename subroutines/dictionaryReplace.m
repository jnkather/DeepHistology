function myText = dictionaryReplace(myText,dict)


for i = 1:size(dict,1)
   
    myText = strrep(myText,dict{i,1},dict{i,2});
    
end

end