function probe_anatomy_info = read_probe_mapping_xls(fname, sheetname)

% important that the variable names are stored in range A1-G1
opts = detectImportOptions(fname, 'filetype', 'spreadsheet', 'variablenamesrange', 'A1:G1', 'sheet', sheetname);
probe_anatomy_info = readtable(fname, 'Sheet', sheetname);

% as of 4/27/2022, variable names are:
% AmplifierChannel - recording channel number in the amplifier.dat file
%   (the "intan channel number")
% NN_Shank_Number - shank number for this site on an 8 x 8 neuronexus probe
% NN_SiteNumber - site number as defined on neuronexus probe
% AP - anterior-posterior site location
% ML - medial-lateral site location
% DV - dorsal-ventral site location
% Region - presumed brain region