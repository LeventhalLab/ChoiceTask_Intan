function trials_structure_data_folder_name = is_intan_trials_structure_datafolder(test_folder)

subfolders = dir(test_folder);

trials_structure_data_folder_name = '';
        
test_files = dir(test_folder);
        
for i_file = 1 : length(test_files)
    if contains(test_files(i_file).name, '_trials.mat')
        trials_structure_data_folder_name = test_folder;
        break;
    end
end