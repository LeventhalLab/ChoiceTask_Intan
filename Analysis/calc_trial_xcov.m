function [ mean_xcorr ] = calc_trial_xcov( s, trialTimes, filtLFP, Fs, twin )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
% s - spike density estimate

sampWin = round(twin * Fs);
% numSamps = range(sampWin) + 1;
% mean_xcorr = zeros(1, numSamps);

if size(s,2) == length(s); s = s'; end
if size(filtLFP,2) == length(filtLFP); filtLFP = filtLFP'; end

num_valid_ts = 0;
for i_ts = 1 : length(trialTimes)

    centerSamp = round(trialTimes(i_ts) * Fs);
    if centerSamp < (1-sampWin(1)) || centerSamp > length(filtLFP) - sampWin(2)
        continue;
    end
    num_valid_ts = num_valid_ts + 1;
    sampRange = centerSamp + sampWin;
    curr_s = s(sampRange(1):sampRange(2));
    curr_LFP = filtLFP(sampRange(1):sampRange(2));
    curr_xcorr = xcov(curr_s, curr_LFP,'coeff'); 
    startSamp = round(length(curr_s)/2);
    endSamp = startSamp + length(curr_s) - 1;
    all_xcorr(num_valid_ts,:) = curr_xcorr(startSamp:endSamp);
%     STA = STA + lfp(sampRange(1):sampRange(2));
    
end

mean_xcorr = nanmean(all_xcorr,1);

