parentDir = 'X:\Neuro-Leventhal\data\ChoiceTask\RegionalSummary';
allEntries = dir(parentDir);

% Filter only directories, excluding '.' and '..'
isSubFolder = [allEntries.isdir] & ~ismember({allEntries.name}, {'.', '..'});
regionsAvailable = {allEntries(isSubFolder).name};

load(fullfile(parentDir,'AllRegions_unitTable.mat'))
behaviorFields={'alltrials','correct_cuedleft','correct_cuedright'};
params.compareSelectivity={'ipsilateral','contralateral','NotDirectionallySelective'};
for b=1:length(behaviorFields)
    behavior=behaviorFields{b};
    comparePrimaryEventBySelectivity2(allUnitTable,parentDir,behavior,params)
    primaryEventsBarGraph(allUnitTable, behavior, parentDir,params); %plots counts of primary events by treatment type
    primaryEventsProportionBarGraph(allUnitTable, params,behavior) %Note: requires only 1 behaviorcompares proportion of primary events by treatment type and determines significance using chisquare test
    plotSecondaryEventPieCharts(allUnitTable, params,behavior) %compares two treatment types for only 1 behavior
    compareSelectivityProportionBarGraph(allUnitTable, params, behavior)
    comparePrimaryEventBySelectivity2(allUnitTable,regionPath,behavior,params)
    plotSelectivityPieChartForControls(allunitTable, params);

end
plotToneEventProportionsByRegion(allUnitTable, behaviorField)
tonePrimaryUnitsAllTrials=alltrialstable(strcmp(allUnitTable.primaryEvent, 'tone'), :);
alltrialstable=allUnitTable(strcmp(allUnitTable.behavior,'alltrials'),:);
    plotSelectivityPieChartForControls(alltrialstable, params);
params.treatmentFilter='control';