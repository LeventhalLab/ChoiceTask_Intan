% fxn to plot '*_monopolar_power.mat' files by shank
% lfp_NNsite_order, NNsite_order = lfp_by_probe_site(lfp_fname, probe_type);
% [power_lfps, f] = extract_power(LFP,Fs);

function plot_monopolar = plot_monopolar_power_single_plot_NNsite(power_lfps_fname, valid_sites_reordered)

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
Fs = 500;

ts = 10;
sample_limits = (ts + t_win) * Fs;
% lfp_to_plot = power_lfps(:, round(sample_limits(1):sample_limits(2))); % used the round feature because the error "integer operands are required
% for colon operator when used as an index" came up. Round seemed like a solid fix?

num_rows = size(power_lfps, 1);
num_points = size(power_lfps,2);
% t = linspace(t_win(1), t_win(2), size(power_lfps, 2));
 y_lim = [0 100];
 x_lim = [0 100];

% Plot the data
LFPs_per_shank = num_rows / 8;   % will be 8 for 64 channels, 7 for 56 channels (diff)
for i_row = 1 : num_rows

    plot_col = ceil(i_row / LFPs_per_shank);
    plot_row = i_row - LFPs_per_shank * (plot_col-1);
    plot_num = (plot_row-1) * 8 + plot_col;
    
    subplot(LFPs_per_shank,8,plot_num);

    plot_monopolar = plot(f, 10*log10(power_lfps(i_row, :))); % change to log10 -- plot(f, 10*log10(power_lfps(:,1)))
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

    caption = sprintf('NNsite #%d', NNsite_order(i_row)); % using naming_convention for monopolar plot captions (naming_convention_diffs for diffs plot)
    title(caption, 'FontSize', 8);
    
    if plot_row < LFPs_per_shank
        set(gca,'xticklabels',[])
    end
    
    if plot_col > 1
        set(gca,'yticklabels',[])
    end
        
end
