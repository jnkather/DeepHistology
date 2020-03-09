function foldr = getDeepestFolder(pathIn)

parentf = fileparts(pathIn);
seps = strfind(parentf,filesep);
foldr = parentf((seps(end)+1):end);

end