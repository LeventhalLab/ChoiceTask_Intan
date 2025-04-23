function analog_data = readIntanAnalogFile(fname, board_adc_channels)
%
% function to read in the analogin.dat file
%
% INPUTS
%   fname - filename of the Intan analogin file to read
%   intan_data.board_adc_channels - board adc channel structure from
%       read_Intan_RHD2000_file_DL
% OUTPUTS
%   analog_data - m x n matrix where each row is a vector of voltages recorded on
%       a single channel

num_channels = length(board_adc_channels); % ADC input info from header file
fileinfo = dir(fname);
num_samples = fileinfo.bytes/(num_channels * 2); % uint16 = 2 bytes
fid = fopen(fname, 'r');

analog_data = fread(fid, [num_channels, num_samples], 'uint16');
fclose(fid);
v = analog_data * 0.000050354; % convert to volts