% 2发2收 Alamouti方案 BER仿真
clear all
clf

Datasize = 4000000;
EsN0 = 0:2:20;
Nt = 2;
Nr = 2;
P = 1;

M1 = 4;
M2 = 8;
M3 = 16;

%% ===================== QPSK =====================
for index = 1:length(EsN0)

    Input_symbols = randsrc(2,Datasize/2,[0:(M1-1)]);
    Input_symbols_qam = qammod(Input_symbols,M1,'UnitAveragePower',true);

    % 信道：2Rx × 2Tx × N
    H = randn(Nr,Nt,Datasize/2)/sqrt(2) + 1j*randn(Nr,Nt,Datasize/2)/sqrt(2);

    sigma = sqrt((P/2)/(10^(EsN0(index)/10)));
    n = sigma*(randn(Nr,Datasize/2)+1j*randn(Nr,Datasize/2));

    y3 = zeros(2,Datasize/2);

    for ii = 1:(Datasize/2)

        y1_total = zeros(2,1);
        H_power = 0;

        for r = 1:Nr
            h1 = H(r,1,ii);
            h2 = H(r,2,ii);

            % 两个时隙接收信号
            y1 = h1*sqrt(P/Nt)*Input_symbols_qam(1,ii) + ...
                 h2*sqrt(P/Nt)*Input_symbols_qam(2,ii) + n(r,ii);

            y2 = h1*sqrt(P/Nt)*(-conj(Input_symbols_qam(2,ii))) + ...
                 h2*sqrt(P/Nt)*(conj(Input_symbols_qam(1,ii)));

            % Alamouti 解码矩阵
            Ha = [h1 h2;
                  conj(h2) -conj(h1)];

            y_vec = [y1; conj(y2)];

            y1_total = y1_total + Ha' * y_vec;
            H_power = H_power + (abs(h1)^2 + abs(h2)^2);
        end

        y3(:,ii) = y1_total / H_power / sqrt(P/Nt);
    end

    Output_symbols = qamdemod(y3,M1,'UnitAveragePower',true);
    [~, ber1(index)] = biterr(Input_symbols,Output_symbols,log2(M1));
    if ber1(index) == 0
        ber1(index) = 1/(Datasize*log2(M1));
    end
end

save('data_doubleRX_QPSK.mat','EsN0','ber1');


%% ===================== 8QAM =====================
for index = 1:length(EsN0)

    Input_symbols = randsrc(2,Datasize/2,[0:(M2-1)]);
    Input_symbols_qam = qammod(Input_symbols,M2,'UnitAveragePower',true);

    H = randn(Nr,Nt,Datasize/2)/sqrt(2) + 1j*randn(Nr,Nt,Datasize/2)/sqrt(2);

    sigma = sqrt((P/2)/(10^(EsN0(index)/10)));
    n = sigma*(randn(Nr,Datasize/2)+1j*randn(Nr,Datasize/2));

    y3 = zeros(2,Datasize/2);

    for ii = 1:(Datasize/2)

        y1_total = zeros(2,1);
        H_power = 0;

        for r = 1:Nr
            h1 = H(r,1,ii);
            h2 = H(r,2,ii);

            y1 = h1*sqrt(P/Nt)*Input_symbols_qam(1,ii) + ...
                 h2*sqrt(P/Nt)*Input_symbols_qam(2,ii) + n(r,ii);

            y2 = h1*sqrt(P/Nt)*(-conj(Input_symbols_qam(2,ii))) + ...
                 h2*sqrt(P/Nt)*(conj(Input_symbols_qam(1,ii)));

            Ha = [h1 h2;
                  conj(h2) -conj(h1)];

            y_vec = [y1; conj(y2)];

            y1_total = y1_total + Ha' * y_vec;
            H_power = H_power + (abs(h1)^2 + abs(h2)^2);
        end

        y3(:,ii) = y1_total / H_power / sqrt(P/Nt);
    end

    Output_symbols = qamdemod(y3,M2,'UnitAveragePower',true);
    [~, ber1(index)] = biterr(Input_symbols,Output_symbols,log2(M2));
    if ber1(index) == 0
        ber1(index) = 1/(Datasize*log2(M2));
    end
end

save('data_doubleRX_8QAM.mat','EsN0','ber1');


%% ===================== 16QAM =====================
for index = 1:length(EsN0)

    Input_symbols = randsrc(2,Datasize/2,[0:(M3-1)]);
    Input_symbols_qam = qammod(Input_symbols,M3,'UnitAveragePower',true);

    H = randn(Nr,Nt,Datasize/2)/sqrt(2) + 1j*randn(Nr,Nt,Datasize/2)/sqrt(2);

    sigma = sqrt((P/2)/(10^(EsN0(index)/10)));
    n = sigma*(randn(Nr,Datasize/2)+1j*randn(Nr,Datasize/2));

    y3 = zeros(2,Datasize/2);

    for ii = 1:(Datasize/2)

        y1_total = zeros(2,1);
        H_power = 0;

        for r = 1:Nr
            h1 = H(r,1,ii);
            h2 = H(r,2,ii);

            y1 = h1*sqrt(P/Nt)*Input_symbols_qam(1,ii) + ...
                 h2*sqrt(P/Nt)*Input_symbols_qam(2,ii) + n(r,ii);

            y2 = h1*sqrt(P/Nt)*(-conj(Input_symbols_qam(2,ii))) + ...
                 h2*sqrt(P/Nt)*(conj(Input_symbols_qam(1,ii)));

            Ha = [h1 h2;
                  conj(h2) -conj(h1)];

            y_vec = [y1; conj(y2)];

            y1_total = y1_total + Ha' * y_vec;
            H_power = H_power + (abs(h1)^2 + abs(h2)^2);
        end

        y3(:,ii) = y1_total / H_power / sqrt(P/Nt);
    end

    Output_symbols = qamdemod(y3,M3,'UnitAveragePower',true);
    [~, ber1(index)] = biterr(Input_symbols,Output_symbols,log2(M3));
    if ber1(index) == 0
        ber1(index) = 1/(Datasize*log2(M3));
    end
end

save('data_doubleRX_16QAM.mat','EsN0','ber1');