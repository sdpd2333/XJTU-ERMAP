%仿真V-BLAST结构ZF检测算法性能
clear all
clf
Nt = 2; %发射天线数
Nr = 2; %接收天线数
datasize = 10000; %仿真的总帧数
EsN0 = 0:2:20;%信噪比，总发射功率比每根接收天线的噪声方差
P=1;     %总发射功率为1
M = 4;   %QAM调制

for index=1:length(EsN0)
    x = randi([0,(M-1)],Nt,datasize); %信源数据
    s = qammod(x,M,'UnitAveragePower', true); %QAM调制,Gray映射，功率归一化
    s1 = [];
    s2 = [];
    s3 = [];
    for index1 = 1:datasize
        h = randn(Nr,Nt)+j*randn(Nr,Nt); %Rayleigh衰落信道
        h = h./sqrt(2); %信道系数归一化
        sigma1 = sqrt(P/(10.^(EsN0(index)/10))/2); %每根接收天线的高斯白噪声标准差
        n = sigma1*(randn(Nr,1)+j*randn(Nr,1)); %每根接收天线的高斯白噪声
        
        y =h*sqrt(P/Nt)*s(:,index1)+n; %信号通过信道,乘以sqrt(P/Nt)是为了保持每根天线发射功率为P/Nt
        [q1,r1] = qr(h); %信道QR分解
        r = r1(1:Nt,:); %矩阵R
        q = q1(:,1:Nt); %矩阵Q
        y =q'*y; %用Q矩阵对接收信号矢量进行处理
       
        %检测算法1：线性ZF检测，无串行干扰消除       
        y1 = inv(r)*y/sqrt(P/Nt); 
        s1 = [s1,qamdemod(y1,M,'UnitAveragePower', true)];%s1为采用线性ZF检测的解调信号
        
        %检测算法2和3：基于ZF的串行干扰抵消检测,非理想和理想干扰消除
        y(Nt) = y(Nt)./(r(Nt,Nt))/sqrt(P/Nt); %检测第Nt层,QAM星座发送端对星座符号进行了功率缩放，接收端解映射前需对缩放进行逆处理
        y1(Nt) = qamdemod(y(Nt),M,'UnitAveragePower', true); %解调第Nt层
        y(Nt) = qammod(y1(Nt),M,'UnitAveragePower', true); %对第Nt层解调结果重新进行调制
        y2 = y;%理想干扰抵消后信号
        y3 = y1;%基于ZF检测的干扰抵消后信号
        for jj=Nt-1:-1:1
            for kk=jj+1:Nt
                y(jj) = y(jj)-r(jj,kk).*sqrt(P/Nt)*y(kk); %非理想干扰消除
                y2(jj) = y2(jj)-r(jj,kk).*sqrt(P/Nt)*s(kk,index1); %理想干扰消除
            end
            y(jj) = y(jj)./r(jj,jj)/sqrt(P/Nt); %非理想，第jj层判决统计量
            y2(jj) = y2(jj)./r(jj,jj)/sqrt(P/Nt); %理想，第jj层判决统计量
            y1(jj) = qamdemod(y(jj),M,'UnitAveragePower', true); %非理想，第jj层进行解调
            y3(jj) = qamdemod(y2(jj),M,'UnitAveragePower', true);%理想，第jj层进行解调
            y(jj) = qammod(y1(jj),M,'UnitAveragePower', true); %非理想，第jj层解调结果重新进行调制
            y2(jj) = qammod(y3(jj),M,'UnitAveragePower', true);%理想，第jj层解调结果重新进行调制，理想抵消时暂未使用
        end
        s2 = [s2,y1];
        s3 = [s3,y3];
    end
    
    [temp,ber1(index)] = biterr(x,s1,log2(M)); %无干扰消除时的系统误码
    [temp,ber2(index)] = biterr(x,s2,log2(M)); %非理想干扰消除时的系统误码
    [temp,ber3(index)] = biterr(x,s3,log2(M)); %理想干扰消除时的系统误码
    
    [temp,ber21(index)] = biterr(x(1,:),s2(1,:),log2(M)); %非理想干扰消除时第1层的系统误码
    [temp,ber22(index)] = biterr(x(2,:),s2(2,:),log2(M)); %非理想干扰消除时第2层的系统误码

    
    [temp,ber31(index)] = biterr(x(1,:),s3(1,:),log2(M)); %理想干扰消除时第1层的系统误码
    [temp,ber32(index)] = biterr(x(2,:),s3(2,:),log2(M)); %理想干扰消除时第2层的系统误码

    
end
 
semilogy(EsN0,ber1,'-ko',EsN0,ber2,'-r*',EsN0,ber3,'-gv')
title('V-BLAST各种检测算法的性能对比')
legend('无干扰消除，线性ZF','非理想干扰消除', '理想干扰消除')
xlabel('信噪比Es/N0')
ylabel('误比特率（BER）')
 
figure
semilogy(EsN0,ber31,'-ko',EsN0,ber32,'-r*')
title('V-BLAST结构ZF-SIC检测算法性能，理想干扰消除')
legend('第1层','第2层')
xlabel('信噪比Es/N0')
ylabel('误比特率（BER）')
 
figure
semilogy(EsN0,ber21,'-ko',EsN0,ber22,'-r*')
title('V-BLAST结构ZF-SIC检测算法性能,非理想干扰消除')
legend('第1层','第2层')
xlabel('信噪比Es/N0')
ylabel('误比特率（BER）')

save('data_VBLAST_QPSK_2T2R.mat','EsN0','ber1','ber2','ber3','ber21','ber22','ber31','ber32');










