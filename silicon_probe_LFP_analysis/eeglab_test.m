%%
choicetask_path = '\\corexfs.med.umich.edu\SharedX\Neuro-Leventhal\data\ChoiceTask';
summary_xls_dir = fullfile(choicetask_path, 'Probe Histology Summary');
summary_xls = 'ProbeSite_Mapping_MATLAB_RL2.xlsx';
summary_xls = fullfile(summary_xls_dir, summary_xls);

qc_xls = 'channels_qc_final_DL.xlsx';
qc_xls = fullfile(summary_xls_dir, qc_xls);

probe_type_sheet = 'probe_type';
probe_types = read_Jen_xls_summary(summary_xls, probe_type_sheet);

unit_csv_path = choicetask_path;
unit_csv_name = 'AllROIs_unitTable.csv';
unit_csv_name = fullfile(unit_csv_path, unit_csv_name);

unit_table = read_unit_info_from_csv(unit_csv_name);
unit_table_updated = clean_units_table(unit_table);


%%
session_name = 'R0420_20220715a';
rat_num = str2num(string(extractBetween(session_name, 'R0', '_')));
ratID = sprintf('R%04d', rat_num);

% load the qc data for this rat
qc_table = readtable(qc_xls, sheet=ratID);
qc_channels = qc_table.(session_name);
% above was commented out because this info is included in the bipolar lfp
% .mat file

rat_folder = fullfile(choicetask_path, ratID);
processed_folder = fullfile(rat_folder, sprintf('%s-processed', ratID));
%%
bipolar_lfp_name = sprintf('%s_bipolar_lfp.mat', session_name);
bipolar_lfp_name = fullfile(processed_folder, session_name, bipolar_lfp_name);
load(bipolar_lfp_name);

%%
EEG = eeg_emptyset;

EEG.data = bipolar_lfp;
EEG.nbchan = size(bipolar_lfp, 1);
EEG.pnts = size(bipolar_lfp, 2);
EEG.srate = actual_Fs;
EEG.times = linspace(1/actual_Fs, EEG.pnts/actual_Fs, EEG.pnts);
%%
trials_name = sprintf('%s_trials.mat', session_name);
trials_name = fullfile(processed_folder, session_name, trials_name);
load(trials_name);

probe_type = probe_types.probe_type(ratID==probe_types.ratID);
EEG.chanlocs = create_eeglab_chanlocs(probe_type, 'bipolar');
EEG.urchanlocs = EEG.chanlocs;

valid_channels = valid_bipolar_from_qc(qc_channels, probe_type);

EEG.event = create_eeglab_event(trials, actual_Fs);
EEG.urevent = EEG.event;

EEG.xmin = -1;

%%

EEG.filepath = fullfile(processed_folder, session_name);
EEG.filename = sprintf('%s_EEG.mat', session_name);


save(fullfile(EEG.filepath, EEG.filename), 'EEG');

%%
% the higher the burst criterion, the more conservative the algorithm is
% with identifying bad LFP stretches. 20 seems to work well - the default
% of 5 is too aggressive
temp3 = clean_artifacts(EEG, BurstCriterion=20);