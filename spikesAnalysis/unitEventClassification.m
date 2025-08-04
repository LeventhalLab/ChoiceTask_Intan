%script to classify units in regions based on their maximum zscored value
%within 200ms of a behavioral event. Whatever event contains the max z
%scored value, this is considered the primary event. See gaidica leventhal
%et al 2018
parentDir = 'X:\Neuro-Leventhal\data\ChoiceTask\RegionalSummary';
processSpecificSessions=1;% do you want to only process a specific subset of sessions?
removeOldUnits=0; %do you want to remove the units from this session that were previously processed?
if processSpecificSessions
    sessions_to_process={'R0465_20230420a',	'R0544_20240625a',	'R0544_20240626a',	'R0544_20240627a',	'R0544_20240628b',	'R0544_20240701a',	'R0544_20240702a',	'R0544_20240703a',	'R0544_20240708a',	'R0544_20240709b',	'R0544_20240710a',...
    'R0544_20240711a',	'R0546_20240715a',	'R0546_20240716a',	'R0546_20240717a',	'R0572_20240924a',	'R0545_20250113a'};
    ratsToReprocess={'R0465','R0544','R0545','R0546','R0572'};
    [regionsAvailable]=regionFinder(ratsToReprocess);
else
    allEntries = dir(parentDir);
    % Filter only directories, excluding '.' and '..'
    isSubFolder = [allEntries.isdir] & ~ismember({allEntries.name}, {'.', '..'});
    regionsAvailable = {allEntries(isSubFolder).name};
