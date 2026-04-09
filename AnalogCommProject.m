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
fc2 = fc + delta_f; % For the n signal it would have fc + n delta_f
Quran_Channel_Modulated = signal1 .* cos(2 * pi * fc1 * t);
BBC_Channel_Modulated = signal2 .* cos(2 * pi * fc2 * t);
FDM = Quran_Channel_Modulated + BBC_Channel_Modulated;
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
%% Demodulation

% --- 1. RF Filtering Process ---
RF_Filter_Order = 26;

% Quran Channel RF Filter (100 kHz Center)
RF_PassBand_Low_Quran_Channel = 85e3;
RF_PassBand_High_Quran_Channel = 115e3;
RF_Filter_Specs_Quran = fdesign.bandpass('N,F3dB1,F3dB2', RF_Filter_Order, RF_PassBand_Low_Quran_Channel, RF_PassBand_High_Quran_Channel, Fs1);
RF_filter_Quran_Channel = design(RF_Filter_Specs_Quran, 'butter'); 
RF_output_Quran_Channel = filter(RF_filter_Quran_Channel, FDM);

% BBC Channel RF Filter (130 kHz Center)
RF_PassBand_Low_BBC_Channel = 115e3;
RF_PassBand_High_BBC_Channel = 145e3;
RF_Filter_Specs_BBC = fdesign.bandpass('N,F3dB1,F3dB2', RF_Filter_Order, RF_PassBand_Low_BBC_Channel, RF_PassBand_High_BBC_Channel, Fs1);
RF_filter_BBC_Channel = design(RF_Filter_Specs_BBC, 'butter'); 
RF_output_BBC_Channel = filter(RF_filter_BBC_Channel, FDM);


% --- 2. Mixer Stage ---
F_IF = 15e3;
F_osc_Quran = fc1 + F_IF; % Local oscillator tuned for Quran
F_osc_BBC = fc2 + F_IF;   % Local oscillator tuned for BBC

Mixer_Output_Quran_Channel = RF_output_Quran_Channel .* cos(2 * pi * F_osc_Quran * t);
Mixer_Output_BBC_Channel = RF_output_BBC_Channel .* cos(2 * pi * F_osc_BBC * t);


% --- 3. IF Filtering Process (Shared Filter) ---
% Since both signals are now at the same 15 kHz IF, we can build the filter once and apply it to both!
IF_Filter_Order = 8;
IF_PassBand_Low = 5e3;
IF_PassBand_High = 30e3;
IF_Filter_Specs = fdesign.bandpass('N,F3dB1,F3dB2', IF_Filter_Order, IF_PassBand_Low, IF_PassBand_High, Fs1);
IF_filter = design(IF_Filter_Specs, 'butter'); 

IF_Quran_Channel = filter(IF_filter, Mixer_Output_Quran_Channel);
IF_BBC_Channel = filter(IF_filter, Mixer_Output_BBC_Channel);


% --- 4. Return to Baseband ---
baseband_mixed_Quran = IF_Quran_Channel .* cos(2 * pi * F_IF * t);
baseband_mixed_BBC = IF_BBC_Channel .* cos(2 * pi * F_IF * t);


% --- 5. Baseband Low-Pass Filtering ---
LPF_Filter_Order = 8;
LPF_Cutoff = 10e3; % 10 kHz cutoff
LPF_Specs = fdesign.lowpass('N,F3dB', LPF_Filter_Order, LPF_Cutoff, Fs1);
LPF_filter = design(LPF_Specs, 'butter');

% Demodulate Quran Channel
demodulated_Quran = filter(LPF_filter, baseband_mixed_Quran);
demodulated_Quran = demodulated_Quran - mean(demodulated_Quran); % remove dc offset

% Demodulate BBC Channel
demodulated_BBC = filter(LPF_filter, baseband_mixed_BBC);
demodulated_BBC = demodulated_BBC - mean(demodulated_BBC); % remove dc offset


%% ========== LISTEN TO DEMODULATED SIGNALS ==========
original_Fs = Fs1 / upsample_factor;

