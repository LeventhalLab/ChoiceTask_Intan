%%
unit_csv_path = '\\corexfs.med.umich.edu\SharedX\Neuro-Leventhal\data\ChoiceTask';
unit_csv_name = 'AllROIs_unitTable.csv';
unit_csv_name = fullfile(unit_csv_path, unit_csv_name);

unit_table = read_unit_info_from_csv(unit_csv_name);

%%
% get ratIDs from the unit table
n_units = size(unit_table, 1);
rat_nums = zeros(size(unit_table, 1), 1);

for i_unit = 1 : n_units
    rat_nums(i_unit) = str2num(cell2mat(extractBetween(unit_table.unitID{i_unit}, 'R0', '_')));
end

unit_table.rat_nums = rat_nums;
unit_table_byrat = sortrows(unit_table, 'rat_nums');

%%
EEG.data = bipolar_lfp;
EEG.nbchan = size(bipolar_lfp, 1);
EEG.pnts = size(bipolar_lfp, 2);
EEG.srate = actual_Fs;
EEG.times = linspace(1/actual_Fs, EEG.pnts/actual_Fs, EEG.pnts);

probe_type = 'NN8x8';

EEG.chanlocs.labels = 
EEG.chanlocs.type
EEG.chanlocs.x
EEG.chanlocs.y
EEG.chanlocs.z

%%
temp = clean_artifacts(EEG);