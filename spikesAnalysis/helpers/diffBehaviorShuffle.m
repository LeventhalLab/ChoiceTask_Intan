function [p_values,shuffle_diffs] = diffBehaviorShuffle(psthDiffReal,behaviorAts,behaviorBts,n_shuffles,binSize,spikeTimes,window)

%compare two behavior types based on the difference of their psthHz values

tsAll=[behaviorAts;behaviorBts];
behA=length(behaviorAts);
n_samples=size(psthDiffReal,2);

shuffle_diffs = nan(n_shuffles, n_samples);
maxCombinations=nchoosek(length(tsAll),behA);
if maxCombinations<100
    p_values=[];
    shuffle_diffs=[];
    disp('Unable to shuffle')
    return

end
disp('Shuffling unit behaviors')
tic
for i_shuffle = 1 : n_shuffles

    shuffle_idx = randperm(length(tsAll), behA);
    shuffle_bool = false(length(tsAll),1);
    shuffle_bool(shuffle_idx) = true;
    surrA=tsAll(shuffle_bool);
    surrB=tsAll(~shuffle_bool);
    
    [ ~, ~, psthHzA, ~, ~, ~]=psthRasterAndCountsFORSHUFFLEONLY(spikeTimes', surrA, window, binSize);
    [ ~, ~, psthHzB, ~, ~, ~]=psthRasterAndCountsFORSHUFFLEONLY(spikeTimes', surrB, window, binSize);
    shuffle_diffs(i_shuffle, :) = psthHzA - psthHzB;

end
disp('shuffling took')
toc
diffs_bool = false(n_shuffles, n_samples);
p_values = zeros(1, n_samples);
for i_samp = 1 : n_samples
    diffs_bool(:, i_samp) = shuffle_diffs(:, i_samp) > psthDiffReal (i_samp);
end
n_outliers = sum(diffs_bool, 1);
p_values = n_outliers / n_shuffles;
p_values(p_values > 0.5) = 1 - p_values(p_values > 0.5);
end