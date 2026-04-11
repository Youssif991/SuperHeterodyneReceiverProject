% preprocessing.m

%% Reading the files
[signal1_raw, Fs1] = audioread("audios\Short_QuranPalestine.wav");
[signal2_raw, Fs2] = audioread("audios\Short_BBCArabic2.wav");

%% Convert stereo to mono
if size(signal1_raw, 2) == 2, signal1 = signal1_raw(:,1) + signal1_raw(:,2); else, signal1 = signal1_raw; end
if size(signal2_raw, 2) == 2, signal2 = signal2_raw(:,1) + signal2_raw(:,2); else, signal2 = signal2_raw; end

disp(['Fs1 = ', num2str(Fs1), ' Hz']);
disp(['Fs2 = ', num2str(Fs2), ' Hz']);

%% Pad to equal length
len1 = length(signal1);
len2 = length(signal2);
max_len = max(len1, len2);

if len1 < max_len, signal1 = [signal1; zeros(max_len - len1, 1)]; end
if len2 < max_len, signal2 = [signal2; zeros(max_len - len2, 1)]; end

%% ========== PLOT SPECTRUM (Original Baseband) ============
N_plot1 = length(signal1);
Y1_shifted = fftshift(fft(signal1));
Y2_shifted = fftshift(fft(signal2));

magnitude1_shifted = abs(Y1_shifted);
magnitude2_shifted = abs(Y2_shifted);
freq_shifted = (-N_plot1/2 : N_plot1/2 - 1) * (Fs1 / N_plot1);

figure('Name', 'Original Baseband Spectra');
subplot(2,1,1);
plot(freq_shifted / 1000, magnitude1_shifted);
xlabel('Frequency (kHz)'); ylabel('Magnitude'); title('Spectrum of Signal 1 (Quran Channel)'); grid on; xlim([-25, 25]);

subplot(2,1,2);
plot(freq_shifted / 1000, magnitude2_shifted);
xlabel('Frequency (kHz)'); ylabel('Magnitude'); title('Spectrum of Signal 2 (BBC Channel)'); grid on; xlim([-25, 25]);
drawnow;

%% Upsampling
upsample_factor = 10;
signal1 = interp(signal1, upsample_factor);
signal2 = interp(signal2, upsample_factor);

original_Fs = Fs1;
Fs1 = Fs1 * upsample_factor;
Fs2 = Fs2 * upsample_factor;
disp(['New Fs1 = ', num2str(Fs1), ' Hz']);
disp(['New Fs2 = ', num2str(Fs2), ' Hz']);
