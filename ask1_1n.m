% Task 1.n Realistic Simulation of Flat Fading Channel with (4-QAM)

close all;
clear all;
clc;

% Παραμετροί 
fc = 800e3;                    % 800 kHz
roll_off = 0.35;               % Roll-off factor για το SRRC pulse
SNR_dB_FlatFading = 0:2:30;    
Nbits = 10e6;                  % Συνολικός αριθμός bits
over = 10;                     % oversampling factor
T = (1 + roll_off) / 80e3;     % Symbol period
dt = T / over;                
Nsymbol = Nbits / 2;           
m = 10;                        % Μέγεθος block (δέκαδα συμβόλων)
num_blocks = ceil(Nsymbol / m);% Αριθμός blocks

% Δημιουργία SRRC pulse
A = 4;  % Pulse spans 4 symbol periods
[phi, time_vector] = srrc_pulse(T, over, A, roll_off);
phi = phi(:); 

% Δημιουργία τυχαίας ακολουθίας bits για 4-QAM
b = randi([0, 1], Nbits, 1);  % Transmitted bits
symbols_real = -1 + 2 * (b(1:2:end) == 1);
symbols_imag = -1 + 2 * (b(2:2:end) == 1);
symbols = symbols_real + 1j * symbols_imag;  

% Upsample και εφαρμογή SRRC pulse shaping
s_upsampled = upsample(symbols, over);

% Αρχικοποίηση του πίνακα BER_values
BER_values = zeros(1, length(SNR_dB_FlatFading));

% Αρχικοποίηση του πίνακα bit_errors_total για κάθε SNR
bit_errors_total = zeros(1, length(SNR_dB_FlatFading));


% Εξωτερικός βρόχος: για κάθε block (δέκαδα συμβόλων)
for idx1 = 1 : num_blocks

    % Υπολογισμός δεικτών για symbol+over  για το τρέχον block
    %(1-100,101-200,....)
    start_symbol = (idx1-1)*m + 1;
    end_symbol   = (idx1*m); 
    
    % Υπολογισμός δεικτών για τα bits του τρέχοντος block
    start_bit = (start_symbol-1)*2 + 1;
    end_bit = min(end_symbol*2, Nbits);
    
    % Λήψη των συμβόλων για αυτό το block
    packet_symbols = s_upsampled((start_symbol-1)*over + 1 : end_symbol*over);
  
    % Εφαρμογή SRRC pulse shaping
    s_shaped = conv(packet_symbols, phi); 
    L_block = length(s_shaped);  % Αριθμός samples στο shaped block
    tBlock  = (0 : L_block-1).' * dt;

    % Upconversion
    carrier_signal = 2 * exp(1j * 2 * pi * fc * tBlock);  
    ready = real(s_shaped .* carrier_signal);   

    % Δημιουργία συντελεστών  fading
    h = generate_ray_coeff_sequence(L_block, inf); 
    block_to_transmit = ready.* abs(h);% αγνοώ τη φαση "καπως" αυθέρετα, θελω να ειναι 
                                       % real αυτο που μεταδιδω αλλα με το
                                       % real(h) δε δούλευε.

    % Εσωτερικός βρόχος: για κάθε SNR
    for idx2 = 1 : length(SNR_dB_FlatFading) 

        SNR = 10^(SNR_dB_FlatFading(idx2)/10); 

        % Generating real Gaussian noise 
        s = 2 / SNR;  % Ισχύς θορύβου 
        t = (0:dt:(length(block_to_transmit)-1)*dt); 
        noise = sqrt(s/(2*dt)) .* (randn(length(t), 1));
         
        
        % Σήμα με θόρυβο
        received_signal = block_to_transmit+noise;
    
        % Downconversion
        received_baseband = received_signal .* exp(-1j * 2 * pi * fc * tBlock);

        % αφαιρεση επιδρασης  για fading
        equalized_signal = received_baseband ./ abs(h);
        
        % Matched filtering
        phi_fliped = flip(conj(phi));
        filtered_signal = conv(equalized_signal, phi_fliped);
  
        % Sampling
        sample_start = length(phi_fliped);
        sample_end = length(filtered_signal) - (length(phi_fliped)-1);
        sample_for_detection = filtered_signal(sample_start : over : sample_end);
        
        % Ανάκτηση bits από τα sampled symbols
        num_detected_symbols = length(sample_for_detection);
        detected_bits_block = zeros(2*num_detected_symbols, 1); % 2 bits per symbol
        
        detected_bits_real = real(sample_for_detection) > 0;
        detected_bits_imag = imag(sample_for_detection) > 0;
        
        % Ανάθεση bits στο block
        detected_bits_block(1:2:end) = detected_bits_real;
        detected_bits_block(2:2:end) = detected_bits_imag;
        
        % Λήψη των αρχικών bits για σύγκριση
        original_bits = b(start_bit:end_bit);
 
        
        % Υπολογισμός Σφαλμάτων Bits
        num_errors = sum(original_bits ~= detected_bits_block);
        bit_errors_total(idx2) = bit_errors_total(idx2) + num_errors;
    end
end

% Υπολογισμός BER για κάθε SNR
BER_values = bit_errors_total / Nbits;

% Εμφάνιση των αποτελεσμάτων
disp('BER for each SNR:');
disp(BER_values);

% Plot BER vs SNRdB
figure;
semilogy(SNR_dB_FlatFading, BER_values, '-o', 'DisplayName', 'Προσομοίωση');
xlabel('SNR (dB)');
ylabel('BER');
title('BER vs SNR για Flat Fading Channel με 4-QAM');
grid on;
legend;
