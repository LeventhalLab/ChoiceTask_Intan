function [amplifier_data] = readIntanAmplifierData_by_sample_number(filename,samp_start,samp_end,amplifier_channels,convert_to_microvolts)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% INPUTS
%   filename - 
%   t_start - 
%   t_end - 
%   Fs - sampling rate, in Hz

bytes_per_sample = 2;

num_channels = length(amplifier_channels); % amplifier channel info from header file

fid = fopen(filename, 'r');

% figure out the starting point in the file
bytes_to_skip = samp_start * num_channels * bytes_per_sample;
samples_to_read = samp_end - samp_start + 1;

fseek(fid, bytes_to_skip, 0);

amplifier_data = fread(fid, [num_channels, samples_to_read], 'int16');
fclose(fid);

if convert_to_microvolts
    amplifier_data = amplifier_data * 0.195; % convert to microvolts
end

end