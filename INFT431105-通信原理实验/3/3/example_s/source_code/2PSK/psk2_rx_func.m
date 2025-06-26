function [ output_args ] = psk2_rx_func( rxdata )
bit_Width = 10;
num = floor(length(rxdata)./(1023*bit_Width));
num_len = num*1023*bit_Width;
rxdata = rxdata(1:num_len);

code_phase=[1,8];%抽头
[inputcode]=code_gen(code_phase);%产生伪码

c2 = repmat(inputcode',1,bit_Width);
descode2 = reshape(c2',1,length(c2).*bit_Width);

%-----产生I、Q两路载波信号-----%
carrier_I=cos(2*pi/bit_Width*[0:bit_Width-1]);
carrier_Q=sin(2*pi/bit_Width*[0:bit_Width-1]);
%-----载波扩展，长度和data_trans相等-----%
carrier_I=repmat(carrier_I,1,num*1023);
carrier_Q=repmat(carrier_Q,1,num*1023);
carrier=carrier_I+1i.*carrier_Q;
rxdata=rxdata.';
rx_i = real(rxdata) .* (carrier_I(1:end));
rx_q = imag(rxdata) .* (carrier_Q(1:end));
rx = rx_i + 1i*rx_q;

x1=rx(1:1023*bit_Width);
x2=descode2;
y1=fft(x1);
y2=fft(x2);
z1=ifft(y2.*conj(y1));
z2=abs(z1).^2;

[~,max_index] = max(z2);
max_index=max_index-1;
now_carrier = carrier(max_index:end);
now_rx_data = rxdata(1:end-max_index+1);
down_rx_i =  real(now_rx_data) .* real(now_carrier);
down_rx_q =  imag(now_rx_data) .* imag(now_carrier);
down_rx = down_rx_i +1i*down_rx_q;
abs_down_rx = abs(down_rx);
flt1=rcosine(1,8,'fir/sqrt',0.05,1);
st_flt_i = rcosflt(down_rx_i, 1, 1, 'filter', flt1);
st_flt_q = rcosflt(down_rx_q, 1, 1, 'filter', flt1);
st_flt_i=st_flt_i.';
st_flt_q=st_flt_q.';
% for i=length(descode2):length(st_flt_i)
%     cor_abs_i(i)=abs((st_flt_i(i-length(descode2)+1:i))*descode2');
%     cor_abs_q(i)=abs((st_flt_q(i-length(descode2)+1:i))*descode2');
% end 

figure(1);clf;
subplot(221);
plot(real(rxdata));
hold on;
plot(imag(rxdata));
subplot(222);
plot(z2);
subplot(223);
plot(down_rx_i(1:120));
hold on;
plot(down_rx_q(1:120));
subplot(224);
plot(st_flt_i(20:end-20));
hold on;
plot(st_flt_q(20:end-20));
% plot(cor_abs_i);
% hold on;
% plot(cor_abs_q);
end

