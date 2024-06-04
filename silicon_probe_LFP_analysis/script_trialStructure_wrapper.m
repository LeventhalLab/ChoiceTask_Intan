% script_calculate_perievent_scalograms

% script_trialStructure_wrapper

% probe_mapping_fname = '/Volumes/SharedX/Neuro-Leventhal/data/ChoiceTask/Probe Histology Summary/ProbeSite_Mapping.xlsx';

intan_parent_directory = 'X:\Neuro-Leventhal\data\ChoiceTask';
rats_with_intan_sessions = find_rawdata_folders(intan_parent_directory);

% lists for ratID probe_type       
NN8x8 = ["R0326", "R0327", "R0372", "R0379", "R0374", "R0378", "R0394", "R0395", "R0396", "R0412", "R0413"]; % Specify list of ratID associated with each probe_type
ASSY156 = ["R0411", "R0419"];
ASSY236 = ["R0420", "R0425", "R0427", "R0457"];

%%
for i_rat = 1 : length(rats_with_intan_sessions)
    
    intan_folders = rats_with_intan_sessions(i_rat).intan_folders;
    
    for i_sessionfolder = 1 : length(intan_folders)
        
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
        
        rd_metadata = parse_rawdata_folder(intan_folders{i_sessionfolder});
        pd_folder = create_processed_data_folder(rd_metadata, intan_parent_directory);
        
        lfp_fname = fullfile(pd_folder, create_lfp_fname(rd_metadata));
        lfp_data = load(lfp_fname); % Load in the LFP data for rearranging LFP data (ordering it by probe_type)
        Fs = lfp_data.actual_Fs; % need the Fs loaded in for gathering event_triggered_lfps in the next 'for' loop
       
        if contains(ratID, NN8x8) % if the ratID is in the list, it'll assign it the correct probe_type for ordering the LFP data correctly
            probe_type = 'NN8x8'; 
        elseif contains(ratID, ASSY156)
            probe_type = 'ASSY156';
        elseif contains(ratID, ASSY236)
            probe_type = 'ASSY236';
        end
        
        % Order the lfps here        
        [ordered_lfp, intan_site_order, site_order] = lfp_by_probe_site_ALL(lfp_data, probe_type); 
        % Orders the lfps by probe site mapping (double check the single file to remove catches for loading in single data)
        
    end
    
end