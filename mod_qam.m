function [ber, rx_bits] = mod_qam(bits, snr_db, M, nov, channel, sir_db)
    % bits: input binary vector
    % snr_db: channel SNR in dB
    % M: modulation order (2= BPSK, 4= QPSK, 16= 16-QAM)
    % nov: oversampling rate (samples per symbol)
    % channel: 'awgn' or 'awgn+interference'
    % sir_db: signal-to-interference (dB)

    if nargin < 6, sir_db = Inf; end       % default: no interference

    % 1. Modulate
    symbols = qammod(bits', M, 'InputType', 'bit', 'UnitAveragePower', true);
    
    % 2. Pulse Shaping (Adapted from Lab 8, root-raised cosine)
    span = 10;        % Filter span: larger means more accuracy and delay
    rolloff = 0.25;   % Excess bandwidth factor
    ps_filter = rcosdesign(rolloff, span, nov, 'sqrt');
    tx_sig = upfirdn(symbols, ps_filter, nov); % Upsample and filter

    % 3. Channel 
    rx_sig = awgn(tx_sig, snr_db, 'measured');
    if strcmp(channel, 'awgn+interference')
        t = 0:length(tx_sig)-1;
        int_amp = sqrt(10^(-sir_db/10) * mean(abs(tx_sig).^2));
        rx_sig = rx_sig + int_amp * sin(2*pi*0.1*t)';  % narrowband jammer
    end

    % 4. Matched Filter & downsample
    mf_sig = upfirdn(rx_sig, ps_filter, 1, nov);
    mf_sig = mf_sig(span+1:end-span);            % Remove filter delay

    % 5. Demodulate
    rx_bits = qamdemod(mf_sig, M, 'OutputType', 'bit', 'UnitAveragePower', true)';
    
    % 6. Ensure lengths match for BER calculation
    actual_len = min(length(bits), length(rx_bits)); % to remove filter delay
    ber = mean(bits(1:actual_len) ~= rx_bits(1:actual_len)); 
end