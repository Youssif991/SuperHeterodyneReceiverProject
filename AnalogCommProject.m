% Authors : Youssef Hisham Ahmed, Youssef Mohammed Ibrahim
% Date : 4/4/2026
% Subject : Modulation schemes for various signals

clear; clc; close all;
%%Readig the files
[signal1_raw, Fs1]=audioread("C:\Users\bobyo\Downloads\Short_QuranPalestine.wav");
[signal2_raw, Fs2]=audioread("C:\Users\bobyo\Downloads\Short_BBCArabic2.wav");
%% convert stereo to mono
if size(signal1_raw, 2) == 2
    signal1 = signal1_raw(:,1) + signal1_raw(:,2);
else
    signal1 = signal1_raw;
end

if size(signal2_raw, 2) == 2
    signal2 = signal2_raw(:,1) + signal2_raw(:,2);
else
    signal2 = signal2_raw;
end

disp(['Fs1 = ', num2str(Fs1), ' Hz']);
disp(['Fs2 = ', num2str(Fs2), ' Hz']);

%% pad to equal length
len1 = length(signal1);
len2 = length(signal2);
max_len = max(len1, len2);

if len1 < max_len
    signal1 = [signal1; zeros(max_len - len1, 1)];
end
if len2 < max_len
    signal2 = [signal2; zeros(max_len - len2, 1)];
end
%% ========== PLOT SPECTRUM  ============
N_plot1 = length(signal1);

Y1_shifted = fftshift(fft(signal1));
Y2_shifted = fftshift(fft(signal2));

magnitude1_shifted = abs(Y1_shifted);
magnitude2_shifted = abs(Y2_shifted);

freq_shifted = (-N_plot1/2 : N_plot1/2 - 1) * (Fs1 / N_plot1);

figure;
plot(freq_shifted / 1000, magnitude1_shifted);
xlabel('Frequency (kHz)');
ylabel('Magnitude');
title('Spectrum of Signal 1');
grid on;
xlim([-25, 25]);
figure;
plot(freq_shifted / 1000, magnitude2_shifted);
xlabel('Frequency (kHz)');
ylabel('Magnitude');
title('Spectrum of Signal 2');
grid on;
xlim([-25, 25]);

%% As fc> FS/2 we shold upsample it
upsample_factor = 10;
signal1 = interp(signal1, upsample_factor);
signal2 = interp(signal2, upsample_factor);
Fs1 = Fs1 * upsample_factor;
Fs2 = Fs2 * upsample_factor;
disp(['New Fs1 = ', num2str(Fs1), ' Hz']);
disp(['New Fs2 = ', num2str(Fs2), ' Hz']);
% Modulation
N1 =length(signal1);
Ts= 1/Fs1;
t = (0:N1-1)' * Ts;
% MODULATION
fc = 100e3; % The frequency carrier
delta_f = 30e3; % The frequency increasing factor for each carrier frequency
fc1 = fc; % The frequency carrier for the first signal
fc2 = fc + delta_f; % For the n signal it would have fc + n delta_F
modulated1 = signal1 .* cos(2 * pi * fc1 * t);
modulated2 = signal2 .* cos(2 * pi * fc2 * t);
FDM = modulated1 + modulated2;
%% ==========PLOTTING============
Y_FDM = fft(FDM);
Y_FDM_shifted = fftshift(Y_FDM);
magnitude_FDM = abs(Y_FDM_shifted);
freq_axis = (-N1/2 : N1/2 - 1) * (Fs1 / N1);

figure;
plot(freq_axis / 1000, magnitude_FDM);
xlabel('Frequency (kHz)');
ylabel('Magnitude');
title('FDM Signal Spectrum');
grid on;
xlim([-200, 200]);
hold on;
xline(fc1/1000, 'r--', '100 kHz');
xline(fc2/1000, 'g--', '130 kHz');
xline(-fc1/1000, 'r--', '-100 kHz');
xline(-fc2/1000, 'g--', '-130 kHz');
legend('FDM', 'Station 1', 'Station 2');
%  demodulation for signal1
RF_center1 = 100e3;   
RF_bandwidth = 30e3;   
RF_Fs = Fs1; 
RF_filter1 = designfilt('bandpassfir', ...
    'PassbandFrequency1', 85000, ...
    'PassbandFrequency2', 115000, ...
    'StopbandFrequency1', 70000, ...
    'StopbandFrequency2', 130000, ...
    'PassbandRipple', 1, ...
    'StopbandAttenuation1', 60, ...    
    'StopbandAttenuation2', 60, ...     
    'SampleRate', Fs1);
RF_output1 = filter(RF_filter1, FDM);
% mixer for fisrt station
F_IF = 15e3;
F_osc1 = 100e3 + F_IF;
mixer_output1 = RF_output1 .* cos(2 * pi * F_osc1 * t);
%filtering
IF_filter1 = designfilt('bandpassfir', ...
    'PassbandFrequency1', 5000, ...
    'PassbandFrequency2', 30000, ...
    'StopbandFrequency1', 1000, ...
    'StopbandFrequency2', 40000, ...
    'PassbandRipple', 1, ...
    'StopbandAttenuation1', 60, ...     
    'StopbandAttenuation2', 60, ...     
    'SampleRate', Fs1);
IF_output1 = filter(IF_filter1, mixer_output1);
% return to baseband
baseband_mixed1 = IF_output1 .* cos(2 * pi * F_IF * t);
% Low-Pass Filter for Station 1
LPF_filter1 = designfilt('lowpassfir', ...
    'PassbandFrequency', 10000, ...
    'StopbandFrequency', 15000, ...
    'PassbandRipple', 1, ...
    'StopbandAttenuation', 60, ...
    'SampleRate', Fs1);
demodulated1 = filter(LPF_filter1, baseband_mixed1);
demodulated1 = demodulated1 - mean(demodulated1); % remove dc offset
% ========== LISTEN TO DEMODULATED SIGNAL ==========
% Downsample back
original_Fs = Fs1 / upsample_factor;
demodulated1_down = downsample(demodulated1, upsample_factor);

% Normalize to prevent clipping
demodulated1_down = demodulated1_down / max(abs(demodulated1_down));

% Play the sound
disp('Playing demodulated Station 1 (Quran Palestine)...');
pause(2);
sound(demodulated1_down, original_Fs);

% ========== PLOT SPECTRA OF EACH STAGE (Q 2) ==========
N_plot = length(FDM);
freq_plot = (-N_plot/2 : N_plot/2 - 1) * (Fs1 / N_plot);

% Spectra
Y_RF = fftshift(fft(RF_output1));
Y_IF = fftshift(fft(IF_output1));
Y_base = fftshift(fft(demodulated1));

mag_RF = abs(Y_RF);
mag_IF = abs(Y_IF);
mag_base = abs(Y_base);
% ===========Plot all three==================
figure;

subplot(3,1,1);
plot(freq_plot / 1000, mag_RF);
xlabel('Frequency (kHz)');
ylabel('Magnitude');
title('RF Stage Output (After BPF at 100 kHz)');
grid on;
xlim([-200, 200]);

subplot(3,1,2);
plot(freq_plot / 1000, mag_IF);
xlabel('Frequency (kHz)');
ylabel('Magnitude');
title('IF Stage Output (After BPF at 15 kHz)');
grid on;
xlim([-50, 50]);

subplot(3,1,3);
plot(freq_plot / 1000, mag_base);
xlabel('Frequency (kHz)');
ylabel('Magnitude');
title('Baseband Output (After LPF)');
grid on;
xlim([-25, 25]);
