function rx_parser=rx_stream_parser(rx_bits,sim_options)
nss=sim_options.Nss;
nbpscs=sim_options.Nbpscs;
s=max(1,nbpscs/2);
num_bits_stream=size(rx_bits,1);
for i=1:nss
    for j=0:num_bits_stream-1
        index(j+1,i)=s*(i-1)+s*nss*floor(j/s)+rem(j,s);
    end
end
index=index+1;
for i=1:nss
    rx_parser(index(:,i),1)=rx_bits(:,i);
end