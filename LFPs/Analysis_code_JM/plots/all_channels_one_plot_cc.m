% all channels one plot cc (color coded)

%{
quick info
Created by: ZH 6/19/24

Purpose: plots the monopolar power spectra for all channels on one plot 
            to help  identify outlier channels and their features, with
            traces color coded based on excel file for easier comparison
            btwn traces that appear bad and channels we visually identified
            as bad based on raw data

Full path: 
X:\Neuro-Leventhal\data\ChoiceTask\GitHub\ChoiceTask_Intan\LFPs\Analysis_code_JM\plots\all_channels_one_plot_cc.m

Files used: monopolarpower.mat, channels_qc_final.xlsx

Outputs: Just a figure, not currently being saved anywhere 

Last updated: 6/19/24

%}

% what goes in:
% Define the rat ID and session number and probe type
ratID = 'R0493';
session_number = '20230731a';
probe_type = 'assy236';
% x location for channel labels
text_x = 60;

% what we want out:
    % one set of axis with the monoppolar power spectra for all channels on
    % top of each other to easily identify outliers and bad channels
        % color code channels based on the excel file

%file path
monopolarpower_file_path = fullfile('X:\Neuro-Leventhal\data\ChoiceTask', ratID, [ratID '-processed'], [ratID '_' session_number], [ratID '_' session_number '_monopolarpower.mat']);
% Load the monopolar LFP data file
monopolarpower_data = load(monopolarpower_file_path);
f = monopolarpower_data.f;

% Load Excel file to identify bad channels
excel_file =  'X:\Neuro-Leventhal\data\ChoiceTask\Probe Histology Summary\channels_qc_final.xlsx';
% Specify the sheet name you want to read
sheet_name = ratID;  % Replace with your actual sheet name

% Load Excel file to identify bad channels
channels_table = readtable(excel_file, 'Sheet', sheet_name);

session_num_adj = ['x' session_number];
% Extract the column corresponding to session_number
ones_and_twos = channels_table.(session_num_adj);

% Define colors
good_color = 'k';    % Black for good channels
bad_color = [1 0 1]; % Magenta (RGB values) for bad channels

% initialize figure
figure;

%for each channel plot the monopolar power on the same set of axis 
% (assumes 64 channels, may not be the case for all probes) 
for i = 1:64
    monopolarpower_channel_data=monopolarpower_data.power_lfps(i,:);

    % i is the geographic location because the monopolar power files are
    % ordered already
    %need to get from i --> intan number
    [intan_site_order,site_order] = intan_and_channel_site_order(probe_type);
    intan_number=intan_site_order(i);

    % if ones_and_twos(intan_number+1) = 1 
    % plot pink
    % elseif = 2 
    %plot black
    %else plot red
    %might need to delete the +1
    if ones_and_twos(intan_number)==1
         plot(f, 10*log10(monopolarpower_channel_data), 'Color', bad_color);
    elseif ones_and_twos(intan_number)==2
        plot(f, 10*log10(monopolarpower_channel_data), 'Color', good_color);
    else
        plot(f, 10*log10(monopolarpower_channel_data), 'Color','r');
    end
    hold on

    % label each channel
    % Calculate position for the text annotation
    text_y = 10*log10(monopolarpower_channel_data(text_x));
    % Add channel number as text annotation
    text(text_x, text_y, sprintf('%d', intan_number),'FontSize', 8,'Color','b');

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

% Legend for color coding
legend({'Bad Channels', 'Good Channels'}, 'Location', 'best');