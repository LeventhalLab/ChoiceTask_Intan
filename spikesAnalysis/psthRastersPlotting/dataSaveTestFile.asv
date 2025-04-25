%Script to generate psth and rasters for choice task beahvioral assays
%by using behaviorA and behaviorB, user can look at any behavioral events
%of interest possible in the choice task by combining possible options along
% with incompatible behavioral options listed in parentheses or risk throwing error.
%
%Options include
 
    %correct- only correct trials (no wrong,slowmovement,slowreaction,falsestart,wrongstart)
    
    %wrong-only wrong trials (no correct)
    
    %moveright- the side direction the rat moved was to the right 
    % (no moveleft,slowmovement,slowreaction,falsestart,wrongstart)
    
    %moveleft- the side direction the rat moved was to the right 
    %(no moveright slowmovement,slowreaction,falsestart,wrongstart)
    
    %cuedright- rat was instructed to go right 
    % (no cuedleft,wrongstart,falsestart)
    
    %cuedleft- rat was instructed to go left
    % (no cuedright,wrongstart,falsestart)
    
    %slowmovement-rat was too slow to getting to side port
    % (no moveleft,moveright,correct,wrongstart,falsestart)
    
    %slowreaction-rat was too slow leaving centerport
    % (no moveleft,moveright,correct,wrongstart,falsestart)
    
    %wrongstart-rat poked to wrong centerport 
    % (not compatible with other behaviors besides wrong)
    
    %falsestart-rat poked badly to centerport 
    % (not compatible with other behaviors besisdes wrong)
tic;
parent_directory = 'X:\Neuro-Leventhal\data\ChoiceTask';
summary_xls = 'ProbeSite_Mapping_MATLAB_RL2.xlsx';
summary_xls_dir = 'X:\Neuro-Leventhal\data\ChoiceTask\Probe Histology Summary';
summary_xls = fullfile(summary_xls_dir, summary_xls);
sessions_to_ignore = {'R0378_20210507a', 'R0326_20191107a', 'R0425_20220728a', 'R0425_20220816b', 'R0427_20220920a','R0427_20220919a','R0479_20230601a','R0572_20240918a' }; % R0425_20220728a debugging because the intan side was left on for 15 hours;

probe_type_sheet = 'probe_type';
probe_types = read_Jen_xls_summary(summary_xls, probe_type_sheet);
% NOTE - UPDATE FUNCTION read_Jen_xls_summary WHEN WE NEED OTHER%
% INFORMATION OUT OF THAT SPREADSHEET

%[rat_nums, ratIDs, ratIDs_goodhisto] = get_rat_list();
ratIDs=probe_types.ratID;
ignoreRats={'R0326','R0327','R0372','R0374','R0379','R0376','R0378','R0394','R0395','R0396','R0411','R0412','R0413','R0419',...
            'R0425','R0427','R0456','R0459'};%,'R0420','R0460','R0463','R0466','R0465','R0467','R0479','R0492','R0493'};
num_rats = length(ratIDs);
% parameter=[];
% parameter.Allcorrect=true;

%Input your parameters!!
regionOfinterest={'VM','VL'};
behaviorA={'correct','cuedleft'};
behaviorAname='Correct Left';
behaviorB={'wrong','cuedleft'};
behaviorBname='All wrong left';
behaviorC={};
behaviorCname='';
allFeatures={behaviorA,behaviorB,behaviorC};

allNames={behaviorAname,behaviorBname,behaviorCname};
trialfeatureList={};
trialName={};
binSize=0.02;
for i = 1:length(allFeatures)
    if ~isempty(allFeatures{i})
        trialfeatureList{end+1} = allFeatures{i};
        trialName{end+1} = allNames{i};
    end
end

