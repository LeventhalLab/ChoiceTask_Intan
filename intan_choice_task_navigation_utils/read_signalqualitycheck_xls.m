function session_qc_check = read_signalqualitycheck_xls(filename, sheetname)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% update this function when need information from the other spreadsheets

session_qc_check = readtable(filename, filetype='spreadsheet',...
    sheet=sheetname,...
    texttype='string');


end