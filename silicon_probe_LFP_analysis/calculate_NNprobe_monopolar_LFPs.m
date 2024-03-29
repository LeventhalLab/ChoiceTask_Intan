function [lfp_data, actual_lfpFs] = calculate_NNprobe_monopolar_LFPs(intan_folder, target_Fs)

raw_block_size = 100000;    % number of samples to handle at a time (titrate to memory), may want to make this a varargin
bytes_per_sample = 2;
convert_to_microvolts = false;
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

amp_file = dir('amplifier.dat');
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
raw_overlap_size = ceil(filtOrder * 2 / r) * r;
lfp_overlap_size = raw_overlap_size / r;

lfp_block_size = raw_block_size / r;
num_lfp_samples = ceil(samples_per_channel / r);
lfp_data = zeros(num_channels, num_lfp_samples);

% calculate the number of blocks that will be needed
net_lfp_samples_per_block = lfp_block_size - lfp_overlap_size;
num_blocks = ceil(num_lfp_samples / net_lfp_samples_per_block);

currentLFP = zeros(num_channels, lfp_block_size);
% rawdata = zeros(num_channels, raw_block_size);

% do the first block separate from the rest, since there will be some
% overlap for the rest of the blocks
LFPstart = 1;
LFPend = (LFPstart + lfp_block_size - 1) - lfp_overlap_size;

disp(['Block 1 of ' num2str(num_blocks)]);
amplifier_data = readIntanAmplifierData_by_sample_number(amp_file.name,1,raw_block_size,amplifier_channels,convert_to_microvolts);
for i_ch = 1 : num_channels
    currentLFP(i_ch, :) = ...
        decimate(amplifier_data(i_ch, :), r, filtOrder, 'fir');
%     decimated_signal = decimate_zerophase(amplifier_data(i_ch, :), r, round(filtOrder/2));
end
lfp_data(:, LFPstart:LFPend) = currentLFP(:, 1:LFPend);
clear currentLFP;

LFPstart = LFPend + 1;
raw_block_plus_overlap_size = raw_block_size + raw_overlap_size;
LFPblock_start = lfp_overlap_size + 1;
LFPblock_end = (LFPblock_start + lfp_block_size - 1) - lfp_overlap_size;
for i_block = 2 : num_blocks
    
    disp(['Block ' num2str(i_block) ' of ' num2str(num_blocks)]);
    
%     read_start_sample = (i_block-1) * raw_block_size - raw_overlap_size + 1;
    read_start_sample = (LFPstart-1) * r - raw_overlap_size;
    read_end_sample = read_start_sample + raw_block_plus_overlap_size - 1;
    
    new_amplifier_data = readIntanAmplifierData_by_sample_number(amp_file.name,read_start_sample,read_end_sample,amplifier_channels,convert_to_microvolts);
    
    if i_block < num_blocks
        LFPend = (LFPstart + lfp_block_size - 1) - lfp_overlap_size;
    else
        clear currentLFP;
        LFPend = size(lfp_data, 2);
    end
    
    for i_ch = 1 : num_channels
        try
            currentLFP(i_ch,:) = ...
                decimate(new_amplifier_data(i_ch, :), r, filtOrder, 'fir');
        catch
            % this only fails if we get to the end of the file after the 
            % samples to include in the LFP for this block, but before 
            % we get to the end of the extra samples loaded to reduce edge
            % effects. In this case, just copy what's available of the
            % decimated signal into currentLFP and ignore the rest.
            % Shouldn't be a problem because it won't read past
            % LFPblock_end into the lfp_data array
            a = decimate(new_amplifier_data(i_ch, :), r, filtOrder, 'fir');
            currentLFP(i_ch,1:length(a)) = a;
        end
        % below was for testing that decimate performs zero-phase filter
%         decimated_signal = decimate_zerophase(new_amplifier_data(i_ch, :), r, round(filtOrder/2));
%         figure(1)
%         hold off
%         plot(currentLFP(i_ch, :))
%         hold on
%         plot(decimated_signal)
    end
     
    if i_block == num_blocks
        LFPblock_end = size(currentLFP, 2);
    end
    try
        lfp_data(:, LFPstart:LFPend) = currentLFP(:, LFPblock_start : LFPblock_end);
    catch
        keyboard
    end
    LFPstart = LFPend + 1;
end