function [phase_corr,phase_p] = phase_behavior_correlations(phase_data,behavior_data)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% phase_data: m x n array where m is the number of trials and n is the
%   number of time-frequency points
arguments (Input)
    phase_data
    behavior_data
end

arguments (Output)
    phase_corr
    phase_p
end

n_points = size(phase_data, 2);
phase_corr = zeros(n_points, 1);
phase_p = zeros(n_points, 1);

for i_t = 1 : n_points

    [phase_corr(i_t), phase_p(i_t)] = circ_corrcl(phase_data(:, i_t), behavior_data);

end
end