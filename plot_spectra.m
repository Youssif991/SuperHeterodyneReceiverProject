% plot_spectra.m
function plot_spectra(RF_sig, IF_sig, base_sig, freq_plot, channel_name, condition)
    % Creates a new figure for each condition
    figure('Name', sprintf('%s - %s', channel_name, condition));
    
    % RF Stage Plot
    subplot(3,1,1); 
    plot(freq_plot / 1000, abs(fftshift(fft(RF_sig)))); 
    title(['RF Output: ', condition]); 
    xlabel('Frequency (kHz)'); ylabel('Magnitude'); 
    grid on; xlim([-200, 200]);
    
    % IF Stage Plot
    subplot(3,1,2); 
    plot(freq_plot / 1000, abs(fftshift(fft(IF_sig)))); 
    title(['IF Output: ', condition]); 
    xlabel('Frequency (kHz)'); ylabel('Magnitude'); 
    grid on; xlim([-50, 50]);
    
    % Baseband Plot
    subplot(3,1,3); 
    plot(freq_plot / 1000, abs(fftshift(fft(base_sig)))); 
    title(['Baseband: ', condition]); 
    xlabel('Frequency (kHz)'); ylabel('Magnitude'); 
    grid on; xlim([-25, 25]);
    
    drawnow;
end
