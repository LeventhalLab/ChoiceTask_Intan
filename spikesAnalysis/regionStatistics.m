function [unitTable,saveRegionFlag] = regionStatistics(regionUnits)
unitNames = fieldnames(regionUnits);  % Get all unitIDs
allData = {};  % Initialize cell array to hold all table rows

for u = 1:numel(unitNames)
    unitID = unitNames{u};
    
    % Check unitMetrics exists
    if ~isfield(regionUnits.(unitID), 'unitMetrics')
        continue;
    end
    
    unit = regionUnits.(unitID).unitMetrics;

    % Skip units without treatment info
    if ~isfield(unit, 'treatement')
        continue;
    end
    treatment = unit.treatement;
    if isfield(unit,'UIDs')
        try
            MatchedUnitID=unit.UIDs;
        catch ME
            keyboard
        end
    else
        keyboard
        MatchedUnitID=[];
    
    end
    
    % Direction selectivity if available
    if isfield(unit, 'unitClass') && isstruct(unit.unitClass.directionDependence)
        try
            directionSelectivity = unit.unitClass.directionDependence.direction;
        catch ME
            
            if ~isfield(unit.unitClass.directionDependence,'direction') || isempty(unit.unitClass.directionDependence.direction)
                directionSelectivityBehaviors={'correct_cuedleft','correct_cuedright'}; 
                unitSelectivity=unitDirectionSelectivity(regionUnits.(unitID).behavioralFeatures,unit.clusterSpikes, directionSelectivityBehaviors,...
                   'centerOut' ,[-1 1],0.02,5000);
                regionUnits.(unitID).unitMetrics.unitClass.directionDependence=unitSelectivity;
                saveRegionFlag=1;
                if isfield(unitSelectivity,'direction')
                    directionSelectivity=unitSelectivity.direction;
                else
                    directionSelectivity=unitSelectivity;
                end
            end
        end
    elseif isfield(unit, 'unitClass') && (isfield(unit.unitClass,'directionDependence') && ~isempty(unit.unitClass.directionDependence))
        if isstruct(unit.unitClass.directionDependence) %probably not needed
            keyboard
        end
        directionSelectivity = unit.unitClass.directionDependence;
    elseif strcmp(treatment,'lesion') && isempty(unit.unitClass.directionDependence)
        directionSelectivity='undeterminable'; %update region units?
    else
        disp('UnitSelectivity not found for a unit reprocessing')
        if isempty(unit.unitClass.directionDependence)
            directionSelectivityBehaviors={'correct_cuedleft','correct_cuedright'}; 
            unitSelectivity=unitDirectionSelectivity(regionUnits.(unitID).behavioralFeatures,unit.clusterSpikes, directionSelectivityBehaviors,...
               'centerOut' ,[-1 1],0.02,5000);
            regionUnits.(unitID).unitMetrics.unitClass.directionDependence=unitSelectivity;
            saveRegionFlag=1;
            if isfield(unitSelectivity,'direction')
                directionSelectivity=unitSelectivity.direction;
            else
                directionSelectivity=unitSelectivity;
            end
        end
    end

    % Unit classification type
    if isfield(unit, 'unitClass') && isfield(unit.unitClass, 'type')
        type = unit.unitClass.type;
    else
        type = 'nonResponsive';
    end

    % Behavioral classification features
    if isfield(unit, 'unitClass')
        unitClass = unit.unitClass;
        behaviorFields = setdiff(fieldnames(unitClass), {'type', 'directionDependence'});

        for b = 1:length(behaviorFields)
            behavior = behaviorFields{b};
            behaviorInfo = unitClass.(behavior);

            % Default event values
            primaryEvent = '';
            secondaryEvent = '';
            primaryZScoreValue = NaN;
            secondaryZScoreValue = NaN;

            if isfield(behaviorInfo, 'primaryEvent')
                primaryEvent = behaviorInfo.primaryEvent;
            end
            if isfield(behaviorInfo, 'secondaryEvent')
                secondaryEvent = behaviorInfo.secondaryEvent;
            end
            if isfield(behaviorInfo, 'primaryZScoreValue')
                primaryZScoreValue = behaviorInfo.primaryZScoreValue;
            end
            if isfield(behaviorInfo, 'secondaryZScoreValue')
                secondaryZScoreValue = behaviorInfo.secondaryZScoreValue;
            end

            % Add row
            row = {unitID, treatment, directionSelectivity, type, behavior, primaryEvent, secondaryEvent, primaryZScoreValue, secondaryZScoreValue,MatchedUnitID};
            allData(end+1, :) = row;
        end
    else
        % If unitClass does not exist, still log as nonResponsive with no behavior
        row = {unitID, treatment, '', 'nonResponsive', '', '', '', NaN, NaN};
        allData(end+1, :) = row;
    end
end

