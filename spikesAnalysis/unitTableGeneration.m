%% Script that generates a unit table which summarizes every units metrics into one combined table for each region


parentDir = 'X:\Neuro-Leventhal\data\ChoiceTask\RegionalSummary';
allEntries = dir(parentDir);
isSubFolder = [allEntries.isdir] & ~ismember({allEntries.name}, {'.', '..'});
regionsAvailable = {allEntries(isSubFolder).name};

for i = 1:length(regionsAvailable)
    region = regionsAvailable{i};
    fprintf('Working on region %s\n',region)
    params.region=region;
    regionPath = fullfile(parentDir, region);
    
    params.regionSummaryPath=regionPath;
    matFileName = strcat(region, '_unitSummary.mat');
    regionFileName=fullfile(regionPath,matFileName);
    load(regionFileName);
    if exist('combinedRegions') && isstruct(combinedRegions)
        regionUnits=combinedRegions.allUnits;
        keyboard
    end
    if strcmp(region,'x')
        continue
    end
   
    [unitTable,saveRegionFlag]=regionStatistics(regionUnits);

    saveFileName = fullfile(regionPath, strcat(region, '_unitTable.mat'));
    csvFileName = fullfile(regionPath, strcat(region, '_unitTable.csv'));
    save(saveFileName, 'unitTable');
    writetable(unitTable, csvFileName);
    
    % for b=1:length(params.behaviorField)
    %     behaviorField=params.behaviorField{b};
    %     if ~any(strcmp(unitTable.behavior, behaviorField))
    %         disp(params.region)
    %         fprintf('Doesnt contain fields for %s\n',params.behaviorField)
    %         continue
    %     end
    %     primaryEventsBarGraph(unitTable, behaviorField, params.regionSummaryPath,params); %plots counts of primary events by treatment type
    %     primaryEventsProportionBarGraph(unitTable, params,behaviorField) %Note: requires only 1 behaviorcompares proportion of primary events by treatment type and determines significance using chisquare test
    %     plotSecondaryEventPieCharts(unitTable, params,behaviorField) %compares two treatment types for only 1 behavior
    % end
    % compareSecondaryEventPieChartsMultiBehavior(unitTable, params) %works for comparing any number of behaviors given by behavior field (seems like 2 is the max unless you have a bigger screen)
    % comparePrimaryEventProportionsByBehavior(unitTable, params); %works for determining significant differences between behaviors within a given treatment type for their proporiton of primary event types
    % plotSelectivityPieChartForControls(unitTable, params);%Counts only 1 per unique id  %really only used for controls potentially add to a larger tiled layout that can be useful for comparing selectivity of different regions
    % -- ADD TILE FOR PIE CHART
   
    fprintf('Finished making unit table for %s\n',region)
    if saveRegionFlag
        disp('regionUnits was updated so saving...')
        save(regionFileName,'regionUnits','-v7.3','-mat')
    end
end
% Save combined figure
% saveas(selectivityFig, fullfile(parentDir, 'AllRegions_SelectivityPieCharts.png'));
toc
disp('fuck yes we love data')