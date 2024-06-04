% script to load in trials structure
intan_choicetask_parent = 'X:\Neuro-Leventhal\data\ChoiceTask';

valid_trials_folder = find_trials_struct_folders(intan_choicetask_parent); % find the folders with the trials structures to lab each lfp with data calculated as 'bad'; % need to match this with the loaded in lfp data

fname = 'X:\Neuro-Leventhal\data\ChoiceTask\Probe Histology Summary\Rat_Information_channels_to_discard.xlsx'; % for channels to ignore based on visualizing in Neuroscope etc

%%
for i_ratfolder = 1 : length(valid_trials_folder)
        
    session_trials_struct_folders = valid_trials_folder(i_ratfolder).trials_folders;
    
    for i_sessionfolder = 1 : length(session_trials_struct_folders)
        % extract the ratID and session name from the LFP file
            session_path = session_trials_struct_folders{i_sessionfolder};
            pd_trials_data = parse_trials_struct_folder(session_path);
            ratID = pd_trials_data.ratID;
            session_name = pd_trials_data.session_name;

            % Load trials structure
        for i_trialsfolder = 1:length(session_trials_struct_folders)
            session_trials_structure = fullfile(intan_choicetask_parent, ratID, [ratID '-LFP-trials-structures'], session_name);
            session_trials = find_trials_mat(session_trials_structure);
            trials_structure_file = dir(fullfile(session_trials));
            trials_structure_fname = fullfile(trials_structure_file.folder, trials_structure_file.name); 
            trials_structure = load(trials_structure_fname);
            trials_validchannels_marked = trials_structure.trials_validchannels_marked;
        end

    end
end
