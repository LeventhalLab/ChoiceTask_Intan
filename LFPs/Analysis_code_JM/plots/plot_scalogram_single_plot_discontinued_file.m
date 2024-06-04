% calculate many scalograms and average them

% [numtrials, numchannels, numevents] = size(event_triggered_lfps);
% numtrials - number of trials in the array pulled out from
%   ChoiceTask_intan_workflow trial structure for a given trial type (e.g.
%   CorrectGo

% numchannels - number of channels/amplifier channels (pulling from the LFP
%   data)

% numevents - number of events pulled based on time e.g. if LFP data is at 
%   Fs = 500 and you pull out [-2 2], there will be 2001 numevents

% create 'if' or 'for' loop to loop through 1:145 (loop through numtrials).
% Then take the mean of numtrials for that channel. Then squeeze that and
% plot it. mean(data,dim)

function surface_plot = plot_scalogram_single_plot(myData_ordered)
%       monopolar_fname - filename of the file to plot
% INPUTS
%   event_triggered_lfps - squeezed data

% OUTPUTS
%       cfs_mean - m x n array of monopolar power
%       f - 
myData_ordered = load('R0326_20200228a_myData.mat'); % Will make the names of the variables more consistent for scripts. Using this for now for ease of troubleshooting.
myData_ordered = myData_ordered.myData2;

figure;

time = linspace(-2,2,2001); % time (x-axis)
Fs = 500;
 % frequency (y-axis); writing it this way allows for the high frequencies to actually plot correctly

naming_convention; % This script pulls out the probe site names in order of dorsal to ventral for plot caption generation. 
% This script checks ratID and matches to the specific probe_type.

num_rows = size(myData_ordered, 1);
num_points = size(myData_ordered,2); % don't think this is needed on this script.

% Plot the data
LFPs_per_shank = num_rows / 8;   % will be 8 for 64 channels, 7 for 56 channels (diff)
for i_row = 1 : num_rows
   [cfs_mean,f] = cwt(myData_ordered(i_row, :), 'amor', Fs); % the data I used was averaged BEFORE calculating the cwt. CWT does not like 3D matrices (only likes vectors)
   % Working on creating a 2D array to calculate the CWT then average (need
   % to verify which lines of data match which probe site).
     
    plot_col = ceil(i_row / LFPs_per_shank);
    plot_row = i_row - LFPs_per_shank * (plot_col-1);
    plot_num = (plot_row-1) * 8 + plot_col;
    
    subplot(LFPs_per_shank,8,plot_num);
    
    f = flip(linspace(0,60,81))'; % yaxis
    
    surface_plot = surface(time,f,abs(cfs_mean));
    % set(gca,'xlim', x_lim, 'ylim',y_lim); %example line for setting xlim
    % and ylim; use clim for surface/heat plots
    axis tight
    shading flat
    grid on
    caption = sprintf('NNsite #%d', NNsite_order(i_row)); % using naming_convention for monopolar plot captions (naming_convention_diffs for diffs plot). 
    % Need to rewrite caption to specify title for each probe_type (NN vs Cambridge)
    title(caption, 'FontSize', 8); % This creates a title on each plot. Need to create a general overal title with session ID, trial type (correctGo) and trial ID (cueOn, NoseIn)
    set(gca,'yscale','linear');
    
    if plot_row < LFPs_per_shank
        set(gca,'xticklabels',[])
    end
    
    if plot_col > 1
        set(gca,'yticklabels',[])
    end
end
end