function [ber, rx_bits] = mod_csk(bits, snr_db, nov, a, channel, sir_db)
    % bits: input binary vector
    % snr_db: channel SNR in dB
    % K: spreading factor (samples per bit); match nov in QAM
    % a: Chaos parameter (>2)
    % channel: 'awgn' or 'awgn+interference'
    % sir_db: signal-to-interference (dB)

    if nargin < 6, sir_db = Inf; end       % default: no interference

    % Bipolar mapping
    Nb = length(bits); % bits are {0,1}
    b = 2*bits - 1; % b is bipolar {-1, 1}

    % 1. Generate chaotic carrier
    K = nov; % Match oversampling rate for consistent sampling time
    x = zeros(1, Nb*K + 100);
    x(1) = 0.1;
    for n = 1:length(x)-1
        x(n+1) = a*cos(x(n));
    end
    x_chaotic = x(101:end);

    % 2. Modulate
    s = zeros(1, Nb*K);
    for k = 1:Nb
        idx = (k-1)*K + (1:K);
        s(idx) = b(k) * x_chaotic(idx);
    end

    % 3. Channel
    r = awgn(s, snr_db, 'measured');
    if strcmp(channel, 'awgn+interference')
        t = 0:length(s)-1;
        int_amp = sqrt(10^(-sir_db/10) * mean(s.^2));
        r = r + int_amp * sin(2*pi*0.1*t);  % narrowband jammer
    end

    % 4. Detection (Correlation receiver)
    rx_bits_bipolar = zeros(1, Nb);
    for k = 1:Nb
        idx = (k-1)*K + (1:K);
        z = sum(r(idx) .* x_chaotic(idx));
        rx_bits_bipolar(k) = sign(z);
    end
    rx_bits_bipolar(rx_bits_bipolar == 0) = 1; % if corr=0, then default +1
    
    rx_bits = (rx_bits_bipolar + 1) / 2; % convert back to {0,1}
    ber = mean(bits ~= rx_bits); % compute BER
end