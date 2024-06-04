% script run through folders and make the monopolar and diff plots

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

% Fs = 500; -- commenting out so we can just load the Fs from the
% power_lfps file.

naming_convention_diffs_NNsite;
naming_convention_diffs_Cambridge; % this loads the NNsite order ventral to dorsal as a variable in the workspace for labeling the plots (create this as a fxn?)
naming_convention;

% lfp_fname = dir(fullfile(intan_choicetask_parent,'**','*_lfp.mat')); % This
% generates a matrix of '*_lfp.mat' filenames

% lists for ratID probe_type
NN8x8 = ["R0326", "R0327", "R0372", "R0379", "R0374", "R0376", "R0378", "R0394", "R0395", "R0396", "R0412", "R0413"]; % Specify list of ratID associated with each probe_type
ASSY156 = ["R0411", "R0419"];
ASSY236 = ["R0420", "R0425", "R0427", "R0457"];

fname = 'X:\Neuro-Leventhal\data\ChoiceTask\Probe Histology Summary\Rat_Information_channels_to_discard.xlsx'; % for channels to ignore based on visualizing in Neuroscope etc

sessions_to_ignore = {'R0327_20191111a','R0327_20191015a','R0376_20210115a', 'R0378_20210507a', 'R0326_20191107a', 'R0425_20220728a', 'R0425_20220816b', 'R0427_20220920a'};
sessions_to_ignore1 = {'R0425_20220728_ChVE_220728_112601', 'R0427_20220920_Testing_220920_150255'}; 
sessions_to_ignore2 = {'R0427_20220908a', 'R0427_20220909a', 'R0427_20220912a','R0427_20220913a', 'R0427_20220914a', 'R0427_20220915a', 'R0427_20220916a'};
% Trying this as a workaround. Code wouldn't skip these two trials. R0425 - 15 hour session and R0427 no data (files didn't save correctly)?
%%
for i_ratfolder = 1 : length(valid_rat_folders)
    
    session_processed_folders = valid_rat_folders(i_ratfolder).processed_folders;
    
    for i_sessionfolder = 1 : length(session_processed_folders)
    % extract the ratID and session name from the LFP file
        session_path = session_processed_folders{i_sessionfolder};
        pd_processed_data = parse_processed_folder(session_path);
        ratID = pd_processed_data.ratID;
        session_name = pd_processed_data.session_name;
        
        if any(strcmp(session_name, sessions_to_ignore)) 
            continue;
        end

        if  contains(ratID, 'R0328') || contains(ratID, 'R0326') || contains(ratID, 'R0327') || contains(ratID, 'R0411') % skip over 326 and 327 since they're done with updated images
             continue;  % R0328 has no actual ephys; using these lines to skip unneeded data. R0327 Can't create trials struct; R0420 I haven't added lines for
        end

        if contains(ratID, NN8x8) % just trying to skip some lines of data to get to the last set to debug. Uncomment out to run more trialTypes
             continue;
        end

        parentFolder = fullfile(intan_choicetask_parent, ...
         ratID, ...
         [ratID '-processed']);

        A=cell(1,3);
        A{1} = ['Subject: ' ratID];
        A{2} = ['Session: ' session_name];
        
        session_rawfolder = fullfile(intan_choicetask_parent, ratID, [ratID '-rawdata'], session_name);
        session_log = find_session_log(session_rawfolder);
        logData = readLogData(session_log);
        A{3} = ['Task Level: ' choiceRTdifficulty{logData.taskLevel+1}]; 

        % load_channel_information - this file is coded 0 = bad, 1 = good,
        % 2 = variable for data in each channel for each session_name for
        % each rat_ID. Use the opts.VariableNamesRange for eat ratID to
        % detectImportOptions otherwise there's an error due to different
        % session number for each rat
        
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
        end

        % make a folder for the processed data graphs (monopolar and diff
        % graphs)        
        processed_graphFolder = [parentFolder(1:end-9) 'processed-graphs'];
        if ~exist(processed_graphFolder, 'dir')
            mkdir(processed_graphFolder);
        end    
        
        % create filenames to hold mono- and diff-LFPs
        mono_power_plot = [session_name, '_monopolarpower.pdf'];
        mono_power_plot = fullfile(processed_graphFolder, mono_power_plot);

        diff_power_plot = [session_name, '_diffpower.pdf'];
        diff_power_plot = fullfile(processed_graphFolder, diff_power_plot);

