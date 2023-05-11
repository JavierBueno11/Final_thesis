%BER of OFDM in Frequency selective channel
clc;
clear all;
close all;
N = 128;                             % No of subcarriers
Ncp = 16;                            % Cyclic prefix length
Ts = 1e-3;                           % Sampling period of channel
Fd = 0;                              % Max Doppler frequency shift
Np = 4;                              % # of pilot symbols
M = 2;                               % # of symbols for PSK modulation: BPSK
Nframes = 10^3;                      % # of OFDM frames

D = round((M-1)*rand((N-2*Np),Nframes));
const = pskmod([0:M-1],M);
Dmod = pskmod(D,M);
Data = [zeros(Np,Nframes); Dmod ; zeros(Np,Nframes)];   % Pilot Insertion

% OFDM symbol
IFFT_Data = (N/sqrt(120))*ifft(Data,N);
TxCy = [IFFT_Data((N-Ncp+1):N,:); IFFT_Data];  % Cyclic prefix -> avoid ISI
[r c] = size(TxCy);
Tx_Data = TxCy;

% Frequency selective channel with 4 taps
tau = [0 1e-5 3.5e-5 12e-5];                     % Path delays
pdb = [0 -1 -1 -3];                              % Avg path power gains
h = rayleighchan(Ts, Fd, tau, pdb); %channel -> used to filter the tx OFDM channel
h.StoreHistory = 0;
h.StorePathGains = 1;
h.ResetBeforeFiltering = 1;

% SNR of channel
EbNo = 0:5:30;
EsNo= max(0, EbNo + 10*log10(120/128)+ 10*log10(128/144));      % symbol to noise ratio
snr= EsNo - 10*log10(128/144); %128=FFT size & 144=total num of subcarriers.

% Transmit through channel
berofdm = zeros(1,length(snr));
Rx_Data = zeros((N-2*Np),Nframes);
for i = 1:length(snr)
    for j = 1:c                                % Transmit frame by frame
        hx = filter(h,Tx_Data(:,j).');         % Pass through Rayleigh channel
        a = h.PathGains;
        AM = h.channelFilter.alphaMatrix;
        g = a*AM;                              % Channel coefficients
        G(j,:) = fft(g,N);                     % DFT of channel coefficients
        y = awgn(hx,snr(i));  % Add AWGN noise
        
% Receiver
        Rx = y(Ncp+1:r);                                % Removal of cyclic prefix 
        FFT_Data = (sqrt(120)/128)*fft(Rx,N)./G(j,:);   % Frequency Domain Equalization
        Rx_Data(:,j) = pskdemod(FFT_Data(5:124),M);     % Removal of pilot and Demodulation 
    end
    berofdm(i) = sum(sum(Rx_Data~=D))/((N-2*Np)*Nframes);
end

% Plot the BER
figure;
semilogy(EbNo,berofdm,'--or','linewidth',2);
hold on;
%grid on;
%title('OFDM BER vs SNR in Frequency selective Rayleigh fading channel');
%xlabel('EbNo');
%ylabel('BER');

% Compute the theoretical BER
%berofdm_theoretical = qfunc(sqrt(2*EsNo)*sqrt(N/(N-2*Np+1)));
%semilogy(snr,berofdm_theoretical,'-b','linewidth',2);
%grid on;
title('OFDM BER vs SNR in Frequency selective Rayleigh fading channel');
xlabel('SNR (dB)');
ylabel('BER');