% script to calculate scalograms for all of Jen's rats; store in files in
% the processed data folders

parent_directory = 'X:\Neuro-Leventhal\data\ChoiceTask';
summary_xls = 'ProbeSite_Mapping_MATLAB.xlsx';
summary_xls_dir = 'X:\Neuro-Leventhal\data\ChoiceTask\Probe Histology Summary';
summary_xls = fullfile(summary_xls_dir, summary_xls);

% change the line below to allow looping through multiple trial types,
% extract left vs right, etc.
trials_to_analyze = 'correct';
lfp_types = {'monopolar', 'bipolar'};
lfp_type = 'monopolar';
% trials_to_analyze = 'all';

t_window = [-2.5, 2.5];
event_list = {'cueOn', 'centerIn', 'tone', 'centerOut' 'sideIn', 'sideOut', 'foodClick', 'foodRetrieval'};

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

    probe_type = probe_types{probe_types.ratID == ratID, 2};
    processed_folder = find_data_folder(ratID, 'processed', parent_directory);
    session_dirs = dir(fullfile(processed_folder, strcat(ratID, '*')));
    num_sessions = length(session_dirs);

    probe_lfp_type = sprintf('%s_%s', probe_type, lfp_type);

    for i_session = 1 : num_sessions
        
        session_name = session_dirs(i_session).name;
        cur_dir = fullfile(session_dirs(i_session).folder, session_name);
        cd(cur_dir)

        for i_lfptype = 1 : length(lfp_types)

            lfp_type = lfp_types{i_lfptype};

            for i_event = 1 : length(event_list)
                event_name = event_list{i_event};
                sprintf('working on session %s, event %s', session_name, event_name)
    
                scalo_folder = create_scalo_folder(session_name, event_name, parent_directory);
                if ~exist(scalo_folder, 'dir')
                    continue
                end
        
                for i_channel = 1 : num_channels
                    [shank_num, site_num] = get_shank_and_site_num(probe_lfp_type, i_channel);
        
                    old_scalo_name = sprintf('%s_scalos_%s_shank%02d_site%02d.mat',session_name, event_name, shank_num, site_num);
                    old_scalo_name = fullfile(scalo_folder, old_scalo_name);

                    if exist(old_scalo_name, 'file')
                        new_scalo_name = sprintf('%s_scalos_%s_%s_shank%02d_site%02d.mat',session_name, lfp_type, event_name, shank_num, site_num);
                        new_scalo_name = fullfile(scalo_folder, new_scalo_name);

                        movefile(old_scalo_name, new_scalo_name)
                    end
        
                end
            end
        end
    end

end