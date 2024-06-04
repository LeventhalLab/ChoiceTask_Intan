% pxx = pwelch(x) returns the power spectral density (PSD) estimate, pxx, of the input signal, x, found using Welch's overlapped segment averaging estimator.
t_win = trialRanges_final(3:4,1);
Fs = 500;

ts = 10;
sample_limits = (ts + t_win) * Fs;
lfp_to_plot = lfp_NNsite_order(:, round(sample_limits(1):sample_limits(2))); % used the round feature because the error "integer operands are required
% for colon operator when used as an index" came up. Round seemed like a solid fix?

rows = size(lfp_to_plot, 1);
t = linspace(t_win(1), t_win(2), size(lfp_to_plot, 2));
y_lim = [-2000,2000];

figure;

for i_row = 1 : rows
    subplot(8,8,i_row);
    plot(t, lfp_to_plot(i_row, :));
    set(gca,'xlim', t_win, 'ylim',y_lim);
    grid on
    caption = sprintf('NNsite #%d', i_row);
    title(caption, 'FontSize', 15);
 end