% Downsample back
demod_Quran_down = downsample(demodulated_Quran, upsample_factor);
demod_BBC_down = downsample(demodulated_BBC, upsample_factor);

% Normalize to prevent clipping
demod_Quran_down = demod_Quran_down / max(abs(demod_Quran_down));
demod_BBC_down = demod_BBC_down / max(abs(demod_BBC_down));

% Play Quran
disp('Playing demodulated Station 1 (Quran Palestine)...');
pause(1);
sound(demod_Quran_down, original_Fs);
audio_duration = length(demod_Quran_down) / original_Fs;
pause(audio_duration + 1);

% Play BBC
disp('Playing demodulated Station 2 (BBC Arabic)...');
sound(demod_BBC_down, original_Fs);
audio_duration_bbc = length(demod_BBC_down) / original_Fs;
pause(audio_duration_bbc + 1);


%% ========== PLOT SPECTRA OF EACH STAGE (Quran Channel Example) ==========
N_plot = length(FDM);
freq_plot = (-N_plot/2 : N_plot/2 - 1) * (Fs1 / N_plot);

% Spectra for Quran Channel
Y_RF = fftshift(fft(RF_output_Quran_Channel));
Y_IF = fftshift(fft(IF_Quran_Channel));
Y_base = fftshift(fft(demodulated_Quran));

mag_RF = abs(Y_RF);
mag_IF = abs(Y_IF);
mag_base = abs(Y_base);

%% ========== PLOT SPECTRA OF EACH STAGE (BBC Channel Example) ==========
% Spectra for BBC Channel
Y_RF_BBC = fftshift(fft(RF_output_BBC_Channel));
Y_IF_BBC = fftshift(fft(IF_BBC_Channel));
Y_base_BBC = fftshift(fft(demodulated_BBC));

mag_RF_BBC = abs(Y_RF_BBC);
mag_IF_BBC = abs(Y_IF_BBC);
mag_base_BBC = abs(Y_base_BBC);

%% ===========Plot all three==================
figure;
subplot(3,1,1);
plot(freq_plot / 1000, mag_RF_BBC);
xlabel('Frequency (kHz)');
ylabel('Magnitude');
title('BBC Channel RF Stage Output (After BPF at 130 kHz)');
grid on;
xlim([-200, 200]);

subplot(3,1,2);
plot(freq_plot / 1000, mag_IF_BBC);
xlabel('Frequency (kHz)');
ylabel('Magnitude');
title('BBC Channel IF Stage Output (After BPF at 15 kHz)');
grid on;
xlim([-50, 50]);

subplot(3,1,3);
plot(freq_plot / 1000, mag_base_BBC);
xlabel('Frequency (kHz)');
ylabel('Magnitude');
title('BBC Channel Baseband Output (After LPF)');
grid on;
xlim([-25, 25]);
% ===========Plot all three==================
figure;
subplot(3,1,1);
plot(freq_plot / 1000, mag_RF);
xlabel('Frequency (kHz)');
ylabel('Magnitude');
title('Quran Channel RF Stage Output (After BPF at 100 kHz)');
grid on;
xlim([-200, 200]);

subplot(3,1,2);
plot(freq_plot / 1000, mag_IF);
xlabel('Frequency (kHz)');
ylabel('Magnitude');
title('Quran Channel IF Stage Output (After BPF at 15 kHz)');
grid on;
xlim([-50, 50]);

subplot(3,1,3);
plot(freq_plot / 1000, mag_base);
xlabel('Frequency (kHz)');
ylabel('Magnitude');
title('Quran Channel Baseband Output (After LPF)');
grid on;
xlim([-25, 25]);
%% Q4 - Removing the RF BPF filter
disp('========== Q4: Removing RF Filter ==========');

% Taking the FDM output directly without passing through the RF filter
RF_output_NoBPF = FDM;

% Mixing with Local Oscillators (High Side Injection)
mixer_NoBPF_Quran = RF_output_NoBPF .* cos(2 * pi * F_osc_Quran * t);
mixer_NoBPF_BBC = RF_output_NoBPF .* cos(2 * pi * F_osc_BBC * t);

