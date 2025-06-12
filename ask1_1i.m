% Task 1.i

% Parameters
num_bits = 1e7;
SNR_dB_AWGN = 0:2:14;
SNR_dB_FlatFading = 0:2:30;

% Generating symbols
bits = randi([0, 1], num_bits, 1); 
symbols = 2*bits - 1; % mapping

% AWGN Channel Simulation
BER_AWGN = zeros(size(SNR_dB_AWGN));
for i = 1:length(SNR_dB_AWGN)
    SNR = 10^(SNR_dB_AWGN(i)/10); % Linear SNR
    noise_std = sqrt(1/(2*SNR)); % Noise standard deviation
    noise = noise_std * (randn(num_bits, 1) + 1j*randn(num_bits, 1));
    received = symbols + noise; % Received signal
    detected = real(received) > 0; 
    BER_AWGN(i) = mean(bits ~= detected); 
end

% Flat-Fading Channel Simulation (Experimental)
BER_FlatFading = zeros(size(SNR_dB_FlatFading));
for i = 1:length(SNR_dB_FlatFading)
    SNR = 10^(SNR_dB_FlatFading(i)/10); % Linear SNR
    noise_std = sqrt(1/(2*SNR)); % Noise standard deviation
    noise = noise_std * (randn(num_bits, 1) + 1j*randn(num_bits, 1));
    h = generate_ray_coeff_sequence(num_bits, inf); % fading coefficients
    received = h .* symbols + noise; % Received signal
    % Equalize the received signal by dividing by h to cancel out the fading effect
    detected = real(received ./h) > 0; 
    BER_FlatFading(i) = mean(bits ~= detected); 
end

% Flat-Fading Channel: Theoretical BER using Pe = 1/2 (1 - sqrt(SNR / (1 + SNR)))
BER_FlatFading_Theory = zeros(size(SNR_dB_FlatFading)); 
for i = 1:length(SNR_dB_FlatFading)
    SNR = 10^(SNR_dB_FlatFading(i)/10); % Linear SNR
    BER_FlatFading_Theory(i) = 0.5 * (1 - sqrt(SNR / (1 + SNR)));
end

% AWGN Channel: Theoretical BER using Pe = Q(sqrt( SNR))
SNR_linear_AWGN = 10.^(SNR_dB_AWGN / 10);
BER_AWGN_Theory = erfc(sqrt( SNR_linear_AWGN));

% Approximations
BER_AWGN_Approx = 0.5* exp(-SNR_linear_AWGN);%from upper barrier of Q-function
SNR_linear_FlatFading = 10.^(SNR_dB_FlatFading / 10); 
BER_FlatFading_Approx = 1 ./ (4 * SNR_linear_FlatFading);% from task f

% Plot Results
figure;
semilogy(SNR_dB_AWGN, BER_AWGN, 'b-o', 'DisplayName', 'AWGN (Experimental)');
hold on;
semilogy(SNR_dB_AWGN, BER_AWGN_Theory, 'b--', 'DisplayName', 'AWGN (Theory)');
semilogy(SNR_dB_AWGN, BER_AWGN_Approx, 'b-.', 'DisplayName', 'AWGN (Approximation)');
semilogy(SNR_dB_FlatFading, BER_FlatFading, 'r-o', 'DisplayName', 'Flat-Fading (Experimental)');
semilogy(SNR_dB_FlatFading, BER_FlatFading_Theory, 'r--', 'DisplayName', 'Flat-Fading (Theory)');
semilogy(SNR_dB_FlatFading, BER_FlatFading_Approx, 'r-.', 'DisplayName', 'Flat-Fading (Approximation)');

xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');
grid on;
legend;
title('BER vs SNR for AWGN and Flat-Fading Channels');
