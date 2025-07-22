function [filteredUnitNames,eventHeatMaps,primaryEvents,secondaryEvents]=heatMapPlotting(regionUnits,params)

%function that plots and saves heat maps using given parameters and 
%region units

if isfield(params, 'excludeNonSelectiveUnits')
    excludeNonSelectiveUnits=params.excludeNonSelectiveUnits; %1 recommended
else
    excludeNonSelectiveUnits=0;
end
if isfield(params, 'excludeSelectiveUnits')
    excludeSelectiveUnits=params.excludeSelectiveUnits; %0 recommended
else
    excludeSelectiveUnits=0;
end
if isfield(params,'excludeUndeterminable')
    excludeUndeterminable=params.excludeUndeterminable; %1 recommended
else
    excludeUndeterminable=0;
end
if isfield(params,'excludeContralateral')
    excludeContralateral=params.excludeContralateral;
else
    excludeContralateral=0;
end
if isfield(params, 'excludeIpsilateral')
    excludeIpsilateral=params.excludeIpsilateral;
else
    excludeIpsilateral=0;
end
if isfield(params,'excludeNonResponsive')
    excludeNonResponsive=params.excludeNonResponsive;
else
    excludeNonResponsive=0;
end
zScale=params.zScale;
useAbsoluteZ=params.useAbsoluteZ;
behaviorField = params.behaviorField;
potentialeventNames=params.potentialeventNames;
treatmentToProcess=params.treatmentToProcess;
region=params.region;
plotTitle=params.heatMapTitle;
savePath=params.regionSummaryPath;

unitNames = fields(regionUnits);
unitNames = sort(unitNames); %%%% start of new code
eventOrder = potentialeventNames;
defaultRank = length(eventOrder) + 1;

primaryEvents = cell(size(unitNames));
secondaryEvents = cell(size(unitNames));

eventRanks = zeros(size(unitNames));

for u = 1:length(unitNames)
    unitID = unitNames{u};
    if isfield(regionUnits.(unitID).unitMetrics.unitClass, behaviorField)
        unitClass = regionUnits.(unitID).unitMetrics.unitClass;
        if isfield(unitClass.(behaviorField), 'primaryEvent')
            primaryEvent = unitClass.(behaviorField).primaryEvent;
            primaryEvents{u} = primaryEvent;
            
            % Find rank from potentialeventNames
            idx = find(strcmp(primaryEvent, eventOrder), 1);
            if ~isempty(idx)
                eventRanks(u) = idx;
            else
                eventRanks(u) = defaultRank;
            end
        else
            primaryEvents{u} = 'unknown';
            eventRanks(u) = defaultRank;
        end
        if isfield(unitClass.(behaviorField), 'secondaryEvent')
            secondaryEvent = unitClass.(behaviorField).secondaryEvent;
            secondaryEvents{u} = secondaryEvent;

        else
            secondaryEvents{u} = 'unknown';
            eventRanks(u) = defaultRank;
        end

    else
        primaryEvents{u} = 'unknown';
        secondaryEvents{u} = 'unknown';
        eventRanks(u) = defaultRank;
    end
end

% Sort unitNames by event rank
[~, sortIdx] = sort(eventRanks);
unitNames = unitNames(sortIdx); %%%%end of new code
% Initialize a structure to store zscoredHz for each event
eventHeatMaps = struct(); 

filteredUnitNames={};

