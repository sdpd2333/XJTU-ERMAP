function [UW_Ge] = UW_Generate( U )
%   产生Frank_Zadoff序列的独特字UW
%   输入U为产生UW序列的长度
%   输出为U*1的Frank_Zadoff序列
F = zeros(1,U);
UW_Ge = zeros(1,U);

for q = 0:(sqrt(U)-1)
    for p = 0:(sqrt(U)-1)
        F(p+q*sqrt(U)+1) = 2*pi*p*q/sqrt(U);
    end
end

I = cos(F);
Q = sin(F);
UW_Ge = I + j*Q;
end

