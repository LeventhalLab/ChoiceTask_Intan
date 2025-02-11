function [h_fig, h_axs, t] = create_single_event_scalogram_panels(n_rows, cols_per_shank, n_shanks, varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
display_fig = 'on';
for iarg = 1 : 2 : nargin - 3
    switch lower(varargin{iarg})
        case 'visible'
            display_fig = varargin{iarg + 1};
    end
end

n_cols = cols_per_shank * n_shanks;
% can update later to maybe make the layout more geometrically realistic,
% not worth the trouble right now
figsize = [8.5, 11];   % (width, height) in inches
[h_fig, h_axs, t] = create_panels(n_rows, n_cols, figsize, 'visible', display_fig);

end


function [h_fig, h_axs, t] = create_panels(n_rows, n_cols, figsize, varargin)
display_fig = 'on';
for iarg = 1 : 2 : nargin - 3
    switch lower(varargin{iarg})
        case 'visible'
            display_fig = varargin{iarg + 1};
    end
end

top_margin = 0.5;
bot_margin = 0.25;
l_margin = 0.5;
r_margin = 0.5;

fig_w = figsize(1);
fig_h = figsize(2);

tile_h = fig_h - (top_margin + bot_margin);
tile_bot = bot_margin;
tile_w = fig_w - (l_margin + r_margin);
tile_left = l_margin;

h_fig = figure('units', ...
    'inches','position',[1,0.25,fig_w,fig_h],...
    visible=display_fig);

t = tiledlayout(n_rows, n_cols, ...
    Units="inches",...
    TileSpacing="tight", ...
    Padding="compact", ...
    TileIndexing="rowmajor", ...
    OuterPosition=[tile_left,tile_bot,tile_w,tile_h], ...
    PositionConstraint="outerposition");

for i_row = 1 : n_rows
    for i_col = 1 : n_cols
        % if i_col == 1
            tile_num = (i_row - 1) * n_cols + i_col;
            ax = nexttile(tile_num);
        % else
        %     ax = nexttile;
        % end
        h_axs(i_row, i_col) = ax;
%         imagesc(rand(20))
        if i_col > 1
            yticklabels([])
        end
        if i_row < n_rows
            xticklabels([])
        end
    end
end

end