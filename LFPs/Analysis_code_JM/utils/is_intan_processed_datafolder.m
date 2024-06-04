function processed_data_folder_name = is_intan_processed_datafolder(test_folder)

subfolders = dir(test_folder);

processed_data_folder_name = '';
        
test_files = dir(test_folder);
        
for i_file = 1 : length(test_files)
    if contains(test_files(i_file).name, '_lfp.mat')
        processed_data_folder_name = test_folder;
        break;
    end
end