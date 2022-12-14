% script create_and_save_trials_struct_Intan

% loop through all rats with valid choice task data, create trials
% structure for each session, save in the processed data folder to save
% time

parent_directory = 'Z:\data\ChoiceTask\';

[rat_nums, ratIDs, ratIDs_goodhisto] = get_rat_list();

num_rats = length(ratIDs);

for i_rat = 1 : num_rats
    ratID = ratIDs{i_rat};
    rat_folder = fullfile(parent_directory, ratID);

    if ~isfolder(rat_folder)
        continue;
    end

    processed_folder = find_data_folder(ratID, 'processed', parent_directory);
    session_dirs = dir(fullfile(processed_folder, strcat(ratID, '*')));
    num_sessions = length(session_dirs);

    rawdata_folder = find_data_folder(ratID, 'rawdata', parent_directory);

    for i_session = 1 : num_sessions
        
        session_name = session_dirs(i_session).name;
        cur_processed_dir = fullfile(session_dirs(i_session).folder, session_name);
        cur_rawdata_dir = fullfile(rawdata_folder, session_name);
        cd(cur_processed_dir)

        lfp_fname = strcat(session_name, '_lfp.mat');
        if ~isfile(lfp_fname)
            sprintf('%s not found, skipping', lfp_file)
            continue
        end
        rawdata_ephys_folder = get_rawdata_ephys_folder(rawdata_folder,session_name);
        nexData = extractEventsFromIntanSystem(rawdata_ephys_folder);

        log_file = find_log_file(session_name, parent_directory);
        logData = readLogData(log_file);

    end

end