function valid_channels = valid_channels_from_qc(session_qc_check,session_name)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% as on 2/3/2025, good channels are labeled as "2" and bad channels
% as "1" in the excel spreadsheet
% the spreadsheet is also organized according to the amplifier channel
% number, not the site number on the probe

valid_channels = session_qc_check.(session_name);
valid_channels = valid_channels - 1;

end