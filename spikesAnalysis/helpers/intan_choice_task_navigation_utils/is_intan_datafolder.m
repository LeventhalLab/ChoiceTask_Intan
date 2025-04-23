function intan_data_folder_name = is_intan_datafolder(test_folder)

subfolders = dir(test_folder);

intan_data_folder_name = '';
for i_folders = 1 : length(subfolders)
    
    fp = fullfile(test_folder, subfolders(i_folders).name);
    if isfolder(fp)
        
        test_files = dir(fp);
        
        for i_file = 1 :length(test_files)
            if strcmp(test_files(i_file).name, 'amplifier.dat')
                intan_data_folder_name = fp;
                break;
            end
        end
    end
end