% calculate spectral density (pWelch) to plot all 64 channels in an NN8x8 probe in a single graph

function [power_lfps, f] = extract_power(ordered_lfp,Fs)

% INPUTS
%   LFP - num_channels x num_samples array
%   Fs - sampling rate in Hz
%
% OUTPUTS
%   power_lfps - array containing power analysis

pw_twin = 4;
pw_samplewin = pw_twin * Fs;
pw_overlapsamples = round(pw_samplewin / 2);
% nfft = max(256,2^nextpow2(length(window)));

f = 1:250;

ordered_lfp = ordered_lfp';

[power_lfps, f] = pwelch(ordered_lfp,pw_samplewin,pw_overlapsamples,f,Fs, 'power');

f = f';
power_lfps = power_lfps';

end

% figure;
% plot(f, 10*log10(power_lfps(:,1)))
