% Task 1.h
% Flat-Fading Channel Simulation

% Παραμετροί 
n = 5000;                   
SNRdB = 20;                
SNR = 10^(SNRdB / 10);                    
N0 = 1 / SNR;               

H = generate_ray_coeff_sequence(n, inf); 

% Δημιουργία τυχαίας ακολουθίας bits για BPSK 
X =2 * randi([0, 1], 1, n) - 1;

% 
N = sqrt(N0 / 2) * (randn(1, n) + 1j * randn(1, n));

% Ληφθέν σημα 
Y = H .* X + N;

%Κανόνας Απόφασης για Detected symbols
X_hat = sign(real(Y ./ H));


errors = abs(X - X_hat); 


figure;

% Upper plot:Channel magnitude (logarithmic scale)
subplot(2, 1, 1);
semilogy(1:n, abs(H));
xlabel('Time');
ylabel('|H| (Logarithmic scale)');
title('Channel Magnitude');

% Lower plot:Errors
subplot(2, 1, 2);
stem(1:n, errors, 'c', 'Marker', 'none');
xlabel('Time');
ylabel('Errors');
title('Errors per Symbol');

% Ο διάνυσμα 'errors' περιέχει τη απόλυτη διαφορά μεταξύ του συμβόλου (X)
% και του (X_hat).
% Οι τιμές για abs(X - X_hat) είναι:
%   - 0: κανενα σφάλμα
%   - 2a: σφάλμα
% Το διάνυσμα errors θα έχει τιμή 0 για σωστές αποφάσεις και 2a για σφάλματα.

% Παράδειγμα:
% Αν X = [-1, 1, 1, -1]
% και X_hat = [-1, -1, 1, -1], τότε:
% errors = abs([-1 - (-1), 1 - (-1), 1 - 1, -1 - (-1)])
%        = abs([0, 2, 0, 0])
%        = [0, 2, 0, 0].
