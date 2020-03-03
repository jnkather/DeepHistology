% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% split image data store of blocks for cross validation

function [imdsContainer,AnnData] = splitImdsForXVal(allBlocksLabeled,AnnData,cnst)

    disp('-- starting to split the patient cohort for cross validation');        
    ugroups = unique(AnnData.TARGET); 
    
    AnnData.PARTITION = uint8(nan(1,numel(AnnData.TARGET))); % preallocate
    for ui = 1:numel(ugroups) % split each target group separately for balance
        disp(['--- splitting label ',char(cellstr(ugroups(ui)))]);
        % locate all unique patients in the target group
        currUniqPats = unique(AnnData.PATIENT(AnnData.TARGET == ugroups(ui)));
        % calculate the fraction of this group in the total cohort
        currUniqPatsFraction = numel(currUniqPats)/numel(unique(AnnData.PATIENT));
        disp(['-- the current group makes up ',num2str(currUniqPatsFraction),' of the total cohort']);
        
        if isfield(cnst,'patientsPerPartition') && ~isempty(cnst.patientsPerPartition)
            disp('-- enforcing upper limit for # patients in partition (for learning curve)');
            ids = splitListFixedNum(numel(currUniqPats),cnst.foldxval,ui, round(currUniqPatsFraction*cnst.patientsPerPartition));
        else
            disp('-- naive balanced splitting of patients in partitions (default behavior)');
            ids = splitList(numel(currUniqPats),cnst.foldxval,ui);
        end
        if isempty(ids)
            warning('split list failed... aborting');
            imdsContainer = [];
            AnnData = [];
            return;
        end 
        for up = 1:numel(currUniqPats)
            currPatient = currUniqPats{up};
            AnnData.PARTITION(strcmp(AnnData.PATIENT,currPatient)) = ids(up);
        end    
    end
    
    allBlockNames = allBlocksLabeled.Files;
    % remove rescue string from block name
    allBlockWSIs = block2filename(allBlockNames);
    % SPLIT PATIENT COHORT for a balanced cross validation
    for ua = 1:cnst.foldxval
        disp(['-- creating partition ',num2str(ua),' of ',num2str(cnst.foldxval)]);
        % find all patients for current partition
        matchingWSI = AnnData.FILENAME(AnnData.PARTITION == ua);
        sanityCheck(numel(matchingWSI)== numel(unique(matchingWSI)),'number of filenames');
        mB = containsmember(allBlockWSIs',matchingWSI');
        disp(['--- matched ',num2str(sum(mB)),' blocks to this group']);
        sanityCheck(sum(mB)>0,'not zero blocks');
        disp('--- starting to subset image datastore...');
        imdsContainer{ua} = copy(allBlocksLabeled);
        imdsContainer{ua}.Files(~mB) = []; % remove non-matching blocks
        disp('--- removed non-matching blocks...');
    end
    
end