function tx_parser=tx_stream_parser(tx_bits,sim_options)
nss=sim_options.Nss;
nbpscs=sim_options.Nbpscs;
s=max(1,nbpscs/2);
num_bits_stream=length(tx_bits)/nss;
for i=1:nss
    for j=0:num_bits_stream-1
        index(j+1,i)=s*(i-1)+s*nss*floor(j/s)+rem(j,s);
    end
end
index=index+1;
for i=1:nss
    tx_parser(:,i)=tx_bits(index(:,i));
end
end