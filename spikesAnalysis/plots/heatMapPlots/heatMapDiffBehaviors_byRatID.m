function heatMapDiffBehaviors_byRatID(regionUnits,params)
%% Heatmap of difference between BehaviorA and BehaviorB (zscoreA - zscoreB)
%% For each Rat in a given region
%% filteredUnitNames used to pre-select units based on params

behaviorA = params.heatMapBehaviorA;
behaviorB = params.heatMapBehaviorB;
potentialeventNames = params.potentialeventNames;
zScale = params.zScale;
useAbsoluteZ = params.useAbsoluteZ;
treatmentToProcess = params.treatmentToProcess;
region = params.region;
subPlotTitle = params.heatMapTitle;

unitNames = fields(regionUnits);
ratIDs = cellfun(@(x) extractBefore(x, '_'), unitNames, 'UniformOutput', false);

for r = 1:length(unique(ratIDs))
    ratID = ratIDs{r};
    if~startsWith(ratID,'R') && (params.combinedRegionFlag==0)
        continue
    end
    savePath = fullfile(params.regionSummaryPath,ratID);

    % Reset per-rat variables here
    filteredUnitNames = {};
    primaryEvents = {};
    eventHeatMaps = struct();

    %% === STEP 1: Create filteredUnitNames based on params ===
    for u = 1:length(unitNames)
        uid = unitNames{u};
        
        % Only process units that start with 'R'
        if ~startsWith(uid,'R')
            continue
        end
        if ~contains(uid,ratID)
            continue
        end
        unit = regionUnits.(uid);
        
        % Skip units missing unitMetrics
        if ~isfield(unit,'unitMetrics')
            continue
        end
        
        unitClass = unit.unitMetrics.unitClass;
        directionDependence = unitClass.directionDependence;
        
        % === Filtering based on params ===
        if isfield(params,'excludeNonResponsive') && params.excludeNonResponsive && strcmp(unitClass.type,'nonResponsive')
            continue
        end
        if isfield(params,'excludeUndeterminable') && params.excludeUndeterminable
            if isempty(directionDependence) || (isfield(directionDependence,'direction') && strcmp(directionDependence.direction,'undeterminable'))
                continue
            end
        end
        if isfield(params,'excludeNonSelectiveUnits') && params.excludeNonSelectiveUnits
            if isfield(directionDependence,'direction') && strcmp(directionDependence.direction,'NotDirectionallySelective')
                continue
            end
        end
        if isfield(params,'excludeIpsilateral') && params.excludeIpsilateral
            if isfield(directionDependence,'direction') && strcmp(directionDependence.direction,'ipsilateral')
                continue
            end
        end
        if isfield(params,'excludeContralateral') && params.excludeContralateral
            if isfield(directionDependence,'direction') && strcmp(directionDependence.direction,'contralateral')
                continue
            end
        end
        % Passed all filters
        filteredUnitNames{end+1} = uid;
    end
    
    %% === STEP 2: Compute primaryEvents and sort by BehaviorA ===
    eventOrder = potentialeventNames;
    defaultRank = length(eventOrder)+1;
    eventRanks = zeros(size(filteredUnitNames));
    
    for u = 1:length(filteredUnitNames)
        uid = filteredUnitNames{u};
        unitClass = regionUnits.(uid).unitMetrics.unitClass;
        
        if isfield(unitClass,behaviorA) && isfield(unitClass.(behaviorA),'primaryEvent')
            primaryEvent = unitClass.(behaviorA).primaryEvent;
            primaryEvents{u} = primaryEvent;
            idx = find(strcmp(primaryEvent, eventOrder),1);
            if ~isempty(idx)
                eventRanks(u) = idx;
            else
                eventRanks(u) = defaultRank;
            end
        else
            primaryEvents{u} = 'unknown';
            eventRanks(u) = defaultRank;
        end
    end
    
    % Sort filteredUnitNames and primaryEvents by eventRanks
    [~, sortIdx] = sort(eventRanks);
    filteredUnitNames = filteredUnitNames(sortIdx);
    primaryEvents = primaryEvents(sortIdx);
    
    %% === STEP 3: Compute difference heatmaps ===
    timeBins = linspace(-1,1,101);
    
    for u = 1:length(filteredUnitNames)
        uid = filteredUnitNames{u};
        behavioralFeatures = regionUnits.(uid).behavioralFeatures;
        
        if ~isfield(behavioralFeatures, behaviorA) || ~isfield(behavioralFeatures, behaviorB)
            continue
        end
        
        behaviorAData = behavioralFeatures.(behaviorA);
        behaviorBData = behavioralFeatures.(behaviorB);
        
        eventNames = intersect(fields(behaviorAData), fields(behaviorBData));
        for e = 1:length(eventNames)
            eventName = eventNames{e};
            if ~any(strcmp(eventName,potentialeventNames))
                continue
            end
            
            zA = behaviorAData.(eventName).zscoredHz;
            zB = behaviorBData.(eventName).zscoredHz;
            diffZ = zA - zB;
            if useAbsoluteZ
                diffZ = abs(diffZ);
            end
            
            if ~isfield(eventHeatMaps,eventName)
                eventHeatMaps.(eventName) = [];
            end
            eventHeatMaps.(eventName) = [eventHeatMaps.(eventName); diffZ];
        end
    end
    
    %% === STEP 4: Plot heatmaps with primary/secondary ticks ===
    f=figure('Name',['Diff Heatmaps ' region ' Rat ' ratID],'NumberTitle','off','Units', 'inches', ...
       'Position', [1 1 11 8.5]);
    eventNames = fields(eventHeatMaps);
    
    [~, sortOrder] = ismember(potentialeventNames, eventNames);
    sortOrder(sortOrder==0) = []; % remove any events not present
    eventNames = eventNames(sortOrder);
    numEvents = length(eventNames);
    if numEvents==0
        fprintf('unable to compare zscored values between %s and %s for rat %s',behaviorA,behaviorB,ratID)
        close(f);
        continue
    end
    t = tiledlayout(1,numEvents,'TileSpacing','Tight','Padding','None');
    sgtitle(t, sprintf('Treatment = %s | zDiff (%s - %s) | Region: %s | Rat: %s', ...
        treatmentToProcess, behaviorA, behaviorB, region, ratID),'FontSize', 12, 'Interpreter', 'none');
    subtitle(t,subPlotTitle)
    for j = 1:numEvents
        eventName = eventNames{j};
        zscoredData = eventHeatMaps.(eventName);
        
        ax = nexttile(t);
        imagesc(timeBins, 1:size(zscoredData,1), zscoredData);
        colormap(ax,'jet');
        clim(ax,zScale);
        xlabel(ax,'Time (s)');
        ylabel(ax,'Unit #');
        title(ax,eventName,'Interpreter','none');
        
        % === Add primary/secondary event ticks from BehaviorA ===
        for u = 1:length(filteredUnitNames)
            uid = filteredUnitNames{u};
            unitClass = regionUnits.(uid).unitMetrics.unitClass;
            if isfield(unitClass,behaviorA)
                % Primary event tick (pink, left)
                if isfield(unitClass.(behaviorA),'primaryEvent') && strcmp(unitClass.(behaviorA).primaryEvent,eventName)
                    line(ax, [-1, -0.88], [u,u], 'Color',[1 0.4 0.7],'LineWidth',3);
                end
                % Secondary event tick (white, right)
                if isfield(unitClass.(behaviorA),'secondaryEvent') && strcmp(unitClass.(behaviorA).secondaryEvent,eventName)
                    line(ax, [0.90,1.02],[u,u],'Color','w','LineWidth',2);
                end
            end
        end
        
        if j==numEvents
            colorbar(ax);
        else
            yticks([]);
            xticks([]);
        end
    end
    
    %% === STEP 5: Save figure ===
    if ~exist(savePath,'dir'), mkdir(savePath); end
    subPlotTitle=strrep(subPlotTitle,' ','_');
    figFileName = fullfile(savePath, sprintf('%s_diffHeatmaps_%s_%s_%s_%s_%s.fig',treatmentToProcess,behaviorA,behaviorB,region,ratID,subPlotTitle));
    saveas(f, figFileName);
    pngFileName = fullfile(savePath, sprintf('%s_diffHeatmaps_%s_%s_%s_%s.png',treatmentToProcess,behaviorA,behaviorB,region,subPlotTitle));
    saveas(f, pngFileName);
    close(f);
    
end 
return
end