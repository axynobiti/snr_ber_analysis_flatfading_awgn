% Task 1.m: Flat-Fading Channel with (4-QAM)

% Παραμετροί 
num_bits = 1e7; % Number of bits
SNR_dB_FlatFading = 0:2:30; % SNR range in dB


% Δημιουργία τυχαίας ακολουθίας bits για 4-QAM
bits = randi([0, 1], num_bits, 1); 
symbols_real = 2 * bits(1:2:end) - 1;
symbols_imag = 2 * bits(2:2:end) - 1; 
symbols = symbols_real + 1j * symbols_imag; 

 % Δημιουργία συντελεστών  fading
 h = generate_ray_coeff_sequence(num_bits/2, inf);

% Flat-Fading Channel Simulation (Experimental)
BER_FlatFading = zeros(size(SNR_dB_FlatFading));

for i = 1:length(SNR_dB_FlatFading)

    SNR = 10^(SNR_dB_FlatFading(i)/10); % Linear SNR
    noise_std = sqrt(1/(2*SNR)); 
    noise = noise_std * (randn(num_bits/2, 1) + 1j*randn(num_bits/2, 1));
    received = h .* symbols + noise; % Received signal
    
    % αφαιρεση επιδρασης  για fading
    equalized = received ./ h;
    
    % Ανάκτηση bits από τα sampled symbols
    detected_bits = zeros(num_bits, 1);

    % real part of symbols
    for idx = 1:num_bits/2
        detected_bits(2*idx - 1) = real(equalized(idx)) > 0;
    end
    % imaginary part of symbols
    for idx = 1:num_bits/2
        detected_bits(2*idx) = imag(equalized(idx)) > 0;
    end

   % Υπολογισμός BER για κάθε SNR
    BER_FlatFading(i) = mean(bits ~= detected_bits);
end

% Flat-Fading Channel: Θεωρητικό BER για 4-QAM
BER_FlatFading_Theory = zeros(size(SNR_dB_FlatFading));
for i = 1:length(SNR_dB_FlatFading)
    SNR = 10^(SNR_dB_FlatFading(i)/10); % Linear SNR
    BER_FlatFading_Theory(i) = 0.5 * (1 - sqrt(SNR / (1 + SNR))); % Theoretical BER for 4-QAM
end

% Plot Results
figure;
semilogy(SNR_dB_FlatFading, BER_FlatFading, 'r-o', 'DisplayName', 'Flat-Fading (Experimental)');
hold on;
semilogy(SNR_dB_FlatFading, BER_FlatFading_Theory, 'r--', 'DisplayName', 'Flat-Fading (Theory)');
xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');
grid on;
legend;
title('BER vs SNR for Flat-Fading Channel with 4-QAM Modulation');

% P.S
% Το πραγματικό μέρος των συμβόλων αποθηκεύεται στις θέσεις με μονό δείκτη του πίνακα detected_bits.
% Το φανταστικό μέρος των συμβόλων αποθηκεύεται στις θέσεις με ζυγό δείκτη του πίνακα detected_bits.
