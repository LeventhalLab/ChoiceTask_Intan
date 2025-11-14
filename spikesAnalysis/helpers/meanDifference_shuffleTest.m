function [p_value, shuffle_diffs] = meanDifference_shuffleTest(control, test, n_shuffles)
%  shuffle test comparing difference in means bewteen a test &
%
% Inputs:
%   meanFR_control - vector of mean firing rates (control)
%   meanFR_lesion  - vector of mean firing rates (lesion)
%   n_shuffles     - number of shuffles (e.g., 10000)
%
% Outputs:
%   p_value        - permutation test p-value (two-tailed)
%   shuffle_diffs  - distribution of shuffled mean differences

    % Combine data
    try
        all = [control, test];
    catch ME
        all = [control; test];
    end
    nControl = numel(control);
    nTotal = numel(all);

    % Observed difference in means
    realDiff = mean(control) - mean(test);

    % Preallocate
    shuffle_diffs = nan(1, n_shuffles);

    % --- Run Shuffles ---
    for i_shuffle = 1:n_shuffles
        shuffle_idx = randperm(nTotal, nControl);
        shuffle_bool = false(1, nTotal);
        shuffle_bool(shuffle_idx) = true;

        % Assign groups
        shuffled_control = all(shuffle_bool);
        shuffled_test = all(~shuffle_bool);

        % Compute shuffled difference
        shuffle_diffs(i_shuffle) = mean(shuffled_control) - mean(shuffled_test);
    end

    % --- Compute p-value (two-sided) ---
    n_extreme = sum((shuffle_diffs) > (realDiff));
    p_value = n_extreme / n_shuffles;

    % Optional: symmetry correction like your other code
    if p_value > 0.5
        p_value = 1 - p_value;
    end

    % Bias-corrected safeguard (avoid p = 0)
    p_value = max(p_value, 1 / (n_shuffles + 1));
end
