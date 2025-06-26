% Resonator2.m --- Designed by pcmu@mail.xjtu.edu.cn
%
% Description
%   function y=Resonator2(x,N,r,Order,H)
%       Resonator of order 2 to obtain real-valued harmonics
% Parameters
%   x:          Input signal
%   N:          Order of the comb filter
%   r:          Radius
%   Order:      Order of the resonator
%   H:          Magnification coeficient of the resonator
% Return
%   y:          Output signal

function y=Resonator2(x,N,r,Order,H)

if Order<0
    display('Order should not be negative in function Resonator2!');
elseif Order>N/2
    display('Order should not be greater than N/2 in function Resonator2!');
else
    L=length(x);
    f=zeros(1,L);
    y=zeros(1,L);
    if mod(N,2)==0

       if Order==0
            y(1)=x(1)*H;
            for n=2:L
                y(n)=H*x(n)+y(n-1)*r;
            end
        elseif Order==N/2
            y(1)=x(1)*H;
            for n=2:L
                y(n)=H*x(n)-y(n-1)*r;
            end
        else
            w=exp(1i*2*pi*Order/N);
            alfa0=2*real(H);
            alfa1=-2*r*real(H.*conj(w));
            beta1=2*r*cos(2*pi*Order/N);
            beta2=-r^2;
            f(1)=x(1); y(1)=f(1)*alfa0;
            f(2)=x(2)+f(1)*beta1; y(2)=f(2)*alfa0+f(1)*alfa1;
            for n=3:L
                f(n)=x(n)+f(n-1)*beta1-f(n-2)*r^2;
                y(n)=f(n)*alfa0+f(n-1)*alfa1;
            end
        end
    else
        if Order==0
            y(1)=x(1)*H;
            for n=2:L
                y(n)=H*x(n)+y(n-1)*r;
            end
        else
            w=exp(1i*2*pi*Order/N);
            alfa0=2*real(H);
            alfa1=-2*r*real(H.*conj(w));
            beta1=2*r*cos(2*pi*Order/N);
            beta2=-r^2;
            f(1)=x(1); y(1)=f(1)*alfa0;
            f(2)=x(2)+f(1)*beta1; y(2)=f(2)*alfa0+f(1)*alfa1;
            for n=3:L
                f(n)=x(n)+f(n-1)*beta1-f(n-2)*r^2;
                y(n)=f(n)*alfa0+f(n-1)*alfa1;
            end
        end
    end
end