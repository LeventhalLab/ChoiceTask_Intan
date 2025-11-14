%% Script to combine regions into a single mat file

parentDir = 'X:\Neuro-Leventhal\data\ChoiceTask\RegionalSummary';
allEntries = dir(parentDir);
% Filter only directories, excluding '.' and '..'
isSubFolder = [allEntries.isdir] & ~ismember({allEntries.name}, {'.', '..'});
regionsAvailable = {allEntries(isSubFolder).name};
%% Input Parameters
params={};


% do not change
params.potentialeventNames={'cueOn','centerIn','tone','centerOut','houseLightOn','sideIn','wrong','sideOut','foodClick','foodRetrieval'};
% lesion or control?
params.treatmentToProcess='control';
combinedRegionName='OtherRegions';
regionsToCombine={'LH','Mt','PLH','PaPo','PefLH-LH','Rt','SubI', 'ZI','ZI-SubI'};
plotHeatMap=0;
% Specify the behavior we are interested in plotting for heat map
params.behaviorField = 'correct_cuedleft';
%--Units that are not directionally selective
params.excludeNonSelectiveUnits=0; % 1 recommended if running controls
%--Units that are directionally selective usually
params.excludeSelectiveUnits=0; %0 recommended for all cases
 %--Units where selectivity could not be determined due to failed shuffle test 