% IF Filtering (Using the shared IF_filter designed previously)
IF_NoBPF_Quran = filter(IF_filter, mixer_NoBPF_Quran);
IF_NoBPF_BBC = filter(IF_filter, mixer_NoBPF_BBC);

% BaseBand Demodulation
baseband_NoBPF_Quran = IF_NoBPF_Quran .* cos(2 * pi * F_IF * t);
demod_NoBPF_Quran = filter(LPF_filter, baseband_NoBPF_Quran);
demod_NoBPF_Quran = demod_NoBPF_Quran - mean(demod_NoBPF_Quran);

baseband_NoBPF_BBC = IF_NoBPF_BBC .* cos(2 * pi * F_IF * t);
demod_NoBPF_BBC = filter(LPF_filter, baseband_NoBPF_BBC);
demod_NoBPF_BBC = demod_NoBPF_BBC - mean(demod_NoBPF_BBC);

% Downsampling and Normalizing
original_Fs = Fs1 / upsample_factor;
demod_NoBPF_Quran_down = downsample(demod_NoBPF_Quran, upsample_factor);
demod_NoBPF_Quran_down = demod_NoBPF_Quran_down / max(abs(demod_NoBPF_Quran_down));

demod_NoBPF_BBC_down = downsample(demod_NoBPF_BBC, upsample_factor);
demod_NoBPF_BBC_down = demod_NoBPF_BBC_down / max(abs(demod_NoBPF_BBC_down));

% Audio Playback
disp('Playing Station 1 (Quran Palestine) WITHOUT RF Filter...');
sound(demod_NoBPF_Quran_down, original_Fs);
pause((length(demod_NoBPF_Quran_down) / original_Fs) + 1);

disp('Playing Station 2 (BBC Arabic) WITHOUT RF Filter...');
sound(demod_NoBPF_BBC_down, original_Fs);
pause((length(demod_NoBPF_BBC_down) / original_Fs) + 1);

% --- Plotting Q4 ---
% Quran Plot
figure;
subplot(3,1,1); plot(freq_plot / 1000, abs(fftshift(fft(RF_output_NoBPF))));
title('Q4: Output WITHOUT RF BPF (Raw FDM)'); xlabel('Frequency (kHz)'); ylabel('Magnitude'); grid on; xlim([-200, 200]);
subplot(3,1,2); plot(freq_plot / 1000, abs(fftshift(fft(IF_NoBPF_Quran))));
title('Q4: IF Stage Output (Quran Channel)'); xlabel('Frequency (kHz)'); ylabel('Magnitude'); grid on; xlim([-50, 50]);
subplot(3,1,3); plot(freq_plot / 1000, abs(fftshift(fft(demod_NoBPF_Quran))));
title('Q4: Baseband Output (Quran Channel)'); xlabel('Frequency (kHz)'); ylabel('Magnitude'); grid on; xlim([-25, 25]);

% BBC Plot
figure;
subplot(3,1,1); plot(freq_plot / 1000, abs(fftshift(fft(RF_output_NoBPF))));
title('Q4: Output WITHOUT RF BPF (Raw FDM)'); xlabel('Frequency (kHz)'); ylabel('Magnitude'); grid on; xlim([-200, 200]);
subplot(3,1,2); plot(freq_plot / 1000, abs(fftshift(fft(IF_NoBPF_BBC))));
title('Q4: IF Stage Output (BBC Channel)'); xlabel('Frequency (kHz)'); ylabel('Magnitude'); grid on; xlim([-50, 50]);
subplot(3,1,3); plot(freq_plot / 1000, abs(fftshift(fft(demod_NoBPF_BBC))));
title('Q4: Baseband Output (BBC Channel)'); xlabel('Frequency (kHz)'); ylabel('Magnitude'); grid on; xlim([-25, 25]);


%% Q5 - Adding the mixer offset (1 kHz)
disp('========== Q5: Adding 1 kHz Oscillator Offset ==========');

