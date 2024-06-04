function probe_channel_info = load_channel_information(fname, sheetname)

% important that the variable names are stored in range A1-H1
opts = detectImportOptions(fname, 'filetype', 'spreadsheet', 'sheet', sheetname);

% Import the data
probe_channel_info = readtable(fname, opts, "UseExcel", false);
