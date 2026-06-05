function [mean_counts,edges] = autocorrelogram(ts,bin_width,t_win)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

arguments (Input)
    ts (1, :) double
    bin_width (1,1) double = 0.050    % 50 ms default bin size
    t_win (2,1) double = [-0.5, 0.5]
end

spike_ts = ts(~isnan(ts));

[test_hist, edges] = histcounts([1,2], BinLimits=t_win, BinWidth=bin_width);
nbins = length(test_hist);
total_counts = zeros(1, nbins);
for i_spike = 1 : length(spike_ts)

    relative_ts = ts(ts ~= ts(i_spike)) - ts(i_spike);
    relative_ts = relative_ts(relative_ts > t_win(1));
    relative_ts = relative_ts(relative_ts < t_win(2));
    N = histcounts(relative_ts, edges);

    total_counts = total_counts + N;
end

mean_counts = total_counts / length(spike_ts);

end