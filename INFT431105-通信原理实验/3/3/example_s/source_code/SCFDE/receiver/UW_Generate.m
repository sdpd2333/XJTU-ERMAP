function [UW_Ge] = UW_Generate( U )
%   ����Frank_Zadoff���еĶ�����UW
%   ����UΪ����UW���еĳ���
%   ���ΪU*1��Frank_Zadoff����
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

