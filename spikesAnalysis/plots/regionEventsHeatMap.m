%% Not recommended go to regionPlots.m and use heatMapPlotting.m function RL 8/22/25

parentDir = 'X:\Neuro-Leventhal\data\ChoiceTask\RegionalSummary';
allEntries = dir(parentDir);
% Filter only directories, excluding '.' and '..'
isSubFolder = [allEntries.isdir] & ~ismember({allEntries.name}, {'.', '..'});
regionsAvailable = {allEntries(isSubFolder).name};
excludeNonSelectiveUnits=0; %1 recommended
excludeSelectiveUnits=0; %0 recommended
excludeUndeterminable=1; %1 recommended
excludeContralateral=0;
excludeIpsilateral=0;
excludeNonResponsive=0;

% Specify the behavior we are interested in
behaviorField = 'alltrials';
potentialeventNames={'cueOn','centerIn','tone','centerOut','houseLightOn','sideIn','wrong','sideOut','foodClick','foodRetrieval'};
treatmentToProcess='lesion';
for i = 1:length(regionsAvailable)
    region = regionsAvailable{i};
    regionPath = fullfile(parentDir, region);
    regionPath = cd(regionPath);
    matFileName = strcat(region, '_unitSummary.mat');
    regionMatFile = load(matFileName);
    regionUnits = regionMatFile.regionUnits;
    unitNames = fields(regionUnits);
    unitNames = sort(unitNames); %%%% start of new code
    eventOrder = potentialeventNames;
    defaultRank = length(eventOrder) + 1;
    
    primaryEvents = cell(size(unitNames));
    eventRanks = zeros(size(unitNames));
    % Initialize a structure to store zscoredHz for each event
    eventHeatMaps = struct(); 
    
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
        else
            primaryEvents{u} = 'unknown';
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
        if ~strcmp(treatmentToProcess,treatment)
            continue
        end
        % if ~isstruct(unitClass.directionDependence)
        %     noseOutResponsiveness=unitClass.directionDependence;
        % 
        % elseif ~isfield(unitClass.directionDependence,'direction')
        %    noseOutResponsiveness='undeterminable';
        % else
        %     noseOutResponsiveness=unitClass.directionDependence.direction;
        % end
        % if excludeUndeterminable && strcmp(noseOutResponsiveness,'undeterminable')
        %     continue
        % end
        % 
        % if excludeNonSelectiveUnits && strcmp(noseOutResponsiveness,'NotDirectionallySelective') 
        %     continue
        % end
        % 
        % response= unitClass.type;    
        % 
        % if excludeNonResponsive && strcmp(response,'nonResponsive')
        %     continue
        % end
        % if excludeSelectiveUnits && (strcmp(noseOutResponsiveness,'ipsilateral') | strcmp(noseOutResponsiveness,'contralateral'))
        %     continue
        % end
        % if excludeIpsilateral && strcmp(noseOutResponsiveness,'ipsilateral')
        %     continue
        % end
        % if excludeContralateral && strcmp(noseOutResponsiveness,'contralateral')
        %     continue
        % end
        % Access the specific behavior
        if isfield(behavioralFeatures, behaviorField)
            behavior = behavioralFeatures.(behaviorField);  % Get the behavior structure
            % if ~isfield(unitClass,behaviorField)
            %     continue
            % end

            % primaryClass=unitClass.(behaviorField).primaryEvent;
            % if isfield(unitClass.(behaviorField), 'secondaryEvent')
            %     secondaryClass=unitClass.(behaviorField).secondaryEvent;
            % end
            
            % Loop through the event names associated with this behavior
            filteredUnitNames{end+1}=unitID;
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
                    %zscoredHz=abs(zscoredHz);
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

    figure('Name', ['Event Heatmaps - ' region], 'NumberTitle', 'off');
    eventNames = fields(eventHeatMaps);
    numEvents = length(eventNames);
    t = tiledlayout(1,numEvents,'TileSpacing', 'Tight', 'Padding', 'None');
    title(t, ['Z-scored Event Heatmaps for "' behaviorField '" in Region: ' region]);
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
end