%%
choicetask_path = '\\corexfs.med.umich.edu\SharedX\Neuro-Leventhal\data\ChoiceTask';
summary_xls_dir = fullfile(choicetask_path, 'Probe Histology Summary');
summary_xls = 'ProbeSite_Mapping_MATLAB_RL2.xlsx';
summary_xls = fullfile(summary_xls_dir, summary_xls);

probe_type_sheet = 'probe_type';
probe_types = read_Jen_xls_summary(summary_xls, probe_type_sheet);

unit_csv_path = choicetask_path;
unit_csv_name = 'AllROIs_unitTable.csv';
unit_csv_name = fullfile(unit_csv_path, unit_csv_name);

unit_table = read_unit_info_from_csv(unit_csv_name);
unit_table_updated = clean_units_table(unit_table);


%%
rat_num = 420;
ratID = sprintf('R%04d', rat_num);

EEG.data = bipolar_lfp;
EEG.nbchan = size(bipolar_lfp, 1);
EEG.pnts = size(bipolar_lfp, 2);
EEG.srate = actual_Fs;
EEG.times = linspace(1/actual_Fs, EEG.pnts/actual_Fs, EEG.pnts);

probe_type = probe_types.probe_type(ratID==probe_types.ratID);
EEG.chanlocs = create_eeglab_chanlocs(probe_type);
EEG.chanlocs.labels = 
EEG.chanlocs.type
EEG.chanlocs.x
EEG.chanlocs.y
EEG.chanlocs.z

%%
temp = clean_artifacts(EEG);