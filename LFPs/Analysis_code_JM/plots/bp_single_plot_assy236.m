%   bp single plot assy236
% ZH 6/26/2024

%Makes bipolar power plots for each channel
% axes color coded based on good/bad and titles color coded based on region


% made by adjusting flattened_mp_single_plot_nn8x8 as a reference
    %flattned
    %bipolar instead of monopolar
    %  good/bad channel color coding
    % region labeling and color coding

    %calls the function getChannelRegionLabel for regions and title color

function plot_bipolar = bp_single_plot_assy236(power_lfps_diff_fname, valid_sites_reordered)

% INPUTS
%       monopolar_fname - filename of the file to plot
%       valid_sites_reordered - m x n array of sites that were marked good,
%               bad or check data based on Neuroscope file 
%               (loaded in from fname =
%               'X:\Neuro-Leventhal\data\ChoiceTask\Probe Histology Summary\Rat_Information_channels_to_discard.xlsx')


% OUTPUTS
%       power_lfps - m x n array of monopolar power
%       f - 
%       Fs - sampling frequency

power_lfps_diff = load(power_lfps_diff_fname);
% f = power_lfps.f;
% Fs = power_lfps.Fs;
% power_lfps = power_lfps.power_lfps;

f = power_lfps_diff.f;
Fs = power_lfps_diff.Fs;
power_lfps_diff = power_lfps_diff.power_lfps_diff;

naming_convention; %  This needs to be changed based on probe type
% Shouldn't we have a line about probe_site_mapping somewhere here? Or how
% does the code below account  for probe site mapping?

figure;
% plot(f, 10*log10(power_lfps(:,1)))

% edit the following to match line 7 but in subplotting format
t_win = [0 3600];
%Fs = 500;
ts = 10;
sample_limits = (ts + t_win) * Fs;
% lfp_to_plot = power_lfps(:, round(sample_limits(1):sample_limits(2))); % used the round feature because the error "integer operands are required
% for colon operator when used as an index" came up. Round seemed like a solid fix?

num_rows = size(power_lfps_diff, 1);
num_points = size(power_lfps_diff,2);
% t = linspace(t_win(1), t_win(2), size(power_lfps, 2));
 y_lim = [-10 10];
 x_lim = [0 65];
  

% Plot the data
LFPs_per_shank = num_rows / 4;   % will be 8 for 64 channels, 7 for 56 channels (diff)
for i_row = 1 : num_rows %num rows is 64
     plot_col = ceil(i_row / LFPs_per_shank); 
    plot_row = i_row - LFPs_per_shank * (plot_col-1);
    plot_num = (plot_row-1) * 4 + plot_col; 
    
    %8 by 8 grid with the bottom row empty
    subplot(LFPs_per_shank,4,plot_num);
    
     % Flatten the spectrum while preserving peaks
    % Assuming a simple method of flattening by subtracting the 1/f trend
    % Log-transform the spectrum for flattening estimation
    log_spectrum = log10(power_lfps_diff(i_row, :));
    log_f = log10(f);
    
    % Fit a linear model to estimate the 1/f trend
    p = polyfit(log_f, log_spectrum, 1);
    trend = polyval(p, log_f);
    
    % Subtract the trend to flatten the spectrum
    flattened_log_spectrum = log_spectrum - trend;
    flattened_spectrum = 10 .^ flattened_log_spectrum;

    % Plot the flattened spectrum (log scale)
    plot_bipolar=plot(f, 10*log10(flattened_spectrum), 'LineWidth', 1.5);
   
    grid on
    set(gca,"XLim",x_lim,"YLim",y_lim);
    ax = gca;
    %taller
    ax.Position(4) = 1.3*ax.Position(4);

    % This section is coded to color the axes of
    % the plots when checking the amplifier.dat
    % files 'by eye' using Neuroscope


        %converts the row numbers for the diff power back to standard row
    %values that make sense with the excel file
    i_row_adj= i_row + plot_col - 1;
    %if both channels involved are good --> black
    if valid_sites_reordered(i_row_adj)==2 && valid_sites_reordered(i_row_adj+1)==2
        ax.XColor = 'k';
        ax.YColor = 'k';
        %if the top channel is bad --> pink
    elseif valid_sites_reordered(i_row_adj)==1
        ax.XColor = 'm';
        ax.YColor = 'm';
%if the bottom channel is bad --> pink
    elseif valid_sites_reordered(i_row_adj+1)==1
        ax.XColor = 'm';
        ax.YColor = 'm';
%anything else --> blue
    else
        ax.XColor = 'b';
        ax.YColor = 'b';
    end


    probe_type = 'assy236';
    [intan_num, channel_num] = intan_and_channel_site_order(probe_type);
    site_num_top=intan_num(i_row_adj);
    site_num_bot=intan_num(i_row_adj+1);
    ratID = power_lfps_diff_fname(36:40);
    [region_top,color_top] = getChannelRegionLabel(ratID, site_num_top);
    [region_bot,color_bot] = getChannelRegionLabel(ratID, site_num_bot);

    % if both channels are in the same region, save the color
if color_top == color_bot
    color = color_top;
    % otherwise the bipolar calculation occurs over a border : set color to black "k"
else
    color = "k";
end

    % s: is site number , in: is intan number 1 scaled, and the last few
    % letters is an abreviation for the brain region
    
    %temporary title to help me figure out what going on
  %  caption = sprintf('i_row-i_row+1: %d-%d, plot:%d, in:%d-%d(1)',i_row,i_row+1,plot_num,intan_num(i_row),intan_num(i_row+1));
  %  title(caption, 'FontSize', 7,'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');


    %temporarily commenting this out while debugging
    caption = sprintf('assy236 s:%d-%d in:%d-%d(1) %s-%s', channel_num(i_row_adj),channel_num(i_row_adj+1),intan_num(i_row_adj),intan_num(i_row_adj+1),region_top,region_bot); % Make a catch so this doesn't need to be edited every graph
    title(caption, 'FontSize', 7,'HorizontalAlignment', 'center', 'VerticalAlignment', 'top','Color',color);
  
    if plot_row < LFPs_per_shank
        set(gca,'xticklabels',[])
    end
    
    if plot_col > 1
        set(gca,'yticklabels',[])
    end
        
end
