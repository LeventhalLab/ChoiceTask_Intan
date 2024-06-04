function valid_rat_folder = find_rawdata_folders_testing(intan_choicetask_parent)

potential_rat_folders = dir(intan_choicetask_parent);
valid_rat_folder = struct('name',[], 'intan_folders', []);

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
num_rat_folders_with_intan_data = 0;
for i_ratfolder = 1 : num_valid_rat_folders
    
    [root_path, cur_ratID, ext] = fileparts(rat_folders{i_ratfolder});
    
    cur_rawdata_folder = fullfile(rat_folders{i_ratfolder}, strcat(cur_ratID, '-rawdata'))
    
    if ~isfolder(cur_rawdata_folder)
        continue
    end
    
    potential_session_folders = dir(cur_rawdata_folder);
    
    % find session folders with choice/ephys data
    num_intan_sessionfolders = 0;
    num_valid_sessionfolders = 0;
    found_intan_data = false;
    for i_sessionfolder = 1 : length(potential_session_folders)
        if isvalidchoicesessionfolder(potential_session_folders(i_sessionfolder).name)
            num_valid_sessionfolders = num_valid_sessionfolders + 1;
            
            % test if session folder contains intan data
            full_rd_path = fullfile(cur_rawdata_folder, potential_session_folders(i_sessionfolder).name);
            test_folders = dir(full_rd_path);
            for i_tf = 1 : length(test_folders)
                fp = fullfile(full_rd_path, test_folders(i_tf).name);
                
                if ~isfolder(fp) || length(test_folders(i_tf).name) < 5
                    continue
                end
                
                if ~isvalidratfolder(test_folders(i_tf).name(1:5))
                    continue
                end
                
%                 if isbehavior_vi_folder(test_folders(i_tf).name)
%                     continue
%                 end
            
                intan_datafolder = is_intan_datafolder(full_rd_path);
                if ~isempty(intan_datafolder)
                    num_intan_sessionfolders = num_intan_sessionfolders + 1;
                    intan_datafolders{num_intan_sessionfolders} = intan_datafolder;
                    found_intan_data = true;
                end
            end
        end
    end
    
    if found_intan_data
        num_rat_folders_with_intan_data = num_rat_folders_with_intan_data + 1;
        valid_rat_folder(num_rat_folders_with_intan_data).name = rat_folders{i_ratfolder};
        valid_rat_folder(num_rat_folders_with_intan_data).intan_folders = intan_datafolders;
    end
    
end

end
