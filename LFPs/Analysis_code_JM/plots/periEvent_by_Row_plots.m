% This file plots all 8 channels in an NN8x8 probe in a single graph with
% each channel as its own row. (e.g. sites 1 - 8 as a single column)

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
t = linspace(t_win(1), t_win(2), size(power_lfps, 2));
 y_lim = [0 1500];
 x_lim = [0 100];

shank_num = 3;
for i_row = 1 : 8
    subplot(8,1,i_row);
    lfp_row = (shank_num - 1) * 8 + i_row;
    plot(f, power_lfps(lfp_row, :));
    set(gca,'xlim', x_lim, 'ylim',y_lim);
    grid on
    caption = sprintf('NNsite #%d', NNsite_order(i_row)); % input mapping file so its in the correct NNsite order (check mapping)
    title(caption, 'FontSize', 8);
end
%save file here as a pdf (print?)
% saveas(h, 'R0372_lfp_NNsite_single_row', 'pdf');
% close(h);