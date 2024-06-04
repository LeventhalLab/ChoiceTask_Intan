function valid_rat_folder = find_processed_folders(intan_choicetask_parent)

potential_rat_folders = dir(intan_choicetask_parent);
valid_rat_folder = struct('name',[], 'processed_folders', []);

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

% now look for valid session folders within each rat folder
num_rat_folders_with_processed_data = 0;
for i_ratfolder = 1 : num_valid_rat_folders
    
    [root_path, cur_ratID, ext] = fileparts(rat_folders{i_ratfolder});
    
    cur_processed_folder = fullfile(rat_folders{i_ratfolder}, strcat(cur_ratID, '-processed'));
    
    if ~isfolder(cur_processed_folder)
        continue
    end
    
    potential_session_folders = dir(cur_processed_folder);
    
    % rewrite this section to find session folders with processed data
    num_valid_sessionfolders = 0;
    found_processed_data = false;
    num_processed_sessionfolders = 0;
    for i_sessionfolder = 1 : length(potential_session_folders)
        if isvalidchoicesessionfolder(potential_session_folders(i_sessionfolder).name)
            num_valid_sessionfolders = num_valid_sessionfolders + 1;
            
            % test if session folder contains lfp data
            full_pd_path = fullfile(cur_processed_folder, potential_session_folders(i_sessionfolder).name);
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
            
            processed_datafolder = is_intan_processed_datafolder(full_pd_path);
            if ~isempty(processed_datafolder)
                num_processed_sessionfolders = num_processed_sessionfolders + 1;
                processed_datafolders{num_processed_sessionfolders} = processed_datafolder;
                found_processed_data = true;
            end
            
%             end
        end
    end
    
    if found_processed_data
        num_rat_folders_with_processed_data = num_rat_folders_with_processed_data + 1;
        valid_rat_folder(num_rat_folders_with_processed_data).name = rat_folders{i_ratfolder};
        valid_rat_folder(num_rat_folders_with_processed_data).processed_folders = processed_datafolders;
    end
    
end

end