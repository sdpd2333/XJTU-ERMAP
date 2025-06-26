function [ ret ] = tone_rx_func( rxdata, rx_sampling_freq)

for i=1:size(rxdata,2)
    subplot(size(rxdata,2),3,(i-1)*3+1);
    plot(real(rxdata(:,i)));hold on;plot(imag(rxdata(:,i)));
    subplot(size(rxdata,2),3,(i-1)*3+2);
    plot(rxdata(:,i));axis equal;
    subplot(size(rxdata,2),3,(i-1)*3+3);
    pwelch(rxdata(:,i),[],[],[],rx_sampling_freq,'centered','psd');
end
ret='plot ok';

end

