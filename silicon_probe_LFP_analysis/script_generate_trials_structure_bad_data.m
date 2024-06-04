% script to write field potentials around each trial

intan_parent_directory = 'X:\Neuro-Leventhal\data\ChoiceTask';
valid_trials_folder = find_trials_struct_folders(intan_parent_directory);
rats_with_intan_sessions = find_rawdata_folders(intan_parent_directory);

%%
fname = 'X:\Neuro-Leventhal\data\ChoiceTask\Probe Histology Summary\Rat_Information_channels_to_discard.xlsx'; % for channels etc
num_trials_to_plot = 5;

% start with an LFP file
% get the trial structure for that session
% run this analysis

trialType = ('allgo'); % to pull out trIdx of the trials structure (all trials)

switch lower(trialType)
    case 'allgo'
        eventFieldnames = {'centerIn'};
    case 'correctgo'
        eventFieldnames = {'cueOn', 'centerIn', 'centerOut', 'tone', 'sideIn', 'sideOut', 'foodClick', 'foodRetrievel'};
end

    % eventlist = {'centerin','cueon','centerout', 'sidein', 'sideout',
    % 'foodretrievel'}; This is the full eventlist for a correctGo trial.
    % Choose one for generating event_triggered_lfps.
num_events = length(eventFieldnames);
t_win = [-2.5 2.5]; % need this line for the event_triggered_lfps to select the correct 


% lists for ratID probe_type
NN8x8 = ["R0326", "R0327", "R0372", "R0379", "R0374", "R0376", "R0378", "R0394", "R0395", "R0396", "R0412", "R0413"]; % Specify list of ratID associated with each probe_type
ASSY156 = ["R0411", "R0419"];
ASSY236 = ["R0420", "R0425", "R0427", "R0457"];

sessions_to_ignore = {'R0378_20210507a', 'R0326_20191107a', 'R0425_20220728a', 'R0427_20220920a'};
sessions_to_ignore1 = {'R0425_20220728_ChVE_220728_112601', 'R0427_20220920_Testing_220920_150255'}; 
sessions_to_ignore2 = {'R0427_20220908a', 'R0427_20220909a', 'R0427_20220912a','R0427_20220913a', 'R0427_20220914a', 'R0427_20220915a', 'R0427_20220916a'};
% Trying this as a workaround. Code wouldn't skip these two trials. R0425 - 15 hour session and R0427 no data (files didn't save correctly)?

naming_convention; % for labeling graphs

% choiceTask difficulty levels
choiceRTdifficulty = cell(1, 10);
choiceRTdifficulty{1}  = 'poke any';
choiceRTdifficulty{2}  = 'very easy';
choiceRTdifficulty{3}  = 'easy';
choiceRTdifficulty{4}  = 'standard';
choiceRTdifficulty{5}  = 'advanced';
choiceRTdifficulty{6}  = 'choice VE';
choiceRTdifficulty{7}  = 'choice easy';
choiceRTdifficulty{8}  = 'choice standard';
choiceRTdifficulty{9}  = 'choice advanced';
choiceRTdifficulty{10} = 'testing';

%%
for i_rat = 1 : length(rats_with_intan_sessions)
    
    intan_folders = rats_with_intan_sessions(i_rat).intan_folders;
    
    for i_sessionfolder = 1 : length(intan_folders)
        % extract the ratID and session name from the LFP file
        session_path = intan_folders{i_sessionfolder};
        rd_metadata = parse_rawdata_folder(intan_folders{i_sessionfolder});
        ratID = rd_metadata.ratID;
        intan_session_name = rd_metadata.session_name;
        session_name = rd_metadata.session_name;
        
        if any(strcmp(session_path, sessions_to_ignore)) % can't quite get this to debug but seems ok - it keeps running these sessions and catching errors (hence the need to skip them!)
            continue;
        end        
                
%          if contains(ratID, 'R0326') || contains(ratID, 'R0372') || contains(ratID, 'R0376')...
%                  || contains(ratID, 'R0374') || contains(ratID, 'R0378') || contains(ratID, 'R0379') % just trying to skip some lines of data to get to the last set to debug. Uncomment out to run more trialTypes
%              continue;
%          end

        if contains(ratID, NN8x8)|| contains(ratID, ASSY156)|| contains(ratID, 'R0420')|| contains(ratID, 'R0425')
            continue;
        end

        if  contains(ratID, 'R0328') || contains(ratID, 'R0327') || contains(ratID, 'R0411') % the first style it wouldn't skip these sessions so trying it as the 'intan' name instead of just the rawdata folder name.
             continue; % Just skip R0425 bc it has bad sessions, check with Dan if need to include. % R0328 has no actual ephys; using these lines to skip unneeded data. R0327 Can't create trials struct
        end

        if contains(session_name, sessions_to_ignore) || contains(intan_session_name, sessions_to_ignore1)|| contains(ratID, 'DigiInputTest') % Just always ignore these sessions. R0411 no data, DigitInputTest is t est files
            continue;
        end