% Convert to table
unitTable = cell2table(allData, 'VariableNames', ...
    {'unitID', 'treatment', 'directionSelectivity', 'type', ...
     'behavior', 'primaryEvent', 'secondaryEvent', 'primaryZScoreValue', 'secondaryZScoreValue','MatchedUnitID'});

% Optional: sort by treatment and unitID
unitTable = sortrows(unitTable, {'treatment', 'unitID'});
if  ~exist('saveRegionFlag')
    saveRegionFlag=0;
end
end




% unitNames = fields(regionUnits);
% if ~isfield(regionUnits,'regionMetrics')
%     regionUnits.regionMetrics=struct();
%     regionUnits.regionMetrics.lesionUnits={};
%     regionUnits.regionMetrics.controlUnits={};
% else 
%     if ~isfield(regionUnits.regionMetrics,'lesionUnits')
%         regionUnits.regionMetrics.lesionUnits={};
%     end
%     if ~isfield(regionUnits.regionMetrics,'controlUnits')
%         regionUnits.regionMetrics.controlUnits={};
%     end
% end
% regionUnits.regionMetrics.numUnits=length(unitNames);
% controlEphysProperties=table();
% lesionEphysProperties=table();
% controlUnitFRs=[];
% regionSummaryStatistics={};
% controlResponsiveUnits=[];
% lesionResponsiveUnits=[];
% controlDirection={};
% lesionDirection={};
% 
% 
% lesionUnitFRs=[];
%     %eventsOverlayed(regionUnits,unitNames,behavioralFeatures)
%     for u=1:length(unitNames)
%         unitID=unitNames{u};
%         % unitFR=regionUnits.(unitID).unitMetrics.meanFiringRate;
%         % spikeTimes=regionUnits.(unitID).unitMetrics.clusterSpikes;
%         % ephysProp=regionUnits.(unitID).unitMetrics.ephysProperties;
%         % acg=regionUnits.(unitID).unitMetrics.unitACG;
% 
%         % ISIs=diff(spikeTimes);
%         if strcmp(regionUnits.(unitID).unitMetrics.treatement,'control')
%             %% Create variables that will become the struct that saves the info maybe do it at the END?????
%             if isfield(regionUnits.(unitID).unitMetrics,'unitClass')
%                 unitClass=regionUnits.(unitID).unitMetrics.unitClass;
%                 if isfield(unitClass, 'directionDependence')
%                     controlDirection{end+1}=unitClass.directionDependence.direction;
%                 end
%                 controlResponsiveUnits{end+1}=unitClass.type;
%                 for f=1:length(fields(unitClass))
%                     behavior=fields(unitClass{u});
%                     if strcmp(behavior,'directionDependence') || strcmp(behavior,'type')
%                         continue
%                     end
%                     if ~isfield(regionUnits.regionMetrics.controlUnits,behavior)
%                         regionUnits.regionMetrics.controlUnits.(behavior)={};
%                     end
%                     if isfield(unitClass.(behavior),'primaryEvent')
%                         regionUnits.regionMetrics.controlUnits.(behavior).primaryEvents{end+1}=primaryEvent;
%                     end
%                     if isfield(unitClass.(behavior),'secondaryEvent')
%                         regionUnits.regionMetrics.controlUnits.(behavior).secondaryEvents{end+1}=secondaryEvent;
%                     end
%                 end
%             end
%         end
%         if strcmp(regionUnits.(unitID).unitMetrics.treatement,'control')
%             controlUnitFRs(u)=unitFR;
%         else
% 
%         end
%         if strcmp(regionUnits.(unitID).unitMetrics.treatement, 'control')
%             controlEphysProperties = [controlEphysProperties; ephysProp];
%         else
%             lesionEphysProperties = [lesionEphysProperties; ephysProp];
%         end
%         %unitClass=unitClassificationByFR(unitFR,spikeTimes);
%             % if regionUnits.(unitID).unitMetrics.
%         % controlRegionFRs(u)=unitFR;
%     end
%     if ~isempty(controlUnitFRs)
%         regionUnits.regionMetrics.controlUnitFRs=controlUnitFRs;
%     else
%         regionUnits.regionMetrics.controlUnitFRs=NaN;
%     end
%     if ~isempty(lesionUnitFRs)
%         regionUnits.regionMetrics.lesionUnitFRs=lesionUnitFRs;
%     else
%         regionUnits.regionMetrics.lesionUnitFRs=NaN;
%     end
%     if ~isempty(controlEphysProperties)
%         regionUnits.regionMetrics.controlEphysProperties=controlEphysProperties;
%     else
%         regionUnits.regionMetrics.controlEphysProperties=NaN;
%     end
%     if ~isempty(lesionEphysProperties)
%         regionUnits.regionMetrics.lesionEphysProperties=lesionEphysProperties;
%     else
%         regionUnits.regionMetrics.lesionEphysProperties=NaN;
%     end
% 
%     mean3RegionFR=movmean(regionFRs,3);
% 
%     stdMeanRegionFR=std(mean3regionFRs);