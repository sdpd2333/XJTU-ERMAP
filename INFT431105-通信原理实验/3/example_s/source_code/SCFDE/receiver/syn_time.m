function [C]=syn_time(data)
Ns=128;
N=length(data);
N1=320;

r=data;
t1=zeros(1,N);
t2=zeros(1,N);

C=zeros(1,N);%ԭ���ֵ������ֵ��һ��
C1=zeros(1,N+4);%��ѭ��ǰ׺��һ����һ��

tt=0;
for timing=1:N-700
    for m=1:2*Ns
        t1(timing)=t1(timing)+0.5*((abs(r(m+timing)))^2);%������������ֵ������1/2
    end 
    for m=1:Ns
        t2(timing)=t2(timing)+conj(r(m+timing))*r(m+Ns+timing);%ǰ�����кͺ���������ֵ
    end
    C(1,timing)=(abs(t2(timing))^2)/(t1(timing)^2);%���ֵ������ֵ��һ��

end
for timing=65:N-700  %����ѵ�����е�ѭ��ǰ׺�趨һ���������㴰�ڶ����н��й�һ��
    for i=-64:0
        C1(1,timing)= C1(1,timing)+(1/65)*C(1,i+timing);
    end
end 
[Y,I]=max(abs(C1));
timing_coarse=I-384;
C=abs(C1);

end