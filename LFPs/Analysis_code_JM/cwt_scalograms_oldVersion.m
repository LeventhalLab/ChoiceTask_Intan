% Test code for scalograms using cwt function 
% x = event_triggered_lfps. Maybe pull out one line
[cfs,f] = cwt(test_data1,'amor',500); % Fs of data is decimated to 500 (original data acquired at 20ks

% [wt,f] = cwt(___,fs) specifies the sampling frequency, fs, in hertz, and returns the scale-to-frequency conversions f in hertz. 
        % If you do not specify a sampling frequency, cwt returns f in cycles per sample.
% image("XData",time,"YData",f,"CData",abs(cfs),"CDataMapping","scaled") % This plots the data as a scalogram - takes the absolute values of cfs from previous line
% set(gca,"YScale","log") % sets the scale
% axis tight
% xlabel("Time (Seconds)")
% ylabel("Frequency (Hz)")
% title("Scalogram of Two-Tone Signal")

figure
subplot(2,1,1)
plot(time,test_data1)
axis tight
title('Signal and Scalogram')
xlabel('Time (s)')
ylabel('Amplitude')
subplot(2,1,2)
surface(time,f1,abs(cfs))
axis tight
shading flat
xlabel('Time (s)')
ylabel('Frequency (Hz)')
set(gca,'yscale','linear')