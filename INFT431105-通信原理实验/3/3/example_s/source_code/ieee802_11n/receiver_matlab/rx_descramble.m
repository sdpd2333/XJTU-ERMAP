%scrambling x^7+x^4+1
function [scramble,out_bits]=rx_descramble(data_bits)
h1=data_bits(1:7);
for k=1:7
    hr=xor(h1(7),h1(3));
    h1(2:7)=h1(1:6);
    h1(1)=hr;
end
scramble=h1(7:-1:1);
h1=h1(7:-1:1);
for i=1:length(data_bits)
h2(i)=xor(h1(7),h1(4));
h1(2:7)=h1(1:6);
h1(1)=h2(i);
end
out_bits=double(xor(data_bits,h2));

