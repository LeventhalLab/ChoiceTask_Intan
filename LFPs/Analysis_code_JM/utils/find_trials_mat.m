function trials_structure_fname = find_trials_mat(session_folder)

% This function has NOT been validated

trials_struct_files = dir(fullfile(session_folder, '*.mat'));

if isempty(trials_struct_files)
    trials_structure_fname = '';
end

num_new_trials_struct = 0;
for i_trial_struct = 1 : length(trials_struct_files)
    
%    if contains(trials_struct_files(i_log).name, 'old')
%        continue
%    end
   
   num_new_trials_struct = num_new_trials_struct + 1;
   new_trials(i_trial_struct) = trials_struct_files(i_trial_struct);
   
end

if num_new_trials_struct == 1
    trials_structure_fname = fullfile(session_folder, new_trials.name);
else
    trials_structure_fname = '';
end