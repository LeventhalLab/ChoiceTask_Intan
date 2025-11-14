parentDir = 'X:\Neuro-Leventhal\data\ChoiceTask\RegionalSummary';
allEntries = dir(parentDir);
% Filter only directories, excluding '.' and '..'
isSubFolder = [allEntries.isdir] & ~ismember({allEntries.name}, {'.', '..'});
regionsAvailable = {allEntries(isSubFolder).name};
%% Input Parameters
params={};
params.plotHeatMap=1;
% do not change
params.potentialeventNames={'cueOn','centerIn','tone','centerOut','sideIn','sideOut','foodRetrieval'};
% lesion or control?
params.treatmentToProcess={'control','lesion'};
params.treatmentFilter='control';
% Specify the behavior we are interested in plotting for heat map
params.behaviorField = {'alltrials','correct'};%,'moveleft','moveright','wrong'};
%--Units that are not directionally selective
params.excludeNonSelectiveUnits=1; % 1 recommended if running controls
%--Units that are directionally selective usually
params.excludeSelectiveUnits=0; %0 recommended for all cases
 %--Units where selectivity could not be determined due to failed shuffle test 
params.excludeUndeterminable=1;%1 recommended for controls
%--Units that are contralaterally selective (move left selective)
params.excludeContralateral=0;
%--Units that are ipsilaterally selective (move right selective)
params.excludeIpsilateral=0;
%--Units that are not responsive to events 
%(z-score doesn't exceed 1)
params.excludeNonResponsive=1;
%Gaidica leventhal '18 used [-.5 2] inspect data
params.zScale=[-2 2];

params.heatMapBehaviorA='moveleft';
params.heatMapBehaviorB='moveright';
% params.heatMapTitle='CB Recipient Zones all units';
params.useAbsoluteZ=0;
params.heatMapTitle=' all units';
params.viewplots=0;%to make your computer happy
params.controlSelectivityFilter = 'contralateral'; %use this to only compare lesion units to those that are some type of selective
params.compareSelectivity = {'ipsilateral','contralateral', 'NotDirectionallySelective'};
params.selectivityLabels = {'contralateral', 'ipsilateral', 'NotDirectionallySelective', 'undeterminable'};
params.selectivityColors = [
    0, 0.4470, 0.7410;        % Blue (Contralateral)
    0.8500, 0.3250, 0.0980; % Orange (Ipsilateral)
    0.9290, 0.6940, 0.1250 ; % Yellow (Non-selective)
    0.5, 0.5, 0.5;  % gray (Undetermined) 
];
% Create tiled layout for selectivity pie charts
nRegions = numel(regionsAvailable);
nCols = ceil(sqrt(nRegions));
nRows = ceil(nRegions / nCols);

matchBehaviors={'alltrials', 'correct','moveleft','moveright'};

ignoreRegions={'AHP',	'LH',	'Mt',	'PLH',	'PaPo',	'PefLH-LH'};
for i = 1:length(regionsAvailable)
    region = regionsAvailable{i};
    if any(strcmp(region,ignoreRegions))
        continue
    end
    fprintf('Working on region %s\n',region)
    params.region=region;
    regionPath = fullfile(parentDir, region);
    params.regionSummaryPath=regionPath;
    %load table and unit file
    unitTableName=fullfile(regionPath, strcat(region, '_unitTable.mat'));
    load(unitTableName);
    regionFileName=fullfile(regionPath, strcat(region, '_unitSummary_lite.mat'));
    load(regionFileName);
    ratIDs = cell(height(unitTable), 1);
    %add a region column
    unitTable.region = repmat({region}, height(unitTable), 1);
    % Loop through each row
    for i = 1:height(unitTable)
        currentUnitID = unitTable.unitID{i};
        % Extract the rat ID starting with 'R0'
        ratID = regexp(currentUnitID, 'R0\d+', 'match', 'once');
        ratIDs{i} = ratID;
    end
    unitTable.ratID = ratIDs;
    hasMatchedUnit=~cellfun(@isempty, unitTable.MatchedUnitID);
    uniqueBehaviors = unique(unitTable.behavior);
    MatchedUnitTable = unitTable(hasMatchedUnit, :);
    [~, idx] = unique(MatchedUnitTable.unitID);
    unitsWmatch = MatchedUnitTable(idx, :);
    % Create abbreviated table
    for i = 1:numel(uniqueBehaviors)
        thisBehavior = uniqueBehaviors{i};
        % Filter rows for this behavior
        behaviorTable = MatchedUnitTable(strcmp(MatchedUnitTable.behavior, thisBehavior), :);
    
        % Store it in a struct using the behavior name as the field
        behaviorTables.(thisBehavior) = behaviorTable;
    end
    for mm=1:length(matchBehaviors)
        matchBehavior=matchBehaviors{mm};
        plottedMatchedIDs = {};
    
        
        for u = 1:length(unitsWmatch.unitID)
            uid = unitsWmatch.unitID{u};
            unitRatID = unitsWmatch.ratID{u};
            matchID = unitsWmatch.MatchedUnitID{u};
        
            % Create a unique key combining ratID and matchID
            uniqueKey = sprintf('%s_%s', unitRatID, num2str(matchID));
            
            if any(strcmp(plottedMatchedIDs, uniqueKey))
                continue
            end
        
            matchingRows = strcmp(unitsWmatch.ratID, unitRatID) & ...
                           cellfun(@(x) isequal(x, matchID), unitsWmatch.MatchedUnitID);
        
            % Extract the matching unitIDs
            matchingUnitIDs = unitsWmatch.unitID(matchingRows);
        
            % Store that we’ve plotted this matched group
            plottedMatchedIDs{end+1} = uniqueKey;
        
            % ==========================
            % PLOT OVERLAYED Z-SCORED PSTHs
            % ==========================
            fprintf('Plotting matched PSTHs for Rat %s, MatchedUnitID %s (%d units)\n', ...
                unitRatID, num2str(matchID), numel(matchingUnitIDs));
        
            % Call the plotting helper function
            plotMatchedUnitsZscoredPSTHs(regionUnits, matchingUnitIDs, unitRatID, matchID, matchBehavior, params, region);
        end
    end
end
