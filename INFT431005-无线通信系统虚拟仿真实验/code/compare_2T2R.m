% 2发2收场景下，调制方式QPSK，对比V-BLAST结构ZF/ZF-SIC与Alamouti方案的误码率性能
clear all
close all
clc

%% 参数设置
Nt = 2;                     % 发射天线数
Nr = 2;                     % 接收天线数
datasize = 10000;           % 仿真的总帧数（V-BLAST每帧发送Nt个符号，Alamouti每两个时隙发送Nt个符号）
EsN0 = 0:2:20;              % 信噪比(dB)，总发射功率与每根接收天线噪声方差之比
P = 1;                      % 总发射功率
M = 16;                      % QPSK调制阶数

%% 预分配存储误码率数组
ber_zf_linear = zeros(1, length(EsN0));      % V-BLAST 线性ZF
ber_zf_sic_nonideal = zeros(1, length(EsN0));% V-BLAST ZF-SIC 非理想干扰消除
ber_zf_sic_ideal = zeros(1, length(EsN0));   % V-BLAST ZF-SIC 理想干扰消除
ber_alamouti = zeros(1, length(EsN0));       % Alamouti方案

%% 主循环：遍历不同信噪比
for index = 1:length(EsN0)
    disp(['仿真信噪比: ', num2str(EsN0(index)), ' dB']);
    
    %% 生成信源数据（同一数据用于V-BLAST和Alamouti，保证公平比较）
    % V-BLAST: 每帧发送 Nt 个符号
    x_vblast = randi([0, M-1], Nt, datasize);
    s_vblast = qammod(x_vblast, M, 'UnitAveragePower', true); % QPSK调制，平均功率归一化
    
    % Alamouti: 也发送 datasize 个符号对（即 2*datasize 个符号）
    % 为了保持总信息量一致，每列两个符号作为一个数据块
    x_alam = randi([0, M-1], Nt, datasize);
    s_alam = qammod(x_alam, M, 'UnitAveragePower', true);
    
    % 计算噪声标准差（每根接收天线）
    sigma_n = sqrt(P / (10^(EsN0(index)/10)) / 2); % 复噪声实部/虚部标准差
    
    %% 初始化临时存储
    s1_linear = [];      % 线性ZF解调符号
    s2_nonideal = [];    % ZF-SIC非理想解调符号
    s3_ideal = [];       % ZF-SIC理想解调符号
    s_alam_demod = [];   % Alamouti解调符号
    
    %% 逐帧仿真
    for frame = 1:datasize
        % ---------- 生成信道矩阵（2x2 瑞利衰落，归一化）----------
        H = (randn(Nr, Nt) + 1j*randn(Nr, Nt)) / sqrt(2);
        
        % ---------- 1. V-BLAST 传输与检测 ----------
        % 发射信号（每根天线功率 P/Nt）
        tx_vblast = sqrt(P/Nt) * s_vblast(:, frame);
        % 接收信号
        noise = sigma_n * (randn(Nr, 1) + 1j*randn(Nr, 1));
        y_vblast = H * tx_vblast + noise;
        
        % QR分解
        [Q, R] = qr(H);
        R = R(1:Nt, :);
        Q = Q(:, 1:Nt);
        y_tilde = Q' * y_vblast;   % 匹配滤波
        
        % (1) 线性ZF检测（无干扰消除）
        y_zf = (R \ y_tilde) / sqrt(P/Nt);
        s1_linear = [s1_linear, qamdemod(y_zf, M, 'UnitAveragePower', true)];
        
        % (2) ZF-SIC 检测（非理想干扰消除）
        y_sic = y_tilde;
        x_hat_sic = zeros(Nt, 1);
        % 从最后一层开始检测
        for layer = Nt:-1:1
            % 当前层判决统计量
            y_sic(layer) = y_sic(layer) / R(layer, layer) / sqrt(P/Nt);
            x_hat_sic(layer) = qamdemod(y_sic(layer), M, 'UnitAveragePower', true);
            % 非理想：用解调再调制符号进行干扰消除
            sym_remod = qammod(x_hat_sic(layer), M, 'UnitAveragePower', true);
            % 从上层信号中减去该层的干扰
            for k = 1:layer-1
                y_sic(k) = y_sic(k) - R(k, layer) * sqrt(P/Nt) * sym_remod;
            end
        end
        s2_nonideal = [s2_nonideal, x_hat_sic];
        
        % (3) ZF-SIC 检测（理想干扰消除，使用原始发送符号）
        y_ideal = y_tilde;
        x_hat_ideal = zeros(Nt, 1);
        for layer = Nt:-1:1
            y_ideal(layer) = y_ideal(layer) / R(layer, layer) / sqrt(P/Nt);
            x_hat_ideal(layer) = qamdemod(y_ideal(layer), M, 'UnitAveragePower', true);
            % 理想消除：直接使用真实的发送符号（仅用于性能上界分析）
            sym_true = s_vblast(layer, frame);
            for k = 1:layer-1
                y_ideal(k) = y_ideal(k) - R(k, layer) * sqrt(P/Nt) * sym_true;
            end
        end
        s3_ideal = [s3_ideal, x_hat_ideal];
        
        % ---------- 2. Alamouti 传输方案 (2x2) ----------
        s1 = s_alam(1, frame);
        s2 = s_alam(2, frame);
        
        % Alamouti 空时编码矩阵（每根天线功率 P/2）
        X = sqrt(P/2) * [ s1, -conj(s2);
                          s2,  conj(s1) ];
        
        % 经过信道（两个时隙）
        Y = H * X;  % 2x2 接收矩阵，每列对应一个时隙
        
        % 加噪声
        N1 = sigma_n * (randn(Nr, 1) + 1j*randn(Nr, 1));
        N2 = sigma_n * (randn(Nr, 1) + 1j*randn(Nr, 1));
        Y(:, 1) = Y(:, 1) + N1;
        Y(:, 2) = Y(:, 2) + N2;
        
        % Alamouti 合并（每根接收天线独立合并后相加）
        % 提取信道系数
        h11 = H(1,1); h12 = H(1,2);
        h21 = H(2,1); h22 = H(2,2);
        
        % 接收天线1的合并
        r11 = Y(1,1);  r12 = Y(1,2);
        s_tilde1_1 = conj(h11)*r11 + h12*conj(r12);
        s_tilde2_1 = conj(h12)*r11 - h11*conj(r12);
        
        % 接收天线2的合并
        r21 = Y(2,1);  r22 = Y(2,2);
        s_tilde1_2 = conj(h21)*r21 + h22*conj(r22);
        s_tilde2_2 = conj(h22)*r21 - h21*conj(r22);
        
        % 最大比合并（相加）
        s_tilde1 = s_tilde1_1 + s_tilde1_2;
        s_tilde2 = s_tilde2_1 + s_tilde2_2;
        
        % 计算等效信道增益（考虑发射功率缩放）
        channel_gain = (abs(h11)^2 + abs(h12)^2 + abs(h21)^2 + abs(h22)^2) * sqrt(P/2);
        
        % 判决变量
        s1_hat = s_tilde1 / channel_gain;
        s2_hat = s_tilde2 / channel_gain;
        
        % 解调
        x1_hat = qamdemod(s1_hat, M, 'UnitAveragePower', true);
        x2_hat = qamdemod(s2_hat, M, 'UnitAveragePower', true);
        s_alam_demod = [s_alam_demod, [x1_hat; x2_hat]];
    end
    
    %% 计算当前信噪比下的误码率
    % V-BLAST 线性ZF
    [~, ber_zf_linear(index)] = biterr(x_vblast, s1_linear, log2(M));
    % V-BLAST ZF-SIC 非理想
    [~, ber_zf_sic_nonideal(index)] = biterr(x_vblast, s2_nonideal, log2(M));
    % V-BLAST ZF-SIC 理想
    [~, ber_zf_sic_ideal(index)] = biterr(x_vblast, s3_ideal, log2(M));
    % Alamouti
    [~, ber_alamouti(index)] = biterr(x_alam, s_alam_demod, log2(M));
end

%% 绘制性能对比图
figure;
semilogy(EsN0, ber_zf_linear, '-ko');
hold on;
semilogy(EsN0, ber_zf_sic_nonideal, '-r*');
semilogy(EsN0, ber_zf_sic_ideal, '-gv');
semilogy(EsN0, ber_alamouti, '-bs');
hold off;
grid on;
title('准静态瑞利衰落信道下误码性能，Alamouti VS VBLAST');
xlabel('信噪比 E_s/N_0 (dB)');
ylabel('误比特率 (BER)');
legend('V-BLAST 线性ZF', 'V-BLAST ZF-SIC (非理想)', ...
       'V-BLAST ZF-SIC (理想)', 'Alamouti (2T2R)', 'Location', 'southwest');
set(gca, 'YScale', 'log');
axis([0 20 1e-5 1]);

%% 保存数据
save('comparison_VBLAST_Alamouti_QPSK_2T2R.mat', ...
     'EsN0', 'ber_zf_linear', 'ber_zf_sic_nonideal', 'ber_zf_sic_ideal', 'ber_alamouti');