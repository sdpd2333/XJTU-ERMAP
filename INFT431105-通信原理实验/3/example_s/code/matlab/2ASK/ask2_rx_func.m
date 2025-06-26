function ask2_rx_func(rxdata)

c1=max(max([abs(real(rxdata)),abs(imag(rxdata))]));
rxdata_norm = rxdata./c1;

demod_2ask = abs(rxdata_norm) > 0.5;
demod_2ask = demod_2ask.*2 - 1;
demod_bits = demod_2ask(1:20:end).';
demod_bits = (demod_bits+1)./2;

figure(1);clf;
subplot(311);
plot(real(rxdata));
hold on;
plot(imag(rxdata));
title('接收端基带原始信号')
subplot(312);
plot(demod_2ask);
grid on;
ylim([-1.5 1.5]);
title('包络检波判决信号');
subplot(313);
text(0.0,0.5,num2str('解调序列：'));
text(0.0,0.1,num2str(demod_bits(1:100)));
axis off;
grid on;
ylim([-1 1]);

end

