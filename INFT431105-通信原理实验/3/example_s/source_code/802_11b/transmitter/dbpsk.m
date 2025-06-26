function [stateo,mod_symbols] = dbpsk(state,datain)
Barker=[1 -1 1 1 -1 1 1 1 -1 -1 -1].';
datar(1)=xor(state,datain(1));
for i=2:length(datain)
    datar(i)=xor(datar(i-1),datain(i));
end
stateo=datar(end);
datarn=double(~datar);
data_n=datarn.*2-1;
data_r=repmat(data_n,11,1);
Barker_r=repmat(Barker,1,size(data_r,2));
data_pn=data_r.*Barker_r;
data_mod=data_pn.*exp(1i*pi/4);
mod_symbols=data_mod(:);
end