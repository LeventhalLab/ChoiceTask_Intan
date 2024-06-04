function [outputArg1,outputArg2] = create_scalogram_map(session_name,event_name,lfp_type,parent_directory)
%UNTITLED Summary of this function goes here
%   function to create a map of scalograms for a specific event across all
%   channels

scalo_folder = create_scalo_folder(session_name, event_name, parent_directory);

h_fig = figure('papertype','usletter',...
    'PaperOrientation','landscape', ...
    'units', 'inches',...
    'position',[0 0 11 8.5]);
fig_title = sprintf('%s, %s, %s', session_name, event_name, lfp_type);

num_cols = 8;    % may need to change for the Cambridge probes
switch lfp_type
    case 'monopolar'
        num_rows = 8;
        fname_append = '';
    case 'bipolar'
        num_rows = 7;
        fname_append = 'bipolar';
end
t_layout = tiledlayout(num_rows, 8, 'tilespacing','tight');

for ii = 1 : 64
    shank_num = ceil(ii/num_rows);
    site_num = ii - (shank_num-1) * num_rows;

    scalo_name = sprintf('%s_scalos_%s_shank%02d_site%02d.mat',session_name, event_name, shank_num, site_num);
    scalo_name = fullfile(scalo_folder, scalo_name);

    load(scalo_name)
% %     f = centerFrequencies(fb);
% 
    mean_scalo = squeeze(mean(log(abs(event_related_scalos)), 1));

    tile_num = (site_num-1) * num_cols + shank_num;
    ax = nexttile(tile_num);
    display_scalogram(mean_scalo, t_window, fb, 'ax', ax);
%     plot(sin(site_num*(1:10)))
    if shank_num > 1
        set(gca,'yticklabel','')
    end
    if site_num < num_rows
        set(gca,'XTickLabel','')
    end
end

title(t_layout, fig_title, 'interpreter', 'none')
xlabel(t_layout, 'time (s)')
ylabel(t_layout, 'frequency (Hz)')

savename = sprintf('%s_%s_%s_meanlogpower.pdf', session_name, event_name, lfp_type);
fig_savename = sprintf('%s_%s_%s_meanlogpower.fig', session_name, event_name, lfp_type);
savename = fullfile(scalo_folder, savename);
fig_savename = fullfile(scalo_folder, fig_savename);

print(savename, '-dpdf')
savefig(h_fig, fig_savename, 'compact')

close(h_fig)

end