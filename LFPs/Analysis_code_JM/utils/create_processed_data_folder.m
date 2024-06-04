function session_pf = create_processed_data_folder(rd_metadata, parent_directory)

pf = strcat(rd_metadata.ratID, '-processed');
session_pf = fullfile(parent_directory, rd_metadata.ratID, pf, rd_metadata.session_name);

if ~isfolder(session_pf)
    
    mkdir(session_pf)
    
end