% QPSK simulation with Gray coding and simple Rayleigh multipath 
% and AWGN included.
clear all;
close all;
format long;

bit_count = 10000; %info bits to be tx
Eb_No = -3: 1: 30;
SNR = Eb_No + 10*log10(2);

for aa = 1: 1: length(SNR)
    
    Tx_Errors = 0;
    Tx_bits = 0;
    
    while Tx_Errors < 100
    
        uncoded_bits  = round(rand(1,bit_count));

        % in-phase & quadrature carriers
        B1 = uncoded_bits(1:2:end);
        B2 = uncoded_bits(2:2:end);
        
        % QPSK modulator (Gray Coding) -> pi/4 radians constellation
        qpsk_sig = ((B1==0).*(B2==0)*(exp(1i*pi/4))+(B1==0).*(B2==1)*(exp(3*1i*pi/4))+(B1==1).*(B2==1)*(exp(5*1i*pi/4))+(B1==1).*(B2==0)*(exp(7*1i*pi/4))); 
        
        %2 receiving antennas
        H1 = sqrt(0.5)*randn(1, length(qpsk_sig)) + 1i*sqrt(0.5)*randn(1, length(qpsk_sig));
        H2 = sqrt(0.5)*randn(1, length(qpsk_sig)) + 1i*sqrt(0.5)*randn(1, length(qpsk_sig));
        
        % random rayleigh fading channel w/ Variance = 0.5 
        %ray = sqrt(0.5*((randn(1,length(qpsk_sig))).^2+(randn(1,length(qpsk_sig))).^2));
        ray1 = sqrt(0.5*((randn(1,length(qpsk_sig))).^2+(randn(1,length(qpsk_sig))).^2));
        ray2 = sqrt(0.5*((randn(1,length(qpsk_sig))).^2+(randn(1,length(qpsk_sig))).^2));
        
        rx1 = qpsk_sig.*ray1; %symbols*fading channel
        rx2 = qpsk_sig.*ray2;
        
        N01 = 1/10^(SNR(aa)/10); %noise
        N02 = 1/10^(SNR(aa)/10);
        
        % AWGN added to rx
        %rx = rx + sqrt(N0/2)*(randn(1,length(qpsk_sig))+i*randn(1,length(qpsk_sig)));
        rx1 = rx1 + sqrt(N01/2)*(randn(1,length(qpsk_sig))+1i*randn(1,length(qpsk_sig)));
        rx2 = rx2 + sqrt(N02/2)*(randn(1,length(qpsk_sig))+1i*randn(1,length(qpsk_sig)));
        
        rx = rx1 + rx2;
        % Equaliser
        %rx = rx./ray; -> devides the received signal by the rayleigh
        %fading channel estimate to compensare for the effects of fading.
        
        % QPSK demodulator at rx
        B4 = (real(rx)<0);
        B3 = (imag(rx)<0);
        
        uncoded_bits_rx = zeros(1,2*length(rx));
        uncoded_bits_rx(1:2:end) = B3;
        uncoded_bits_rx(2:2:end) = B4;
        
%         B4_1 = (real(rx1)<0);
%         B3_1 = (imag(rx1)<0);
%         B4_2 = (real(rx2)<0);
%         B3_2 = (imag(rx2)<0);
%         
%         uncoded_bits_rx = zeros(1,2*length(rx1));
%         uncoded_bits_rx(1:4:end) = B3_1;
%         uncoded_bits_rx(2:4:end) = B4_1;
%         uncoded_bits_rx(3:4:end) = B3_2;
%         uncoded_bits_rx(4:4:end) = B4_2;
    
        diff = uncoded_bits - uncoded_bits_rx;
        Tx_Errors = Tx_Errors + sum(abs(diff));
        Tx_bits = Tx_bits + length(uncoded_bits);
        
    end
    BER(aa) = Tx_Errors / Tx_bits;
end

figure(1);
semilogy(SNR,BER,'-or');
hold on;
xlabel('SNR (dB)');
ylabel('BER');
title('(SNR Vs BER) SIMO QPSK in Flat Fading Channel');
% Rayleigh Theoretical BER
%figure(1);
EbN0Lin = 10.^(Eb_No/10);
theoryBerRay = 0.5.*(1-sqrt(EbN0Lin./(EbN0Lin+1)));
%semilogy(SNR,theoryBerRay);
grid on;
% Theoretical BER
figure(1);
theoryBerAWGN = 0.5*erfc(sqrt(10.^(Eb_No/10)));
semilogy(SNR,theoryBerAWGN,'b-*');
grid on;
legend('Simulated Raylegh', 'Theroretical AWGN');
axis([SNR(1,1) SNR(end-3) 0.00001 1]);