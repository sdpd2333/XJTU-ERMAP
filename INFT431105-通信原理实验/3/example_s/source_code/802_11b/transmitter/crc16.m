function ret = crc16(PLCP_Header)
h=ones(1,16);
for i=1:length(PLCP_Header) 
    tmp=bitxor(PLCP_Header(i),h(16)); 
    tmp13=bitxor(tmp,h(12)); 
    tmp6=bitxor(tmp,h(5));
    h=[tmp h(1:15)]; 
    h(13)=tmp13;
    h(6)=tmp6;
end 
ret=double(~h(16:-1:1));
end

