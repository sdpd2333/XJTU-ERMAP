function [ output_args ] = fsk2_rx_func(rxdata)

c1=max(max([abs(real(rxdata)),abs(imag(rxdata))]));
rxdata_norm = rxdata./c1;

%-----解调，采用滤波法，滤除2MHz频率成分-----%
flt1=rcosine(1,8,'fir/sqrt',0.05,1);
st_flt = rcosflt(rxdata_norm, 1, 1, 'filter', flt1);
 data_abs=abs(st_flt);
demod_2fsk=(data_abs>0.6);
demod_2fsk = demod_2fsk.*2-1;

data_ex=demod_2fsk(4:20:end);
demod_2fsk=data_ex(2:end).';

demod_bits = (demod_2fsk+1)./2;


figure(1);clf;
subplot(321);
plot(real(rxdata));
hold on;
plot(imag(rxdata));
title('接收端基带原始信号');
subplot(322);
plot(demod_2fsk);
grid on;
ylim([-1.5 1.5]);
title('包络检波判决信号');
subplot(323);
pwelch(rxdata,[],[],[],20e6,'centered','psd');
subplot(324);
pwelch(st_flt,[],[],[],20e6,'centered','psd');
subplot(325)
text(0.0,0.5,num2str('解调序列：'));
text(0.0,0.1,num2str(demod_bits(1:100)));
axis off;
grid on;
ylim([-1 1]);
end

