function xls_data = read_choicetask_xls_summary(filename, sheetname)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here

% update this function when need information from the other spreadsheets

switch sheetname
    case 'probe_type'
        xls_data = readtable(filename,'filetype','spreadsheet',...
            'sheet','probe_type',...
            'texttype','string');
    otherwise
        xls_data = '';
end

end