params.excludeUndeterminable=0;%1 recommended
%--Units that are contralaterally selective
params.excludeContralateral=0;
%--Units that are ipsilaterally selective
params.excludeIpsilateral=0;
%--Units that are not responsive to events 
%(z-score doesn't exceed 1)
params.excludeNonResponsive=0;
%Gaidica leventhal '18 used [-.5 2] inspect data
params.zScale=[-2 2];
params.heatMapTitle='CB Recipient Zones no VM overlapping units';
%% ONLY SET TO 1 IF YOU ARE PLANNING TO CONTINUE DOING ANALYSIS ON A REGION
reuseWorkspace=0;
%specify for mat file that is more generic in nature (ie not segregated)
useAllTrialsMatFile=0;
regionSummaryPath=fullfile(parentDir,combinedRegionName);
if ~isfile(regionSummaryPath)
    mkdir(regionSummaryPath)
end
regionFile = fullfile(regionSummaryPath, [combinedRegionName '_unitSummary.mat']);
combinedRegions={};
% if any(~exist(strcmp(regionsAvailable,regionsToCombine)))
%     disp('Some or all of the specified regions to combine dont exist!! Displaying available regions')
%     regionFinder
%     keyboard
% end

%% combine regions together into a single struct
if ~reuseWorkspace
    for i = 1:length(regionsAvailable)
        region = regionsAvailable{i};
        regionPath = fullfile(parentDir, region);
        
        regionPath = cd(regionPath);
        
        matFileName = strcat(region, '_unitSummary.mat');
        
        if ~any(strcmp(region,regionsToCombine))
            continue
        end
        fprintf('Appending region to combined region mat file%s\n',region)
        regionMatFile = load(matFileName);
        regionUnits = regionMatFile.regionUnits;
        region = matlab.lang.makeValidName(region);
        combinedRegions.(region)=regionUnits;
        unitNames = fieldnames(regionUnits);
        for j = 1:length(unitNames)
            unitName = unitNames{j};
            uniqueName = [region '_' unitName];  % Make globally unique name
            combinedRegions.allUnits.(uniqueName) = regionUnits.(unitName);
        end
        disp('Region added')
    end
else
    warning('Careful youre analyzing the current workspace!!')
end

%% Plot heat map and save as figure
if plotHeatMap
    params.regionSummaryPath=regionSummaryPath;
    params.region=combinedRegionName;
    [eventHeatMaps,primaryEvents,secondaryEvents]=heatMapPlotting(combinedRegions.allUnits,params);
    behaviorField=params.behaviorField;
    combinedRegions.(behaviorField)=eventHeatMaps;
    save(regionFile,'combinedRegions','-v7.3','-mat')
else
    disp('saving combined region file')
    save(regionFile,'combinedRegions','-v7.3','-mat')
    disp('Congrats! Youve made a region baby')
end

%%
%for r=1:length(fields(cbRegions.allUnits))
%     %regionUnits=cbRegions.{r};
% 
%     regionUnits=cbRegions.allUnits;
%     unitNames = fields(regionUnits);
%     unitNames = sort(unitNames); %%%% start of new code
%     eventOrder = potentialeventNames;
%     defaultRank = length(eventOrder) + 1;
% 
%     primaryEvents = cell(size(unitNames));
%     eventRanks = zeros(size(unitNames));
% 
%     for u = 1:length(unitNames)
%         unitID = unitNames{u};
%         if isfield(regionUnits.(unitID).unitMetrics.unitClass, behaviorField)
%             unitClass = regionUnits.(unitID).unitMetrics.unitClass;
%             if isfield(unitClass.(behaviorField), 'primaryEvent')
%                 primaryEvent = unitClass.(behaviorField).primaryEvent;
%                 primaryEvents{u} = primaryEvent;
% 
%                 % Find rank from potentialeventNames
%                 idx = find(strcmp(primaryEvent, eventOrder), 1);
%                 if ~isempty(idx)
%                     eventRanks(u) = idx;
%                 else
%                     eventRanks(u) = defaultRank;
%                 end
%             else
%                 primaryEvents{u} = 'unknown';
%                 eventRanks(u) = defaultRank;
%             end
%         else
%             primaryEvents{u} = 'unknown';
%             eventRanks(u) = defaultRank;
%         end
%     end
% 
%     % Sort unitNames by event rank
%     [~, sortIdx] = sort(eventRanks);
%     unitNames = unitNames(sortIdx); %%%%end of new code
%     % Initialize a structure to store zscoredHz for each event
%     eventHeatMaps = struct(); 
% 
%     filteredUnitNames={};
% 
%     for u = 1:length(unitNames)
%         unitID = unitNames{u};
%         behavioralFeatures = regionUnits.(unitID).behavioralFeatures;
%         treatment= regionUnits.(unitID).unitMetrics.treatement;
%         unitClass=regionUnits.(unitID).unitMetrics.unitClass;
%         if ~isstruct(unitClass.directionDependence)
%             noseOutResponsiveness=unitClass.directionDependence;
% 
%         elseif ~isfield(unitClass.directionDependence,'direction')
%            noseOutResponsiveness='undeterminable';
%         else
%             noseOutResponsiveness=unitClass.directionDependence.direction;
%         end
%          if excludeUndeterminable &&  isempty(noseOutResponsiveness)
%             continue
%         end
%         if excludeUndeterminable && (strcmp(noseOutResponsiveness,'undeterminable')) 
%             continue
%         end
% 
%         if excludeNonSelectiveUnits && strcmp(noseOutResponsiveness,'NotDirectionallySelective') 
%             continue
%         end
% 
%         response= unitClass.type;    
%         if ~strcmp(treatmentToProcess,treatment)
%             continue
%         end
%         if excludeNonResponsive && strcmp(response,'nonResponsive')
%             continue
%         end
%         if excludeSelectiveUnits && (strcmp(noseOutResponsiveness,'ipsilateral') | strcmp(noseOutResponsiveness,'contralateral'))
%             continue
%         end
%         if excludeIpsilateral && strcmp(noseOutResponsiveness,'ipsilateral')
%             continue
%         end
%         if excludeContralateral && strcmp(noseOutResponsiveness,'contralateral')
%             continue
%         end
%         % Access the specific behavior
%         if isfield(behavioralFeatures, behaviorField)
%             behavior = behavioralFeatures.(behaviorField);  % Get the behavior structure
%             if ~isfield(unitClass,behaviorField)
%                 continue
%             end
%             filteredUnitNames{end + 1} = unitID;
%             primaryClass=unitClass.(behaviorField).primaryEvent;
%             if isfield(unitClass.(behaviorField), 'secondaryEvent')
%                 secondaryClass=unitClass.(behaviorField).secondaryEvent;
%             end
% 
%             % Loop through the event names associated with this behavior
%             eventNames = fields(behavior); 
%             for e = 1:length(eventNames)
%                 eventName = eventNames{e};  % Event name (e.g., 'cueOn', 'sideIn')
%                 if ~any(strcmp(eventName,potentialeventNames))
%                     continue
%                 end
%                 % Check if the event exists
%                 if isfield(behavior, eventName)
%                     eventData = behavior.(eventName);  % Get the event data
%                     zscoredHz = eventData.zscoredHz;  % Extract the zscoredHz values
%                     %zscoredHz=abs(zscoredHz);
%                     % If this is the first unit or event, initialize the heatmap matrix for this event
%                     if ~isfield(eventHeatMaps, eventName)
%                         eventHeatMaps.(eventName) = [];
%                     end
% 
%                     % Add the zscoredHz values to the event's heatmap matrix
%                     eventHeatMaps.(eventName) = [eventHeatMaps.(eventName); zscoredHz];
% 
%                 end
%             end
%         end
%     end
%     regionUnits.eventHeatMaps.(behaviorField).data=eventHeatMaps;
%     % Now that we have collected zscoredHz values for each event, plot the heatmap for each event
%     timeBins = linspace(-1, 1, 101);
%     unitNames=filteredUnitNames;
%     figure('Name', ['Event Heatmaps - ' region], 'NumberTitle', 'off');
%     eventNames = fields(eventHeatMaps);
%     numEvents = length(eventNames);
%     t = tiledlayout(1,numEvents,'TileSpacing', 'Tight', 'Padding', 'None');
%     behaviorTitle=strrep(behaviorField,'_',' ');
%     title(t, ['Z-scored Event Heatmaps for "' behaviorTitle '" in Region: ' region ' Absolute Z Ipsilaterally Selective ONLY']);
%     min_z = Inf;
%     max_z = -Inf;
% 
%     eventNames = fieldnames(eventHeatMaps);
%     numEvents = length(eventNames);
% 
%     for j = 1:numEvents
%         eventName = eventNames{j};
%         zscoredData = eventHeatMaps.(eventName);
% 
%         min_z = min(min_z, min(zscoredData(:)));
%         max_z = max(max_z, max(zscoredData(:)));
%     end
%     for j = 1:numEvents
%         eventName = eventNames{j};
%         zscoredData = eventHeatMaps.(eventName);
% 
%         ax = nexttile(t);
%         axes(ax);  % Ensure plotting in the right tile
% 
%         imagesc(timeBins, 1:size(zscoredData, 1), zscoredData);
%         colormap(ax, 'jet');
% 
%         clim(ax, zScale);  % Synchronize color scale
%         % Left ticks for primaryEvent
%         % Left ticks for primaryEvent
%         for u = 1:length(unitNames)
%             unitID = unitNames{u};
%             if isfield(regionUnits.(unitID).unitMetrics.unitClass, behaviorField)
%                 unitClass = regionUnits.(unitID).unitMetrics.unitClass;
%                 if isfield(unitClass.(behaviorField), 'primaryEvent')
%                     if strcmp(unitClass.(behaviorField).primaryEvent, eventName)
%                         % Draw left-side black tick
%                         line(ax, [-1, -0.88],  [u , u ], 'Color', [1 0.4 0.7], 'LineWidth', 3);
%                     end
%                 end
%                 if isfield(unitClass.(behaviorField), 'secondaryEvent')
%                     if strcmp(unitClass.(behaviorField).secondaryEvent, eventName)
%                         % Draw right-side white tick (shorter)
%                         line(ax, [0.90, 1.02],  [u , u ], 'Color', 'w', 'LineWidth', 2);
%                     end
%                 end
%             end
%         end
%         if j==1
% 
%             xlabel(ax, 'Time (s)');
%             ylabel(ax, 'Unit #');
%         elseif j==max(numEvents)
%             colorbar(ax);
%             yticks([]);
%             xticks([]); 
%         else
%             yticks([]);
%             xticks([]); 
%         end
%         title(ax, eventName, 'Interpreter', 'none');
%     end
% %end
