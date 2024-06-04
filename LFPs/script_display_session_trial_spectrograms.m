% script to calculate scalograms for all of Jen's rats; store in files in
% the processed data folders

parent_directory = 'Z:\data\ChoiceTask\';
summary_xls = 'ProbeSite_Mapping_MATLAB.xlsx';
summary_xls_dir = 'Z:\data\ChoiceTask\Probe Histology Summary';
summary_xls = fullfile(summary_xls_dir, summary_xls);

% change the line below to allow looping through multiple trial types,
% extract left vs right, etc.
trials_to_analyze = 'correct';
lfp_type = 'monopolar';
% trials_to_analyze = 'all';

probe_type_sheet = 'probe_type';
probe_types = read_Jen_xls_summary(summary_xls, probe_type_sheet);
% NOTE - UPDATE FUNCTION read_Jen_xls_summary WHEN WE NEED OTHER
% INFORMATION OUT OF THAT SPREADSHEET

[rat_nums, ratIDs, ratIDs_goodhisto] = get_rat_list();

num_rats = length(ratIDs);

for i_rat = 1 : num_rats
    ratID = ratIDs{i_rat};
    rat_folder = fullfile(parent_directory, ratID);

    if ~isfolder(rat_folder)
        continue;
    end

    probe_type = probe_types{probe_types.RatID == ratID, 2};
    processed_folder = find_data_folder(ratID, 'processed', parent_directory);
    session_dirs = dir(fullfile(processed_folder, strcat(ratID, '*')));
    num_sessions = length(session_dirs);

    probe_lfp_type = sprintf('%s_%s', probe_type, lfp_type);

    for i_session = 1 : num_sessions
        
        session_name = session_dirs(i_session).name;
        cur_dir = fullfile(session_dirs(i_session).folder, session_name);
        cd(cur_dir)

        for i_event = 1 : length(event_list)
            event_name = event_list{i_event};
            sprintf('working on session %s, event %s', session_name, event_name)

            perievent_data = extract_perievent_data(ordered_lfp, selected_trials, event_list{4}, t_window, Fs);

            scalo_folder = create_scalo_folder(session_name, event_name, parent_directory);
%             scalo_folder = sprintf('%s_scalos_%s', session_name, event_name);
%             scalo_folder = fullfile(cur_dir, scalo_folder);
            if ~exist(scalo_folder, 'dir')
                continue
            end
            create_scalogram_map(session_name, event_name, lfp_type, parent_directory);

        end
    end

end