offset_1k = 1e3; 
F_osc_err_Quran_1k = fc1 + F_IF + offset_1k; 
F_osc_err_BBC_1k   = fc2 + F_IF + offset_1k;

% Mixing (Using the properly RF-filtered signals from the main block)
mixer_err1k_Quran = RF_output_Quran_Channel .* cos(2 * pi * F_osc_err_Quran_1k * t);
mixer_err1k_BBC   = RF_output_BBC_Channel .* cos(2 * pi * F_osc_err_BBC_1k * t);

% IF Filtering
IF_err1k_Quran = filter(IF_filter, mixer_err1k_Quran);
IF_err1k_BBC   = filter(IF_filter, mixer_err1k_BBC);

% Demodulation
demod_err1k_Quran = filter(LPF_filter, (IF_err1k_Quran .* cos(2 * pi * F_IF * t)));
demod_err1k_Quran = demod_err1k_Quran - mean(demod_err1k_Quran);

demod_err1k_BBC = filter(LPF_filter, (IF_err1k_BBC .* cos(2 * pi * F_IF * t)));
demod_err1k_BBC = demod_err1k_BBC - mean(demod_err1k_BBC);

% Downsample and Normalize
demod_err1k_Quran_down = downsample(demod_err1k_Quran, upsample_factor);
demod_err1k_Quran_down = demod_err1k_Quran_down / max(abs(demod_err1k_Quran_down));

demod_err1k_BBC_down = downsample(demod_err1k_BBC, upsample_factor);
demod_err1k_BBC_down = demod_err1k_BBC_down / max(abs(demod_err1k_BBC_down));

% Audio Playback
disp('Playing Station 1 (Quran Palestine) WITH 1 kHz Offset...');
sound(demod_err1k_Quran_down, original_Fs);
pause((length(demod_err1k_Quran_down) / original_Fs) + 1);

disp('Playing Station 2 (BBC Arabic) WITH 1 kHz Offset...');
sound(demod_err1k_BBC_down, original_Fs);
pause((length(demod_err1k_BBC_down) / original_Fs) + 1);

% --- Plotting Q5 1kHz ---
% Quran Plot
figure;
subplot(3,1,1); plot(freq_plot / 1000, abs(fftshift(fft(RF_output_Quran_Channel))));
title('Q5 (1kHz Offset): RF Stage Output (Quran Channel)'); xlabel('Frequency (kHz)'); ylabel('Magnitude'); grid on; xlim([-200, 200]);
subplot(3,1,2); plot(freq_plot / 1000, abs(fftshift(fft(IF_err1k_Quran))));
title('Q5 (1kHz Offset): IF Stage Output (Quran Channel)'); xlabel('Frequency (kHz)'); ylabel('Magnitude'); grid on; xlim([-50, 50]);
subplot(3,1,3); plot(freq_plot / 1000, abs(fftshift(fft(demod_err1k_Quran))));
title('Q5 (1kHz Offset): Baseband Output (Quran Channel)'); xlabel('Frequency (kHz)'); ylabel('Magnitude'); grid on; xlim([-25, 25]);

% BBC Plot
figure;
subplot(3,1,1); plot(freq_plot / 1000, abs(fftshift(fft(RF_output_BBC_Channel))));
title('Q5 (1kHz Offset): RF Stage Output (BBC Channel)'); xlabel('Frequency (kHz)'); ylabel('Magnitude'); grid on; xlim([-200, 200]);
subplot(3,1,2); plot(freq_plot / 1000, abs(fftshift(fft(IF_err1k_BBC))));
title('Q5 (1kHz Offset): IF Stage Output (BBC Channel)'); xlabel('Frequency (kHz)'); ylabel('Magnitude'); grid on; xlim([-50, 50]);
subplot(3,1,3); plot(freq_plot / 1000, abs(fftshift(fft(demod_err1k_BBC))));
title('Q5 (1kHz Offset): Baseband Output (BBC Channel)'); xlabel('Frequency (kHz)'); ylabel('Magnitude'); grid on; xlim([-25, 25]);


%% Q5 - Adding the mixer offset (0.1 kHz)
disp('========== Q5: Adding 0.1 kHz Oscillator Offset ==========');

