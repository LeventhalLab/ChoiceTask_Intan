% Plot spectral density (pWelch) of all 64 channels in an NN8x8 probe in a single graph

function [power_lfps, f] = extract_power(LFP,Fs)

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

LFP = LFP';

[power_lfps, f] = pwelch(LFP,pw_samplewin,pw_overlapsamples,f,Fs, 'power');

power_lfps = power_lfps';

% save the file. use fullfile and sprintf ? % checking on code to do this %
% tried several iterations but no success yet.


end

% figure;
% plot(f, 10*log10(power_lfps(:,1)))
