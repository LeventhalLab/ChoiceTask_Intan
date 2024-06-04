% try plotting channel 1 of a lfp_NNsite file for the first correctgo trial for eventFieldnames cueOn and centerIn of the data
% trialRanges_final(1:2,1); - [row, column]
t_win = [0 3600];
Fs = 500;

ts = 10;
sample_limits = (ts + t_win) * Fs;
lfp_to_plot = lfp_NNsite_order(:, round(sample_limits(1):sample_limits(2))); % used the round feature because the error "integer operands are required
% for colon operator when used as an index" came up. Round seemed like a solid fix?

rows = size(lfp_to_plot, 1);
t = linspace(t_win(1), t_win(2), size(lfp_to_plot, 2));
y_lim = [-5000,5000];

h = figure;

shank_num = 2;
for i_row = 1 : 1
    subplot(1,1,i_row);
    lfp_row = (shank_num - 1) * 8 + i_row + 1;
    plot(t, lfp_to_plot(lfp_row, :));
    set(gca,'xlim', t_win, 'ylim',y_lim);
    set(gcf, 'PaperOrientation', 'landscape', 'Position',[100 100 650 650])
    grid on
    caption = sprintf('NNsite #%d', lfp_row); % input mapping file so its in the correct NNsite order (check mapping)
    title(caption, 'FontSize', 15);
    % save file here as a pdf (print?)
    %saveas(gcf, 'R0372_lfp_NNsite_single_row', 'pdf')
    % use sprintf to save based on file names
end
%save file here as a pdf (print?)
saveas(h, 'R0372_lfp_NNsite_single_channel_all_LFP', 'pdf');
close(h);