function plot_diff = plot_diff_power_single_plot_NNsite(power_lfps_diff_fname, valid_sites_reordered)

% INPUTS
%       diff_fname - filename of the file to plot

% OUTPUTS
%       power_lfps_diff - m x n array of differentials
%       f - 
%       Fs - sampling frequency

power_lfps_diff = load(power_lfps_diff_fname);
f = power_lfps_diff.f;
Fs = power_lfps_diff.Fs;
power_lfps_diff = power_lfps_diff.power_lfps_diff;

naming_convention_diffs_NNsite; % This needs to be changed based on probe type
% Shouldn't we have a line about probe_site_mapping somewhere here? Or how
% does the code below account  for probe site mapping?

figure;
% plot(f, 10*log10(power_lfps(:,1)))

t_win = [0 3600];
Fs = 500;

ts = 10;
sample_limits = (ts + t_win) * Fs;
% lfp_to_plot = power_lfps(:, round(sample_limits(1):sample_limits(2))); % used the round feature because the error "integer operands are required
% for colon operator when used as an index" came up. Round seemed like a solid fix?

num_rows = size(power_lfps_diff, 1);
num_points = size(power_lfps_diff,2);
% t = linspace(t_win(1), t_win(2), size(power_lfps_diff, 2));
 y_lim = [0 100];
 x_lim = [0 100];

% Plot the data
LFPs_per_shank = num_rows / 8;   % will be 8 for 64 channels, 7 for 56 channels (diff)
for i_row = 1 : num_rows

    plot_col = ceil(i_row / LFPs_per_shank);
    plot_row = i_row - LFPs_per_shank * (plot_col-1);
    plot_num = (plot_row-1) * 8 + plot_col;
    
    subplot(LFPs_per_shank,8,plot_num);
    plot_diff = plot(f, 10*log10(power_lfps_diff(i_row, :))); % change to log10 -- plot(f, 10*log10(power_lfps(:,1)))
    set(gca,'xlim', x_lim, 'ylim',y_lim);
    grid on

    ax = gca;
    % This section is coded to color the axes of
    % the plots when checking the amplifier.dat
    % files 'by eye' using Neuroscope
    switch valid_sites_reordered(i_row)   % make sure is_valid_lfp is a boolean with true if it's a good channel; make sure this is in the same order as channel_lfps
        case 0
            ax.XColor = 'r'; % Red % marks bad channels within specified trial
            ax.YColor = 'r'; % Red
            % ax.ylabel = 'k';
        case 1
            ax.XColor = 'k'; % black % marks good channels within specified trial
            ax.YColor = 'k'; % black
            % ax.ylabel = 'k';
        case 2
            ax.XColor = 'b'; % blue % marks channels as 'variable' and could be good for portions of the whole amplifier.dat file but bad for others. Thus some channels may be good for only some trials, not all.
            ax.YColor = 'b';
            % ax.ylabel = 'k';
        otherwise
            ax.XColor = 'b'; % blue % catch in case the data was not input into the structure
            ax.YColor = 'b';
            %  ax.ylabel = 'k';
    end

    caption = sprintf('Diff #%d', NNsite_order_diffs(i_row)); % This names the channels 1 - 64; need to rename this section ...
    % so it names each one according to the actual NNsite mapping
    title(caption, 'FontSize', 8);
    %nexttile(p);
    
    if plot_row < LFPs_per_shank
        set(gca,'xticklabels',[])
    end
    
    if plot_col > 1
        set(gca,'yticklabels',[])
    end
        
end
