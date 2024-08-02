% flattened mp single plot assy236
% ZH

% like flattened mp single plot nn8x8 but adjusted for assy 156


function plot_monopolar_flattened = flattened_mp_single_plot_assy236(power_lfps_fname, valid_sites_reordered)

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

power_lfps = load(power_lfps_fname);
% f = power_lfps.f;
% Fs = power_lfps.Fs;
% power_lfps = power_lfps.power_lfps;

f = power_lfps.f;
Fs = power_lfps.Fs;
power_lfps = power_lfps.power_lfps;

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

num_rows = size(power_lfps, 1);
num_points = size(power_lfps,2);
% t = linspace(t_win(1), t_win(2), size(power_lfps, 2));
 y_lim = [-20 20];
 x_lim = [0 65];
  

% Plot the data
LFPs_per_shank = num_rows / 4;   % will be 8 for 64 channels, 7 for 56 channels (diff)
for i_row = 1 : num_rows

    plot_col = ceil(i_row / LFPs_per_shank);
    plot_row = i_row - LFPs_per_shank * (plot_col-1);
    plot_num = (plot_row-1) * 4 + plot_col;
    
    subplot(LFPs_per_shank,4,plot_num);
    
    %original unflattened plot
    %plot_monopolar = plot(f, 10*log10(power_lfps(i_row, :))); 

%
    % Original unflattened plot (log scale)
   % plot_monopolar_orig=plot(f, 10*log10(power_lfps(i_row, :)), 'Color', 'k', 'LineWidth', 1.5); 
   % hold on;

    % Flatten the spectrum while preserving peaks
    % Assuming a simple method of flattening by subtracting the 1/f trend
    % Log-transform the spectrum for flattening estimation
    log_spectrum = log10(power_lfps(i_row, :));
    log_f = log10(f);
    
    % Fit a linear model to estimate the 1/f trend
    p = polyfit(log_f, log_spectrum, 1);
    trend = polyval(p, log_f);
    
    % Subtract the trend to flatten the spectrum
    flattened_log_spectrum = log_spectrum - trend;
    flattened_spectrum = 10 .^ flattened_log_spectrum;

    % Plot the flattened spectrum (log scale)
    plot_monopolar_flattened=plot(f, 10*log10(flattened_spectrum), 'LineWidth', 1.5);
%
     % Set plot limits and grid (in log scale)
   
    grid on
    set(gca,"XLim",x_lim,"YLim",y_lim);
    ax = gca;
    %taller
    ax.Position(4) = 1.3*ax.Position(4);

    % This section is coded to color the axes of
    % the plots when checking the amplifier.dat
    % files 'by eye' using Neuroscope
    switch valid_sites_reordered(i_row)   % make sure is_valid_lfp is a boolean with true if it's a good channel; make sure this is in the same order as channel_lfps
        case 0
             ax.XColor = 'b'; % blue % marks bad channels within specified trial
            ax.YColor = 'b'; % blue
            % ax.ylabel = 'k';
        case 1
            ax.XColor = 'm'; % magenta % marks good channels within specified trial
            ax.YColor = 'm'; % magenta
            % ax.ylabel = 'k';
        case 2
            ax.XColor = 'k'; % black % marks channels as 'variable' and could be good for portions of the whole amplifier.dat file but bad for others. Thus some channels may be good for only some trials, not all.
            ax.YColor = 'k';
            % ax.ylabel = 'k';
        otherwise
            ax.XColor = 'b'; % blue % catch in case the data was not input into the structure
            ax.YColor = 'b';
            %  ax.ylabel = 'k';
    end

    probe_type = 'ASSY236';
    [intan_num, channel_num] = intan_and_channel_site_order(probe_type);
    site_num=channel_num(i_row);
    ratID = power_lfps_fname(36:40);
     [channel_region_label,color] = getChannelRegionLabel(ratID, site_num);
    % s: is site number , in: is intan number 1 scaled, and the last few
    % letters is an abreviation for the brain region
    caption = sprintf('ASSY236 s:%d in:%d (1) %s', site_num,intan_num(i_row),channel_region_label); % Make a catch so this doesn't need to be edited every graph
  title(caption, 'FontSize', 8,'HorizontalAlignment', 'center', 'VerticalAlignment', 'top','Color',color);
  
    if plot_row < LFPs_per_shank
        set(gca,'xticklabels',[])
    end
    
    if plot_col > 1
        set(gca,'yticklabels',[])
    end
        
end
