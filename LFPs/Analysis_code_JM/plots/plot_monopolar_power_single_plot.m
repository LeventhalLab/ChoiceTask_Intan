% fxn to plot '*_monopolar_power.mat' files by shank
% lfp_NNsite_order, NNsite_order = lfp_by_probe_site(lfp_fname, probe_type);
% [power_lfps, f] = extract_power(LFP,Fs);

function plot_monopolar = plot_monopolar_power_single_plot(power_lfps_fname)

% INPUTS
%       monopolar_fname - filename of the file to plot

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
    % caption = sprintf('ASSY236 #%d', ASSY236_order(i_row)); % Make a catch so this doesn't need to be edited every graph
    caption = sprintf('NNsite #%d', NNsite_order(i_row)); % using naming_convention for monopolar plot captions (naming_convention_diffs for diffs plot)
    title(caption, 'FontSize', 8);
    
    if plot_row < LFPs_per_shank
        set(gca,'xticklabels',[])
    end
    
    if plot_col > 1
        set(gca,'yticklabels',[])
    end
        
end
