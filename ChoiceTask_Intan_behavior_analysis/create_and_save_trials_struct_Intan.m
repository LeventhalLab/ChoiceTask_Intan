% script create_and_save_trials_struct_Intan

% loop through all rats with valid choice task data, create trials
% structure for each session, save in the processed data folder to save
% time

% parent_directory = 'Z:\data\ChoiceTask\';
parent_directory = '\\corexfs.med.umich.edu\SharedX\Neuro-Leventhal\data\ChoiceTask';

[ratIDs, ratIDs_goodhisto] = get_rat_list('all', parent_directory);
sessions_to_skip = {'R0425_20220728a'};
% for some reason, R0425_20220728a has a super-long recording -
% digitalin.dat is too big to load (> 3 GB)
n_rats = length(ratIDs);

for i_rat = 22 : n_rats
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
        if ismember(session_name, sessions_to_skip)
            continue
        end
        cur_processed_dir = fullfile(session_dirs(i_session).folder, session_name);
        cur_rawdata_dir = fullfile(rawdata_folder, session_name);
        cd(cur_processed_dir)

        % lfp_fname = strcat(session_name, '_lfp.mat');
        % if ~isfile(lfp_fname)
        %     sprintf('%s not found, skipping', lfp_fname)
        %     continue
        % end

        trials_name = sprintf('%s_trials.mat', session_name);
        trials_name = fullfile(cur_processed_dir, trials_name);
        if exist(trials_name, 'file')
            % skip if already calculated
            sprintf('trials structure already calculated for %s', session_name)
            continue
        end

        rawdata_ephys_folder = get_rawdata_ephys_folder(rawdata_folder,session_name);
        % check that the digitalIn file exists - was missing from some
        % early sessions
        digitalin_fname = fullfile(rawdata_ephys_folder, 'digitalin.dat');
        if ~exist(digitalin_fname, 'file')
            sprintf('no digital input file found for %s', session_name)
            continue
        end

        log_file = find_log_file(session_name, parent_directory);
        if isempty(log_file)
            fprintf('log file not found for %s\n', session_name)
            continue
        end
        logData = readLogData(log_file);
        
        try
            nexData = extractEventsFromIntanSystem(rawdata_ephys_folder);
        catch
            sprintf('there was a problem generating nexData for %s', session_name)
            % some sessions there is a mismatch between digital samples
            % acquired and analog/amplifier signals acquired (generally
            % more on the digital lines). Why is that? Will things like up
            % if we take just the start or the end of the digital signals
            % to make them match with the analog? For now, just skipping
            % those sessions, unless there's a lot of them.
            continue
        end
        if isempty(nexData)
            % something was wrong with the analog/digital input files from
            % the intan system
            sprintf('nexData could not be generated for %s', session_name)
            continue
        end

        sprintf('loaded logData and nexData for %s', session_name)

        try
            trials = createTrialsStruct_simpleChoice_Intan( logData, nexData );
        catch ME
            if strcmp(ME.identifier, 'lognexmerge:lognexmismatch')
                sprintf('mismatch between log and nex files for %s', session_name)
                continue
            end
        end

        save(trials_name, 'trials');

    end

end