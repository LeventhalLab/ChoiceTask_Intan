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
params.behaviorFields = {'alltrials','correct','moveright','moveleft','correct_cuedleft','correct_cuedright'};%,'moveleft','moveright','wrong'};
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
specifyRegions=0;
regionsOfInterest={'cbRecipients','cbRecipientsBroad'}; 
%% for plotting the difference in zscore values of behaviorA-behaviorB  %%
params.heatMapBehaviorA='moveleft';
params.heatMapBehaviorB='moveright';
params.sortField='moveleft';

params.useAbsoluteZ=0;
params.heatMapTitle='Excluding NonResponsive'; %% IMPORTANT: Use this to note what units your excluding
params.viewplots=0;%to make your computer happy
ignoreRegions={};

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
    
    load(fullfile(regionPath, strcat(region,'_unitSummary.mat')))
    if exist('combinedRegions') && isstruct(combinedRegions)   
        keyboard
        regionUnits=combinedRegions.allUnits;
        params.combinedRegionFlag=1;
    end
    fieldNames=fields(regionUnits);
    for u=1:length(fieldNames)
        unitID=fieldNames{u};
        if strfind(unitID,'previouslyCurated')
            continue
        end
        
         regionUnits.(unitID).unitMetrics.unitACG=[];
         %regionUnits.(unitID).unitMetrics.templateWaveforms=[];
         %regionUnits.(unitID).unitMetrics.clusterSpikes=[];
         behaviors=fields(regionUnits.(unitID).behavioralFeatures);
         if ~isfield(regionUnits.(unitID),'behavioralFeatures')
            keyboard
            continue
         end
        
         for b=1:length(behaviors)
             behavior=behaviors{b};
             subFields=fields(regionUnits.(unitID).behavioralFeatures.(behavior));
             for s=1:length(subFields)
                 subField=subFields{s};
                 if ~strcmp(subField,'allEventTimestamps')
                      regionUnits.(unitID).behavioralFeatures.(behavior)=rmfield( regionUnits.(unitID).behavioralFeatures.(behavior),subField);
                 end
             end
         end

    end
    saveFile=fullfile(regionPath, [region '_unitSummary_spikesWbehavioralTS.mat']);
    if params.combinedRegionFlag
        combinedRegions.allUnits=regionUnits;
        save(saveFile,'combinedRegions','-v7.3','-mat')
    else
        save(saveFile,'regionUnits','-v7.3','-mat')
    end
    fprintf('Finished %s\n',region)
end
