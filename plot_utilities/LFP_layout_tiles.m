function [h_fig, h_axes, t] = LFP_layout_tiles(nrows, ncols, title_text)
% 
% INPUTS:
%   nrows - number of rows to plot
%
% OUTPUTS:
%

top_margin = 0.5;
bot_margin = 0.5;
l_margin = 0.5;
r_margin = 0.5;

fig_w = 11;
fig_h = 8.5;

tile_h = fig_h - (top_margin + bot_margin);
tile_bot = bot_margin;
tile_w = fig_w - (l_margin + r_margin);
tile_left = l_margin;

h_fig = figure('units', ...
    'inches','position',[1,1,fig_w,fig_h]);

t = tiledlayout(nrows, ncols, ...
    Units="inches",...
    TileSpacing="tight", ...
    Padding="compact", ...
    TileIndexing="rowmajor", ...
    OuterPosition=[tile_left,tile_bot,tile_w,tile_h], ...
    PositionConstraint="outerposition");

for i_row = 1 : nrows
    for i_col = 1 : 3
        if i_col == 1
            ax = nexttile([1, ncols-2]);
        else
            ax = nexttile;
        end
        h_axes(i_row, i_col) = ax;
%         imagesc(rand(20))
        if i_col > 1
            yticklabels([])
        end
        if i_row < nrows
            xticklabels([])
        end
    end
end

title(t, title_text, 'interpreter', 'none')
  % set interpreter to none?