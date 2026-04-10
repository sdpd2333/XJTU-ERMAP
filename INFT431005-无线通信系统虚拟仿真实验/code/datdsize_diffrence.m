%Alamouti方案在瑞利衰落信道下的性能
clear all
clf
Datasize1 = 1000;                             %信源符号数
Datasize2 = 10000;   
Datasize3 = 100000;   
EsN0 = 0:2:20;                                  %比特信噪比，dB为单位
Nt=2;                                           %发射天线数
P=1;                                            %每个映射符号的总功率，若为QPSK映射，每2个比特映射为1个符号，则每比特功率为0.5
M = 4;                                         %QPSK调制M=4，8QAM M=8，16QAM M=16

for index=1:length(EsN0)
    Input_symbols = randsrc(2,Datasize1/2,[0:(M-1)]);                %生成信源数据流
    Input_symbols_qam = qammod(Input_symbols,M,'UnitAveragePower', true);%QAM调制，功率归一化，Gray编码
    H = randn(2,Datasize1/2)/sqrt(2) +j*randn(2,Datasize1/2)/sqrt(2); %生成Rayleigh衰落信道矩阵，2*(Datasize/2)维，
                                                                    %每一列的2个信道系数对应两根发射天线到接收机的信道信息，且两个相邻时隙保持一样
                                                                    %实部和虚部除以sqrt(2)是为了保证每个信道系数能量归一化
    
    sigma = sqrt((P/2)/(10.^(EsN0(index)/10))); %根据信噪比计算高斯白噪声标准差
    n = sigma*(randn(2,Datasize1/2)+j*randn(2,Datasize1/2));%生成噪声矩阵，2*(Datasize/2)维，每一列的2个噪声符号对应一对符号在相邻两个时隙上发送时，各时隙接收机处噪声
    %2发1收Alamouti方案
    y=zeros(2,Datasize1/2);
    Ha=zeros(2,2);
    for ii=1:(Datasize1/2)
        %逐个符号对处理，按照传输信号模型仿真Alamouti编码和信号通过信道传输的过程
        %生成每个块的第1个和第2个时隙的接收信号
        y(1,ii)=[H(1,ii),H(2,ii)]*[sqrt(P/Nt)*Input_symbols_qam(1,ii),sqrt(P/Nt)*Input_symbols_qam(2,ii)].'+n(1,ii);%第1个时隙两根天线上分别发送x1和x2,发送符号*sqrt(P/Nt)是为了控制每根天线的发射功率为P/Nt
        y(2,ii)=[H(1,ii),H(2,ii)]*[sqrt(P/Nt)*(-1)*Input_symbols_qam(2,ii)',sqrt(P/Nt)*Input_symbols_qam(1,ii)'].'+n(2,ii);%第2个时隙两根天线上分别发送-x2'和x1'
        %对接收信号进行解码和解映射
        %先构造解码矩阵Ha,此处假设接收端理想已知信道矩阵，在实际系统中要通过发射端插入导频符号，接收端进行信道估计，才能得到信道矩阵信息
        Ha=[H(1,ii),H(2,ii);H(2,ii)',(-1)*H(1,ii)'];
        %对两个时隙的接收信号进行变形
        y1=[y(1,ii);y(2,ii)'];
        %利用正交特性对接收信号进行处理，解耦两个发送符号的传输
        y2=Ha'*y1/(sum(H(:,ii).*conj(H(:,ii))))/sqrt(P/Nt);%除以信道系数平方和是做信道均衡，且QAM星座发送端对星座符号进行了功率缩放，接收端解映射前需对缩放进行逆处理
        y3(:,ii)=y2;
    end
    Output_symbols_MQAM = qamdemod(y3,M,'UnitAveragePower', true);
    [err_num,ber1(index)] = biterr(Input_symbols,Output_symbols_MQAM,log2(M));
end
for index=1:length(EsN0)
    Input_symbols = randsrc(2,Datasize2/2,[0:(M-1)]);                %生成信源数据流
    Input_symbols_qam = qammod(Input_symbols,M,'UnitAveragePower', true);%QAM调制，功率归一化，Gray编码
    H = randn(2,Datasize2/2)/sqrt(2) +j*randn(2,Datasize2/2)/sqrt(2); %生成Rayleigh衰落信道矩阵，2*(Datasize/2)维，
                                                                    %每一列的2个信道系数对应两根发射天线到接收机的信道信息，且两个相邻时隙保持一样
                                                                    %实部和虚部除以sqrt(2)是为了保证每个信道系数能量归一化
    
    sigma = sqrt((P/2)/(10.^(EsN0(index)/10))); %根据信噪比计算高斯白噪声标准差
    n = sigma*(randn(2,Datasize2/2)+j*randn(2,Datasize2/2));%生成噪声矩阵，2*(Datasize/2)维，每一列的2个噪声符号对应一对符号在相邻两个时隙上发送时，各时隙接收机处噪声
    %2发1收Alamouti方案
    y=zeros(2,Datasize2/2);
    Ha=zeros(2,2);
    for ii=1:(Datasize2/2)
        %逐个符号对处理，按照传输信号模型仿真Alamouti编码和信号通过信道传输的过程
        %生成每个块的第1个和第2个时隙的接收信号
        y(1,ii)=[H(1,ii),H(2,ii)]*[sqrt(P/Nt)*Input_symbols_qam(1,ii),sqrt(P/Nt)*Input_symbols_qam(2,ii)].'+n(1,ii);%第1个时隙两根天线上分别发送x1和x2,发送符号*sqrt(P/Nt)是为了控制每根天线的发射功率为P/Nt
        y(2,ii)=[H(1,ii),H(2,ii)]*[sqrt(P/Nt)*(-1)*Input_symbols_qam(2,ii)',sqrt(P/Nt)*Input_symbols_qam(1,ii)'].'+n(2,ii);%第2个时隙两根天线上分别发送-x2'和x1'
        %对接收信号进行解码和解映射
        %先构造解码矩阵Ha,此处假设接收端理想已知信道矩阵，在实际系统中要通过发射端插入导频符号，接收端进行信道估计，才能得到信道矩阵信息
        Ha=[H(1,ii),H(2,ii);H(2,ii)',(-1)*H(1,ii)'];
        %对两个时隙的接收信号进行变形
        y1=[y(1,ii);y(2,ii)'];
        %利用正交特性对接收信号进行处理，解耦两个发送符号的传输
        y2=Ha'*y1/(sum(H(:,ii).*conj(H(:,ii))))/sqrt(P/Nt);%除以信道系数平方和是做信道均衡，且QAM星座发送端对星座符号进行了功率缩放，接收端解映射前需对缩放进行逆处理
        y3(:,ii)=y2;
    end
    Output_symbols_MQAM = qamdemod(y3,M,'UnitAveragePower', true);
    [err_num,ber2(index)] = biterr(Input_symbols,Output_symbols_MQAM,log2(M));
end
for index=1:length(EsN0)
    Input_symbols = randsrc(2,Datasize3/2,[0:(M-1)]);                %生成信源数据流
    Input_symbols_qam = qammod(Input_symbols,M,'UnitAveragePower', true);%QAM调制，功率归一化，Gray编码
    H = randn(2,Datasize3/2)/sqrt(2) +j*randn(2,Datasize3/2)/sqrt(2); %生成Rayleigh衰落信道矩阵，2*(Datasize/2)维，
                                                                    %每一列的2个信道系数对应两根发射天线到接收机的信道信息，且两个相邻时隙保持一样
                                                                    %实部和虚部除以sqrt(2)是为了保证每个信道系数能量归一化
    
    sigma = sqrt((P/2)/(10.^(EsN0(index)/10))); %根据信噪比计算高斯白噪声标准差
    n = sigma*(randn(2,Datasize3/2)+j*randn(2,Datasize3/2));%生成噪声矩阵，2*(Datasize/2)维，每一列的2个噪声符号对应一对符号在相邻两个时隙上发送时，各时隙接收机处噪声
    %2发1收Alamouti方案
    y=zeros(2,Datasize3/2);
    Ha=zeros(2,2);
    for ii=1:(Datasize3/2)
        %逐个符号对处理，按照传输信号模型仿真Alamouti编码和信号通过信道传输的过程
        %生成每个块的第1个和第2个时隙的接收信号
        y(1,ii)=[H(1,ii),H(2,ii)]*[sqrt(P/Nt)*Input_symbols_qam(1,ii),sqrt(P/Nt)*Input_symbols_qam(2,ii)].'+n(1,ii);%第1个时隙两根天线上分别发送x1和x2,发送符号*sqrt(P/Nt)是为了控制每根天线的发射功率为P/Nt
        y(2,ii)=[H(1,ii),H(2,ii)]*[sqrt(P/Nt)*(-1)*Input_symbols_qam(2,ii)',sqrt(P/Nt)*Input_symbols_qam(1,ii)'].'+n(2,ii);%第2个时隙两根天线上分别发送-x2'和x1'
        %对接收信号进行解码和解映射
        %先构造解码矩阵Ha,此处假设接收端理想已知信道矩阵，在实际系统中要通过发射端插入导频符号，接收端进行信道估计，才能得到信道矩阵信息
        Ha=[H(1,ii),H(2,ii);H(2,ii)',(-1)*H(1,ii)'];
        %对两个时隙的接收信号进行变形
        y1=[y(1,ii);y(2,ii)'];
        %利用正交特性对接收信号进行处理，解耦两个发送符号的传输
        y2=Ha'*y1/(sum(H(:,ii).*conj(H(:,ii))))/sqrt(P/Nt);%除以信道系数平方和是做信道均衡，且QAM星座发送端对星座符号进行了功率缩放，接收端解映射前需对缩放进行逆处理
        y3(:,ii)=y2;
    end
    Output_symbols_MQAM = qamdemod(y3,M,'UnitAveragePower', true);
    [err_num,ber3(index)] = biterr(Input_symbols,Output_symbols_MQAM,log2(M));
end
figure(1)
semilogy(EsN0,ber1,'-ro',EsN0,ber2,'-b*',EsN0,ber3,'-k+')
%semilogy(EsN0,ber1,'-ro',EsN0,ber3,'-r+')
%axis([0 15 10^-4 1]) 
grid on
legend('仿真1000次2发1收Alamouti方案','仿真10000次2发1收Alamouti方案','仿真100000次2发1收Alamouti方案')
xlabel('信噪比Es/N0')
ylabel('误比特率（BER）')
title('Alamouti方案在准静态瑞利衰落信道下的误码率性能')
save('data_singleRX_1000.mat','EsN0','ber1');
save('data_singleRX_10000.mat','EsN0','ber2');
save('data_singleRX_100000.mat','EsN0','ber3');
