%{
quick info
Created by: ZH 6/13/24

Purpose: plots the monopolar power spectra for all channels on one plot 
            to help  identify outlier channels and their features

Full path: 
X:\Neuro-Leventhal\data\ChoiceTask\GitHub\ChoiceTask_Intan\LFPs\Analysis_code_JM\plots\monopolar_power_all_channels_one_plot.m

Files used: monopolarpower.mat

Outputs: Just a figure, not currently being saved anywhere 

Last updated: 6/13/24

%}

% what goes in:
% Define the rat ID and session number and probe type
ratID = 'R0425';
session_number = '20220726a';
probe_type = 'assy236';
% x location for channel labels 
    % (easy to move to where channels are most spread out or to specific spikes etc)
text_x = 10;

% what we want out:
    % one set of axis with the monoppolar power spectra for all channels on
    % top of each other to easily identify outliers and bad channels

%file path
monopolarpower_file_path = fullfile('X:\Neuro-Leventhal\data\ChoiceTask', ratID, [ratID '-processed'], [ratID '_' session_number], [ratID '_' session_number '_monopolarpower.mat']);
% Load the monopolar LFP data file
monopolarpower_data = load(monopolarpower_file_path);
f = monopolarpower_data.f;

% initialize figure
figure;

%for each channel plot the monopolar power on the same set of axis 
% (assumes 64 channels, may not be the case for all probes) 
for i = 1:64
    monopolarpower_channel_data=monopolarpower_data.power_lfps(i,:);
    plot(f, 10*log10(monopolarpower_channel_data));
    hold on

    % label each channel
    % Calculate position for the text annotation
    text_y = 10*log10(monopolarpower_channel_data(text_x));
    % Add channel number as text annotation
    % i is the geographic location because the monopolar power files are
    % ordered already
    %need to get from i --> intan number
    [intan_site_order,site_order] = intan_and_channel_site_order(probe_type);
    intan_number=intan_site_order(i);
    text(text_x, text_y, sprintf('%d', intan_number),'FontSize', 8);

end
hold off

% plot specs
xlabel('frequency');
ylabel('power');
title(sprintf('monopolar power for all channels %s %s', ratID,session_number));
xlim([0,65]);
ylim([0,65]);

% Add subtitle clarifying what the labels represent
subtitle('(labels are intan numbers (1 scaled))');