for u = 1:length(unitNames)
    unitID = unitNames{u};
    behavioralFeatures = regionUnits.(unitID).behavioralFeatures;
    treatment= regionUnits.(unitID).unitMetrics.treatement;
    unitClass=regionUnits.(unitID).unitMetrics.unitClass;
    if ~isstruct(unitClass.directionDependence)
        noseOutResponsiveness=unitClass.directionDependence;
        
    elseif ~isfield(unitClass.directionDependence,'direction')
       noseOutResponsiveness='undeterminable';
    else
        noseOutResponsiveness=unitClass.directionDependence.direction;
    end
     if excludeUndeterminable &&  isempty(noseOutResponsiveness)
        continue
    end
    if excludeUndeterminable && (strcmp(noseOutResponsiveness,'undeterminable')) 
        continue
    end
        
    if excludeNonSelectiveUnits && strcmp(noseOutResponsiveness,'NotDirectionallySelective') 
        continue
    end
    
    response= unitClass.type;    
    if ~strcmp(treatmentToProcess,treatment)
        continue
    end
    if excludeNonResponsive && strcmp(response,'nonResponsive')
        continue
    end
    if excludeSelectiveUnits && (strcmp(noseOutResponsiveness,'ipsilateral') | strcmp(noseOutResponsiveness,'contralateral'))
        continue
    end
    if excludeIpsilateral && strcmp(noseOutResponsiveness,'ipsilateral')
        continue
    end
    if excludeContralateral && strcmp(noseOutResponsiveness,'contralateral')
        continue
    end
    % Access the specific behavior
    if isfield(behavioralFeatures, behaviorField)
        behavior = behavioralFeatures.(behaviorField);  % Get the behavior structure
        if ~isfield(unitClass,behaviorField)
            continue
        end
        filteredUnitNames{end + 1} = unitID;
        primaryClass=unitClass.(behaviorField).primaryEvent;
        if isfield(unitClass.(behaviorField), 'secondaryEvent')
            secondaryClass=unitClass.(behaviorField).secondaryEvent;
        end
        
        % Loop through the event names associated with this behavior
        eventNames = fields(behavior); 
        for e = 1:length(eventNames)
            eventName = eventNames{e};  % Event name (e.g., 'cueOn', 'sideIn')
            if ~any(strcmp(eventName,potentialeventNames))
                continue
            end
            % Check if the event exists
            if isfield(behavior, eventName)
                eventData = behavior.(eventName);  % Get the event data
                zscoredHz = eventData.zscoredHz;  % Extract the zscoredHz values
                if useAbsoluteZ
                    zscoredHz=abs(zscoredHz);
                end
                % If this is the first unit or event, initialize the heatmap matrix for this event
                if ~isfield(eventHeatMaps, eventName)
                    eventHeatMaps.(eventName) = [];
                end

                % Add the zscoredHz values to the event's heatmap matrix
                eventHeatMaps.(eventName) = [eventHeatMaps.(eventName); zscoredHz];
                
            end
        end
    end
end
regionUnits.eventHeatMaps.(behaviorField).data=eventHeatMaps;
% Now that we have collected zscoredHz values for each event, plot the heatmap for each event
timeBins = linspace(-1, 1, 101);
unitNames=filteredUnitNames;
figure('Name', ['Event Heatmaps for- ' region], 'NumberTitle', 'off');
eventNames = fields(eventHeatMaps);
numEvents = length(eventNames);
t = tiledlayout(1,numEvents,'TileSpacing', 'Tight', 'Padding', 'None');
behaviorTitle=strrep(behaviorField,'_',' ');
title(t, ['Treatment= ' treatmentToProcess ' Z-scored Event Heatmaps for "' behaviorTitle '" in Region: ' region ' ' plotTitle]);
min_z = Inf;
max_z = -Inf;

eventNames = fieldnames(eventHeatMaps);
numEvents = length(eventNames);

for j = 1:numEvents
    eventName = eventNames{j};
    zscoredData = eventHeatMaps.(eventName);

    min_z = min(min_z, min(zscoredData(:)));
    max_z = max(max_z, max(zscoredData(:)));
end
for j = 1:numEvents
    eventName = eventNames{j};
    zscoredData = eventHeatMaps.(eventName);

    ax = nexttile(t);
    axes(ax);  % Ensure plotting in the right tile

    imagesc(timeBins, 1:size(zscoredData, 1), zscoredData);
    colormap(ax, 'jet');
    
    clim(ax, zScale);  % Synchronize color scale
    % Left ticks for primaryEvent
    % Left ticks for primaryEvent
    for u = 1:length(unitNames)
        unitID = unitNames{u};
        if isfield(regionUnits.(unitID).unitMetrics.unitClass, behaviorField)
            unitClass = regionUnits.(unitID).unitMetrics.unitClass;
            if isfield(unitClass.(behaviorField), 'primaryEvent')
                if strcmp(unitClass.(behaviorField).primaryEvent, eventName)
                    % Draw left-side black tick
                    line(ax, [-1, -0.88],  [u , u ], 'Color', [1 0.4 0.7], 'LineWidth', 3);
                end
            end
            if isfield(unitClass.(behaviorField), 'secondaryEvent')
                if strcmp(unitClass.(behaviorField).secondaryEvent, eventName)
                    % Draw right-side white tick (shorter)
                    line(ax, [0.90, 1.02],  [u , u ], 'Color', 'w', 'LineWidth', 2);
                end
            end
        end
    end
    if j==1

        xlabel(ax, 'Time (s)');
        ylabel(ax, 'Unit #');
    elseif j==max(numEvents)
        colorbar(ax);
        yticks([]);
        xticks([]); 
    else
        yticks([]);
        xticks([]); 
    end
    title(ax, eventName, 'Interpreter', 'none');
end
% === Save figure block ===
if ~exist(savePath, 'dir')
    mkdir(savePath);  % Create directory if needed
end
strrep(plotTitle,' ','_')
figFileName = fullfile(savePath, [treatmentToProcess '_eventHeatmaps_' behaviorField '_' region '_' plotTitle '.png']);
saveas(gcf, figFileName);
% figFileName = fullfile(savePath, [treatmentToProcess '_eventHeatmaps_' behaviorField '_' region '_' plotTitle '.fig']);
% savefig(gcf,figFileName);