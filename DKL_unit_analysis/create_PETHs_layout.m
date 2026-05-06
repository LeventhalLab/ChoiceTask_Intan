function [h_fig, t] = create_PETHs_layout(m, n)
arguments
    m (1,1) uint8 = 8
    n (1,1) uint8 = 7
end

h_fig = figure('units', 'inches', 'position', [1 1 11 8.5]);

t = tiledlayout(8, 7);

end