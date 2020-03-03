% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this this script will load CLINI and SLIDE table and will load them and match
% them up after performing a sanity test

function tMERGE = getAnnotationData(cnst)

   % empty cells will be converted to 'x'
   prm.removeTargets = categorical(getDefaultDictionary('invalid_classes'));
   
   % read the clinical table and the slide table
   [tCLINI,tSLIDE] = readProjectTables(cnst);
   
   % optional: subset clinical table
   if isfield(cnst,'subsetTargetsBy') && ~isempty(cnst.subsetTargetsBy)
       disp('-- will start subsetting of target table (assumes subset level is a string)');   
       sanityCheck(any(strcmp(tCLINI.Properties.VariableNames,cnst.subsetTargetsBy)),'target subset exists');
       sanityCheck(any(strcmp(unique(tCLINI.(cnst.subsetTargetsBy)),cnst.subsetTargetsLevel)),'level subset exists');
       disp(['--- before subsetting, there are ',num2str(size(tCLINI,1)),' entries in the CLINI table']);   
       tCLINI(~strcmp(tCLINI.(cnst.subsetTargetsBy),cnst.subsetTargetsLevel),:) = [];
       disp(['--- after subsetting, there are ',num2str(size(tCLINI,1)),' entries in the CLINI table']);     
   else
       disp('-- no subsetting of target table');
   end

   % perform basic sanity checks
   sanityCheck(any(strcmp(tCLINI.Properties.VariableNames,'PATIENT')),'PATIENT column in CLINI');
   sanityCheck(any(strcmp(tSLIDE.Properties.VariableNames,'PATIENT')),'PATIENT column in SLIDE');
   sanityCheck(any(strcmp(tSLIDE.Properties.VariableNames,'FILENAME')),'FILENAME column in SLIDE');
   sanityCheck(numel(unique(tCLINI.PATIENT))==numel(tCLINI.PATIENT),'no duplicate patients CLINI');
   sanityCheck(numel(unique(tSLIDE.FILENAME))==numel(tSLIDE.FILENAME),'no duplicate filenames SLIDE');
   sanityCheck(any(strcmp(tCLINI.Properties.VariableNames,cnst.annotation.targetCol)),'target variable CLINI');
   
   % are there patients with no slides?
   missCount = 0;
   for cp = 1:numel(tCLINI.PATIENT)
       currPatient = char(tCLINI.PATIENT(cp));
       if ~any(strcmp(tSLIDE.PATIENT,currPatient))
           disp(['--- did not find a slide table entry for patient ',currPatient]);
           missCount = missCount +1;
       end
   end
   disp(['-- there were ',num2str(missCount),' out of ',num2str(numel(tCLINI.PATIENT)),...
                ' patients without any slide table entry']);    
   
   % prepare merged table
   tMERGE.FILENAME = tSLIDE.FILENAME;
   if isnumeric(tMERGE.FILENAME)
       tMERGE.FILENAME = cellstr(num2str(tMERGE.FILENAME));
       disp('--- detected and fixed numerical FILENAME field');
   end
   tMERGE.PATIENT  = tSLIDE.PATIENT;
   if isnumeric(tMERGE.PATIENT)
       tMERGE.PATIENT = cellstr(num2str(tMERGE.PATIENT));
       disp('--- detected and fixed numerical PATIENT field');
   end
   
   targetData = tCLINI.(cnst.annotation.targetCol);
   % numerical targets with more than cnst.binarizeThresh levels will be 
   % converted to "HI", "LO" and "UNDEF". 
   
   if isnumeric(targetData)
       ulevels = numel(unique(targetData(~isnan(targetData))));
   else
       ulevels = numel(unique(targetData));
   end
   disp(['-- before binarization checkpoint, there are ',...
       num2str(ulevels),' unique target levels']);
   if ulevels>cnst.binarizeThresh % if there are many unique target levels check for numbers stored as string
       if isnumeric(targetData)
           disp(['--- detected NUMERICAL target with ',num2str(sum(isnan(targetData))),' NaNs']);
           targetData = binarizeNumerical(targetData,cnst.binarizeQuantile); 
           disp('--- converted continuous numerical target to binary string');
       else
           disp('--- detected suspicious NON-NUMERICAL target... will try to convert to numerial');
           try
           targetData = cellfun(@str2double,targetData);
           if sum(isnan(targetData))<numel(targetData) % if conversion worked
               targetData = binarizeNumerical(targetData,cnst.binarizeQuantile);
               disp('--- numerized and then converted continuous numerical target to binary string');  
           else
               warning('--- conversion to numerical did not work, falling back.');
               targetData = tCLINI.(cnst.annotation.targetCol);
           end
           catch
               warning('could not convert target to numeric. Falling back.');
               targetData = tCLINI.(cnst.annotation.targetCol);
           end
       end
   end 

   if isnumeric(targetData) % make valid name
        allTargets = categorical(matlab.lang.makeValidName(cellstr(num2str(targetData))));
   else 
        allTargets = categorical(matlab.lang.makeValidName(targetData));
   end
   allTargets = categorical(cellstr(allTargets)); % workaround 4 Matlab bug
   
   sanityCheck(numel(unique(allTargets))>1,'more than one target level');
   
   disp('found the following target levels: ');
   disp(cellstr(unique(allTargets)'));

   % match target variable to SLIDE table
   missCount = 0;
   for cp = 1:numel(tMERGE.PATIENT)
       currPatient = char(tMERGE.PATIENT(cp));
       matchPatClin = strcmp(tCLINI.PATIENT,currPatient);
       if matchPatClin == 0
           tMERGE.TARGET(cp) = categorical(NaN);
           disp(['-- could not match patient ',currPatient,', setting TARGET empty']);
           missCount = missCount +1;
       elseif matchPatClin>1
           error(['multiple matches for patient ',currPatient]);
       else % all is good
           tMERGE.TARGET(cp) = allTargets(matchPatClin);
       end
   end
   disp(['-- there were ',num2str(missCount),' out of ',num2str(numel(tSLIDE.PATIENT)),...
             ' patients with no match in CLINI table']);    
   
   disp('----- the table has the following target levels: ');
   disp(cellstr(unique(tMERGE.TARGET))); 
   % clean up target variable
   disp('----- removing instances with undefined target');
   removeMe = find(isundefined(tMERGE.TARGET)); % remove missing targets
   for ct = 1:numel(prm.removeTargets)          % remove invalid targets
       removeMe = [removeMe(:);find(tMERGE.TARGET==prm.removeTargets(ct))'];
   end
   disp(['-- merged table has ',num2str(numel(unique(tMERGE.PATIENT))),' patients']);
   disp(['-- merged table has ',num2str(numel(unique(tMERGE.FILENAME))),' slides']);
   disp('----- the table has the following target levels: ');
   disp(cellstr(unique(tMERGE.TARGET)));
   disp(['--- will remove ',num2str(numel(removeMe)),' slides']);
   tMERGE.PATIENT(removeMe) = [];
   tMERGE.FILENAME(removeMe) = [];
   tMERGE.TARGET(removeMe) = [];
   disp(['-- merged table has ',num2str(numel(unique(tMERGE.PATIENT))),' patients']);
   disp(['-- merged table has ',num2str(numel(unique(tMERGE.FILENAME))),' slides']);
   disp('----- the final table has the following target levels: ');
   disp(cellstr(unique(tMERGE.TARGET)));
   if numel(cellstr(unique(tMERGE.TARGET)))<2
       tMERGE = [];
       warning('there are not enough target levels.');
   end
end
