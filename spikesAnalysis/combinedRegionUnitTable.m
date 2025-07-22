parentDir = 'X:\Neuro-Leventhal\data\ChoiceTask\RegionalSummary';
allEntries = dir(parentDir);

% Filter only directories, excluding '.' and '..'
isSubFolder = [allEntries.isdir] & ~ismember({allEntries.name}, {'.', '..'});
regionsAvailable = {allEntries(isSubFolder).name};

% Initialize master table to collect all units
allUnitTable = table();

%% Input Parameters
params = {};
params.plotHeatMap = 0;
params.potentialeventNames = {'cueOn','centerIn','tone','centerOut','houseLightOn','sideIn','wrong','sideOut','foodClick','foodRetrieval'};
params.treatmentToProcess = 'control';
params.behaviorField = {'alltrials','correct_cuedleft','correct_cuedright'};
params.excludeNonSelectiveUnits = 0;
params.excludeSelectiveUnits = 0;
params.excludeUndeterminable = 0;
params.excludeContralateral = 0;
params.excludeIpsilateral = 0;
params.excludeNonResponsive = 1;
params.zScale = [-2 2];
params.useAbsoluteZ = 0;
params.heatMapTitle = 'Excluding lesion units and non responsive';
params.viewplots = 0;

tic
for i = 1:length(regionsAvailable)
    region = regionsAvailable{i};
    fprintf('🔍 Working on region %s\n', region)
    if strcmp(region,'cbRecipients')
        continue
    end
    params.region = region;
    regionPath = fullfile(parentDir, region);
    params.regionSummaryPath = regionPath;
    
    matFileName = strcat(region, '_unitTable.mat');
    regionFileName = fullfile(regionPath, matFileName);

    if ~isfile(regionFileName)
        warning('⚠️ Missing file: %s, skipping...', regionFileName);
        continue;
    end

    load(regionFileName); % loads unitTable
     
    % Add region column
    unitTable.region = repmat(string(region), height(unitTable), 1);

    % Append to master table
    allUnitTable = [allUnitTable; unitTable];

    % Optional: plot heatmap
    if params.plotHeatMap
        [sortedUnits, eventHeatMaps, primaryEvents, secondaryEvents] = heatMapPlotting(regionUnits, params);
    end

    fprintf('✅ Finished %s\n', region)
end

% Save combined unit table
combinedMatFile = fullfile(parentDir, 'AllRegions_unitTable.mat');
combinedCsvFile = fullfile(parentDir, 'AllRegions_unitTable.csv');
save(combinedMatFile, 'allUnitTable');
writetable(allUnitTable, combinedCsvFile);

toc
disp('🎉 All regions processed and combined unit table saved.');