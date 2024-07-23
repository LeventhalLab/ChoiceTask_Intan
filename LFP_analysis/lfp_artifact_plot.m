% Load the LFP data and artifact mask
lfp_data_file = 'X:\Neuro-Leventhal\data\ChoiceTask\R0326\R0326-processed\R0326_20200220a\R0326_20200220a_monopolar_lfp.mat';
load(lfp_data_file, 'lfp', 'artifact_timestamps', 'actual_Fs');  % Load original LFP data

% Select the channel to plot
channel = 1; % Change this to the channel you want to plot

% Get the time vector in seconds
time_vector = (0:size(lfp, 2)-1) / actual_Fs;

% Plot the original LFP data
figure;
plot(time_vector, lfp(channel, :), 'b');
hold on;
xlabel('Time (s)');
ylabel('LFP (\muV)');
title(sprintf('Original LFP Data with Artifacts Marked - Channel %d', channel));

% Extract artifact indices for the selected channel
artifact_indices = artifact_timestamps{channel};

% Plot the artifact regions as red dots
plot(time_vector(artifact_indices), lfp(channel, artifact_indices), 'r.', 'MarkerSize', 10);
legend('LFP', 'Artifacts');
hold off;