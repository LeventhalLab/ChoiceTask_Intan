parentDir = 'X:\Neuro-Leventhal\data\ChoiceTask\RegionalSummary';
allEntries=dir(parentDir);
% Filter only directories, excluding '.' and '..'
isSubFolder = [allEntries.isdir] & ~ismember({allEntries.name}, {'.', '..'});
regionsAvailable = {allEntries(isSubFolder).name};
behavioralFeature='correct_cuedleft'


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
    controlEphysProperties=table();
    lesionEphysProperties=table();
    controlUnitFRs=[];
    
    lesionUnitFRs=[];
    %eventsOverlayed(regionUnits,unitNames,behavioralFeatures)
    for u=1:length(unitNames)
        unitID=unitNames{u};
        unitFR=regionUnits.(unitID).unitMetrics.meanFiringRate;
        spikeTimes=regionUnits.(unitID).unitMetrics.clusterSpikes;
        ephysProp=regionUnits.(unitID).unitMetrics.ephysProperties;
        acg=regionUnits.(unitID).unitMetrics.unitACG;
        ISIs=diff(spikeTimes);
        if strcmp(regionUnits.(unitID).unitMetrics.treatement,'control')
            controlUnitFRs(u)=unitFR;
        else
            lesionUnitFRs(u)=unitFR;
        end
        if strcmp(regionUnits.(unitID).unitMetrics.treatement, 'control')
            controlEphysProperties = [controlEphysProperties; ephysProp];
        else
            lesionEphysProperties = [lesionEphysProperties; ephysProp];
        end
        %unitClass=unitClassificationByFR(unitFR,spikeTimes);
            % if regionUnits.(unitID).unitMetrics.
        % controlRegionFRs(u)=unitFR;
    end
    if ~isempty(controlUnitFRs)
        regionUnits.regionMetrics.controlUnitFRs=controlUnitFRs;
    end
    if ~isempty(lesionUnitFRs)
        regionUnits.regionMetrics.lesionUnitFRs=lesionUnitFRs;
    end
    if ~isempty(controlEphysProperties)
        regionUnits.regionMetrics.controlEphysProperties=controlEphysProperties;
    end
    if ~isempty(lesionEphysProperties)
        regionUnits.regionMetrics.lesionEphysProperties=lesionEphysProperties;
    end
    mean3RegionFR=movmean(regionFRs,3);
    %meanRegionFR=
    stdMeanRegionFR=std(mean3regionFRs);
end
