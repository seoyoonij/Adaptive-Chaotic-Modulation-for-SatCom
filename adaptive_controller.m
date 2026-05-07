function [ber, mode, bitsPerSym, rx_bits] = adaptive_controller( ...
         bits, currentSNR, predictedSNR, nov, a_chaos, channel_mode, sir_dB)

    % Interference shifts all thresholds up: bias toward CSK earlier
    if strcmp(channel_mode, 'awgn+interference')
        th = [18, 12, 6];    % tighter thresholds under jamming
    else
        th = [15, 8, 4];     % standard thresholds
    end
    
    % High-speed data (clear sky)
    if predictedSNR > th(1) 
        [ber, rx_bits] = mod_qam(bits, currentSNR, 16, nov, channel_mode, sir_dB);
        mode = "16-QAM"; bitsPerSym = 4;
    % Standard telemetry
    elseif predictedSNR > th(2)
        [ber, rx_bits] = mod_qam(bits, currentSNR,  4, nov, channel_mode, sir_dB);
        mode = "QPSK";   bitsPerSym = 2;
    % Critical health
    elseif predictedSNR > th(3)
        [ber, rx_bits] = mod_qam(bits, currentSNR,  2, nov, channel_mode, sir_dB);
        mode = "BPSK";   bitsPerSym = 1;
     % Emergency/Deep fade
    else
        [ber, rx_bits] = mod_csk(bits, currentSNR, nov, a_chaos, channel_mode, sir_dB);
        mode = "CSK";    bitsPerSym = 1/nov;
    end
end
