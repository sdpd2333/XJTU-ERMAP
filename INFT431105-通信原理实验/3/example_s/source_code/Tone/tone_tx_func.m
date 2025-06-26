function txdata = tone_tx_func()

a=cos(2*pi/32*[0:31].');
b=sin(2*pi/32*[0:31].');
c=a+1i*b;
txdata=repmat(c,32,1);

pwelch(txdata,[],[],[],40e6,'centered','psd');

end

