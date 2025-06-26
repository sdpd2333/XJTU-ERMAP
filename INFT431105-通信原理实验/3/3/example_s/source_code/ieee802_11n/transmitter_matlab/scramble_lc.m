%scrambling x^7+x^4+1
function scramble_bits=scramble_lc(data_bits,sim_options)
data_bits_length=length(data_bits);
h1=[1,0,1,1,1,0,1];
for i=1:data_bits_length
h2(i)=xor(h1(7),h1(4));
h1(2:7)=h1(1:6);
h1(1)=h2(i);
end
scramble_bits=double(xor(data_bits,h2));
pack_length=sim_options.PacketLength;
scramble_bits((16+8*pack_length+1):(16+8*pack_length+6))=0;
end