%         if contains(ratID, ASSY156) || contains(ratID, ASSY236)
%             continue;
%         end

        parentFolder = fullfile(intan_parent_directory, ...
            ratID, ...
            [ratID '-processed']);
        
        if contains(ratID, NN8x8) % if the ratID is in the list, it'll assign it the correct probe_type for ordering the LFP data correctly
            probe_type = 'NN8x8'; 
        elseif contains(ratID, ASSY156)
            probe_type = 'ASSY156';
        elseif contains(ratID, ASSY236)
            probe_type = 'ASSY236';
        end

        % load_channel_information - this file is coded 0 = bad, 1 = good,
        % 2 = variable for data in each channel for each session_name for
        % each rat_ID. Use the opts.VariableNamesRange for eat ratID to
        % detectImportOptions otherwise there's an error due to different
        % session number for each rat
        sheetname = ratID;
        if contains(ratID, 'R0326')
            opts = detectImportOptions(fname, 'filetype', 'spreadsheet', 'VariableNamesRange', 'A1:H1', 'datarange', 'A2:H65', 'sheet', sheetname);
        elseif contains(ratID, 'R0327') || contains(ratID, 'R0374')
            opts = detectImportOptions(fname, 'filetype', 'spreadsheet', 'VariableNamesRange', 'A1:E1', 'datarange', 'A2:E65', 'sheet', sheetname);
        elseif contains(ratID, 'R0372') || contains(ratID, 'R0378')|| contains(ratID, 'R0396')
            opts = detectImportOptions(fname, 'filetype', 'spreadsheet', 'VariableNamesRange', 'A1:J1', 'datarange', 'A2:J65', 'sheet', sheetname);
        elseif contains(ratID, 'R0379') || contains(ratID, 'R0413')
            opts = detectImportOptions(fname, 'filetype', 'spreadsheet', 'VariableNamesRange', 'A1:L1', 'datarange', 'A2:L65', 'sheet', sheetname);
        elseif contains(ratID, 'R0376')
            opts = detectImportOptions(fname, 'filetype', 'spreadsheet', 'VariableNamesRange', 'A1:O1', 'datarange', 'A2:O65', 'sheet', sheetname);
        elseif contains(ratID, 'R0394')
            opts = detectImportOptions(fname, 'filetype', 'spreadsheet', 'VariableNamesRange', 'A1:G1', 'datarange', 'A2:G65', 'sheet', sheetname);            
        elseif contains(ratID, 'R0395') || contains(ratID, 'R0427')
            opts = detectImportOptions(fname, 'filetype', 'spreadsheet', 'VariableNamesRange', 'A1:K1', 'datarange', 'A2:K65', 'sheet', sheetname);
        elseif contains(ratID, 'R0412')
            opts = detectImportOptions(fname, 'filetype', 'spreadsheet', 'VariableNamesRange', 'A1:M1', 'datarange', 'A2:M65', 'sheet', sheetname);
        elseif contains(ratID, 'R0419')
            opts = detectImportOptions(fname, 'filetype', 'spreadsheet', 'VariableNamesRange', 'A1:P1', 'datarange', 'A2:P65', 'sheet', sheetname);
        elseif contains(ratID, 'R0420')
            opts = detectImportOptions(fname, 'filetype', 'spreadsheet', 'VariableNamesRange', 'A1:N1', 'datarange', 'A2:N65', 'sheet', sheetname);
        elseif contains(ratID, 'R0425')
            opts = detectImportOptions(fname, 'filetype', 'spreadsheet', 'VariableNamesRange', 'A1:V1', 'datarange', 'A2:V65', 'sheet', sheetname);
        end

        probe_channel_info = load_channel_information(fname, sheetname);
        [channel_information, intan_site_order, site_order] = channel_by_probe_site_ALL(probe_channel_info, probe_type);

        % Create Processed_graphFolder if it doesn't exist (the folder not
            % existing at this point in analysis would be rare but putting in
            % as a catch here)

        trials_structure = [parentFolder(1:end-9) 'LFP-trials-structures'];
            if ~exist(trials_structure, 'dir')
                mkdir(trials_structure);
            end 
        
        processed_graphFolder_LFP_eventFieldname = [parentFolder(1:end-9) 'LFP-eventFieldname-graphs'];
            if ~exist(processed_graphFolder_LFP_eventFieldname, 'dir')
                mkdir(processed_graphFolder_LFP_eventFieldname);
            end  

        [session_folder, ~, ~] = fileparts(intan_folders{i_sessionfolder});
        session_log = find_session_log(session_folder);
        
        if isempty(session_log)
            sprintf('no log file found for %s', session_folder)
        end

        logData = readLogData(session_log); %gathersing logData information
        
        % calculate nexData, need digital input and analog input files
        digin_fname = fullfile(intan_folders{i_sessionfolder}, 'digitalin.dat');
        analogin_fname = fullfile(intan_folders{i_sessionfolder}, 'analogin.dat');
        rhd_fname = fullfile(intan_folders{i_sessionfolder}, 'info.rhd');
        
        if ~exist(digin_fname, 'file')
            sprintf('no digital input file for %s', session_folder);
            continue
        end
        
        if ~exist(analogin_fname, 'file')
            sprintf('no analog input file for %s', session_folder);
            continue
        end
        
        if ~exist(rhd_fname, 'file')
            sprintf('no rhd info file for %s', session_folder);
            continue
        end
        
        % read in rhd info; requires 'info.rhd' file.
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
        num_trials = length(trIdx);
        
        %Getting the LFP-fname
        pd_folder = create_processed_data_folder(rd_metadata, intan_parent_directory);
        
        lfp_fname = fullfile(pd_folder, create_lfp_fname(rd_metadata));
        lfp_data = load(lfp_fname); % Load in the LFP data for rearranging LFP data (ordering it by probe_type)
        Fs = lfp_data.actual_Fs; % need the Fs loaded in for gathering event_triggered_lfps in the next 'for' loop
               
        % for now, skipping R0378_20210507a because the session only recorded 63 channels instead of 64. 
        % sessions_to_ignore doesn't seem to be working here so using this
        % catch instead
        lfp_data_num_rows = size(lfp_data.lfp,1); 
            if lfp_data_num_rows < 64
                continue;
            end 

        % Order the lfps here       
        [ordered_lfp, intan_site_order, intan_site_order_for_trials_struct, site_order] = lfp_by_probe_site_ALL(lfp_data, probe_type); 
                % Orders the lfps by probe site mapping (double check the single file to remove catches for loading in single data)
                   
        %find the column header that matches session_name (session_name and
        %the column headers should match for each session to pull in the
        %info for probe site health
        valid_sites_reordered = channel_information.(session_name);
        %channel_descriptions = find(probe_channel_info.Properties.VariableNames, session_name);

        % Generate event triggered LFPs
        for i_event = 1 : num_events
                    % write code here to get event_triggered_lfps_ordered
                    % for each separate event
                   
                   % create a filename to save the trials_structure 
                   trials_fname_to_save = char(strcat(session_name, '_', eventFieldnames{i_event}, '_', trialType, '_', 'trials', '.mat')); % add in ''_', sprintf('trial%u.pdf', trial_idx)' should you want to save files individually
                   trials_full_name = fullfile(trials_structure, trials_fname_to_save);
                   
                   if exist(trials_full_name, 'file')
                        continue;
                   end
                   % creating a catch here for now while troubleshooting
                   % the data to NOT run through all of the folders and
                   % create the data if the plots are already made. (Remove
                   % once code is sufficient to rewrite the files as edits
                   % are made to graphs)
                   
                   % this function adds 2 fields to the trials structure to identify bad sites
                    
                    trial_ts = extract_trial_ts(trials(trIdx), eventFieldnames{i_event}); % This is actually pulled in from the extract_event_related_LFPs script so do we need it here? 
                   
                    event_triggered_lfps = extract_event_related_LFPs(ordered_lfp, trials(trIdx), eventFieldnames{i_event}, 'fs', Fs, 'twin', t_win); % made this using ordered_lfp data
                    
                    trials_validchannels_marked = identify_bad_data(lfp_data, trials(trIdx), intan_site_order_for_trials_struct, probe_type, trialEventParams, eventFieldnames);
                    save(trials_full_name, 'trials_validchannels_marked');

%                     % at this point, event_triggered_lfps_ordered is an m x n x p array where
%                     % m is the number of events (i.e., all the cueon OR nosein OR other...
%                     % events) in a single session; n is the number of channels in that session
%                     % (generally 64), and p is the number of time samples extracted around each
%                     % event (i.e., p = 2001 if we extract +/- 2 seconds around each event).

                    % above here, the lfp file, trial structure never change
                    
                     % create a filename to save the plots 
                   fname_to_save = char(strcat(session_name, '_', eventFieldnames{i_event}, '_', trialType, '_', 'channel_lfps', '.pdf')); % add in ''_', sprintf('trial%u.pdf', trial_idx)' should you want to save files individually
                   full_name = fullfile(processed_graphFolder_LFP_eventFieldname, fname_to_save);
        
% %                     pts_per_event = size(event_triggered_lfps,3); % I think these lines need to go into the for loop for whenever a set of data is loaded into the workspace.
% %                     num_channels = size(event_triggered_lfps,2);
%                      num_trials = size(event_triggered_lfps, 1);
%                     
                    % catch for num_trials_to_plot < num_trials (this is specifically for R0420_20220714 since it did only 3 trials so can't graph 5 random trials).
                    if num_trials < num_trials_to_plot
                        continue;
                    end
%                      
        end
                      
   end
    
end