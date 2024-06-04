% function A = get_choiceTask_level_information(~)
% %
% %
% % INPUTS:
% %   ratID - string containing the rat ID (e.g., 'R0001'). Should have 5
% %       characters
% %   
% %
% % CHOICE RT DIFFICULTY LEVELS:
% %   0 - Poke Any: rat pokes any port, as soon as it pokes a pellet is
% %       delivered
% %   1 - Very Easy: single port is lit, pellet delivered as soon as the port
% %       is poked
% %   2 - Easy: 
% %   3 - Standard:  
% %   4 - Advanced: 
% %   5 - Choice VE: 
% %   6 - Choice Easy: 
% %   7 - Choice Standard: 
% %   8 - Choice Advanced: 
% %   9 - Testing: 
% %
% % UPDATE LOG:
% % 08/27/2014 - don't have to navigate to the parent folder first, requires
% %   user to specify the rat ID as an input argument

choiceRTdifficulty = cell(1, 10);
choiceRTdifficulty{1}  = 'poke any';
choiceRTdifficulty{2}  = 'very easy';
choiceRTdifficulty{3}  = 'easy';
choiceRTdifficulty{4}  = 'standard';
choiceRTdifficulty{5}  = 'advanced';
choiceRTdifficulty{6}  = 'choice VE';
choiceRTdifficulty{7}  = 'choice easy';
choiceRTdifficulty{8}  = 'choice standard';
choiceRTdifficulty{9}  = 'choice advanced';
choiceRTdifficulty{10} = 'testing';



intan_parent_directory = 'X:\Neuro-Leventhal\data\ChoiceTask';

rats_with_intan_sessions = find_rawdata_folders(intan_parent_directory);

%%
for i_rat = 1 : length(rats_with_intan_sessions)
    
    intan_folders = rats_with_intan_sessions(i_rat).intan_folders;
    
    for i_sessionfolder = 1 : length(intan_folders)
        
        [session_folder, ~, ~] = fileparts(intan_folders{i_sessionfolder});
        session_log = find_session_log(session_folder);
        
        if isempty(session_log)
            sprintf('no log file found for %s', session_folder)
        end
        logData = readLogData(session_log);
        
        % sprintf('placeholder')
    end
    
end