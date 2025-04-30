parentDir = 'X:\Neuro-Leventhal\data\ChoiceTask\RegionalSummary';
allEntries=dir(parentDir);
% Filter only directories, excluding '.' and '..'
isSubFolder = [allEntries.isdir] & ~ismember({allEntries.name}, {'.', '..'});
regionsAvailable = {allEntries(isSubFolder).name};



for i=1:length(regionsAvailable)
    region=regionsAvailable{i};
    regionPath=fullfile(parentDir,region);
    regionPath=cd(regionPath);
    matFileName=strcat(region,'_unitSummary.mat');
    regionMatFile=load(matFileName);
    regionUnits=regionMatFile.regionUnits;
    unitNames = fields(regionUnits);
    if ~isfield(regionUnits,'regionMetrics')
        regionUnits.regionMetrics=struct();
    end
    regionUnits.regionMetrics.numUnits=length(unitNames);
    for u=1:length(unitNames)
        unitID=unitNames{u};
        unitFR=regionUnits.(unitID).unitMetrics.meanFiringRate;
        spikeTimes=regionUnits.(unitID).unitMetrics.clusterSpikes;
        if strcmp(regionUnits.(unitID).unitMetrics.treatement,'control')
            controlUnitFRs(u)=unitFR;
        else
            lesionUnitFRs(u)=unitFR;
        end
        unitClass=unitClassificationByFR(unitFR,spikeTimes);
            % if regionUnits.(unitID).unitMetrics.
        % controlRegionFRs(u)=unitFR;
    end
    regionUnits.regionMetrics.controlUnitFRs=controlUnitFRs;
    regionUnits.regionMetrics.lesionUnitFRs=lesionUnitFRs;
    mean3RegionFR=movmean(regionFRs,3);
    %meanRegionFR=
    stdMeanRegionFR=std(mean3regionFRs);
end
