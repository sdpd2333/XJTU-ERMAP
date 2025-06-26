% CombFilter.m --- Designed by pcmu@mail.xjtu.edu.cn
%
% Description
%   function y=CombFilter(x,N,r)
%       Comb filter
% Parameters
%   x:          Input signal
%   N:          Order of the comb filter
%   r:          Radius
% Return
%   y:          Output signal

function y=CombFilter(x,N,r)

L=length(x);
y=zeros(1,L+N);
if L>=N
    y(1:N)=x(1:N);
    for n=N+1:L
        y(n)=x(n)-x(n-N)*r^N;
    end
    y(L+1:L+N)=-x(L+1-N:L)*r^N;
else
    y(1:L)=x(1:L);
    for n=N+1:N+L
        y(n)=-x(n-N)*r^N;
    end
end