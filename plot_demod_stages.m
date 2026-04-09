function plot_demod_stages(RF_sig, IF_sig, base_sig, freq_axis, channel_name, condition_title)
    % This function generates the 3-subplot figure for any demodulation stage
    figure;
    
    % 1. RF Stage Plot
    subplot(3,1,1); 
    plot(freq_axis / 1000, abs(fftshift(fft(RF_sig))));
    title(sprintf('%s: RF Stage Output (%s)', condition_title, channel_name)); 
    xlabel('Frequency (kHz)'); ylabel('Magnitude'); grid on; xlim([-200, 200]);
    
    % 2. IF Stage Plot
    subplot(3,1,2); 
    plot(freq_axis / 1000, abs(fftshift(fft(IF_sig))));
    title(sprintf('%s: IF Stage Output (%s)', condition_title, channel_name)); 
    xlabel('Frequency (kHz)'); ylabel('Magnitude'); grid on; xlim([-50, 50]);
    
    % 3. Baseband Stage Plot
    subplot(3,1,3); 
    plot(freq_axis / 1000, abs(fftshift(fft(base_sig))));
    title(sprintf('%s: Baseband Output (%s)', condition_title, channel_name)); 
    xlabel('Frequency (kHz)'); ylabel('Magnitude'); grid on; xlim([-25, 25]);
end