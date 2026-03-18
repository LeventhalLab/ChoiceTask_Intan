%% Create FR vs MT/RT Scatter Plots

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
params.behaviorFields = {'correct','moveleft','moveright'};
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
regionsOfInterest={'cbRecipientsBroad','VM'}; 
%% for plotting the difference in zscore values of behaviorA-behaviorB  %%
params.heatMapBehaviorA='moveleft';
params.heatMapBehaviorB='moveright';
params.sortField='moveleft';
%% Exclude matched units?
params.excludeMatchUnits=1;
%% Plot scatters? Creates a lot of plots:
params.plotScatter=0;

params.useAbsoluteZ=0;
params.heatMapTitle='Excluding NonResponsive and Matched Units'; %% IMPORTANT: Use this to note what units your excluding
params.viewplots=0;
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
    if strcmp(region,'cbRecipientsBroad') || strcmp(region,'cbRecipients')
        params.combinedRegionFlag=1;
    end
    load(fullfile(regionPath, strcat(region,'_unitSummary.mat'))) %
    eventZscored={};
    % for t=1:length(params.treatmentsToProcess)
    %         params.treatmentToProcess=params.treatmentsToProcess{t};
    %         treatment=params.treatmentToProcess;
    %         disp('loading summary mat file this may take some time...')
    %         % if exist('combinedRegions') && isstruct(combinedRegions)
    %         % 
    %         %     regionUnits=combinedRegions.allUnits;
    %         %     params.combinedRegionFlag=1;
    %         % end
   if params.combinedRegionFlag
       regionUnits=combinedRegions.allUnits;
   end
        for b=1:length(params.behaviorFields)
            params.behaviorField=params.behaviorFields{b};
            [unitFRRTMTcorrelations]=unitFRvsRTMT(regionUnits,params);
            %[unitFRRTMTcorrelations]=unitZscoreFRvsRTMT(regionUnits,params,unitFRRTMTcorrelations);
            behavior=params.behaviorFields{b};
            correlations.(behavior)=unitFRRTMTcorrelations;

            fprintf('finished %s %s\n',region,behavior)
            % if params.combinedRegionFlag==1
            %     continue
            %     % heatMapPlotting_byRatID_combinedRegion(regionUnits,params);
            %     % heatMapDiffBehaviors_byRatID(regionUnits,params);
            % else
            %     %heatMapPlotting_byRatID(regionUnits,params);
            % end
        end 
    %end
    % for be=1:length(params.behaviorFields)
    %     params.behaviorField=params.behaviorFields{be};
    %     behavior=params.behaviorFields{be};
    %     controlZscores=eventZscored.control.(behavior);
    %     lesionZscores=eventZscored.lesion.(behavior);
    %     plotEventTracesDual(controlZscores, lesionZscores, params);
    % 
    % end
    saveFile=fullfile(regionPath, [region '_unitFRRTMTcorrelations.mat']);
    save(saveFile,'correlations','-v7.3','-mat')
    fprintf('Finished %s\n',region)
    clearvars("regionUnits")
end
