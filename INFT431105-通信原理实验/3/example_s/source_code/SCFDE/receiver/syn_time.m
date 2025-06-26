function [C]=syn_time(data)
Ns=128;
N=length(data);
N1=320;

r=data;
t1=zeros(1,N);
t2=zeros(1,N);

C=zeros(1,N);%原相关值对能量值归一化
C1=zeros(1,N+4);%用循环前缀进一步归一化

tt=0;
for timing=1:N-700
    for m=1:2*Ns
        t1(timing)=t1(timing)+0.5*((abs(r(m+timing)))^2);%整个序列能量值，除了1/2
    end 
    for m=1:Ns
        t2(timing)=t2(timing)+conj(r(m+timing))*r(m+Ns+timing);%前半序列和后半序列相关值
    end
    C(1,timing)=(abs(t2(timing))^2)/(t1(timing)^2);%相关值对能量值归一化

end
for timing=65:N-700  %利用训练序列的循环前缀设定一个滑动运算窗口对序列进行归一化
    for i=-64:0
        C1(1,timing)= C1(1,timing)+(1/65)*C(1,i+timing);
    end
end 
[Y,I]=max(abs(C1));
timing_coarse=I-384;
C=abs(C1);

end