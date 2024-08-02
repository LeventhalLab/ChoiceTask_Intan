% goodbad channel plot check
% ZH

% used to compare a specific good channel against a specific bad channel 
% in one session for one rat 
% displays raw data, processed data, and monopolar power spectra

%{
quick information: 
Full path:
X:\Neuro-Leventhal\data\ChoiceTask\GitHub\ChoiceTask_Intan\LFPs\Analysis_code_JM\plots\goodbad_channel_plot_check.m

Files used:
Amplifier.dat (raw data)
Monopolar_lfp.mat (processed data)
Monopolar_power.mat (power spectra)

Outputs dave to:
Tiled chart layout t (check workspace if it doesn’t pop up automatically)

Made 6/12/24, last updated 6/12/24
%}

% what goes in:
% Define the rat ID and session number
ratID = 'R0493';
session_number = '20230731a';
% good channel (1 scaled)
good_channel = 49;
% bad channel (1 scaled) 
bad_channel = 41;
% the name of the folder that the amplifier.dat file is in
amp_folder_name = 'R0493_20230731_Testing_230731_114520';


% what we want out:
    % 6 tiles
    % 1&2 - display raw data from good channel and bad channel of amplifier.dat
        % time scale must be considered and adjusted relative to the
        % processed (decimated) one
    % 3&4- similar to 1 but showing processed lfp data
    % 5&6- monopolar power spectra plots for the good and bad channels
        % (see power plot display 4 script for more on that)
    
% file paths to raw data, processed monopolar lfps, and monopolar power
amp_file_path = fullfile('X:\Neuro-Leventhal\data\ChoiceTask', ratID, [ratID '-rawdata'], [ratID '_' session_number], [amp_folder_name], 'amplifier.dat');
monopolar_lfp_file_path = fullfile('X:\Neuro-Leventhal\data\ChoiceTask', ratID, [ratID '-processed'], [ratID '_' session_number], [ratID '_' session_number '_monopolar_lfp.mat']);
monopolarpower_file_path = fullfile('X:\Neuro-Leventhal\data\ChoiceTask', ratID, [ratID '-processed'], [ratID '_' session_number], [ratID '_' session_number '_monopolarpower.mat']);

%6 tiles -----------------------------------------------------------
t= tiledlayout(3,2);
        
% 1 and 2 -----------------------------------------------------------------
%1 - display raw data from good channel and bad channel of
    % amplifier.dat
        % time scale must be considered and adjusted relative to the
        % processed (decimated) one

% Open the file
fid = fopen(amp_file_path, 'r');

% Check if the file was opened successfully
if fid == -1
    error('Failed to open file: %s', amp_file_path);
end

% Define the number of samples to read
num_samples_to_read = 1000000; % Adjust this value as needed

% Read the data from the file
data = fread(fid, [64, num_samples_to_read], 'int16');

% Close the file
fclose(fid);


% Define the channels to plot (1 scaled) [good,bad]
channels_to_plot = [good_channel, bad_channel];

% Extract the data for the specified channels
%multiplied by .195 to convert to microvolts
channel_data = .195*data(channels_to_plot, :);

% Define time axis
sampling_rate = 20000; % Sampling rate in samples per second
time_axis = (0:num_samples_to_read-1) / sampling_rate; % Time axis in seconds

% Plot the raw data for the good channel
% Tile 1
nexttile(1)
plot(time_axis, channel_data(1,:));
xlabel('time (sec)');
ylabel('Amplitude (microVolts)');
xlim([10,40]); % 30 second interval after the first 10 seconds in case there is any weirdness in the first few seconds
ylim([-1000,1000]);
title(sprintf('raw data from good channel %d (1)', good_channel));

% plot raw data for the bad channel
nexttile(2)
plot(time_axis, channel_data(2,:));
xlabel('time (sec)');
ylabel('Amplitude (microVolts)');
xlim([10,40]);
ylim([-1000,1000]);
title(sprintf('raw data from bad channel %d (1)', bad_channel));

% 3 and 4  ----------------------------------------------------------------
% display processed lfp data from good channel and bad channel
% Load the monopolar LFP data file
monopolar_lfp_data = load(monopolar_lfp_file_path);
% Extract the LFP data for the specified channels
monopolar_lfp_data_good = monopolar_lfp_data.lfp(good_channel, 1:25000);
monopolar_lfp_data_bad = monopolar_lfp_data.lfp(bad_channel, 1:25000);

processed_samples=25000;
sampling_rate = 500; % Sampling rate in samples per second
time_axis = (0:processed_samples-1) / sampling_rate; % Time axis in seconds

% Tile 3 and 4
% processed lfp data for good and bad channels 
nexttile(3)
plot(time_axis,monopolar_lfp_data_good);
xlabel('time (sec)');
ylabel('Amplitude (microVolts)');
xlim([10,40]);
ylim([-1000,1000]);
title(sprintf('processed LFP Data from good channel %d (1)', good_channel));

nexttile(4)
plot(time_axis,monopolar_lfp_data_bad);
xlabel('time(sec)');
ylabel('Amplitude (microVolts)');
xlim([10,40]);
ylim([-1000,1000]);
title(sprintf('processed LFP Data from bad channel %d (1)', bad_channel));

% 5 ad 6 ----------------------------------------------------------------
% different depending on what probe 
% Load the monopolar LFP data file
monopolarpower_data = load(monopolarpower_file_path);

%monopolar power files are organized geographically
% inputs are intan numbers and the output is the index
    [intan_site_order,site_order] = intan_and_channel_site_order(probe_type);
    good_mono_index = find(intan_site_order==good_channel);
    bad_mono_index = find(intan_site_order==bad_channel);
    

% Extract the power data for the specified channels
monopolarpower_data_good = monopolarpower_data.power_lfps(good_mono_index,:);
monopolarpower_data_bad = monopolarpower_data.power_lfps(bad_mono_index,:);
f = monopolarpower_data.f;

% plot monopolar power spectra for the good and bad channels
% Tile 5
nexttile(5)
plot(f, 10*log10(monopolarpower_data_good));
xlabel('frequency');
ylabel('power');
title(sprintf('good channel %d (1) monopolar power', good_channel));
xlim([0,65]);
ylim([0,65]);
   
% Tile 6
nexttile(6)
plot(f, 10*log10(monopolarpower_data_bad)); 
xlabel('frequency');
ylabel('power');
title(sprintf('bad channel %d (1) monopolar power', bad_channel));
xlim([0,65]);
ylim([0,65]);

    