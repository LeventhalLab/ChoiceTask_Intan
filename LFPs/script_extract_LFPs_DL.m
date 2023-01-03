% script to calculate LFPs for all of Jen's rats; store in files in
% the processed data folders

parent_directory = 'Z:\data\ChoiceTask\';
summary_xls = 'ProbeSite_Mapping_MATLAB.xlsx';
summary_xls_dir = 'Z:\data\ChoiceTask\Probe Histology Summary';
summary_xls = fullfile(summary_xls_dir, summary_xls);

probe_type_sheet = 'probe_type';
probe_types = read_Jen_xls_summary(summary_xls, probe_type_sheet);
% NOTE - UPDATE FUNCTION read_Jen_xls_summary WHEN WE NEED OTHER
% INFORMATION OUT OF THAT SPREADSHEET

[rat_nums, ratIDs, ratIDs_goodhisto] = get_rat_list();

target_Fs = 500;   % in Hz, target LFP sampling rate after decimating the raw signal

num_rats = length(ratIDs);

for i_rat = 1 : num_rats
    ratID = ratIDs{i_rat};
    rat_folder = fullfile(parent_directory, ratID);

    if ~isfolder(rat_folder)
        continue;
    end

    probe_type = probe_types{probe_types.RatID == ratID, 2};
    processed_folder = find_data_folder(ratID, 'processed', parent_directory);
    rawdata_folder = find_data_folder(ratID, 'rawdata', parent_directory);
    session_dirs = dir(fullfile(rawdata_folder, strcat(ratID, '*')));
    num_sessions = length(session_dirs);

    for i_session = 1 : num_sessions
        
        session_name = session_dirs(i_session).name;
        cur_dir = fullfile(session_dirs(i_session).folder, session_name);
        cd(cur_dir)

        phys_folder = find_physiology_data(cur_dir);

        if isempty(phys_folder)
            sprintf('no physiology data found for %s', session_name)
            continue
        end

        lfp_fname = strcat(session_name, '_lfp.mat');
        full_lfp_name = fullfile(processed_folder, session_name, lfp_fname);
%         if isfile(lfp_fname)
%             sprintf('%s already calculated, skipping', lfp_fname)
%             continue
%         end

        sprintf('working on %s', session_name)
        [lfp, actual_Fs] = calculate_monopolar_LFPs(phys_folder, target_Fs);

        save(full_lfp_name, 'lfp', 'actual_Fs');

    end

end