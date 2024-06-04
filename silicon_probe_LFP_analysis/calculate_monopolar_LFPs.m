function [lfp_data, actual_lfpFs] = calculate_monopolar_LFPs(intan_folder, target_Fs, convert_to_microvolts)
%
% INPUTS
%   intan_folder - folder containing intan data (amplifier.dat, info.rhd)
%   target_Fs - target sampling rate
%
% OUTPUTS:
%   lfp_data - num_channels x num_samples array containing the LFP data.
%       NOTE - the channels have NOT been rearranged to reflect probe
%       geometry
%   actual_lfpFs - sampling rate actually achieved when trying to hit
%       target_Fs (may be different due to rounding)

raw_block_size = 100000;    % number of samples to handle at a time (titrate to memory), may want to make this a varargin
bytes_per_sample = 2;
filtOrder = 1000;

cd(intan_folder);

rhd_file = dir('*.rhd');
if length(rhd_file) > 1
    error('more than one rhd file in ' + intan_folder);
    return
elseif isempty(rhd_file)
    error('no rhd files found in ' + intan_folder);
    return
end

amp_file = dir('amplifier.dat'); %rename for Watson Data; change back to amplifier.dat
if isempty(amp_file)
    error('no amplifier files found in ' + intan_folder);
    return
end

rhd_info = read_Intan_RHD2000_file_DL(rhd_file.name);
amplifier_channels = rhd_info.amplifier_channels;
num_channels = length(amplifier_channels);
Fs = rhd_info.frequency_parameters.amplifier_sample_rate;

samples_per_channel = amp_file.bytes / (num_channels * bytes_per_sample);

r = round(Fs / target_Fs);
actual_lfpFs = Fs/r;
raw_overlap_size = ceil(filtOrder * 2 / r) * r; % can use this line to check the overlap by making it equal to zero
lfp_overlap_size = raw_overlap_size / r;

lfp_block_size = raw_block_size / r;
num_lfp_samples = ceil(samples_per_channel / r);
lfp_data = zeros(num_channels, num_lfp_samples);

% calculate the number of blocks that will be needed
net_lfp_samples_per_block = lfp_block_size - lfp_overlap_size;
num_blocks = ceil(num_lfp_samples / net_lfp_samples_per_block);

currentLFP = zeros(num_channels, lfp_block_size);

% do the first block separate from the rest, since there will be some
% overlap for the rest of the blocks
LFPstart = 1;
LFPend = (LFPstart + lfp_block_size - 1) - lfp_overlap_size;

disp(['Block 1 of ' num2str(num_blocks)]);
amplifier_data = readIntanAmplifierData_by_sample_number(amp_file.name,1,raw_block_size,amplifier_channels,convert_to_microvolts);
for i_ch = 1 : num_channels
    currentLFP(i_ch, :) = ...
        decimate(amplifier_data(i_ch, :), r, filtOrder, 'fir');
end
lfp_data(:, LFPstart:LFPend) = currentLFP(:, 1:LFPend);
clear currentLFP;

LFPstart = LFPend + 1;
raw_block_plus_overlap_size = raw_block_size + raw_overlap_size;
LFPblock_start = lfp_overlap_size + 1;
LFPblock_end = (LFPblock_start + lfp_block_size - 1) - lfp_overlap_size;

read_final_samples = false;
for i_block = 2 : num_blocks
   
    disp(['Block ' num2str(i_block) ' of ' num2str(num_blocks)]);
   
%     read_start_sample = (i_block-1) * raw_block_size - raw_overlap_size + 1;
    read_start_sample = (LFPstart-1) * r - raw_overlap_size;
    read_end_sample = read_start_sample + raw_block_plus_overlap_size - 1;
   
    new_amplifier_data = readIntanAmplifierData_by_sample_number(amp_file.name,read_start_sample,read_end_sample,amplifier_channels,convert_to_microvolts);
   
    if i_block < num_blocks
        if read_end_sample > samples_per_channel
            % rarely, the end of the padded block goes past the end of the
            % file, and messes up the indices
            clear currentLFP
            LFPend = size(lfp_data, 2);
            read_final_samples = true;
        else
            LFPend = (LFPstart + lfp_block_size - 1) - lfp_overlap_size;
        end
    else
        clear currentLFP;
        read_final_samples = true;
        LFPend = size(lfp_data, 2);
    end
   
    for i_ch = 1 : num_channels
        currentLFP(i_ch,:) = ...
            decimate(new_amplifier_data(i_ch, :), r, filtOrder, 'fir');
    end
     
    if read_final_samples
        LFPblock_end = size(currentLFP, 2);
    end
    try
        lfp_data(:, LFPstart:LFPend) = currentLFP(:, LFPblock_start : LFPblock_end);
    catch
        keyboard
    end
    if read_final_samples
        break
    end
    LFPstart = LFPend + 1;
end
