% script to generate trials structures
% This file needs to be tested 12/18/2022

intan_parent_directory = 'X:\Neuro-Leventhal\data\ChoiceTask';
rats_with_intan_sessions = find_rawdata_folders(intan_parent_directory);

%%
% lists for ratID probe_type
NN8x8 = ["R0326", "R0327", "R0372", "R0379", "R0374", "R0376", "R0378", "R0394", "R0395", "R0396", "R0412", "R0413"]; % Specify list of ratID associated with each probe_type
ASSY156 = ["R0411", "R0419"];
ASSY236 = ["R0420", "R0425", "R0427", "R0457"];

sessions_to_ignore = {'R0378_20210507a', 'R0326_20191107a', 'R0425_20220728a', 'R0425_20220816b', 'R0427_20220920a', 'R0427_20220920a', 'R0427_20220919a'};
sessions_to_ignore1 = {'R0425_20220728_ChVE_220728_112601', 'R0427_20220920_Testing_220920_150255'}; 
sessions_to_ignore2 = {'R0427_20220908a', 'R0427_20220909a', 'R0427_20220912a','R0427_20220913a', 'R0427_20220914a', 'R0427_20220915a', 'R0427_20220916a'};
% Trying this as a workaround. Code wouldn't skip these two trials. R0425 - 15 hour session and R0427 no data (files didn't save correctly)?

%%
for i_rat = 1 : length(rats_with_intan_sessions)
    
    intan_folders = rats_with_intan_sessions(i_rat).intan_folders;
    
    for i_sessionfolder = 1 : length(intan_folders)
        % extract the ratID and session name from the LFP file
        session_path = intan_folders{i_sessionfolder};
        rd_metadata = parse_rawdata_folder(intan_folders{i_sessionfolder});
        session_trials_folder_original = create_trials_structure_original_folder(rd_metadata, intan_parent_directory);
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


%         if contains(ratID, NN8x8)|| contains(ratID, ASSY156)|| contains(ratID, 'R0420')|| contains(ratID, 'R0425')
%             continue;
%         end

        if  contains(ratID, 'R0328') || contains(ratID, 'R0327') || contains(ratID, 'R0411') % the first style it wouldn't skip these sessions so trying it as the 'intan' name instead of just the rawdata folder name.
             continue;  % R0328 has no actual ephys; using these lines to skip unneeded data. R0327 Can't create trials struct; R0420 I haven't added lines for
        end

        if contains(session_name, sessions_to_ignore) || contains(intan_session_name, sessions_to_ignore1)|| contains(ratID, 'DigiInputTest') % Just always ignore these sessions. R0411 no data, DigitInputTest is t est files
            continue;
        end

        parentFolder = fullfile(intan_parent_directory, ...
            ratID, ...
            [ratID '-processed']);
        
%         if contains(ratID, NN8x8) % if the ratID is in the list, it'll assign it the correct probe_type for ordering the LFP data correctly
%             probe_type = 'NN8x8'; 
%         elseif contains(ratID, ASSY156)
%             probe_type = 'ASSY156';
%         elseif contains(ratID, ASSY236)
%             probe_type = 'ASSY236';
%         end


%         trials_structure = [parentFolder(1:end-9) 'LFP-trials-structures'];
%             if ~exist(trials_structure, 'dir')
%                 mkdir(trials_structure);
%             end 

        trials_structure_original = [parentFolder(1:end-9) 'LFP-trials-structures-original'];
            if ~exist(trials_structure_original, 'dir')
                mkdir(trials_structure_original);
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

        trials_fname_to_save = char(strcat(session_name, '_', 'trials', '.mat')); % add in ''_', sprintf('trial%u.pdf', trial_idx)' should you want to save files individually
        trials_original_full_name = fullfile(session_trials_folder_original, trials_fname_to_save);
        save(trials_original_full_name, 'trials');
    end
end
