function inf_bits = crc74(bits)
g=[1 1 1 0 0 0 0;1 0 0 1 1 0 0;0 1 0 1 0 1 0;1 1 0 1 0 0 1];%生成矩阵
n=length(bits);
bitts=reshape(bits,4,n/4);
bitts=bitts';
for i=1:n/4
    bit_h(i,:)=bitts(i,:)*g;
    for j=1:7
        bit_h(i,j)=mod(bit_h(i,j),2);
    end
end
bit_s=reshape(bit_h',7*n/4,1);
bit_s=bit_s';
inf_bits=bit_s(1:2048); %取前2048位