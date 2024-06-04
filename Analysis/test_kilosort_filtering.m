%%
% navigate to the folder containing rhd and amplifier files before running this
% 


fshigh = 300;

rhd_info = read_Intan_RHD2000_file_DL('info.rhd');
Fs = rhd_info.frequency_parameters.amplifier_sample_rate;

t_limits = [0, 100];
[amplifier_data] = readIntanAmplifierData('amplifier.dat', t_limits(1), t_limits(2), Fs, rhd_info.amplifier_channels,true);

t = linspace(t_limits(1), t_limits(2), size(amplifier_data, 2));

% kilosort filter
[b1, a1] = butter(3, fshigh/Fs*2, 'high');
b_fir = fir1(1000, fshigh/Fs*2,'high');


mean_subt = amplifier_data - mean(amplifier_data, 2);
ks_filt = filter(b1, a1, mean_subt');
ks_filt = flipud(ks_filt);
ks_filt = filter(b1, a1, ks_filt);
ks_filt = flipud(ks_filt);

ks_filt_CAR = ks_filt - median(ks_filt, 2);

fir_filt = filter(b_fir, 1, amplifier_data');
fir_filt = flipud(fir_filt);
fir_filt = filter(b_fir, 1, fir_filt);
fir_filt = flipud(fir_filt);

%% plot raw data in blue, fir filtered data in red, ks filter algorithm (including common average referencing) in yellow
line_num = 1;   % change this to make sure different lines are different
figure(1)
hold off
plot(t, amplifier_data(line_num,:))
hold on
plot(t, fir_filt(:,line_num))
plot(t, ks_filt_CAR(:,line_num))
% plot(t, fir_filt)

%%
figure(3)
plot(t, amplifier_data(line_num, :))
hold on
plot(t, amplifier_data(line_num+1, :))