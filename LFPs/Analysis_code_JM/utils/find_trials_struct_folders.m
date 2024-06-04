function valid_trials_folder = find_trials_struct_folders(intan_choicetask_parent)

potential_rat_folders = dir(intan_choicetask_parent);
valid_trials_folder = struct('name',[], 'trials_structure_folders', []);

num_valid_rat_folders = 0;
for i_folder = 1 : length(potential_rat_folders)
    
    full_path = fullfile(intan_choicetask_parent, potential_rat_folders(i_folder).name);
    if ~isfolder(full_path)
        continue
    end
    % look for folders of format RXXXX
    if isvalidratfolder(potential_rat_folders(i_folder).name)
        num_valid_rat_folders = num_valid_rat_folders + 1;
        rat_folders{num_valid_rat_folders} = full_path;
    end
        
end

num_rat_folders_with_trials_data = 0;
for i_ratfolder = 1 : num_valid_rat_folders
    
    [root_path, cur_ratID, ext] = fileparts(rat_folders{i_ratfolder});
    
    cur_trials_folder = fullfile(rat_folders{i_ratfolder}, strcat(cur_ratID, '-LFP-trials-structures'));
    
    if ~isfolder(cur_trials_folder)
        continue
    end
    
    potential_session_folders = dir(cur_trials_folder);
    
    % rewrite this section to find session folders with processed data
    num_valid_sessionfolders = 0;
    found_trials_data = false;
    num_trials_sessionfolders = 0;
    for i_sessionfolder = 1 : length(potential_session_folders)
        if isvalidchoicesessionfolder(potential_session_folders(i_sessionfolder).name)
            num_valid_sessionfolders = num_valid_sessionfolders + 1;
            
            % test if session folder contains lfp data
            full_pd_path = fullfile(cur_trials_folder, potential_session_folders(i_sessionfolder).name);
%             test_folders = dir(full_pd_path);
%             for i_tf = 1 : length(test_folders)
%                 fp = fullfile(full_pd_path, test_folders(i_tf).name);
%                 
%                 if ~isfolder(fp) || length(test_folders(i_tf).name) < 5
%                     continue
%                 end
%                 
%                 if ~isvalidratfolder(test_folders(i_tf).name(1:5))
%                     continue
%                 end
%                 
% %                 if isbehavior_vi_folder(test_folders(i_tf).name)
% %                     continue
% %                 end
            
            trials_datafolder = is_intan_trials_structure_datafolder(full_pd_path);
            if ~isempty(trials_datafolder)
                num_trials_sessionfolders = num_trials_sessionfolders + 1;
                trials_datafolders{num_trials_sessionfolders} = trials_datafolder;
                found_trials_data = true;
            end
            
%             end
        end
    end
    
    if found_trials_data
        num_rat_folders_with_trials_data = num_rat_folders_with_trials_data + 1;
        valid_trials_folder(num_rat_folders_with_trials_data).name = rat_folders{i_ratfolder};
        valid_trials_folder(num_rat_folders_with_trials_data).trials_folders = trials_datafolders;
    end
    
end

end