% power plot display 4 
% modified from monopolar_diff_plot_all_files.m (in plots folder) by ZHH
% june 2024

% script to run through folders and make the monopolar plots for
% each channel on its own plot organized based on physical location

%{
quick information:
location:
X:\Neuro-Leventhal\data\ChoiceTask\GitHub\ChoiceTask_Intan\LFPs\Analysis_code_JM\plots

functions called:
probe_site_map_all
plot_monopolar_power_single_plot_ASSY156 (and ASSY236, and NNsite)
intan_and_channel_site_order

files used:
Monopolarpower.mat files in processed folders
channels_qc_final.xlsx (Excel file for color coding bad channels)

Outputs save to: 
output_folder =  fullfile(intan_choicetask_parent, 'power_plot_disp2_folder');
Where intan choice task parent is
intan_choicetask_parent = 'X:\Neuro-Leventhal\data\ChoiceTask';

last updated 6/20/24.
%}

% choiceTask difficulty levels
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

intan_choicetask_parent = 'X:\Neuro-Leventhal\data\ChoiceTask';

% loop through all the processed data folders here, load the lfp file
valid_rat_folders = find_processed_folders(intan_choicetask_parent);
rats_with_intan_sessions = find_rawdata_folders(intan_choicetask_parent);


%%

% idk what this is for - ZH
naming_convention_diffs_NNsite;
naming_convention_diffs_Cambridge; % this loads the NNsite order ventral to dorsal as a variable in the workspace for labeling the plots (create this as a fxn?)
naming_convention;

% lfp_fname = dir(fullfile(intan_choicetask_parent,'**','*_lfp.mat')); % This
% generates a matrix of '*_lfp.mat' filenames

% lists for ratID probe_type
% update as new rats are added
NN8x8 = ["R0326", "R0327", "R0372", "R0379", "R0374", "R0376", "R0378", "R0394", "R0395", "R0396", "R0412", "R0413"]; % Specify list of ratID associated with each probe_type
ASSY156 = ["R0411", "R0419"];
ASSY236 = ["R0420", "R0425", "R0427", "R0456","R0457","R0460","R0463","R0465","R0466","R0467", "R0477","R0479","R0492","R0493","R0494","R0495"];

% excel file that identifies channels as good or bad based on our visual neuroscope inspection
fname = 'X:\Neuro-Leventhal\data\ChoiceTask\Probe Histology Summary\channels_qc_final.xlsx';

% skipping certain sessions, often because of an early disconnect
sessions_to_ignore = {'R0327_20191111a','R0376_20210115a', 'R0378_20210507a', 'R0326_20191107a', 'R0425_20220728a', 'R0425_20220816b', 'R0427_20220920a','R0419_20220317a',...
   'R0419_20220321a','R0419_20220321b','R0419_20220321c','R0420_20220707a','R0420_20220708a','R0372_20201116a','R0394_20210115a','R0419_20220317a','R0420_20220703a',...
   'R0420_20220707a','R0420_20220708a','R0420_20220710a','R0420_20220714a','R0420_20220919a','R0425_20220816a','R0425_20220816b','R0427_20220908a','R0456_20221121a','R0456_20221128a','R0460_20230110a','R0460_20230110b','R0327_20191015a'};
sessions_to_ignore1 = {'R0425_20220728_ChVE_220728_112601', 'R0427_20220920_Testing_220920_150255'};
sessions_to_ignore2 = {'R0427_20220908a'};
% Trying this as a workaround. Code wouldn't skip these two trials. R0425 - 15 hour session and R0427 no data (files didn't save correctly)?
%%

% go through all sessions for all rats
for i_ratfolder = 1 : length(valid_rat_folders)
    
    session_processed_folders = valid_rat_folders(i_ratfolder).processed_folders;
    
    for i_sessionfolder = 1 : length(session_processed_folders)
    % extract the ratID and session name from the LFP file
        session_path = session_processed_folders{i_sessionfolder};
        pd_processed_data = parse_processed_folder(session_path);
        ratID = pd_processed_data.ratID;
        session_name = pd_processed_data.session_name;
        
        % skip sessions that we said should be ignored
        if any(strcmp(session_name, sessions_to_ignore)) 
            continue;
        end

        % R0328 has no actual ephys; using these lines to skip unneeded data. R0327 Can't create trials struct; R0420 I haven't added lines for
        % why skip 411? - ZH 6/13/24
        if  contains(ratID, 'R0328') || contains(ratID, 'R0374') || contains(ratID, 'R0411') 
             continue; 
        end

        %code is catching on R0378 bc only 63 channels were recorded?
        %skipping that rat
        if  contains(ratID, 'R0378')
            continue;
        end
        

        % comment out when wanting to run all valid rats:
 %temporarily skipping because i want to see 456
     %   if  contains(ratID, 'R0419')|| contains(ratID, 'R0420')|| contains(ratID, 'R0425') || contains(ratID, 'R0427')
     %        continue;  
     %   end
