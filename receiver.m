% receiver.m

% Mixer Stage
Mixer_Output = current_RF_in .* cos(2 * pi * current_F_osc * t);

% IF Filtering Process
IF_Channel = filter(IF_filter, Mixer_Output);

% Return to Baseband & Low-Pass Filtering
baseband_mixed = IF_Channel .* cos(2 * pi * F_IF * t);
demodulated = filter(LPF_filter, baseband_mixed);
demodulated = demodulated - mean(demodulated); % remove dc offset

% Downsample back & Normalize
demod_down = downsample(demodulated, upsample_factor);
demod_down = demod_down / max(abs(demod_down));

% Plotting (calling your updated plot_spectra function)
plot_spectra(current_RF_in, IF_Channel, demodulated, freq_plot, station_name, current_condition);

% Audio Playback
sound(demod_down, original_Fs);
pause((length(demod_down) / original_Fs) + 1);