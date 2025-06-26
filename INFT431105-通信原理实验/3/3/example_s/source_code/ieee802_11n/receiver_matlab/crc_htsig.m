function crc=crc_htsig(bits)
h1=ones(8,1);
for i=1:length(bits)
    temp=xor(h1(8),bits(i));
    h1(8:-1:4)=h1(7:-1:3);
    h1(3)=xor(h1(2),temp);
    h1(2)=xor(h1(1),temp);
    h1(1)=temp;
end
crc=abs(h1(8:-1:1)-1);
end
