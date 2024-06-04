% Test code for scalograms using cwt function 
% x = event_triggered_lfps. Maybe pull out one line

num_rows = size(myData2, 1);
% mydata_channel_1 = myData2(1,:);

[cfs_mean,f] = cwt(myData2(1,:),'amor',500);

Fs = 500;
f = flip(linspace(0,60,81))'; % frequency (y-axis); writing it this way allows for the high frequencies to actually plot correctly
time = linspace(-2,2,2001); % time (x-axis)
% [cfs,f] = cwt(test_data1,'amor',500); % Fs of data is decimated to 500 (original data acquired at 20ks
figure
title('Signal and Scalogram')
surface(time,f,abs(cfs_mean))
axis tight
shading flat
xlabel('Time (s)')
ylabel('Frequency (Hz)')
set(gca,'yscale','linear')