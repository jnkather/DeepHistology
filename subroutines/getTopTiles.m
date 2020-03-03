% JN Kather 2018-2020
% This is part of the DeepHistology repository
% License: see separate LICENSE file 
% 
% documentation for this function:
% this is used to collect the top tiles for the top 
% patients for visualization and interpretability

function [dcollect,sparsePatients] = getTopTiles(resultCollection,cnst,currTarget)

    disp('loading all blocks in image datastore');
    uCategories = unique(resultCollection.patientStats.rawData.trueCategory);
    % prepare data for tile-patient assignment
    cnst.annotation.targetCol = currTarget;
    AnnData = getAnnotationData(cnst);
    [~,newBlockStats] = predictions2performance(resultCollection.blockStats,AnnData,cnst);

    if isfield(cnst,'doPlotHistogram') && cnst.doPlotHistogram
        figure
        hi = histogram(categorical(newBlockStats.parentPatient),'DisplayOrder','ascend');
        disp('--- found patients with few tiles, you might want to review their WSIs:');
        sparsePatients = hi.Categories(hi.Values<=cnst.exportTopTiles);
        disp(sparsePatients);
    else
        sparsePatients = [];
    end
    % use highest scoring tiles from the highest scoring true positive patients
    % require each patient to have at least as many tiles as will be plotted
    for icat = 1:numel(uCategories)
        currCategory = uCategories(icat); % get current category
        currPatientsMask = resultCollection.patientStats.rawData.trueCategory == currCategory;

        % remove sparse patients from this list
        if ~isempty(sparsePatients)
            [~,rmpatients,~] = intersect(resultCollection.patientStats.rawData.patientNames,sparsePatients);
            disp(['--- removed ',num2str(sum(rmpatients)),' sparse patients from visualization candidates']);
            currPatientsMask(rmpatients) = 0; % removing sparse patients
        end
        
        % find all patients belonging to this category (ground
        % truth data) & get their patient-level predictions, then 
        % find the N top patients
        currPatients = resultCollection.patientStats.rawData.patientNames(currPatientsMask);
        currPatPredictions = resultCollection.patientStats.rawData.predictions.(char(cellstr(currCategory)))(currPatientsMask);
        [uup,uip] = sort(currPatPredictions,'descend');
        targetPatients = currPatients(uip(1:min(cnst.topPatients,numel(currPatients))));

        % iterate top patients and find their N top tiles
        for ipat = 1:numel(targetPatients)
            thisPatientID = targetPatients(ipat);
            thisPatientTiles = find(strcmp(newBlockStats.parentPatient, thisPatientID));
            [uus,uis] = sort(newBlockStats.Scores(thisPatientTiles,uCategories==currCategory),'descend');

            % collect tiles and prepare montage for export
            uis((cnst.exportTopTiles+1):end) = [];
            uus((cnst.exportTopTiles+1):end) = [];
            if ipat ==1
                dcollect.(char(currCategory)).TileNames = newBlockStats.BlockNames(thisPatientTiles(uis));
                dcollect.(char(currCategory)).ParentNames = repmat(cellstr(thisPatientID),cnst.exportTopTiles,1);
                dcollect.(char(currCategory)).TileScores = uus;
                dcollect.(char(currCategory)).PatientScores = repmat(uup(ipat),cnst.exportTopTiles,1);
            else
                dcollect.(char(currCategory)).TileNames = [dcollect.(char(currCategory)).TileNames; newBlockStats.BlockNames(thisPatientTiles(uis))];
                dcollect.(char(currCategory)).ParentNames = [dcollect.(char(currCategory)).ParentNames; repmat(cellstr(thisPatientID),cnst.exportTopTiles,1)];
                dcollect.(char(currCategory)).TileScores = [dcollect.(char(currCategory)).TileScores;uus];
                dcollect.(char(currCategory)).PatientScores = [dcollect.(char(currCategory)).PatientScores; repmat(uup(ipat),cnst.exportTopTiles,1)];
            end
        end

    end % end of category iteration
    
    

end