parentDir = 'X:\Neuro-Leventhal\data\ChoiceTask\RegionalSummary';
allEntries = dir(parentDir);
% Filter only directories, excluding '.' and '..'
isSubFolder = [allEntries.isdir] & ~ismember({allEntries.name}, {'.', '..'});
regionsAvailable = {allEntries(isSubFolder).name};
%% Input Parameters
params={};
params.plotHeatMap=0;
% do not change
params.potentialeventNames={'cueOn','centerIn','tone','centerOut','houseLightOn','sideIn','wrong','sideOut','foodClick','foodRetrieval'};
% lesion or control?
params.treatmentToProcess='control';

plotHeatMap=1;
% Specify the behavior we are interested in plotting for heat map
params.behaviorField = {'alltrials','correct_cuedleft','correct_cuedright'};
%--Units that are not directionally selective
params.excludeNonSelectiveUnits=0; % 1 recommended if running controls
%--Units that are directionally selective usually
params.excludeSelectiveUnits=0; %0 recommended for all cases
 %--Units where selectivity could not be determined due to failed shuffle test 
params.excludeUndeterminable=0;%1 recommended for controls
%--Units that are contralaterally selective (move left selective)
params.excludeContralateral=0;
%--Units that are ipsilaterally selective (move right selective)
params.excludeIpsilateral=0;
%--Units that are not responsive to events 
%(z-score doesn't exceed 1)
params.excludeNonResponsive=1;
%Gaidica leventhal '18 used [-.5 2] inspect data
params.zScale=[-2 2];
% params.heatMapTitle='CB Recipient Zones all units';
params.useAbsoluteZ=0;
params.heatMapTitle=' Excluding lesion units and non responsive';
params.viewplots=0;%to make your computer happy
% params.parentAxes = nextAx;
% params.selectivityLabels = {'contralateral', 'ipsilateral', 'NotDirectionallySelective', 'undeterminable'};
% params.selectivityColors = [
%     0, 0.4470, 0.7410;        % Blue (Contralateral)
%     0.8500, 0.3250, 0.0980; % Orange (Ipsilateral)
%     0.9290, 0.6940, 0.1250 ; % Yellow (Non-selective)
%     0.5, 0.5, 0.5;  % gray (Undetermined) 
% ];
% % Create tiled layout for selectivity pie charts
% nRegions = numel(regionsAvailable);
% nCols = ceil(sqrt(nRegions));
% nRows = ceil(nRegions / nCols);
% selectivityFig = figure('Position', [100, 100, 300 * nCols, 300 * nRows]);
% t = tiledlayout(nRows, nCols, 'TileSpacing', 'compact', 'Padding', 'compact');
% title(t, 'Direction Selectivity of Control Units by Region');tic
for i = 1:length(regionsAvailable)
    region = regionsAvailable{i};
    fprintf('Working on region %s\n',region)
    params.region=region;
    regionPath = fullfile(parentDir, region);
    
    params.regionSummaryPath=regionPath;
    matFileName = strcat(region, '_unitSummary.mat');
    regionFileName=fullfile(regionPath,matFileName);
    load(regionFileName);
    if strcmp(region,'cbRecipients')
        keyboard
    end
    %regionUnits = regionMatFile.regionUnits;
    [unitTable,saveRegionFlag]=regionStatistics(regionUnits);
    
    % unitNames = fields(regionUnits);
    if params.plotHeatMap
        [sortedUnits, eventHeatMaps,primaryEvents,secondaryEvents]=heatMapPlotting(regionUnits,params);
    end
    % if ~isfield(regionUnits,'regionSummary')
    %     regionUnits.regionSummary=struct();
    % end
    saveFileName = fullfile(regionPath, strcat(region, '_unitTable.mat'));
    csvFileName = fullfile(regionPath, strcat(region, '_unitTable.csv'));
    save(saveFileName, 'unitTable');
    writetable(unitTable, csvFileName);
    disp('Unit table created moving to the plots')
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
    disp('adding selectivity pie chart')
    % Check that the tiled layout exists and is valid
    % if exist('t', 'var') && isgraphics(t, 'tiledlayout')
    %     nextAx = nexttile(t);
    %     params.parentAxes = nextAx;
    %     plotSelectivityPieChartForControls(unitTable, params);
    % else
    %     warning('Tiled layout handle "t" is not valid. Skipping pie chart for region %s.', region);
    % end
    fprintf('Finished %s\n',region)
    if saveRegionFlag
        disp('regionUnits was updated so saving...')
        save(regionFileName,'regionUnits','-v7.3','-mat')
    end
end
% Save combined figure
% saveas(selectivityFig, fullfile(parentDir, 'AllRegions_SelectivityPieCharts.png'));
toc
disp('fuck yes we love data')