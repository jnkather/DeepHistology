% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this function will take a target name (something to be predicted from
% histology images, e.g. "MSI") and assign it to one of these classes:
% mutation-any, mutation-driver, pathology-subtype, signature, etc ...
% this is for visualization of results

function classOut = getTargetClass(dataIn)

    disp('--- replacing class names for better legibility');
    
    % preprocess
    classOut = dictionaryReplace(dataIn,getDefaultDictionary('classes'));

    % replace 
    classOut(contains(classOut,'anymut')) = {'mutation (any)'};
    classOut(contains(classOut,'driver')) = {'mutation (driver)'};
    classOut(contains(classOut,'subtype')) = {'signature/subtype'};
    classOut(contains(classOut,'signature')) = {'signature/subtype'};
    classOut(contains(classOut,'standard')) = {'standard'};
    classOut(contains(classOut,'experimental')) = {'experimental'};
    
end