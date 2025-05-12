parentDir = 'X:\Neuro-Leventhal\data\ChoiceTask\RegionalSummary';
allEntries = dir(parentDir);
% Filter only directories, excluding '.' and '..'
isSubFolder = [allEntries.isdir] & ~ismember({allEntries.name}, {'.', '..'});
regionsAvailable = {allEntries(isSubFolder).name};

% Specify the behavior we are interested in
behaviorField = 'correct_cuedleft';
potentialeventNames={'cueOn','centerIn','tone','centerOut','houseLightOn','sideIn','wrong','sideOut','foodClick','foodRetrieval'};
treatmentToProcess='control';
for i = 1:length(regionsAvailable)
    region = regionsAvailable{i};
    regionPath = fullfile(parentDir, region);
    regionPath = cd(regionPath);
    matFileName = strcat(region, '_unitSummary.mat');
    regionMatFile = load(matFileName);
    regionUnits = regionMatFile.regionUnits;
    unitNames = fields(regionUnits);
    unitNames = sort(unitNames);
    % Initialize a structure to store zscoredHz for each event
    eventHeatMaps = struct(); 

    for u = 1:length(unitNames)
        unitID = unitNames{u};
        behavioralFeatures = regionUnits.(unitID).behavioralFeatures;
        treatment= regionUnits.(unitID).unitMetrics.treatement;
        if ~strcmp(treatmentToProcess,treatment)
            continue
        end
        % Access the specific behavior
        if isfield(behavioralFeatures, behaviorField)
            behavior = behavioralFeatures.(behaviorField);  % Get the behavior structure
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
    t = tiledlayout(1,numEvents);
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
        colorbar(ax);
        clim(ax, [-3 3]);  % Synchronize color scale
    
        xlabel(ax, 'Time (s)');
        ylabel(ax, 'Unit #');
        title(ax, eventName, 'Interpreter', 'none');
    end
end