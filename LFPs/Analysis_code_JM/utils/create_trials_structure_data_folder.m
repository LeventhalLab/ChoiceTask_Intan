function session_trials_folder = create_trials_structure_data_folder(rd_metadata, parent_directory)

trials_folder= strcat(rd_metadata.ratID, '-LFP-trials-structures');
session_trials_folder = fullfile(parent_directory, rd_metadata.ratID, trials_folder, rd_metadata.session_name);

if ~isfolder(session_trials_folder)
    
    mkdir(session_trials_folder)
    
end