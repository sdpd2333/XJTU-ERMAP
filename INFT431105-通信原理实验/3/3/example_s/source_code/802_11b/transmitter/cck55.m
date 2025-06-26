function mod_symbols = cck55(state,BitStream)
eo=0;
for i=1:4:length(BitStream)
    a=2*BitStream(i)+BitStream(i+1);
    switch a
        case 1,    x1=1;
        case 2,    x1=3;
        case 3,    x1=2;
        otherwise, x1=0;
    end
    x1=x1+eo*2;
    x1=mod(x1+state,4);
    x2=BitStream(i+2)*2+1;
    x4=BitStream(i+3)*2;
    c(1,1)=mod(x1+x2+x4,4);
    c(1,2)=mod(x1+x4,4);
    c(1,3)=mod(x1+x2+x4,4);
    c(1,4)=mod(x1+x4+2,4);
    c(1,5)=mod(x1+x2,4);
    c(1,6)=mod(x1,4);
    c(1,7)=mod(x1+x2+2,4);
    c(1,8)=x1;
    state=c(1,8);
    for j=1:8
        switch c(1,j)
            case 0,
                signal1(1,(i-1)*2+j)=1;
                signal2(1,(i-1)*2+j)=0;
                symbols=signal1+1i*signal2;
            case 1,
                signal1(1,(i-1)*2+j)=0;
                signal2(1,(i-1)*2+j)=1;
                symbols=signal1+1i*signal2;
            case 2,
                signal1(1,(i-1)*2+j)=-1;
                signal2(1,(i-1)*2+j)=0;
                symbols=signal1+1i*signal2;
            otherwise,
                signal1(1,(i-1)*2+j)=0;
                signal2(1,(i-1)*2+j)=-1;
                symbols=signal1+1i*signal2;
        end
    end
    eo=xor(eo,1);
end
mod_symbols=symbols.*exp(1i*pi/4);
end