% script to calculate LFPs for all of Jen's rats; store in files in
% the processed data folders

parent_directory = 'Z:\data\ChoiceTask\';
summary_xls = 'ProbeSite_Mapping_MATLAB.xlsx';
summary_xls_dir = 'Z:\data\ChoiceTask\Probe Histology Summary';
summary_xls = fullfile(summary_xls_dir, summary_xls);

probe_type_sheet = 'probe_type';
probe_types = read_choicetask_xls_summary(summary_xls, probe_type_sheet);
% NOTE - UPDATE FUNCTION read_Jen_xls_summary WHEN WE NEED OTHER
% INFORMATION OUT OF THAT SPREADSHEET

[rat_nums, ratIDs, ratIDs_goodhisto] = get_rats2process(summary_xls);

target_Fs = 500;   % in Hz, target LFP sampling rate after decimating the raw signal

num_rats = length(ratIDs);

for i_rat = 16 : num_rats
    ratID = ratIDs{i_rat};
    rat_folder = fullfile(parent_directory, ratID);

    if ~isfolder(rat_folder)
        continue;
    end

    probe_type = probe_types{probe_types.RatID == ratID, 2};
    processed_folder = find_data_folder(ratID, 'processed', parent_directory);
    rawdata_folder = find_data_folder(ratID, 'rawdata', parent_directory);
    session_dirs = dir(fullfile(processed_folder, strcat(ratID, '*')));
    num_sessions = length(session_dirs);

    for i_session = 1 : num_sessions
        
        session_name = session_dirs(i_session).name;
        if strcmp(session_name, 'R0378_20210507a') || strcmp(session_name, 'R0425_20220728a')
            % skip this session because for some reason only 63 channels
            % were recorded
            continue
        end
        cur_dir = fullfile(session_dirs(i_session).folder, session_name);
        cd(cur_dir)

        lfp_fname = strcat(session_name, '_lfp.mat');
        full_lfp_name = fullfile(processed_folder, session_name, lfp_fname);
        if isfile(full_lfp_name)
            lfp_data = load(full_lfp_name);
        else
            continue
        end
        actual_Fs = lfp_data.actual_Fs;

        sprintf('working on %s', session_name)
        lfp_bipolar_name = strcat(session_name, '_bipolar_lfp.mat');
        lfp_bipolar_name = fullfile(processed_folder, session_name, lfp_bipolar_name);
        [bipolar_lfp, intan2probe_mapping] = calculate_bipolar_LFPs(lfp_data.lfp, probe_type);

        save(lfp_bipolar_name, 'bipolar_lfp', 'actual_Fs', 'probe_type', 'intan2probe_mapping', 'full_lfp_name');

    end

end