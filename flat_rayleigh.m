function [h] = flat_rayleigh(N,fD,Ts)
%Based on the sum-of-sinusoid method described in (1)-(3), write a Matlab
%function to simulate flat Rayleigh fading. The function should have three
%input arguments:
%N: the number of samples to be generated.
%fD:maximum Doppler spread.
%Ts:sample period.

%The output of the function should be the complex valued fading process. In
%the simulator development, using M = 16. 
M=16;
a=0;
b=2*pi;
alpha=a+(b-a)*rand(1,M); % U(0,2pi) - uniformly distributed from 0 to 2pi
beta=a+(b-a)*rand(1,M); % U(0,2pi)
theta=a+(b-a)*rand(1,M); % U(0,2pi)
m=1:M;
for n=1:N
    x=cos(((2.*m-1)*pi+theta)/(4*M));
    h_i(n)=1/sqrt(M)*sum(cos(2*pi*fD*x*n'*Ts+alpha));
    h_q(n)=1/sqrt(M)*sum(sin(2*pi*fD*x*n'*Ts+beta));
end

h= h_i + 1i*h_q;
     
end

