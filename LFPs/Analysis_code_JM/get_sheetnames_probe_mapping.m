%%
% get the sheet names for the probe mapping file

sheets = sheetnames(probe_mapping_fname);
num_sheets = size(sheets, 1);

num_rat_sheets = 0;
for i_sheet = 1 : num_sheets
    
    cur_sheet = char(sheets(i_sheet));
    if cur_sheet(1) == 'R'
        num_rat_sheets = num_rat_sheets + 1;
        rat_sheets{num_rat_sheets} = cur_sheet;
    end
    
end
% lfp_name = 
probe_anatomy_info = read_probe_mapping_xls(probe_mapping_fname, sheetname);