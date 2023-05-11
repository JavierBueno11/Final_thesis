N=10^6;
snr=-10:0.1:30;

%EbN0dB = 0:2:16;
%Get SNR value, SNR = 10*log(SNRdB)
%snr = 10.^(EbN0dB/10);

len=length(snr);
x=randi([0,1],1,N); 
x_in=2*x - 1;
y_quant=zeros([1 N]);
BER_flat_fading_BPSK=zeros([1 len]);
err_count=0;
img=sqrt(-1);

for i=1:len
    h =randn(1,N)+ img*randn(1,N); 
    c=h.*x_in;
    y=awgn(c,snr(i),'measured');
    y_rec=y./h;
    for j=1:N
        if(real(y_rec(j))>0)
            y_quant(j)=1;
        else if(real(y_rec(j))<0)
            y_quant(j)=-1;
            end
        end
    end
    for k=1:N
        if(y_quant(k)~=x_in(k))
            err_count=err_count+1;
        end
    end
    ber_temp=err_count/N;
    BER_flat_fading_BPSK(i)=ber_temp;
    err_count=0;
end
figure;
semilogy(snr,BER_awgn_BPSK,'Color','blue');
%x = 0.5*erfc(sqrt(10.^(snr/10)));
%theoretical = qfunc(sqrt(EbN0));
%plot(snr, x)
hold on;
semilogy(snr,BER_flat_fading_BPSK,'Color','red');
legend('AWGN Channel','Flat Fading Channel');
ylabel("Bit Error Rate");
xlabel("SNR in dB");