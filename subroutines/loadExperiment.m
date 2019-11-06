% JN Kather 2019

function cnst = loadExperiment(codename)

try % load source data
    currentData = fileread(fullfile('./experiments/',[lower(codename),'.txt']));
catch
    error(['did not find this source file: ',[lower(codename),'.txt']]);
end

try % decode data
    cnst = jsondecode(currentData); 
catch
    error(['could not decode source data for: ',[lower(codename),'.txt']]);
end   

% ensure consistent file names
cnst.folderName.Temp = fullfile(cnst.folderName.Temp); 

% create random experiment ID
rng('shuffle');
cnst.experimentName = randseq(12,'Alphabet','aa');
disp(['--- this is experiment # ',cnst.experimentName]);

% save code name
cnst.codenameFile = cnst.codename;
cnst.codename = codename;

% output status
disp(['successfully loaded source file: ',[lower(codename),'.txt']]);


end