%skipping to rat 419
     %  if contains(ratID, NN8x8)||contains(ratID, 'R0493') || contains(ratID, 'R0327') || contains(ratID, 'R0372')  || contains(ratID, 'R0376')  || contains(ratID, 'R0379') || contains(ratID, 'R0395') || contains(ratID, 'R0378')|| contains(ratID, 'R0396')|| contains(ratID, 'R0394')|| contains(ratID, 'R0412')|| contains(ratID, 'R0413')||  contains(ratID, 'R0425') || contains(ratID, 'R0427')||contains(ratID, 'R0456')||contains(ratID,'R0460')||contains(ratID,'R0463')||contains(ratID,'R0326')||contains(ratID,'R0465')||contains(ratID,'R0466')||contains(ratID,'R0467')||contains(ratID,'R0479')||contains(ratID,'R0492')||contains(ratID,'R0494')||contains(ratID,'R0420') % just trying to skip some lines of data to get to the last set to debug. Uncomment out to run more trialTypes
     %        continue;
     %   end
 %skipping to a ASSY236 rat, then skip to 425
     %   if contains(ratID, NN8x8)||contains(ratID,ASSY156)||contains(ratID,'R0420')
     %        continue;
     %   end 

     

        parentFolder = fullfile(intan_choicetask_parent, ...
         ratID, ...
         [ratID '-processed']);
        
        % grabs the amplifier.dat raw data file
        session_rawfolder = fullfile(intan_choicetask_parent, ratID, [ratID '-rawdata'], session_name);
        session_log = find_session_log(session_rawfolder);
        logData = readLogData(session_log);
        
        % A is the overall title 
        A=cell(3,1);
        A{1} = ['Subject: ' ratID ' Session: ' session_name];
        A{2} = ['Task Level: ' choiceRTdifficulty{logData.taskLevel+1}];
        A{3} = []; 
        

        % load_channel_information 
        % Use the opts.VariableNamesRange for each ratID to
        % detectImportOptions otherwise there's an error due to different
        % session number for each rat
    % the current excel file uses 2 for good channels and 1 for bad channels (single plot functions are updated according to this new color code) - ZH 6/13/24
        
        % reading the excel sheet (data range varies for each rat because
        % each rat has a different number of sessions) 
        sheetname = ratID;
        if contains(ratID, 'R0326')
            opts = detectImportOptions(fname, 'filetype', 'spreadsheet', 'VariableNamesRange', 'A1:H1', 'datarange', 'A2:H65', 'sheet', sheetname);
        elseif contains(ratID, 'R0327') || contains(ratID, 'R0374')
            opts = detectImportOptions(fname, 'filetype', 'spreadsheet', 'VariableNamesRange', 'A1:E1', 'datarange', 'A2:E65', 'sheet', sheetname);
        elseif contains(ratID, 'R0372') || contains(ratID, 'R0378')|| contains(ratID, 'R0396')
            opts = detectImportOptions(fname, 'filetype', 'spreadsheet', 'VariableNamesRange', 'A1:J1', 'datarange', 'A2:J65', 'sheet', sheetname);
        elseif contains(ratID, 'R0379') || contains(ratID, 'R0413')
            opts = detectImportOptions(fname, 'filetype', 'spreadsheet', 'VariableNamesRange', 'A1:L1', 'datarange', 'A2:L65', 'sheet', sheetname);
        elseif contains(ratID, 'R0376')
            opts = detectImportOptions(fname, 'filetype', 'spreadsheet', 'VariableNamesRange', 'A1:O1', 'datarange', 'A2:O65', 'sheet', sheetname);
        elseif contains(ratID, 'R0394')
            opts = detectImportOptions(fname, 'filetype', 'spreadsheet', 'VariableNamesRange', 'A1:G1', 'datarange', 'A2:G65', 'sheet', sheetname);            
        elseif contains(ratID, 'R0395') || contains(ratID, 'R0427')
            opts = detectImportOptions(fname, 'filetype', 'spreadsheet', 'VariableNamesRange', 'A1:K1', 'datarange', 'A2:K65', 'sheet', sheetname);
        elseif contains(ratID, 'R0412')
            opts = detectImportOptions(fname, 'filetype', 'spreadsheet', 'VariableNamesRange', 'A1:M1', 'datarange', 'A2:M65', 'sheet', sheetname);
        elseif contains(ratID, 'R0419')
            opts = detectImportOptions(fname, 'filetype', 'spreadsheet', 'VariableNamesRange', 'A1:P1', 'datarange', 'A2:P65', 'sheet', sheetname);
        elseif contains(ratID, 'R0420')
            opts = detectImportOptions(fname, 'filetype', 'spreadsheet', 'VariableNamesRange', 'A1:N1', 'datarange', 'A2:N65', 'sheet', sheetname);
        elseif contains(ratID, 'R0425')
            opts = detectImportOptions(fname, 'filetype', 'spreadsheet', 'VariableNamesRange', 'A1:V1', 'datarange', 'A2:V65', 'sheet', sheetname);
        elseif contains(ratID, 'R0456')
            opts = detectImportOptions(fname, 'filetype', 'spreadsheet', 'VariableNamesRange', 'A1:C1', 'datarange', 'A2:C65', 'sheet', sheetname);
        end

        % output folder
        % make a folder for the processed data graphs
        output_folder =  fullfile(intan_choicetask_parent, 'power_plot_disp2_folder'); 
        if ~exist(output_folder, 'dir')
            mkdir(output_folder);
        end    
        
        % create filenames to hold mono- and diff-LFPs
        mono_power_plot = [session_name, '_monopolarpower2.pdf'];
        mono_power_plot = fullfile(output_folder, mono_power_plot);

