function surface_plot = plot_scalogram_single_plot_Files(sessionScalos)
%       monopolar_fname - filename of the file to plot
% INPUTS
%   event_triggered_lfps - squeezed data

% OUTPUTS
%       cfs_mean - m x n array of monopolar power
%       f - 

figure;

time = linspace(-2,2,2001); % time (x-axis)
Fs = 500;
 % frequency (y-axis); writing it this way allows for the high frequencies to actually plot correctly

naming_convention; % This script pulls out the probe site names in order of dorsal to ventral for plot caption generation. 
% This script checks ratID and matches to the specific probe_type.

num_rows = size(sessionScalos, 1);
num_points = size(sessionScalos,2); % don't think this is needed on this script.

% Plot the data
LFPs_per_shank = num_rows / 8;   % will be 8 for 64 channels, 7 for 56 channels (diff)
for i_row = 1 : num_rows
   [cfs_mean,f] = cwt(sessionScalos(i_row, :), 'amor', Fs); % the data I used was averaged BEFORE calculating the cwt. CWT does not like 3D matrices (only likes vectors)
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