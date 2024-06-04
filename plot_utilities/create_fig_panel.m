function [fig, t] = create_fig_panel(nrows, ncols, orientation)

fig = figure(units='inches', position=[1,1,11,8.5]);
t = tiledlayout(nrows, ncols, TileSpacing='compact');
t.Padding = 'compact';

% ax = zeros(nrows, ncols);
% for i_col = 1 : ncols
%     for i_row = 1 : nrows
%         ax(i_col, i_row) = axes(t);
% 
%         tile
%         ax(i_col, i_row).Layout.Tile = 
%     end
% end