% Once plots/data seems accurate, can use this to skip over any existing files and only create new files. When making edits, comment this section out so new graphs are made.        
     %    if exist(mono_power_plot, 'file') && exist(diff_power_plot, 'file') 
     %        continue; 
     %    end
    

        % For monopolar_power plots
        power_lfps_file = dir(fullfile(session_path, '**', '*_monopolarpower.mat'));
        
        % catch before error
        try    
        power_lfps_fname = fullfile(power_lfps_file.folder, power_lfps_file.name); 
        catch
            keyboard
        end

        % This catches at R0378, the file with 63 channels that didn't record a power_lfps file
        power_lfps = load(power_lfps_fname);
        power_lfps = power_lfps.power_lfps;
        num_rows = size(power_lfps,1); % for now, skipping R0378_20210507a because the session only recorded 63 channels instead of 64. Need to rewrite lfp_NNsite_order and diff functions to fix this issue by determining which channel was not recorded. 
        
        session_name_adj=['x',session_name(7:end)];
        if contains(ratID, NN8x8)
            probe_type = 'NN8x8';
            probe_channel_info = load_channel_information(fname, sheetname);
            [channel_information, intan_site_order, site_order] =probe_site_map_all(probe_channel_info, probe_type);
            valid_sites_reordered = channel_information.(session_name_adj);
        elseif contains(ratID, ASSY156)
            probe_type = 'ASSY156';
            probe_channel_info = load_channel_information(fname, sheetname);
            [channel_information, intan_site_order, site_order] = probe_site_map_all(probe_channel_info, probe_type);
            valid_sites_reordered = channel_information.(session_name_adj);
        elseif contains(ratID, ASSY236)
            probe_type = 'ASSY236';
            probe_channel_info = load_channel_information(fname, sheetname);
            [channel_information, intan_site_order, site_order] = probe_site_map_all(probe_channel_info, probe_type);
            valid_sites_reordered = channel_information.(session_name_adj);
        end

        % The actual plot section
        if contains(ratID, NN8x8)
            probe_type = 'NN8x8';
            plot_monopolar = plot_monopolar_power_single_plot_NNsite(power_lfps_fname, valid_sites_reordered);   % include info for making a title, etc. in the single_plot function
            sgtitle(A, 'Interpreter','none'); % 'Interpreter', 'none'  --- allows the title to have an underscore instead of a subscript
            set(gcf, 'WindowState', 'maximize'); % maximizes the window so that it exports the graphics with appropriate font size
            exportgraphics(gcf, mono_power_plot);
            close;
        elseif contains(ratID, ASSY156)
            probe_type = 'ASSY156';
            plot_monopolar = plot_monopolar_power_single_plot_ASSY156(power_lfps_fname, valid_sites_reordered);  % include info for making a title, etc. in the single_plot function
            sgtitle(A, 'Interpreter','none'); % 'Interpreter', 'none'  --- allows the title to have an underscore instead of a subscript
            set(gcf, 'WindowState', 'maximize'); % maximizes the window so that it exports the graphics with appropriate font size
            exportgraphics(gcf, mono_power_plot);
            close;
        elseif contains(ratID, ASSY236)
            probe_type = 'ASSY236';
            plot_monopolar = plot_monopolar_power_single_plot_ASSY236(power_lfps_fname, valid_sites_reordered);   % include info for making a title, etc. in the single_plot function
            sgtitle(A, 'Interpreter','none'); % 'Interpreter', 'none'  --- allows the title to have an underscore instead of a subscript
            set(gcf, 'WindowState', 'maximize'); % maximizes the window so that it exports the graphics with appropriate font size
            exportgraphics(gcf, mono_power_plot);
            close;
        end
         

     % no diff / bipolar plots here, i put those in a different script:
     % bipolar_display.m
     %-ZH
     
    end
 
end