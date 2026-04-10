% modulator.m
disp('--- Running Modulator ---');

%% MODULATION
N1 = length(signal1);
Ts = 1/Fs1;
t = (0:N1-1)' * Ts;

fc = 100e3; % Base carrier frequency
delta_f = 30e3; % Frequency spacing
fc1 = fc;             % Carrier for first signal (100 kHz)
fc2 = fc + delta_f;   % Carrier for second signal (130 kHz)

Quran_Channel_Modulated = signal1 .* cos(2 * pi * fc1 * t);
BBC_Channel_Modulated = signal2 .* cos(2 * pi * fc2 * t);

FDM = Quran_Channel_Modulated + BBC_Channel_Modulated;

%% PLOTTING FDM
Y_FDM = fft(FDM);
Y_FDM_shifted = fftshift(Y_FDM);
magnitude_FDM = abs(Y_FDM_shifted);
freq_axis = (-N1/2 : N1/2 - 1) * (Fs1 / N1);
freq_plot = freq_axis; % Save for later plotting

figure('Name', 'FDM Spectrum');
plot(freq_axis / 1000, magnitude_FDM);
xlabel('Frequency (kHz)'); ylabel('Magnitude'); title('FDM Signal Spectrum'); grid on; xlim([-200, 200]);
hold on;
xline(fc1/1000, 'r--', '100 kHz');
xline(fc2/1000, 'g--', '130 kHz');
xline(-fc1/1000, 'r--', '-100 kHz');
xline(-fc2/1000, 'g--', '-130 kHz');
legend('FDM', 'Station 1 (Quran)', 'Station 2 (BBC)');
drawnow;