N=10^6;
snr=-10:0.1:30;

%EbNo = 0:2:20;
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
    h1 =randn(1,N)+ img*randn(1,N); 
    h2 =randn(1,N)+ img*randn(1,N); 
    c1=h1.*x_in;
    y1=awgn(c1,snr(i),'measured');
    c2=h2.*x_in;
    y2=awgn(c2,snr(i),'measured');
    
    %Receiver 1
    y_rec1=y1./h1;
    for j=1:N
        if(real(y_rec1(j))>0)
            y_quant(j)=1;
        else if(real(y_rec1(j))<0)
            y_quant(j)=-1;
            end
        end
    end
    for k=1:N
        if(y_quant(k)~=x_in(k))
            err_count=err_count+1;
        end
    end
    ber_temp1=err_count/N;
    %BER_flat_fading_BPSK(i)=ber_temp;
    err_count=0;
    
    %Receiver 2
    y_rec2=y2./h2;
    for j=1:N
        if(real(y_rec2(j))>0)
            y_quant(j)=1;
        else if(real(y_rec2(j))<0)
            y_quant(j)=-1;
            end
        end
    end
    for k=1:N
        if(y_quant(k)~=x_in(k))
            err_count=err_count+1;
        end
    end
    ber_temp2=err_count/N;
    %BER_flat_fading_BPSK(i)=ber_temp;
    err_count=0;
    
    % Combined Receiver
    y_rec_comb = y1.*conj(h1) + y2.*conj(h2);
    for j=1:N
        if(real(y_rec_comb(j))>0)
            y_quant(j)=1;
        else if(real(y_rec_comb(j))<0)
            y_quant(j)=-1;
            end
        end
    end
    for k=1:N
        if(y_quant(k)~=x_in(k))
            err_count=err_count+1;
        end
    end
    ber_temp_comb=err_count/N;
    err_count=0; 
    
   % Calculate Bit Error Rate
    BER_flat_fading_BPSK(i)= (ber_temp1 + ber_temp2 + ber_temp_comb)/3;
end
figure;
semilogy(snr,BER_awgn_BPSK,'Color','blue');
%x = 0.5*erfc(sqrt(10.^(snr/10)));
%theoretical = qfunc(sqrt(EbN0));
%plot(snr, x)
hold on;
semilogy(snr,BER_flat_fading_BPSK,'Color','red');
legend('AWGN Channel','SIMO');
ylabel("Bit Error Rate");
xlabel("SNR in dB");