end
ignoreRegions={};
% allEntries = dir(parentDir);
% % Filter only directories, excluding '.' and '..'
% isSubFolder = [allEntries.isdir] & ~ismember({allEntries.name}, {'.', '..'});
% regionsAvailable = {allEntries(isSubFolder).name};
eventTimeWindow=0.2; %in secondsthe time +/- around an event to define selectivity
% Specify the behavior we are interested in
window=[-1 1];
binSize=0.02;
n_shuffles=5000;
behaviorFieldsForShuffle = {'correct_cuedleft','correct_cuedright'};
runShuffles=1;
directionSelectivityEvent=['centerOut'];
potentialeventNames={'cueOn','centerIn','tone','centerOut','houseLightOn','sideIn','wrong','sideOut','foodClick','foodRetrieval'};
% treatmentToProcess='control';
for i = 1:length(regionsAvailable)
    tic
    region = regionsAvailable{i};
    if strcmp(region,ignoreRegions)
        fprintf('skipping %s\n',region)
        continue
    end
    region=strrep(region,'/','-');
    fprintf('Classifying units in %s\n',region)
    regionPath = fullfile(parentDir, region);

    matFileName = strcat(region, '_unitSummary.mat');
    regionFileName=fullfile(regionPath, matFileName);
    load(regionFileName)
    disp('loaded region summary mat file')
    
    unitNames = fields(regionUnits);
    unitNames = sort(unitNames);
    
    
    for u = 1:length(unitNames)
        tic
        unitID = unitNames{u};
        if ~startsWith(unitID,'R')
            continue
        end
        if processSpecificSessions && ~startsWith(unitID,sessions_to_process)
            fprintf('skipping %s\n',unitID)
            continue
        end
        fprintf('Classifying %s\n',unitID)
        behavioralFeatures = regionUnits.(unitID).behavioralFeatures;
        unitMetrics=regionUnits.(unitID).unitMetrics;
        spikeTimes=regionUnits.(unitID).unitMetrics.clusterSpikes;
        if ~isfield(unitMetrics, 'unitClass')    
            regionUnits.(unitID).unitMetrics.unitClass=struct;
        end
        if runShuffles
            unitSelectivity=unitDirectionSelectivity(behavioralFeatures,spikeTimes,behaviorFieldsForShuffle,directionSelectivityEvent,window,binSize,n_shuffles);
            regionUnits.(unitID).unitMetrics.unitClass.directionDependence=unitSelectivity;
        end
        
  
        %Access the specific behavior
        
        max_zscore=-inf;
        max_zscore2=-inf;
        primaryEvent=[];
        secondaryEvent=[];
        behaviorFields=fields(behavioralFeatures);
        for b=1:length(behaviorFields)
            behaviorField=behaviorFields{b};
            
            fprintf('Determining event responsiveness during %s\n',behaviorField)
            if isfield(behavioralFeatures, behaviorField)
                behavior = behavioralFeatures.(behaviorField);  % Get the behavior structure
                % Loop through the event names associated with this behavior
                primaryEvent=[];
                secondaryEvent=[];
                max_zscore=-inf;
                max_zscore2=-inf;
                eventNames = fields(behavior); 
                for e = 1:length(eventNames)
                    eventName = eventNames{e};  % Event name (e.g., 'cueOn', 'sideIn')
                    if strcmp(eventName,'wrong')
                        continue
                    end
                    if ~any(strcmp(eventName,potentialeventNames))
                        continue
                    end
                    %set up adjacent events that cant be secondary events
                    try
                        NAeventName1=eventNames{e+1};%event immediately after current event
                        if ~any(strcmp(NAeventName1,potentialeventNames))
                            NAeventName1=[];
                        end
                    catch 
                        NAeventName1=[];
                    end
                    try
                        NAeventName2=eventNames{e-1};%event immediately before current event
                        if ~any(strcmp(NAeventName2,potentialeventNames))
                            NAeventName2=[];
                        end
                    catch
                        NAeventName2=[];
                    end
                    
                    % Check if the event exists if it does determine the
                    % maximum zscored hz value. If greater than max zscore and >1 this
                    % is now the primary event
                    if isfield(behavior, eventName)
                        eventData = behavior.(eventName);  % Get the event data
                        zscoredHz = eventData.zscoredHz;  % Extract the zscoredHz values
                        zscoredHzraw=zscoredHz;
                        
                        zscoredHz = abs(zscoredHz);
                        bins=eventData.bins;
                        % Find indices of bins between given event time window
                        idxWindow = bins >= -(eventTimeWindow) & bins <= eventTimeWindow;
     
                        zScoredEventWindow = zscoredHz(idxWindow);
                        maxEventZscore=max(zScoredEventWindow);
                        zScoredEventWindowRaw = zscoredHzraw(idxWindow);
                        minEventZscoreRaw=min(zScoredEventWindowRaw);
                        
                        oldMaxZscore=[];oldRawZscore=[];oldEvent=[];
    
                        if maxEventZscore < 1
                            continue
                        end
                        if maxEventZscore > max_zscore
                            if ~isempty(primaryEvent)
                                oldMaxZscore=max_zscore;
                                oldEvent=primaryEvent;
                                oldRawZscore=rawZscore;
                            end
                            primaryEvent=eventName;
                            max_zscore=max(max_zscore,maxEventZscore);
                            
                            if max_zscore == abs(minEventZscoreRaw)
                                rawZscore=minEventZscoreRaw;
                            else 
                                rawZscore=maxEventZscore;
                            end
                            if ~isempty(oldMaxZscore) 
                                    
                                if any(strcmp(oldEvent,NAeventName1)) || any(strcmp(oldEvent,NAeventName2)) %
                                    % disp('old primary event cant be secondary event as it is adjacent to primary event')
                                    continue
                                end
                                if (oldMaxZscore > (max_zscore*0.5) || oldMaxZscore > 1)
                                    if oldMaxZscore < max_zscore2
                                        disp('your logic is fucked up')
                                        keyboard
                                    end
                                    if oldMaxZscore < (max_zscore*0.5) && oldMaxZscore > 1
                                        warning('Secondary event zScore is >1 but is less than half size of max Z score')
                                    end
                                    max_zscore2=oldMaxZscore;
                                    rawZscore2=oldRawZscore;
                                    secondaryEvent=oldEvent;
                                end
                            end
                        elseif (maxEventZscore > max_zscore2) && (maxEventZscore > (max_zscore*0.5) || maxEventZscore > 1) 
                            if any(strcmp(primaryEvent,NAeventName1)) || any(strcmp(primaryEvent,NAeventName2))
                                % disp('current event name cant be secondary event since its adjacent to primary event')
                                continue
                            end
                            % if maxEventZscore < (max_zscore*0.5) && maxEventZscore > 1
                            %     warning('Secondary event zScore is >1 but is less than half size of max Z score')
                            % end
                            secondaryEvent=eventName;
                            max_zscore2=max(max_zscore2,maxEventZscore);
                            if maxEventZscore == abs(minEventZscoreRaw)
                                rawZscore2=minEventZscoreRaw;
                            else 
                                rawZscore2=maxEventZscore;
                            end
                        else
                            continue
                        end
                      
                    end
                end
                if ~isempty(primaryEvent)
                    regionUnits.(unitID).unitMetrics.unitClass.type='Responsive';
                    regionUnits.(unitID).unitMetrics.unitClass.(behaviorField).primaryEvent=primaryEvent;
                    regionUnits.(unitID).unitMetrics.unitClass.(behaviorField).primaryabsZScoreValue=max_zscore;
                    regionUnits.(unitID).unitMetrics.unitClass.(behaviorField).primaryZScoreValue=rawZscore;
                    if ~isempty(secondaryEvent)
                        if strcmp(secondaryEvent,primaryEvent)
                            keyboard
                        end
                        regionUnits.(unitID).unitMetrics.unitClass.(behaviorField).secondaryEvent=secondaryEvent;
                        regionUnits.(unitID).unitMetrics.unitClass.(behaviorField).secondaryabsZScoreValue=max_zscore2;
                        regionUnits.(unitID).unitMetrics.unitClass.(behaviorField).secondaryZScoreValue=rawZscore2;
                    end
                elseif isfield(regionUnits.(unitID).unitMetrics.unitClass,'type') && strcmp(regionUnits.(unitID).unitMetrics.unitClass.type,'Responsive')
                    
                    continue
                else 
                    regionUnits.(unitID).unitMetrics.unitClass.type='nonResponsive';
                end
            end
            
        end
    fprintf('Finished %s\n',unitID)
    toc
    end
    % regionUnits.eventHeatMaps.(behaviorField).data=eventHeatMaps;
    % % Now that we have collected zscoredHz values for each event, plot the heatmap for each event
    % timeBins = linspace(-1, 1, 101);
    % 
    % figure('Name', ['Event Heatmaps - ' region], 'NumberTitle', 'off');
    % eventNames = fields(eventHeatMaps);
    % numEvents = length(eventNames);
    % t = tiledlayout(1,numEvents);
    % title(t, ['Z-scored Event Heatmaps for "' behaviorField '" in Region: ' region]);
    % min_z = Inf;
    % max_z = -Inf;
    % 
    % eventNames = fieldnames(eventHeatMaps);
    % numEvents = length(eventNames);
    % 
    % for j = 1:numEvents
    %     eventName = eventNames{j};
    %     zscoredData = eventHeatMaps.(eventName);
    % 
    %     min_z = min(min_z, min(zscoredData(:)));
    %     max_z = max(max_z, max(zscoredData(:)));
    % end
    % for j = 1:numEvents
    %     eventName = eventNames{j};
    %     zscoredData = eventHeatMaps.(eventName);
    % 
    %     ax = nexttile(t);
    %     axes(ax);  % Ensure plotting in the right tile
    % 
    %     imagesc(timeBins, 1:size(zscoredData, 1), zscoredData);
    %     colormap(ax, 'jet');
    %     colorbar(ax);
    %     clim(ax, [-3 3]);  % Synchronize color scale
    % 
    %     xlabel(ax, 'Time (s)');
    %     ylabel(ax, 'Unit #');
    %     title(ax, eventName, 'Interpreter', 'none');
    % end
    fprintf('Region completed %s\n',region)
    toc
    tic
    disp('Saving updated region mat file')
    save(regionFileName,'regionUnits','-v7.3','-mat')
    disp('Mat file saved in')
    toc

end