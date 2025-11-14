function heatMapPlotting_byRatID_combinedRegion(regionUnits,params)
%% Hypothetical code to plots heat maps for each rat within a given combined region for the given behavior fields and parameters 

behaviorField = params.behaviorField;
saveTitleName=params.heatMapTitle;
    if isfield(params, 'excludeNonSelectiveUnits')
        excludeNonSelectiveUnits = params.excludeNonSelectiveUnits; %1 recommended
    else
        excludeNonSelectiveUnits = 0;
    end
    if isfield(params, 'excludeSelectiveUnits')
        excludeSelectiveUnits = params.excludeSelectiveUnits; %0 recommended
    else
        excludeSelectiveUnits = 0;
    end
    if isfield(params,'excludeUndeterminable')
        excludeUndeterminable = params.excludeUndeterminable; %1 recommended
    else
        excludeUndeterminable = 0;
    end
    if isfield(params,'excludeContralateral')
        excludeContralateral = params.excludeContralateral;
    else
        excludeContralateral = 0;
    end
    if isfield(params, 'excludeIpsilateral')
        excludeIpsilateral = params.excludeIpsilateral;
    else
        excludeIpsilateral = 0;
    end
    if isfield(params,'excludeNonResponsive')
        excludeNonResponsive = params.excludeNonResponsive;
    else
        excludeNonResponsive = 0;
    end

    zScale = params.zScale;
    useAbsoluteZ = params.useAbsoluteZ;
    potentialeventNames = params.potentialeventNames;
    treatmentToProcess = params.treatmentToProcess;
    region = params.region;
    
    
    % -----------------------------------------------------------------
    % STEP 1: build filteredUnitNames per rat (apply all params filters)
    % -----------------------------------------------------------------
    unitNames = fields(regionUnits);
    keyboard %%rat id extraction will need to be modified
    ratIDs = cellfun(@(x) extractBefore(x, '_'), unitNames, 'UniformOutput', false);
    uniqueRatIDs = unique(ratIDs);  % ensures each rat processed once

    for r = 1:length(uniqueRatIDs)
        ratID = uniqueRatIDs{r};
        if isempty(ratID)
            continue
        end
        savePath = fullfile(params.regionSummaryPath, ratID);
        subPlotTitle = params.heatMapTitle;
        % reset per-rat variables
        filteredUnitNames = {};
        eventHeatMaps = struct();
        primaryEvents = {};
        secondaryEvents = {};

        for uu = 1:length(unitNames)
            uid = unitNames{uu};
            % skip non-unit fields
            if~startsWith(uid,'R') && (params.combinedRegionFlag==0)
                continue
            end
            if ~contains(uid,ratID)
                continue
            end
            if ~isfield(regionUnits.(uid),'unitMetrics')
                continue
            end
            if ~isfield(regionUnits.(uid).behavioralFeatures, behaviorField) || ~isfield(regionUnits.(uid).behavioralFeatures.(behaviorField),'cueOn')
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

            % === Apply filters ===
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
            warning('No %s units survived filtering for behavior "%s" in region %s for %s', ...
                    treatmentToProcess,behaviorField, region,ratID);
            continue  % <--- skip this rat, keep going
        end

        % -----------------------------------------------------------------
        % STEP 2: compute primary/secondary events and sort
        % -----------------------------------------------------------------
        eventOrder = potentialeventNames;
        defaultRank = length(eventOrder) + 1;
        primaryEvents = cell(size(filteredUnitNames));
        secondaryEvents = cell(size(filteredUnitNames));
        eventRanks = zeros(size(filteredUnitNames));
        subPlotTitle=strcat(subPlotTitle,' for Rat ', ratID);
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

        [~, sortIdx] = sort(eventRanks);
        filteredUnitNames = filteredUnitNames(sortIdx);
        primaryEvents = primaryEvents(sortIdx);
        secondaryEvents = secondaryEvents(sortIdx);

        % -----------------------------------------------------------------
        % STEP 3: build eventHeatMaps
        % -----------------------------------------------------------------
        for uu = 1:length(filteredUnitNames)
            unitID = filteredUnitNames{uu};
            if~startsWith(uid,'R') && (params.combinedRegionFlag==0)
                continue
            end
            behavioralFeatures = regionUnits.(unitID).behavioralFeatures;
            if ~isfield(behavioralFeatures,behaviorField)
                continue
            end

            behavior = behavioralFeatures.(behaviorField);
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
                        eventHeatMaps.(eventName) = [eventHeatMaps.(eventName); zscoredHz];
                    catch
                        warning('Size mismatch appending zscoredHz for %s - skipping',eventName);
                        continue
                    end
                end
            end
        end

        regionUnits.eventHeatMaps.(behaviorField).data = eventHeatMaps;

        % -----------------------------------------------------------------
        % STEP 4: plotting
        % -----------------------------------------------------------------
        timeBins = linspace(-1, 1, 101);
        unitNamesPlot = filteredUnitNames;
        f=figure('Name', ['Event Heatmaps for: ' region ' ' ratID], 'NumberTitle', 'off','Units', 'inches', ...
       'Position', [1 1 11 8.5]);

        eventNames = fields(eventHeatMaps);
        [~, sortOrder] = ismember(potentialeventNames, eventNames);
        sortOrder(sortOrder==0) = [];
        eventNames = eventNames(sortOrder);
        numEvents = length(eventNames);
        
        t = tiledlayout(1,numEvents,'TileSpacing', 'Tight', 'Padding', 'None');

        
        sgtitle(t, sprintf('Treatment = %s | Behavior = %s | Region = %s ', ...
            treatmentToProcess, strrep(behaviorField,'_',' '), region), ...
            'FontSize', 12, 'Interpreter', 'none');
        subtitle(t,subPlotTitle)

        for j = 1:numEvents
            eventName = eventNames{j};
            if ~isfield(eventHeatMaps,eventName)
                continue
            end
            zscoredData = eventHeatMaps.(eventName);

            ax = nexttile(t);
            imagesc(timeBins, 1:size(zscoredData, 1), zscoredData);
            colormap(ax, 'jet');
            clim(ax, zScale);

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
                yticks([]); xticks([]); 
            else
                yticks([]); xticks([]); 
            end
            title(ax, eventName, 'Interpreter', 'none');
        end

        % === Save figure block ===
        if ~exist(savePath, 'dir')
            mkdir(savePath);
        end
        subPlotTitle=strrep(subPlotTitle,' ','_');
        pngFileName = fullfile(savePath, [treatmentToProcess '_eventHeatmaps_' behaviorField '_' region '_' saveTitleName '.png']);
        figFileName = fullfile(savePath, [treatmentToProcess '_eventHeatmaps_' behaviorField '_' region '_' saveTitleName '.fig']);
        saveas(f, figFileName);
        saveas(f, pngFileName);
        
        close(f);
        
    end
end
