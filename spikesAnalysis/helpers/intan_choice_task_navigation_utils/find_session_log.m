function log_fname = find_session_log(session_folder)

log_files = dir(fullfile(session_folder, '*.log'));

if isempty(log_files)
    log_fname = '';
end

num_new_logs = 0;
for i_log = 1 : length(log_files)
    
   if contains(log_files(i_log).name, 'old')
       continue
   end
   
   num_new_logs = num_new_logs + 1;
   new_logs(i_log) = log_files(i_log);
   
end

if num_new_logs == 1
    log_fname = fullfile(session_folder, new_logs.name);
else
    log_fname = '';
end