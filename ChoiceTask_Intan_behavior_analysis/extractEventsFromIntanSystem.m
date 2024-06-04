function nexData = extractEventsFromIntanSystem(data_directory)
%
% function to translate intan system behavior events into nex format
% 
% INPUTS:
%   data_directory - 
%
% OUTPUTS:
%   nexData

cd(data_directory)
dig_in_file = 'digitalin.dat';
analog_in_file = 'analogin.dat';

analog_thresh = 2;    % volts

rhd_file = dir('*.rhd');

if isempty(rhd_file)
    fprintf('no .rhd file found in %s\n',data_directory);
end

% read intan header file, which will create variables describing the way
% data are stored
intan_info = read_Intan_RHD2000_file_DL('info.rhd');

tic
digital_word = readIntanDigitalFile(dig_in_file);
toc
tic
if ~isfield(intan_info, 'board_adc_channels')
    nexData = [];
    return
end
ADC_signals = readIntanAnalogFile(analog_in_file,intan_info.board_adc_channels);
toc

nexData = intan2nex(digital_word,ADC_signals,intan_info,'analog_thresh',analog_thresh);