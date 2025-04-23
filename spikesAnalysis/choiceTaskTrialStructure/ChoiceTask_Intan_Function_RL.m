function [intan_data, digital_data, nexData, both_log_files, log_file, logData, trials, logConflict, isConflict, isConflictOnly, boxLogConflict] = ChoiceTask_Intan_Function_RL(cur_dir, phys_folder)


intan_data = read_Intan_RHD2000_file_DL(fullfile(phys_folder, 'info.rhd'));

digital_data = readIntanDigitalFile(fullfile(phys_folder,'digitalin.dat'));

if ~isempty(intan_data)
nexData = intan2nex(fullfile(phys_folder,'digitalin.dat'), fullfile(phys_folder,'analogin.dat'), intan_data); 

both_log_files = dir(fullfile(cur_dir, '*.log'));

log_file = both_log_files(~contains({both_log_files.name}, '_old'));
log_file = fullfile(log_file.folder,log_file.name);

logData = readLogData(log_file); 

%generates trial struct
trials = createTrialsStruct_simpleChoice_Intan(logData, nexData);

   if ~isempty(trials)
        logConflict = vertcat(trials.logConflict);
        isConflict = vertcat(logConflict.isConflict); % Returns isConflict in a logical array of isConflict fields
        isConflictOnly = find(isConflict); % Pulls out indices of actual fields with error
        boxLogConflict = vertcat(logConflict.boxLogConflicts); % Returns boxConflict in workspace with fields for outcome, RT, MT, pretone, centerNP sideNP
    else
        logConflict = [];
        isConflict = [];
        isConflictOnly = []; 
        boxLogConflict = [];
    return;
   end
else
        nexData = [];
        both_log_files = [];
        log_file = [];
        logData = [];
        trials = [];
        logConflict = [];
        isConflict = [];
        isConflictOnly = []; 
        boxLogConflict = [];
    return;
end
end