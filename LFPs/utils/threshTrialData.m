function keepTrials = threshTrialData(data,zThresh)
fractionOfTrial = 0.95;
if size(data,1) == 7
    data = reshape(data,[7 * size(data,2),size(data,3)]);
end

keepTrials = [];
zmean = mean(mean(data));
zstd = mean(std(data));
for iTrial = 1:size(data,2)
    ztrial = (data(:,iTrial) - zmean) ./ zstd;
    % z-scored data is less than z-thresh for at least fractionOfTrial
    if sum(ztrial < zThresh) / numel(ztrial) > fractionOfTrial
        keepTrials = [keepTrials;iTrial];
    end
end