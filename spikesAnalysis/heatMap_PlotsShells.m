parentDir = 'X:\Neuro-Leventhal\data\ChoiceTask\RegionalSummary';
allEntries = dir(parentDir);
% Filter only directories, excluding '.' and '..'
isSubFolder = [allEntries.isdir] & ~ismember({allEntries.name}, {'.', '..'});
regionsAvailable = {allEntries(isSubFolder).name};
%% Input Parameters %%
params={};

%% do not change
params.potentialeventNames={'cueOn','centerIn','tone','centerOut','sideIn','sideOut','foodClick','foodRetrieval','wrong','houseLightOn'};
%% lesion or control?
params.treatmentsToProcess={'control','lesion'};
params.treatmentFilter='control';
%% Specify the single behaviors we are interested in plotting for heat map
params.behaviorFields = {'correct'};
%% --Units that are not directionally selective
params.excludeNonSelectiveUnits=0; % 1 recommended if running controls
%% --Units that are directionally selective usually
params.excludeSelectiveUnits=0; %0 recommended for all cases
 %% --Units where selectivity could not be determined due to failed shuffle test 
params.excludeUndeterminable=0;%1 recommended for controls
%% --Units that are contralaterally selective (move left selective)
params.excludeContralateral=0;
%% --Units that are ipsilaterally selective (move right selective)
params.excludeIpsilateral=0;
%% --Units that are not responsive to events z-score doesn't exceed 1)
params.excludeNonResponsive=1;
%% Gaidica leventhal '18 used [-.5 2] inspect data
params.zScale=[-2 2];
%% do you want to process specific region?
specifyRegions=1;
regionsOfInterest={'VM','cbRecipientsBroad'}; 
%% for plotting the difference in zscore values of behaviorA-behaviorB  %%
params.heatMapBehaviorA='moveleft';
params.heatMapBehaviorB='moveright';
params.sortField='moveleft';

params.useAbsoluteZ=0;
params.heatMapTitle='Excluding NonResponsive'; %% IMPORTANT: Use this to note what units your excluding
params.viewplots=0;%to make your computer happy
% params.controlSelectivityFilter = 'contralateral'; %use this to only compare lesion units to those that are some type of selective
% params.compareSelectivity = {'ipsilateral','contralateral', 'NotDirectionallySelective'};
% params.selectivityLabels = {'contralateral', 'ipsilateral', 'NotDirectionallySelective', 'undeterminable'};
% params.selectivityColors = [
%     0, 0.4470, 0.7410;        % Blue (Contralateral)
%     0.8500, 0.3250, 0.0980; % Orange (Ipsilateral)
%     0.9290, 0.6940, 0.1250 ; % Yellow (Non-selective)
%     0.5, 0.5, 0.5;  % gray (Undetermined) 
% ];
% Create tiled layout for selectivity pie charts
% nRegions = numel(regionsAvailable);
% nCols = ceil(sqrt(nRegions));
% nRows = ceil(nRegions / nCols);
% selectivityFig = figure('Position', [100, 100, 300 * nCols, 300 * nRows]);
% t = tiledlayout(nRows, nCols, 'TileSpacing', 'compact', 'Padding', 'compact');
% 
% title(t, 'Direction Selectivity of Control Units by Region');tic
ignoreRegions={};
params.badAllTrialsIDs={'R0544_20240626a_Unit_70_Treatment_lesion', 'R0544_20240625a_Unit_64_Treatment_lesion', 'R0544_20240626a_Unit_76_Treatment_lesion',... 
    'R0544_20240628b_Unit_86_Treatment_lesion', 'R0544_20240627a_Unit_64_Treatment_lesion,' ...
    ' R0544_20240628b_Unit_87_Treatment_lesion', ' R0544_20240701a_Unit_291_Treatment_lesion', ...
    ' R0544_20240702a_Unit_122_Treatment_lesion', ' R0544_20240703a_Unit_321_Treatment_lesion', ...
    ' R0544_20240709b_Unit_85_Treatment_lesion', ' R0544_20240711a_Unit_122_Treatment_lesion',' R0572_20240924a_Unit_10_Treatment_lesion', ...
    ' R0572_20240924a_Unit_14_Treatment_lesion', ' R0572_20240924a_Unit_24_Treatment_lesion',...
    ' R0572_20240924a_Unit_30_Treatment_lesion',' R0572_20240924a_Unit_36_Treatment_lesion',...
    ' R0572_20240924a_Unit_42_Treatment_lesion',' R0545_20250113a_Unit_67_Treatment_lesion',... 
    ' R0545_20250113a_Unit_96_Treatment_lesion',  ' R0545_20250113a_Unit_83_Treatment_lesion'};