% Once plots/data seems accurate, can use this to skip over any existing files and only create new files. When making edits, comment this section out so new graphs are made.        
%         if exist(mono_power_plot, 'file') && exist(diff_power_plot, 'file') 
%             continue; 
%         end
        
        % For monopolar_power plots
        power_lfps_file = dir(fullfile(session_path, '**', '*_monopolarpower.mat'));
        
        try    
        power_lfps_fname = fullfile(power_lfps_file.folder, power_lfps_file.name); 
        catch
            keyboard
        end

        % This catches at R0378, the file with 63 channels that didn't record a power_lfps file
        power_lfps = load(power_lfps_fname);
        power_lfps = power_lfps.power_lfps;
        num_rows = size(power_lfps,1); % for now, skipping R0378_20210507a because the session only recorded 63 channels instead of 64. Need to rewrite lfp_NNsite_order and diff functions to fix this issue by determining which channel was not recorded. 
        
        if contains(ratID, NN8x8)
            probe_type = 'NN8x8';
            probe_channel_info = load_channel_information(fname, sheetname);
            [channel_information, intan_site_order, site_order] = channel_by_probe_site_ALL(probe_channel_info, probe_type);
            valid_sites_reordered = channel_information.(session_name);
        elseif contains(ratID, ASSY156)
            probe_type = 'ASSY156';
            probe_channel_info = load_channel_information(fname, sheetname);
            [channel_information, intan_site_order, site_order] = channel_by_probe_site_ALL(probe_channel_info, probe_type);
            valid_sites_reordered = channel_information.(session_name);
        elseif contains(ratID, ASSY236)
            probe_type = 'ASSY236';
            probe_channel_info = load_channel_information(fname, sheetname);
            [channel_information, intan_site_order, site_order] = channel_by_probe_site_ALL(probe_channel_info, probe_type);
            valid_sites_reordered = channel_information.(session_name);
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
                
        % For diff plots - how do you plot the diff plots for Cambridge
        % probes which should have 60 plots? put an if statement for those
        % probe styles to do the plot differently.
        power_lfps_diff_file = dir(fullfile(session_path, '**', '*_diffpower.mat'));
        power_lfps_diff_fname = fullfile(power_lfps_diff_file.folder, power_lfps_diff_file.name); 
        
        % This catches at R0378, the file with 63 channels that didn't record a power_lfps file
        power_lfps_diff = load(power_lfps_diff_fname);
        f = power_lfps_diff.f;
        power_lfps_diff = power_lfps_diff.power_lfps_diff;
        num_rows_diff = size(power_lfps_diff,1);


        % The actual plot section
        if contains(ratID, NN8x8)
            plot_diff = plot_diff_power_single_plot_NNsite(power_lfps_diff_fname, valid_sites_reordered);
            set(gcf, 'WindowState', 'maximize'); % maximizes the window so that it exports the graphics with appropriate font size
            sgtitle(A, 'Interpreter','none');
            exportgraphics(gcf, diff_power_plot);
            close;
        elseif contains(ratID, ASSY156)
            plot_diff = plot_diff_power_single_plot_Cambridge(power_lfps_diff_fname, valid_sites_reordered);
            set(gcf, 'WindowState', 'maximize'); % maximizes the window so that it exports the graphics with appropriate font size
            sgtitle(A, 'Interpreter','none');
            exportgraphics(gcf, diff_power_plot);
            close;
        elseif contains(ratID, ASSY236)
            plot_diff = plot_diff_power_single_plot_Cambridge(power_lfps_diff_fname, valid_sites_reordered);
            set(gcf, 'WindowState', 'maximize'); % maximizes the window so that it exports the graphics with appropriate font size
            sgtitle(A, 'Interpreter','none');
            exportgraphics(gcf, diff_power_plot);
            close;
        end       
    end
 
end