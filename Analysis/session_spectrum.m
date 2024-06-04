function [p, f] = session_spectrum(lfp, Fs)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
smoothwin = 10;

[p, f] = pspectrum(lfp, Fs);
% psmooth = smoothdata(p, smoothwin);


end