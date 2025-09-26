%% Creates summary plots for all units across all regions

parentDir = 'X:\Neuro-Leventhal\data\ChoiceTask\RegionalSummary';
allEntries = dir(parentDir);

% Filter only directories, excluding '.' and '..'
isSubFolder = [allEntries.isdir] & ~ismember({allEntries.name}, {'.', '..'});
regionsAvailable = {allEntries(isSubFolder).name};

load(fullfile(parentDir,'AllRegions_unitTable.mat'))
behaviorFields={'alltrials','correct_cuedleft','correct_cuedright'};
params.compareSelectivity={'ipsilateral','contralateral','NotDirectionallySelective'};
params.treatmentFilter='control';
regionsAvail=unique(allUnitTable.region);
for r=1:length(regionsAvail)
    region=regionsAvail{r};
    regionUnitTable = allUnitTable(strcmp(allUnitTable.region, region), :);
    for b=1:length(behaviorFields)
        behavior=behaviorFields{b};
        try
            comparePrimaryEventBySelectivity2(regionUnitTable,parentDir,behavior,params)
        catch ME
            keyboard
            disp('this isnt going to work for this region so passing for now...')
            continue
        end
        primaryEventsBarGraph(regionUnitTable, behavior, parentDir,params); %plots counts of primary events by treatment type
        primaryEventsProportionBarGraph(regionUnitTable, params,behavior) %Note: requires only 1 behaviorcompares proportion of primary events by treatment type and determines significance using chisquare test
        plotSecondaryEventPieCharts(regionUnitTable, params,behavior) %compares two treatment types for only 1 behavior
        compareSelectivityProportionBarGraph(regionUnitTable, params, behavior)
        comparePrimaryEventBySelectivity2(regionUnitTable,regionPath,behavior,params)
        plotSelectivityPieChartForControls(regionUnitTable, params);
    
    end
end

plotToneEventProportionsByRegion(allUnitTable, behaviorField) %only works for 1 behavior?   
tonePrimaryUnitsAllTrials=alltrialstable(strcmp(allUnitTable.primaryEvent, 'tone'), :);
alltrialstable=allUnitTable(strcmp(allUnitTable.behavior,'alltrials'),:);
lotSelectivityPieChartForControls(alltrialstable, params);
