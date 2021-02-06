
% assumes that the result file is in the workspace

trueCategory = 'MSIH';

try
    res = resultCollection;
    cnst = resultCollection.cnst;
catch
    warning('detected deploy file');
    res = resultCollection{1};
end

tt = table(res.patientStats.rawData.patientNames',...
    res.patientStats.rawData.trueCategory',...
        res.patientStats.rawData.predictions.(trueCategory)');
tt.Properties.VariableNames = {'PATIENT','TRUE','SCORE'};
writetable(tt,strcat(res.cnst.codename,'-',res.cnst.experimentName,'.xlsx'));

clear all