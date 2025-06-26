%scrambling x^7+x^4+1
function scramble_bits=scramble_lc(scramble_int,data_bits,sim_options)
h1=scramble_int;
for i=1:length(data_bits)
h2(i)=xor(h1(7),h1(4));
h1(2:7)=h1(1:6);
h1(1)=h2(i);
end
scramble_bits=double(xor(data_bits,h2));
scramble_bits((16+8*sim_options.PacketLength+1):(16+8*sim_options.PacketLength+6))=0;
