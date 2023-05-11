% QPSK Modulator in AWGN Channel
clc;
clear all;
close all;

% Parameters
N_bits = 10000; % number of bits
EbN0dB = 0:1:10; % Eb/N0 range
EsN0dB = EbN0dB + 10*log10(2); % Es/N0 range (QPSK)
N0 = 1./(10.^(EsN0dB/10)); % noise variance
N_iter = 100; % number of iterations

% QPSK Mapping
bits = randi([0 1],1,N_bits);
symbols = 1/sqrt(2) * (2*bits(1:2:end)-1 + 1i*(2*bits(2:2:end)-1));

% Modulation
tx_signal = symbols;

% Loop over Eb/N0
BER = zeros(1,length(EbN0dB));
for i = 1:length(EbN0dB)
    for j = 1:N_iter
        % AWGN Channel
        noise = sqrt(N0(i)/2) * (randn(size(tx_signal)) + 1i*randn(size(tx_signal)));
        rx_signal = tx_signal + noise;
        
        % Demodulation
        rx_bits = zeros(1,N_bits);
        rx_bits(1:2:end) = real(rx_signal)>0;
        rx_bits(2:2:end) = imag(rx_signal)>0;
        
        % Count Errors
        errors = sum(bits ~= rx_bits);
        BER(i) = BER(i) + errors/N_bits;
    end
end
BER = BER/N_iter;



% Plot BER vs Eb/N0
semilogy(EbN0dB,BER, 'r+-', 'linewidth', 1);

%THEORETICAL VALUE.
ber = berawgn(EbN0dB, 'qam', 4); % Cálculo del BER teórico
hold on; 
semilogy(EbN0dB, ber, 'b', 'LineWidth', 1);

grid on;
xlabel('Eb/N0 (dB)');
ylabel('BER');
title('QPSK Modulator in AWGN Channel');
legend({'Practical', 'Theoretical'})



%In this program, we first define the parameters, including the number of bits to transmit, 
%the Eb/N0 range, the Es/N0 range, the noise variance, and the number of iterations. 
%Then, we generate random bits and map them to QPSK symbols using a custom mapping. 
%The modulated signal is then transmitted through the AWGN channel, where noise is added to the signal. 
%We then demodulate the received signal, count the number of errors, and compute the bit error rate (BER). 
%We repeat this process for multiple Eb/N0 values to generate a BER curve.