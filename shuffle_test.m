% m = total trials
% n = samples per trial
% p = number of trials of type A (e.g., move left, correct, etc)

function p_values = shuffle_test(data, A_labels)
%
% INPUTS
%   data - m x n matris
%   A_labels - boolean vector for which rows of data are type A trials

m = size(data, 1);
n_samples = size(data, 2);
p = length(A_labels);

n_shuffles = 1000;


true_mean_diff = mean(data(A_trials_bool, 1)) - mean(data(~A_trials_bool, 1));
shuffle_diffs = np.nan(n_shuffles, n_samples);
for i_shuffle = 1 : n_shuffles

    shuffle_idx = randperm(m, p);
    shuffle_bool = false(p, 1);
    shuffle_bool(shuffle_idx) = true;
    shuffle_diffs(i_shuffle, :) = mean(data(shuffle_bool, :)) - mean(data(~shuffle_bool, :));

end

diffs_bool = false(n_shuffles, n_samples);
p_values = zeros(1, n_samples);
for i_samp = 1 : n_samples
    diffs_bool = shuffle_diffs(:, i_samp) > true_mean_diff (i_samp);
end
n_outliers = sum(diffs_bool, 1);
p_values = n_outliers / n_shuffles;
p_values(p_values > 0.5) = 1 - p_values(p_values > 0.5);