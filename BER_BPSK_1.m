%SNR (dB) = S/N
%SNRdB = -8:1:12;
%EbN0dB = 0:2:16;
EbN0dB = -8:1:12;

%Get SNR value, SNR = 10*log(SNRdB)
EbN0 = 10.^(EbN0dB/10);
%SNR = 10.^(SNRdB/10);

%data bits
N = 10^5;
x = randsrc(1,N,[0,1]); %generates 1xN matrix with the values 0 or 1 randomly but with equal probability.

%BPSK data generation
x_BPSK = 1 - 2*x;  %generate BPSK data (-1,+1) from x.
                   % 1 - 2*(0) = 1 .... 1 - 2*(1) = -1

%AWGN noise
n = randn(1,N); %random 1xN matrix.

for k=1:length(EbN0);
    
    %noise follows gaussian distribution (0.1)
    %(sigma square = 1 and mean = 0), so that noise power = 1
    y = (sqrt(EbN0(k)) * x_BPSK) + n;
    
    %find which bits has changed with noise (-1 -> +1, +1 -> -1)
    %in the transmitted channel.    
    % # of indices which are less than one (+1), the bit value has flipped. 
    nosiy_bits = y.*x_BPSK;
    
    % indices of the currupted bits by noise
    indices_currupted = find((nosiy_bits)<0);
    
    % # of currupted bits by the noise
    flipped_bits(k) = length(find(indices_currupted));
    
end

    %BER (bit error rate) -> number of errors divided by the number of tx bits.
    ber = flipped_bits/N;
    
    %plot results
    figure;
    
    %Practical
    prac = semilogy(EbN0dB, ber, 'b*-', 'linewidth', 1);
    hold on;
    
    %Theoretical --> BER formula for BPSK = 1/2 * erfc[sqrt(Eb/No)]
    theoretical = qfunc(sqrt(EbN0));
    theo = semilogy(EbN0dB, theoretical, 'r+-','linewidth', 1);
    legend([prac theo], {'Practical', 'Theoretical'})
    xlabel("EbN0 in dBs");
    ylabel("Bit Error Rate (BER)");
    grid on;
    
    datacursormode on;
    
    
  
    
    
    
    