outputTitle='Correct Left vs Wrong Left';
potentialeventNames={'cueOn','centerIn','tone','centerOut','houseLightOn','sideIn','wrong','sideOut','foodClick','foodRetrieval'};
% parameter.trialfeatures='Correct Trials All';
for i_rat = 1 : num_rats
    ratID = ratIDs{i_rat};
    
    rat_folder = fullfile(parent_directory, ratID);
    if any(strcmp(ratID,ignoreRats))
        continue
    end
    if ~isfolder(rat_folder)
        continue;
    end
    ratHisto=strcat(ratID,'_','finished');
    histo_data = readtable(summary_xls,'filetype','spreadsheet',...
            'sheet',ratHisto,...
            'texttype','string');
    channelRegion=[histo_data.Intan_Site_Number,histo_data.Region];
    channelRegion(:, 1) = cellfun(@(x) num2str(str2double(x)), channelRegion(:, 1), 'UniformOutput', false); %changed back to zero scale 4/15
    probe_type = probe_types{probe_types.ratID == ratID, 2}; % changed probe_types.RatID to probe_types.ratID due to error
    processed_folder = find_data_folder(ratID, 'processed', parent_directory);
    rawdata_folder = find_data_folder(ratID, 'rawdata', parent_directory);
    session_dirs = dir(fullfile(rawdata_folder, strcat(ratID, '*')));
    num_sessions = length(session_dirs);
    psthRasterOutput=fullfile(rat_folder, strcat(ratID,'-PsthAndRastersPlots'));
    if ~exist(psthRasterOutput)
        mkdir(psthRasterOutput)
    end
    savePath = fullfile(psthRasterOutput,outputTitle);
    if ~exist(savePath)
        mkdir(savePath)
    end
    for i_session = 1 : num_sessions
        
        sessionName = session_dirs(i_session).name;
        
        cur_dir = fullfile(session_dirs(i_session).folder, sessionName);
        cd(cur_dir)

        phys_folder = find_physiology_data(cur_dir);
        ephysKilosortPath = fullfile(phys_folder, 'kilosort4');

        if isempty(phys_folder)
            sprintf('no physiology data found for %s', sessionName)
            continue
        end
        % if ~exist(ephysKilosortPath)
        %     keyboard
        % end
        if any(strcmp(sessionName, sessions_to_ignore)) % Jen added this in to ignore sessions as an attempt to debut "too many input arguments"
            continue;
        end
        if ~isfolder(fullfile(phys_folder,'kilosort4'))||~exist(fullfile(ephysKilosortPath,'params.py')) 
            continue
        end
        
        if ~isfolder(fullfile(ephysKilosortPath,'qMetrics'))
            keyboard
            continue %second catch to ignore ks4 that wasn't run
        end
        ephysRawFile = fullfile(phys_folder, 'amplifier.dat'); % path to your raw .bin or .dat data
        ephysMetaDir = ''; % path to your .meta or .oebin meta file
        
        kilosortVersion = 4; % if using kilosort4, you need to have this value kilosertVersion=4. Otherwise it does not matter. 
        gain_to_uV = 0.195;

        %If there is missing behavior inputs continue
        if ~exist(fullfile(phys_folder,'info.rhd'))||~exist(fullfile(phys_folder,'digitalin.dat'))||~exist(fullfile(phys_folder,'analogin.dat'))...
                isempty(dir(fullfile(cur_dir,'*.log'))) || ~exist(fullfile(phys_folder,'auxillary.dat')) ||  ~exist(fullfile(phys_folder,'supply.dat')) ||  ~exist(fullfile(phys_folder,'time.dat'))
            sprintf('missing intan data for %s', sessionName)
            continue
        end
        %load in behavioral data and create trials structure
        fprintf('Processing %s\n', sessionName);
        [intan_data, digital_data, nexData, both_log_files, log_file, logData, trials, logConflict, isConflict, isConflictOnly, boxLogConflict] = ChoiceTask_Intan_Function_RL(cur_dir, phys_folder);
        if ~isempty(intan_data)
            %loop for creating psth and rasters for units during ANY
            %correct trial
            % if parameter.Allcorrect
                
            %Create struct of timestamps for events that you're and remove
            %event names that dont exist 
                %%%%%4/7
                % [ts_data,valid_trials,valid_trial_flags,valid_eventNames] =unit_correct_trial_data_RL(trials, trialfeatures,eventNames);  
                % if length(valid_trials)<3
                %     sprintf('not enough valid trials for the given trialfeature for %s', sessionName)
                %     continue
                % end
                
                % eventNames=valid_eventNames;
                % eventNames = eventNames(~strcmp(eventNames, 'foodClick'));
                %%%%%2025
                % for e = 1:length(eventNames)
                %     eventName=eventNames{e};
                %     if ~isfield(ts_data.(eventName))
                %         eventNames=erase(eventNames,eventName);
                %     end
                % end
                %load in ephys data, for now going to exclude all non-soma, MUA, and noise units.
                %see loadKSdir_RL params.exclude* for altering this param
                [spikeStruct, clu, st, unique_clusters, numSpks, cluster_spikes] = import_ephys_data_RL(ephysKilosortPath);
      
                %Loop through unique clusters and create psths and rasters of events   
                if ~isempty(cluster_spikes)
                    %%%%4/7  
                    % for i=1:length(trialfeatureList)
                    %     trialfeatures=trialfeatureList{i};
                    %     numRows = 2*length(trialfeatureList);
                    % 
                    %     [ts_data,valid_trials,valid_trial_flags,valid_eventNames] =unit_correct_trial_data_RL(trials, trialfeatures,eventNames);  
                    %     if length(valid_trials)<3
                    %         sprintf('not enough valid trials for the given trialfeature for %s', sessionName)
                    %         continue
                    %     end
                    %     eventNames=valid_eventNames;
                    %     eventNames = eventNames(~strcmp(eventNames, 'foodClick'));
                    %     behaviorTitle=trialName{i};
                    %%%%2025
                    
                    for g = 1:size(cluster_spikes, 1)
                          clusID=unique_clusters(g);
                          %Correlate Cluster to Anatomical region
                          clusChannel=spikeStruct.clusterChannel(spikeStruct.clusterChannel(:,1) == clusID, 2);
                          clusRegion=channelRegion(channelRegion(:,1)==num2str(clusChannel),2);
                          clusRegion=clusRegion{1};
                          clusRegion=strrep(clusRegion,'/','-');
                          % meanFiringRate=(numSpks(g)/max(st));
                          % stdMeanFR=std(meanFiringRate/(max(st)/binSize))
                          fig=figure('Visible','on');
                          set(fig, 'Units', 'Inches', 'Position', [1, 1, 11, 8.5]); % Set figure size
                          
                          %Set parameters for tiled layout
                          numRows = 2*length(trialfeatureList);
                          maxNcols=-inf;
                          for c=1:length(trialfeatureList)
                              behName=trialfeatureList{c};
                              if isempty(behName)
                                  continue
                              end
                              if any(strcmp(behName,'correct')|strcmp(behName,'moveright')|strcmp(behName,'moveleft'))
                                  nCols=7;
                              elseif any(strcmp(behName,'slowmovement')|strcmp(behName,'slowreaction'))
                                  nCols=5;
                              else
                                  nCols=4;
                              end
                              maxNcols=max(maxNcols,nCols);
                              numCols=maxNcols;
                         end
                         
                         %Create Tiled Layout
                         t = tiledlayout(numRows, numCols, 'TileSpacing', 'Tight', 'Padding', 'None');
                         sessionName = strrep(sessionName, '_', ' ');
                         
                         %Calculate mean firing rate and standard deviation of mean FR of single unit based on 
                         % the two second window before all cue on events during the session                      
                         [meanFR,stdMeanFR]=preCueOnData(cluster_spikes(g,:)',trials,'cueOn',binSize);
                         
                         %Figure title with pertinent info
                         sgtitle([sessionName, ' ', outputTitle, ' ',' Unit ', num2str(unique_clusters(g)),' ', '\bf', 'Region: ', clusRegion,...
                             '\rm',' Base FR(+/-) ', num2str(meanFR), '+/-', num2str(stdMeanFR), ' Hz']); 
                         subtitle(t, 'Z-score significance: Blue = z>3 | Orange = z<-3');
                         for i=1:length(trialfeatureList)
                                trialfeatures=trialfeatureList{i};
                                if isempty(trialfeatures)
                                    continue
                                end

                                %Extract time stamps of events for each given trial feature 
                                
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
                                behaviorTitle=trialName{i};
                            
                                
                                
                                min_psth = Inf;
                                max_psth = -Inf;

                                %Determine minimum/maxmimum hertz value across all events for this cluster
                                
                                for e = 1:length(eventNames)   % Loop through events
                                    
                                    
                                    eventName = eventNames{e}; % Current event name
    
                                    ts = ts_data.(eventName);  % Extract timestamps for the event
                                    ts=ts(~isnan(ts));
                                    
                                    % [spikeTimes, psth, bins,binWidthInSeconds,psthHz, numRows, zscoredpsth, rasterX, rasterY, spikeCounts] = psthRasterAndCounts(spikeTimes, eventTimes, window, psthBinSize);
                                    [spikeTimes, psth, bins,psthHz, rasterX, rasterY, spikeCounts] = psthRasterAndCounts(cluster_spikes(g, :)', ts, [-1 1], binSize);
                                    
                                    min_psth = min(min_psth, min(psthHz));
                                    max_psth = max(max_psth, max(psthHz));
                                end
                                
                                %Create psths and rasters for given trialfeature and add to tiled layout
                                
                                for e = 1:length(eventNames)   % Loop through events
                                    eventName = eventNames{e}; % Current event name
                                 
                                    ts = ts_data.(eventName);  % Extract timestamps for the event
                                    ts=ts(~isnan(ts));
                                    
                                    % [spikeTimes, psth, bins,binWidthInSeconds,psthHz, numRows, zscoredpsth, rasterX, rasterY, spikeCounts] = psthRasterAndCounts(spikeTimes, eventTimes, window, psthBinSize);
                                    [spikeTimes, psth, bins,psthHz, rasterX, rasterY, spikeCounts] = psthRasterAndCounts(cluster_spikes(g, :)', ts, [-1 1], binSize);
                                    zscoredHz=(psthHz-meanFR) ./ stdMeanFR;
                                    
                                    %Plot PSTH
                                    rowOffset = (i-1)*2;  % Each behavior takes up 2 rows (PSTH + raster)
                                    nexttile(rowOffset*numCols + e);
                                    sigBinsIncrease = zscoredHz > 3;
                                    sigBinCentersIncrease = bins(sigBinsIncrease);
                                    sigBinsDecrease = zscoredHz < -3;
                                    sigBinCentersDecrease = bins(sigBinsDecrease);
                                    plot(bins,psthHz);
                                    hold on;
                                    plot(bins, zscoredHz, 'm', 'LineWidth', 1.2);
                                    % Mark significant bins (z >/< 3) with
                                    
                                    for b = 1:length(sigBinCentersIncrease)
                                        % Draw a short blue vertical bar near the top of the plot if bin is significantly increased 
                                        line([sigBinCentersIncrease(b) sigBinCentersIncrease(b)], [max_psth+1 max_psth+3], 'Color', 'b', 'LineWidth', 1);
                                    end
                                    for b = 1:length(sigBinCentersDecrease)
                                        % Draw a short orange vertical bar near the top of the plot if bin is significantly decreased 
                                        line([sigBinCentersDecrease(b) sigBinCentersDecrease(b)], [max_psth+1 max_psth+3], 'Color', [1, 0.5, 0], 'LineWidth', 1);
                                    end
                                    xlim([-1 1]);
                                    ylim([(min_psth-5) (max_psth+5)]);
                                    if e==1
                                        ylabel('Hz');
                                        title(strcat(behaviorTitle,'--',eventName));
                                    else
                                        yticks([]);
                                        title(strrep(eventName, '_', ' '));
                                    end
                                    xticks([]);                             
                                    median_x = median(bins);
                                    xline(median_x, 'r--', 'LineWidth', 0.5);
                               
                                    %plot raster stacked below PSTH
                                    nexttile((rowOffset+1)*numCols + e);
                                    plot(rasterX, rasterY,'k.','MarkerSize',1);
                                    xlim([-1 1]);
                                    if e==1
                                        ylabel('Trials');
                                        xlabel('Time (sec)')
                                    else
                                        yticks([]);
                                        xticks([]);
                                    end
                                    
                                    
                                    
                                    %StackPSTHandRaster(bins, psthHz, rasterX, rasterY, eventName);
                    
    
                                end
                                    
                                    %saveas(gcf, fullfile(savePath,[RAT_SESSION_UNITNAME, '.png']))
                         end
                         
                         RAT_SESSION_UNITNAME = strcat(sessionName, '_','Unit_',num2str(unique_clusters(g)),'_',clusRegion); %establishing label for output
                         saveas(fig, fullfile(savePath,[RAT_SESSION_UNITNAME, '.png']))
                         if strcmp(clusRegion,RegionOfInterest)
                            
                         close(fig);
                    end
                else
                    fprintf('No good units found in the given session, consider reprocessing or inspect data. For now continuing %s\n',sessionName)
                end
        end
    end
end
elapsedTime = toc;
mins = floor(elapsedTime / 60);
secs = mod(elapsedTime, 60);
fprintf('PSTH and Rasters generated for given trial features in %d min %.2f sec.\n', mins, secs);
