function [outputArg1,outputArg2] = display_scalogram(scalo, t_window, fb, varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

cmap = 'jet';
h_ax = 0;
c_lim = [0, 0];

f_ticks = [1, 10, 20, 50, 100];

for i_arg = 4 : 2 : nargin - 1
    switch lower(varargin{iarg})
        case 'colormap'
            cmap = varargin{iarg + 1};
        case 'ax'
            h_ax = varargin{iarg + 1};
        case 'fticks'
            f_ticks = varargin{iarg + 1};
        case 'clim'
            c_lim = varargin{iarg + 1};
    end
end

if h_ax == 0
    figure;
    h_ax = gca;
end

num_samples = size(scalo, 2);

t = linspace(t_window(1), t_window(2), num_samples);
f = centerFrequencies(fb);

axes(h_ax)

surface(t, f, scalo);

axis tight
shading flat

if any(c_lim ~= 0)
    set(gca,'clim',c_lim)
end
set(gca,'ytick',f_ticks);
set(gca,'yscale','log')

colormap(cmap)
end