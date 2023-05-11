N=10^6; 
snr=-10:0.1:30;
len=length(snr);
x=randi([0,1],1,N); 
x_in=2*x - 1;
y_quant=zeros([1 N]);
BER_awgn_BPSK=zeros([1 len]);
err_count=0;
for i=1:len
    y=awgn(x_in,snr(i),'measured');
    for j=1:N
        if(y(j)>0)
            y_quant(j)=1;
        else if(y(j)<0)
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
    BER_awgn_BPSK(i)=ber_temp;
    err_count=0;
end


semilogy(snr,BER_awgn_BPSK);
ylabel("Bit Error Rate");
xlabel("SNR in dB");
