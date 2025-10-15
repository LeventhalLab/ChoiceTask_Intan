behavioralFeature={'alltrials'};
badIDs={'R0544_20240626a_Unit_70_Treatment_lesion', 'R0544_20240625a_Unit_64_Treatment_lesion', 'R0544_20240626a_Unit_76_Treatment_lesion',... 
    'R0544_20240628b_Unit_86_Treatment_lesion', 'R0544_20240627a_Unit_64_Treatment_lesion,' ...
    ' R0544_20240628b_Unit_87_Treatment_lesion', ' R0544_20240701a_Unit_291_Treatment_lesion', ...
    ' R0544_20240702a_Unit_122_Treatment_lesion', ' R0544_20240703a_Unit_321_Treatment_lesion', ...
    ' R0544_20240709b_Unit_85_Treatment_lesion', ' R0544_20240711a_Unit_122_Treatment_lesion',' R0572_20240924a_Unit_10_Treatment_lesion', ...
    ' R0572_20240924a_Unit_14_Treatment_lesion', ' R0572_20240924a_Unit_24_Treatment_lesion',...
    ' R0572_20240924a_Unit_30_Treatment_lesion',' R0572_20240924a_Unit_36_Treatment_lesion',...
    ' R0572_20240924a_Unit_42_Treatment_lesion',' R0545_20250113a_Unit_67_Treatment_lesion',... 
    ' R0545_20250113a_Unit_96_Treatment_lesion',  ' R0545_20250113a_Unit_83_Treatment_lesion'};
potentialeventNames={'cueOn','centerIn','tone','centerOut','houseLightOn','sideIn','wrong','sideOut','foodClick','foodRetrieval'};
featureName='alltrials';
for uu = 1:length(badIDs)
          unitID=badIDs{uu}; 
          Feature=behavioralFeature{1};
          trials=regionUnits.(unitID).behavioralFeatures.(Feature).valid_trials;
          spikes=regionUnits.(unitID).unitMetrics.clusterSpikes;
                     
                    %% Extract time stamps of events for each given trial feature 
                    trialfeatures=behavioralFeature;
                    [ts_data,valid_trials,valid_trial_flags,valid_eventNames] =unit_correct_trial_data_RL(trials, trialfeatures,potentialeventNames);  
                    n_valid_trials=length(valid_trials);
                    %badFeatures=[];
                    if length(valid_trials)<3
                        sprintf('not enough valid trials for the given trialfeature for %s', sessionName)
                        % badFeatures=trialfeatures(i)
                        fprintf('There is only %s\n', num2str(n_valid_trials))
                        continue
                    end
                    
                    eventNames=valid_eventNames;
                    eventNames = eventNames(~strcmp(eventNames, 'foodClick'));
                    
                                             
                    min_psth = Inf;
                    max_psth = -Inf;
                    min_zscore=Inf;
                    max_zscore=-Inf;
                    %% Determine minimum/maxmimum hertz value across all events for this cluster
                    
                    for e = 1:length(eventNames)   % Loop through events
                        
                        
                        eventName = eventNames{e}; % Current event name

                        ts = ts_data.(eventName);  % Extract timestamps for the event
                        ts=ts(~isnan(ts));
                        
                        % [spikeTimes, psth, bins,binWidthInSeconds,psthHz, numRows, zscoredpsth, rasterX, rasterY, spikeCounts] = psthRasterAndCounts(spikeTimes, eventTimes, window, psthBinSize);
                        [spikeTimes, psth, bins,psthHz, rasterX, rasterY, spikeCounts] = psthRasterAndCounts(spikes, ts, [-1 1], binSize);
                        zscoredHz=(psthHz-meanFR) ./ stdMeanFR;
                        min_psth = min(min_psth, min(psthHz));
                        max_psth = max(max_psth, max(psthHz));
                        min_zscore=min(min_zscore,min(zscoredHz));
                        max_zscore=max(max_zscore,max(zscoredHz));
                    end
                    %% Store Pertinent Feature Information 
                    regionUnits.(unitID).behavioralFeatures.(featureName).valid_trials=valid_trials;
                    regionUnits.(unitID).behavioralFeatures.(featureName).valid_trial_flags=valid_trial_flags;
                    regionUnits.(unitID).behavioralFeatures.(featureName).allEventTimestamps=ts_data;

                    %% Create psths and rasters for given trialfeature and add to tiled layout 
                    
                    for e = 1:length(eventNames)   % Loop through events
                        eventName = eventNames{e}; % Current event name
                        
                        ts = ts_data.(eventName);  % Extract timestamps for the event
                        ts=ts(~isnan(ts));
                        
                        % [spikeTimes, psth, bins,binWidthInSeconds,psthHz, numRows, zscoredpsth, rasterX, rasterY, spikeCounts] = psthRasterAndCounts(spikeTimes, eventTimes, window, psthBinSize);
                        [spikeTimes, psth, bins,psthHz, rasterX, rasterY, spikeCounts] = psthRasterAndCounts(spikes, ts, [-1 1], binSize);
                        zscoredHz=(psthHz-meanFR) ./ stdMeanFR;
                        
                        
                        %% Store Unit Feature Event Info %%%
                        regionUnits.(unitID).behavioralFeatures.(featureName).(eventName).timeStamps=ts;
                        regionUnits.(unitID).behavioralFeatures.(featureName).(eventName).psthCounts=psth;
                        regionUnits.(unitID).behavioralFeatures.(featureName).(eventName).psthHz=psthHz;
                        regionUnits.(unitID).behavioralFeatures.(featureName).(eventName).zscoredHz=zscoredHz;
                        regionUnits.(unitID).behavioralFeatures.(featureName).(eventName).bins=bins;
                        regionUnits.(unitID).behavioralFeatures.(featureName).(eventName).rasterX=rasterX;
                        regionUnits.(unitID).behavioralFeatures.(featureName).(eventName).rasterY=rasterY;
                        regionUnits.(unitID).behavioralFeatures.(featureName).(eventName).maxPsthHz=max_psth;
                        regionUnits.(unitID).behavioralFeatures.(featureName).(eventName).minPsthHz=min_psth;
                        

                        %StackPSTHandRaster(bins, psthHz, rasterX, rasterY, eventName);
        

                    end
                    
                        
                        %saveas(gcf, fullfile(savePath,[RAT_SESSION_UNITNAME, '.png']))
           
             fprintf('Unit behavioral properties calculated and saved for %s\n',unitID)
end
   