%% 

% intan_parent_directory = 'X:\Neuro-Leventhal\data\ChoiceTask';
intan_parent_directory = '\\corexfs.med.umich.edu\SharedX\Neuro-Leventhal\data\ChoiceTask';

rat_xldbfile = 'ProbeSite_Mapping_MATLAB.xlsx';
rat_xldbfile = fullfile(intan_parent_directory, 'Probe Histology Summary', rat_xldbfile);
probe_type_sheet = 'probe_type';

% rat_probe_table = readtable(rat_xldbfile, filetype='spreadsheet', Sheet=probe_type_sheet);
rat_probe_table = read_Jen_xls_summary(rat_xldbfile, probe_type_sheet);

lfp_types = {'monopolar', 'bipolar'};
target_Fs = 500;
new_convert_to_microvolts = true;

%%

rats_with_intan_sessions = find_rawdata_folders(intan_parent_directory);

% test_folder = '/Volumes/SharedX/Neuro-Leventhal/data/ChoiceTask/R0327/R0327-rawdata/R0327_20191218a/R0327_20191218_ChVE_191218_140437';
% cd(test_folder);


sessions_to_ignore = {'R0378_20210507a', 'R0326_20191107a', 'R0425_20220728a', 'R0425_20220816b', 'R0427_20220920a','R0427_20220919a' }; % R0425_20220728a debugging because the intan side was left on for 15 hours;
sessions_to_ignore1 = {'R0425_20220728_ChVE_220728_112601', 'R0427_20220920_Testing_220920_150255', 'R0427_20220920a'}; 
sessions_to_ignore2 = {'R0427_20220908a', 'R0427_20220909a', 'R0427_20220912a','R0427_20220913a', 'R0427_20220914a', 'R0427_20220915a', 'R0427_20220916a'}; % R0427_20220920a does not have an 'info.rhd' file

%%
clear lfp
clear convert_to_microvolts
clear actual_Fs

for i_rat = 4 : length(rats_with_intan_sessions)
    
    intan_folders = rats_with_intan_sessions(i_rat).intan_folders;
    
    for i_sessionfolder = 1 : length(intan_folders)
        intan_folder = intan_folders{i_sessionfolder};
        [rd_path, intan_foldername, ~] = fileparts(intan_folder);
        rd_metadata = parse_rawdata_folder(rd_path);
        pd_folder = create_processed_data_folder(rd_metadata, intan_parent_directory);
        ratID = rd_metadata.ratID;
        intan_session_name = rd_metadata.session_name;
        session_name = rd_metadata.session_name;

        lfp_path = create_lfp_folder(rd_metadata, intan_parent_directory);

        for i_lfptype = 1 : length(lfp_types)

            lfp_type = lfp_types{i_lfptype};
            sprintf('working on %s, %s', session_name, lfp_type)
            
            lfp_fname = create_lfp_fname(rd_metadata, lfp_type);
            old_monopolar_fname = strjoin({rd_metadata.session_name, 'lfp.mat'}, '_');
            old_monopolar_fname = fullfile(lfp_path, old_monopolar_fname);
            full_lfp_path = fullfile(lfp_path, lfp_fname);

            if strcmpi(lfp_type, 'monopolar')
                full_mono_lfp_fname = full_lfp_path;
            end
            
%             if exist(full_lfp_path, 'file')
%                 continue
%             end
        
%             session_path = intan_folders{i_sessionfolder};
%             pd_processed_data = parse_processed_folder(session_path);
%             session_name = pd_processed_data.session_name;
        
            if any(strcmp(session_name, sessions_to_ignore))
                continue;
            end
            
            if contains(session_name, sessions_to_ignore) || contains(intan_session_name, sessions_to_ignore1)|| contains(ratID, 'DigiInputTest') % Just always ignore these sessions. R0411 no data, DigitInputTest is t est files
                continue;
            end

            if strcmpi(lfp_type, 'monopolar')
                if exist(old_monopolar_fname, 'file')
                    movefile(old_monopolar_fname, full_lfp_path)
                    load(full_lfp_path)
                    if ~exist('convert_to_microvolts', 'var')
                        % if convert_to_microvolts wasn't recorded,
                        % recalculate
                        [lfp, actual_lfpFs] = calculate_monopolar_LFPs(intan_folder, target_Fs, new_convert_to_microvolts);
                        convert_to_microvolts = new_convert_to_microvolts;
                        save(full_lfp_path, 'lfp', 'actual_Fs', 'convert_to_microvolts');
                    elseif ~convert_to_microvolts
                        lfp = lfp * 0.195;    % convert to microvolts
                        convert_to_microvolts = true;
                        save(full_lfp_path, 'lfp', 'actual_Fs', 'convert_to_microvolts');
                    end
                elseif exist(full_lfp_path, 'file')
                    load(full_lfp_path)
                    if exist('convert_to_microvolts', 'var')
                        if ~convert_to_microvolts
                            lfp = lfp * 0.195;    % convert to microvolts
                            convert_to_microvolts = true;
                            save(full_lfp_path, 'lfp', 'actual_Fs', 'convert_to_microvolts');
                        end
                    else
                        % if convert_to_microvolts wasn't recorded
                        % originally, redo the calculation with the
                        % conversion to microvolts
                        [lfp, actual_lfpFs] = calculate_monopolar_LFPs(intan_folder, target_Fs, new_convert_to_microvolts);
                        convert_to_microvolts = new_convert_to_microvolts;
                        save(full_lfp_path, 'lfp', 'actual_Fs', 'convert_to_microvolts');
                    end
                else
                    [lfp, actual_Fs] = calculate_monopolar_LFPs(intan_folder, target_Fs, new_convert_to_microvolts);
                    convert_to_microvolts = new_convert_to_microvolts;
                    save(full_lfp_path, 'lfp', 'actual_Fs', 'convert_to_microvolts');
                end
            elseif strcmpi(lfp_type, 'bipolar')
                % lfp should be left over from previous calculation; if
                % not, load the monopolar lfp file
                if ~exist('lfp', 'var')
                    % load the monopolar lfp file
                    monopolar_lfp_fname = create_lfp_fname(rd_metadata, 'monopolar');
                    full_mono_lfp_fname = fullfile(lfp_path, monopolar_lfp_fname);
                    load(full_mono_lfp_fname);
                    if ~convert_to_microvolts
                        lfp = lfp * 0.195;    % convert to microvolts
                        convert_to_microvolts = true;
                        save(full_mono_lfp_fname, 'lfp', 'actual_Fs', 'convert_to_microvolts');
                    end
                end
                probe_type = probe_type_from_table(rat_probe_table, ratID);
                [bipolar_lfp, intan2probe_mapping] = calculate_bipolar_LFPs(lfp, probe_type);
                full_lfp_name = full_mono_lfp_fname;
                save(full_lfp_path, 'bipolar_lfp', 'full_lfp_name', 'actual_Fs', 'intan2probe_mapping', 'probe_type', 'convert_to_microvolts');
            end

        end
        % clear the lfp variable once monopolar and bipolar LFPs have been
        % calculated
        clear lfp
        clear convert_to_microvolts
        clear actual_Fs
        
    end
    
end
%%