for i = 1:length(regionsAvailable)
    region = regionsAvailable{i};
    if any(strcmp(region,ignoreRegions))
        continue
    end
    if specifyRegions
        if ~any(strcmp(region,regionsOfInterest))
            fprintf('processing specific regions based on params so skipping %s\n',region)
            continue
        end
    end
    fprintf('Working on region %s\n',region)
    params.region=region;
    regionPath = fullfile(parentDir, region);
    params.regionSummaryPath=regionPath;
    params.combinedRegionFlag=0;
    load(fullfile(regionPath, strcat(region,'_unitSummary_lite.mat')))
    eventZscored={};
    for t=1:length(params.treatmentsToProcess)
            params.treatmentToProcess=params.treatmentsToProcess{t};
            treatment=params.treatmentToProcess;
            disp('loading summary mat file this may take some time...')
            if exist('combinedRegions') && isstruct(combinedRegions)
                
                regionUnits=combinedRegions.allUnits;
                params.combinedRegionFlag=1;
            end
            for b=1:length(params.behaviorFields)
                params.behaviorField=params.behaviorFields{b};
                [filteredUnitNames,eventHeatMaps,primaryEvents,secondaryEvents]=heatMapPlotting2(regionUnits,params);
                eventZscored.(treatment)=eventHeatMaps;
                

                if isempty(filteredUnitNames)
                    fprintf('No valid %s units in %s',params.treatmentToProcess,region)
                    continue
                end
                % if params.combinedRegionFlag==1
                %     continue
                %     % heatMapPlotting_byRatID_combinedRegion(regionUnits,params);
                %     % heatMapDiffBehaviors_byRatID(regionUnits,params);
                % else
                %     %heatMapPlotting_byRatID(regionUnits,params);
                % end
            end
            %[filteredUnitNames_diffBehaviors,eventHeatMaps_diffBehaviors,primaryEvents_diffBehaviors]=heatMapDiffBehaviors(regionUnits,params);
            % if params.combinedRegionFlag==1
            %     keyboard
            %     % heatMapPlotting_byRatID(regionUnits,params);
            %     % heatMapDiffBehaviors_byRatID(regionUnits,params);
            % else
            %     %heatMapDiffBehaviors_byRatID(regionUnits,params);
            % end
            fprintf('heat maps created for %s units in %s',params.treatmentToProcess,region)
    end
    plotEventTracesDual(eventZscored.control, eventZscored.lesion, params);
    disp('all heat maps created for all beahviors and rat ids')
    % for b=1:length(params.behaviorField)
    %     behaviorField=params.behaviorField{b};
    %     if ~any(strcmp(unitTable.behavior, behaviorField))
    %         disp(params.region)
    %         fprintf('Doesnt contain fields for %s\n',behaviorField)
    %         continue
    %     end
    % 
    %    % primaryEventsBarGraph(unitTable, behaviorField, params.regionSummaryPath,params); %plots counts of primary events by treatment type
    %     for d=1:length(params.compareSelectivity)
    %         selectivityEvent=params.compareSelectivity{d};
    % 
    %         primaryEventsProportionBarGraph(unitTable, params,behaviorField,selectivityEvent) %Note: requires only 1 behaviorcompares proportion of primary events by treatment type and determines significance using chisquare test
    %     end 
    %    %plotSecondaryEventPieCharts(unitTable, params,behaviorField) %compares two treatment types for only 1 behavior
    %    % compareSelectivityProportionBarGraph(unitTable, params, behaviorField)
    %     comparePrimaryEventBySelectivity2(unitTable,regionPath,behaviorField,params) %needs work 
    % end
    % % compareSecondaryEventPieChartsMultiBehavior(unitTable, params) %works for comparing any number of behaviors given by behavior field (seems like 2 is the max unless you have a bigger screen)
    % % comparePrimaryEventProportionsByBehavior(unitTable, params); %works for determining significant differences between behaviors within a given treatment type for their proporiton of primary event types
    % % plotSelectivityPieChartForControls(unitTable, params);%Counts only 1 per unique id  %really only used for controls potentially add to a larger tiled layout that can be useful for comparing selectivity of different regions
    % %-- ADD TILE FOR PIE CHART
    % disp('adding selectivity pie chart')
    % %Check that the tiled layout exists and is valid
    % hasControl = any(strcmp(unitTable.treatment, 'control'));
    % if ~hasControl
    %     fprintf('Skipping %s: no control units found.\n', region);
    %     continue
    % end
    % if exist('t', 'var') && isgraphics(t, 'tiledlayout')
    %     nextAx = nexttile(t);
    %     params.parentAxes = nextAx;
    %     try
    %        plotSelectivityPieChartForControls(unitTable, params);
    %     catch ME
    %         keyboard
    %         disp('selectivity pie chart not possible??')
    %         continue
    %     end
    % else
    %     warning('Tiled layout handle "t" is not valid. Skipping pie chart for region %s.', region);
    % end
    fprintf('Finished %s\n',region)
    clearvars("regionUnits")
end
% Save combined figure
% saveas(selectivityFig, fullfile(parentDir, 'AllRegions_SelectivityPieCharts.png'));
% toc
% disp('fuck yes we love data')