% calculate_cwt_3D_matrix_testing.m

intan_parent_directory = 'X:\Neuro-Leventhal\data\ChoiceTask';
rats_with_intan_sessions = find_rawdata_folders(intan_parent_directory);

NN8x8 = ["R0326", "R0327", "R0372", "R0379", "R0374", "R0376", "R0378", "R0394", "R0395", "R0396", "R0412", "R0413"]; % Specify list of ratID associated with each probe_type
ASSY156 = ["R0411", "R0419"];
ASSY236 = ["R0420", "R0425", "R0427", "R0457"];

% start with an LFP file
% get the trial structure for that session
% run this analysis

eventFieldnames = {'cueOn', 'centerIn', 'centerOut', 'tone', 'sideIn', 'sideOut', 'foodClick', 'foodRetrievel'};
    % eventlist = {'centerin','cueon','centerout', 'sidein', 'sideout',
    % 'foodretrievel'}; This is the full eventlist for a correctGo trial.
    % Choose one for generating event_triggered_lfps.
num_events = length(eventFieldnames);
t_win = [-2.5 2.5]; % need this line for the event_triggered_lfps to select the correct 
trialType = ('correctGo'); % to pull out trIdx of the trials structure (just correct go trials)

intan_ignore = {'R0326_20191107a'}; % still troubleshooting these two lines to avoid looping through irrelevant data files (e.g. files with no info.rhd file.
sessions_to_ignore = {'R0326_20191107a', 'R0427_20220920a'};

%Start here to get the trials structure
for i_rat = 1 : length(rats_with_intan_sessions)
    
    intan_folders = rats_with_intan_sessions(i_rat).intan_folders;
        if any(strcmp(intan_folders, intan_ignore))
            continue
        end 
    for i_sessionfolder = 1 : length(intan_folders)
        
        session_path = intan_folders{i_sessionfolder};
        pd_processed_data = parse_processed_folder(session_path);
        ratID = pd_processed_data.ratID;
        session_name = pd_processed_data.session_name;
        
        if any(strcmp(ratID, sessions_to_ignore)) % can't quite get this to debug but seems ok (if it worked it would run through the code quicker)
            continue
        end        
        
        [session_folder, ~, ~] = fileparts(intan_folders{i_sessionfolder});
        session_log = find_session_log(session_folder);
        
        if isempty(session_log)
            sprintf('no log file found for %s', session_folder)
        end
        logData = readLogData(session_log);
        
        % calculate nexData, need digital input and analog input files
        digin_fname = fullfile(intan_folders{i_sessionfolder}, 'digitalin.dat');
        analogin_fname = fullfile(intan_folders{i_sessionfolder}, 'analogin.dat');
        rhd_fname = fullfile(intan_folders{i_sessionfolder}, 'info.rhd');
        
        if ~exist(digin_fname, 'file')
            sprintf('no digital input file for %s', session_folder)
            continue
        end
        
        if ~exist(analogin_fname, 'file')
            sprintf('no analog input file for %s', session_folder)
            continue
        end
        
        if ~exist(rhd_fname, 'file')
            sprintf('no rhd info file for %s', session_folder)
            continue
        end
        
        % read in rhd info
        rhd_info = read_Intan_RHD2000_file_DL(rhd_fname);
        
        % read digital input file
        dig_data = readIntanDigitalFile(digin_fname);
        if ~isfield(rhd_info, 'board_adc_channels')
            sprintf('board_adc_channels field not found in rhd_info for %s', session_folder)
            continue
        end
        
        analog_data = readIntanAnalogFile(analogin_fname, rhd_info.board_adc_channels);
        nexData = intan2nex(dig_data, analog_data, rhd_info);
        
        try
            sprintf('attempting to create trials structure for %s', session_folder)
            trials = createTrialsStruct_simpleChoice_Intan( logData, nexData );
        catch
            sprintf('could not generate trials structure for %s', session_folder)
            continue
        end
        
        % extract Trial Type (e.g. correctGo)
        % Set trialType at beginning of file
        [ trialEventParams ] = getTrialEventParams(trialType); % Need to verify this section. Working Here
        trIdx = extractTrials(trials, trialEventParams);
        
        
        %Getting the LFP-fname
        rd_metadata = parse_rawdata_folder(intan_folders{i_sessionfolder});
        pd_folder = create_processed_data_folder(rd_metadata, intan_parent_directory);
        
        lfp_fname = fullfile(pd_folder, create_lfp_fname(rd_metadata));
        lfp_data = load(lfp_fname); % Load in the LFP data for rearranging LFP data (ordering it by probe_type)
        Fs = lfp_data.actual_Fs; % need the Fs loaded in for gathering event_triggered_lfps in the next 'for' loop
        
        % for now, skipping R0378_20210507a because the session only recorded 63 channels instead of 64. 
        % sessions_to_ignore doesn't seem to be working here so using this
        % catch instead
        num_rows = size(lfp_data.lfp,1); 
            if num_rows < 64
                continue;
            end
       
        if contains(ratID, NN8x8) % if the ratID is in the list, it'll assign it the correct probe_type for ordering the LFP data correctly
            probe_type = 'NN8x8'; 
        elseif contains(ratID, ASSY156)
            probe_type = 'ASSY156';
        elseif contains(ratID, ASSY236)
            probe_type = 'ASSY236';
        end
        
        % Order the lfps here        
        [ordered_lfp, intan_site_order, site_order] = lfp_by_probe_site_ALL(lfp_data, probe_type); % Orders the lfps by probe site mapping (double check the single file to remove catches for loading in single data)
        
        % This is where the scalograms are being calculated.
        for i_event = 1 : num_events
                    % write code here to get event_triggered_lfps_ordered for each separate
                    % event
                    
                    event_triggered_lfps = extract_event_related_LFPs(ordered_lfp, trials(trIdx), eventFieldnames{i_event}, 'fs', Fs, 'twin', t_win); % made this using ordered_lfp data
                                      
                    % at this point, event_triggered_lfps_ordered is an m x n x p array where
                    % m is the number of events (i.e., all the cueon OR nosein OR other...
                    % events) in a single session; n is the number of channels in that session
                    % (generally 64), and p is the number of time samples extracted around each
                    % event (i.e., p = 2001 if we extract +/- 2 seconds around each event).

                    % session_scalos = zeros(num_events, num_channels, num_trials, length(f), pts_per_event);
                    % in the above, num_events should be the number of DIFFERENT events you're
                    % interested in (i.e., cueon AND nose in AND others...)

                    % above here, the lfp file, trial structure never change
                    
                    trial_ts = extract_trial_ts(trials(trIdx), eventFieldnames{i_event}); % This is actually pulled in from the extract_event_related_LFPs script so do we need it here? 
                    
                    pts_per_event = size(event_triggered_lfps,3); % I think these lines need to go into the for loop for whenever a set of data is loaded into the workspace.
                    num_channels = size(event_triggered_lfps,2);
                    num_trials = size(event_triggered_lfps, 1);
                    flim = [1, 100];
                    Fs = 500; % make a universal Fs to pull out the actual_Fs from _lfp.mat or _ordered_lfp.mat file
                   % t_win = [-3 5]; % This is above
                    fb = cwtfilterbank('SignalLength', pts_per_event, ...
                        'SamplingFrequency', Fs, ...
                        'FrequencyLimits',flim, ...
                        'Wavelet', 'amor');
                    f = centerFrequencies(fb);
                    num_freqs = length(f);
                    t = linspace(t_win(1),t_win(2),pts_per_event);

                    % get averages saved into a bunch of files

                    for i_channel = 1 : num_channels

                        fname_to_save = char(strcat(session_name(1:end-13), eventFieldnames{i_event}, '_', trialType, '_', 'sessionScalos', '_', sprintf('ch%u.mat', i_channel))); 
                        full_name = fullfile(pd_folder, fname_to_save);
                        if exist(full_name,'file')
                            continue;
                        end
                        
                        channel_lfps = squeeze(event_triggered_lfps(:, i_channel, :));

                        [scalograms, f] = calculate_single_channel_event_triggered_scalograms(channel_lfps, fb);

                        % create a file name that includes ratID, session #, chXX,
                        % eventname, scalograms
                        % for example, 'R0326_20200228a_ch01_cueOn_scalos.mat'
               
                       
                        % I believe this is saving channels (i_channel). It was originally written as i_event which rewrote the file.
                        save(fullfile(pd_folder,fname_to_save), 'scalograms', 'Fs', 'f', 'fb', '-v7.3');
                        
                        % test that the scalogram looks reasonable; comment out for batch
                        % processing
                        figure(1)

                        mean_scalogram = squeeze(mean(abs(scalograms), 1));

                        imagesc(t, f, mean_scalogram)
                        set(gca,'ydir','normal','yscale','log','ylim',flim)

                    end
                % you might want to create a separate file for each event and save
                % session_scalos here if it's too big with all the events and all the
                % channels in one file
        end
        
   
    
    end
end
