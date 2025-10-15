function [filteredUnitNames,eventHeatMaps,primaryEvents,secondaryEvents]=heatMapPlotting2(regionUnits,params)
%% This creates heat maps for given regions and parameters for each behavior
%% field 

behaviorField = params.behaviorField;

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
potentialeventNames=params.potentialeventNames;
treatmentToProcess=params.treatmentToProcess;
region=params.region;
subPlotTitle=params.heatMapTitle;
savePath=params.regionSummaryPath;
badIDs=params.badAllTrialsIDs;       
        % -----------------------------------------------------------------
        % STEP 1: build filteredUnitNames up front (apply all params filters)
        % -----------------------------------------------------------------
        unitNames = fields(regionUnits);
        filteredUnitNames = {};
        for uu = 1:length(unitNames)
            uid = unitNames{uu};
            % skip non-unit fields
            if ~startsWith(uid,'R') && (params.combinedRegionFlag==0)
                continue
            end
            if ~isfield(regionUnits.(uid),'unitMetrics')
                continue
            end
            if ~isfield(regionUnits.(uid).behavioralFeatures, behaviorField)
                continue
            end
            if any(strcmp(uid,badIDs)) && strcmp(behaviorField,'alltrials')
                continue
            end
            unit = regionUnits.(uid);
            % handle unitClass availability
            if ~isfield(unit,'unitMetrics') || ~isfield(unit.unitMetrics,'unitClass')
                continue
            end
            unitClass = unit.unitMetrics.unitClass;
            
            % treatment field (account for misspelling 'treatement')
            if isfield(unit.unitMetrics,'treatement')
                treatment = unit.unitMetrics.treatement;
            elseif isfield(unit.unitMetrics,'treatment')
                treatment = unit.unitMetrics.treatment;
            else
                treatment = '';
            end
            
            % directionDependence handling (robust)
            if isfield(unitClass,'directionDependence')
                dd = unitClass.directionDependence;
                if isstruct(dd) && isfield(dd,'direction')
                    noseOutResponsiveness = dd.direction;
                else
                    noseOutResponsiveness = dd;
                end
            else
                noseOutResponsiveness = 'undeterminable';
            end
            
            % === Apply filters (same logic as original) ===
            % treatment check (keep original behavior: compare strings)
            if ~isempty(treatmentToProcess) && ischar(treatmentToProcess)
                if ~strcmp(treatmentToProcess, treatment)
                    continue
                end
            end
            if excludeUndeterminable && (isempty(noseOutResponsiveness) || strcmp(noseOutResponsiveness,'undeterminable'))
                continue
            end
            if excludeNonSelectiveUnits && strcmp(noseOutResponsiveness,'NotDirectionallySelective')
                continue
            end
            if excludeNonResponsive && isfield(unitClass,'type') && strcmp(unitClass.type,'nonResponsive')
                continue
            end
            if excludeSelectiveUnits && (strcmp(noseOutResponsiveness,'ipsilateral') || strcmp(noseOutResponsiveness,'contralateral'))
                continue
            end
            if excludeIpsilateral && strcmp(noseOutResponsiveness,'ipsilateral')
                continue
            end
            if excludeContralateral && strcmp(noseOutResponsiveness,'contralateral')
                continue
            end
            
            % Passed all filters -> keep unit
            filteredUnitNames{end+1} = uid; 
        end
        if isempty(filteredUnitNames)
            warning('No "%s" units survived filtering for behavior "%s" in region %s', ...
                    treatmentToProcess,behaviorField, region);
            eventHeatMaps=[];
            filteredUnitNames=[];
            primaryEvents=[];
            secondaryEvents=[];
            return
        end
        % -----------------------------------------------------------------
        % STEP 2: compute primary/secondary events and sort filtered units
        % -----------------------------------------------------------------
        eventOrder = potentialeventNames;
        defaultRank = length(eventOrder) + 1;
        primaryEvents = cell(size(filteredUnitNames));
        secondaryEvents = cell(size(filteredUnitNames));
        eventRanks = zeros(size(filteredUnitNames));
        
        for uu = 1:length(filteredUnitNames)
            uid = filteredUnitNames{uu};
            unit = regionUnits.(uid);
            if ~isfield(unit,'unitMetrics') || ~isfield(unit.unitMetrics,'unitClass')
                primaryEvents{uu} = 'unknown';
                secondaryEvents{uu} = 'unknown';
                eventRanks(uu) = defaultRank;
                continue
            end
            unitClass = unit.unitMetrics.unitClass;
            if isfield(unitClass, behaviorField) && isfield(unitClass.(behaviorField),'primaryEvent')
                primaryEvents{uu} = unitClass.(behaviorField).primaryEvent;
                idx = find(strcmp(primaryEvents{uu}, eventOrder), 1);
                if ~isempty(idx)
                    eventRanks(uu) = idx;
                else
                    eventRanks(uu) = defaultRank;
                end
            else
                primaryEvents{uu} = 'unknown';
                eventRanks(uu) = defaultRank;
            end
            if isfield(unitClass, behaviorField) && isfield(unitClass.(behaviorField),'secondaryEvent')
                secondaryEvents{uu} = unitClass.(behaviorField).secondaryEvent;
            else
                secondaryEvents{uu} = 'unknown';
            end
        end
        
        % sort filteredUnitNames by computed primary-event ranks
        [~, sortIdx] = sort(eventRanks);
        try
            filteredUnitNames = filteredUnitNames(sortIdx);
            primaryEvents = primaryEvents(sortIdx);
            secondaryEvents = secondaryEvents(sortIdx);
        catch ME
            keyboard
        end
        
        % -----------------------------------------------------------------
        % STEP 3: build eventHeatMaps using the sorted filteredUnitNames
        % -----------------------------------------------------------------
        eventHeatMaps = struct();
        for uu = 1:length(filteredUnitNames)
            unitID = filteredUnitNames{uu};
            if~startsWith(uid,'R') && (params.combinedRegionFlag==0)
                continue
            end
            behavioralFeatures = regionUnits.(unitID).behavioralFeatures;
            if ~isfield(behavioralFeatures,behaviorField)
                continue
            end
            
            behavior = behavioralFeatures.(behaviorField);  % Get the behavior structure
            % Loop through the event names associated with this behavior
            eventNames = fields(behavior);
            for e = 1:length(eventNames)
                eventName = eventNames{e};
                if ~any(strcmp(eventName,potentialeventNames))
                    continue
                end
                if isfield(behavior, eventName)
                    eventData = behavior.(eventName);
                    if ~isfield(eventData,'zscoredHz')
                        continue
                    end
                    zscoredHz = eventData.zscoredHz;
                    if useAbsoluteZ
                        zscoredHz = abs(zscoredHz);
                    end
                    if ~isfield(eventHeatMaps, eventName)
                        eventHeatMaps.(eventName) = [];
                    end
                    try
                        % --- Check shape of zscoredHz ---
                        if strcmp(eventName,'foodRetrieval') && ~isequal(size(zscoredHz),[1 101])
                            % If foodRetrieval is malformed, replace with NaNs
                            warning('foodRetrieval zscoredHz wrong size for unit %s, padding with NaNs', unitID);
                            zscoredHz = nan(1,101);
                        end
                        
                        % Append normally
                        eventHeatMaps.(eventName) = [eventHeatMaps.(eventName); zscoredHz];
                    catch
                        % If append still fails, enforce column width from existing data
                        if isempty(eventHeatMaps.(eventName))
                            nCols = numel(zscoredHz); % if first entry, trust zscoredHz length
                        else
                            nCols = size(eventHeatMaps.(eventName),2);
                        end
                        
                        warning('Failed to append data for %s in unit %s, padding with NaNs', ...
                            eventName, unitID);
                        eventHeatMaps.(eventName) = [eventHeatMaps.(eventName); nan(1,nCols)];
                    end
                end
                    
                
            end
        end
        
        regionUnits.eventHeatMaps.(behaviorField).data = eventHeatMaps;
        
        % -----------------------------------------------------------------
        % STEP 4: plotting (use filteredUnitNames order)
        % -----------------------------------------------------------------
        timeBins = linspace(-1, 1, 101);
        unitNamesPlot = filteredUnitNames;
        f=figure('Name', ['Event Heatmaps for- ' region], 'NumberTitle', 'off','Units', 'inches', ...
       'Position', [1 1 11 8.5]);
        
        % ensure event tiles are in potentialeventNames order
        eventNames = fields(eventHeatMaps);
        [~, sortOrder] = ismember(potentialeventNames, eventNames);
        sortOrder(sortOrder==0) = [];
        eventNames = eventNames(sortOrder);
        numEvents = length(eventNames);
        if numEvents==0
            filteredUnitNames=[];
            primaryEvents=[];
            secondaryEvents=[];
            eventHeatMaps=[];
            close(f)
            return
        end
        try
            t = tiledlayout(1,numEvents,'TileSpacing', 'Tight', 'Padding', 'None');
        catch ME
            keyboard
            return
        end
        
       
        sgtitle(t, sprintf('Treatment = %s | Behavior = %s | Region = %s ', ...
                    treatmentToProcess, strrep(behaviorField,'_',' '), region), ...
                    'FontSize', 12, 'Interpreter', 'none');        
        subtitle(t,subPlotTitle)
        min_z = Inf;
        max_z = -Inf;
        
        for j = 1:numEvents
            eventName = eventNames{j};
            if ~isfield(eventHeatMaps,eventName)
                continue
            end
            zscoredData = eventHeatMaps.(eventName);
            if ~isempty(zscoredData)
                min_z = min(min_z, min(zscoredData(:)));
                max_z = max(max_z, max(zscoredData(:)));
            end
        end
        
        for j = 1:numEvents
            eventName = eventNames{j};
            if ~isfield(eventHeatMaps,eventName)
                continue
            end
            zscoredData = eventHeatMaps.(eventName);
            
            ax = nexttile(t);
            axes(ax);  % Ensure plotting in the right tile
            
            imagesc(timeBins, 1:size(zscoredData, 1), zscoredData);
            colormap(ax, 'jet');
            clim(ax, zScale);  % Synchronize color scale
            
            % Left/right ticks for primary/secondaryEvent using filteredUnitNames order
            for uidx = 1:length(unitNamesPlot)
                unitID = unitNamesPlot{uidx};
                if isfield(regionUnits.(unitID).unitMetrics.unitClass, behaviorField)
                    unitClass = regionUnits.(unitID).unitMetrics.unitClass;
                    if isfield(unitClass.(behaviorField), 'primaryEvent')
                        if strcmp(unitClass.(behaviorField).primaryEvent, eventName)
                            line(ax, [-1, -0.88],  [uidx , uidx ], 'Color', [1 0.4 0.7], 'LineWidth', 3);
                        end
                    end
                    if isfield(unitClass.(behaviorField), 'secondaryEvent')
                        if strcmp(unitClass.(behaviorField).secondaryEvent, eventName)
                            line(ax, [0.90, 1.02],  [uidx , uidx ], 'Color', 'w', 'LineWidth', 2);
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
        subPlotTitle=strrep(subPlotTitle,' ','_');
        pngFileName = fullfile(savePath, [treatmentToProcess '_eventHeatmaps_' behaviorField '_' region '_' subPlotTitle '.png']);
        figFileName = fullfile(savePath, [treatmentToProcess '_eventHeatmaps_' behaviorField '_' region '_' subPlotTitle '.fig']);
        saveas(f, figFileName);
        saveas(f, pngFileName);
       
        close(f);
       
   
    
end