offset_100Hz = 0.1e3; 
F_osc_err_Quran_100Hz = fc1 + F_IF + offset_100Hz; 
F_osc_err_BBC_100Hz   = fc2 + F_IF + offset_100Hz;

% Mixing
mixer_err100_Quran = RF_output_Quran_Channel .* cos(2 * pi * F_osc_err_Quran_100Hz * t);
mixer_err100_BBC   = RF_output_BBC_Channel .* cos(2 * pi * F_osc_err_BBC_100Hz * t);

% IF Filtering
IF_err100_Quran = filter(IF_filter, mixer_err100_Quran);
IF_err100_BBC   = filter(IF_filter, mixer_err100_BBC);

% Demodulation
demod_err100_Quran = filter(LPF_filter, (IF_err100_Quran .* cos(2 * pi * F_IF * t)));
demod_err100_Quran = demod_err100_Quran - mean(demod_err100_Quran);

demod_err100_BBC = filter(LPF_filter, (IF_err100_BBC .* cos(2 * pi * F_IF * t)));
demod_err100_BBC = demod_err100_BBC - mean(demod_err100_BBC);

% Downsample and Normalize
demod_err100_Quran_down = downsample(demod_err100_Quran, upsample_factor);
demod_err100_Quran_down = demod_err100_Quran_down / max(abs(demod_err100_Quran_down));

demod_err100_BBC_down = downsample(demod_err100_BBC, upsample_factor);
demod_err100_BBC_down = demod_err100_BBC_down / max(abs(demod_err100_BBC_down));

% Audio Playback
disp('Playing Station 1 (Quran Palestine) WITH 0.1 kHz Offset...');
sound(demod_err100_Quran_down, original_Fs);
pause((length(demod_err100_Quran_down) / original_Fs) + 1);

disp('Playing Station 2 (BBC Arabic) WITH 0.1 kHz Offset...');
sound(demod_err100_BBC_down, original_Fs);
pause((length(demod_err100_BBC_down) / original_Fs) + 1);

% --- Plotting Q5 0.1kHz ---
% Quran Plot
figure;
subplot(3,1,1); plot(freq_plot / 1000, abs(fftshift(fft(RF_output_Quran_Channel))));
title('Q5 (0.1kHz Offset): RF Stage Output (Quran Channel)'); xlabel('Frequency (kHz)'); ylabel('Magnitude'); grid on; xlim([-200, 200]);
subplot(3,1,2); plot(freq_plot / 1000, abs(fftshift(fft(IF_err100_Quran))));
title('Q5 (0.1kHz Offset): IF Stage Output (Quran Channel)'); xlabel('Frequency (kHz)'); ylabel('Magnitude'); grid on; xlim([-50, 50]);
subplot(3,1,3); plot(freq_plot / 1000, abs(fftshift(fft(demod_err100_Quran))));
title('Q5 (0.1kHz Offset): Baseband Output (Quran Channel)'); xlabel('Frequency (kHz)'); ylabel('Magnitude'); grid on; xlim([-25, 25]);

% BBC Plot
figure;
subplot(3,1,1); plot(freq_plot / 1000, abs(fftshift(fft(RF_output_BBC_Channel))));
title('Q5 (0.1kHz Offset): RF Stage Output (BBC Channel)'); xlabel('Frequency (kHz)'); ylabel('Magnitude'); grid on; xlim([-200, 200]);
subplot(3,1,2); plot(freq_plot / 1000, abs(fftshift(fft(IF_err100_BBC))));
title('Q5 (0.1kHz Offset): IF Stage Output (BBC Channel)'); xlabel('Frequency (kHz)'); ylabel('Magnitude'); grid on; xlim([-50, 50]);
subplot(3,1,3); plot(freq_plot / 1000, abs(fftshift(fft(demod_err100_BBC))));
title('Q5 (0.1kHz Offset): Baseband Output (BBC Channel)'); xlabel('Frequency (kHz)'); ylabel('Magnitude'); grid on; xlim([-25, 25]);