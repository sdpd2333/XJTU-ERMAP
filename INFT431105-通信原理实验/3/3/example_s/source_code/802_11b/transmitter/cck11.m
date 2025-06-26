function mod_symbols = cck11(state,BitStream)
eo=0;
x=ones(1,4);
c=ones(1,8);
for i=1:8:length(BitStream)
    a=2*BitStream(i)+BitStream(i+1);
    switch a
        case 1,    x(1)=1;
        case 2,    x(1)=3;
        case 3,    x(1)=2;
        otherwise, x(1)=0;
    end
    x(1)=x(1)+eo*2;
    x(1)=rem(x(1)+state,4);
    for k=2:4
        x(k)=2*BitStream(i+k*2-2)+BitStream(i+k*2-1);
    end
    c(1)=rem(x(1)+x(2)+x(3)+x(4),4);
    c(2)=rem(x(1)+x(3)+x(4),4);
    c(3)=rem(x(1)+x(2)+x(4),4);
    c(4)=rem(x(1)+x(4)+2,4);
    c(5)=rem(x(1)+x(2)+x(3),4);
    c(6)=rem(x(1)+x(3),4);
    c(7)=rem(x(1)+x(2)+2,4);
    c(8)=rem(x(1),4);
    state=c(8);
    for j=1:8
        switch c(j)
            case  0,
                signal1(1,i+j-1)=1;
                signal2(1,i+j-1)=0;
                symbols=signal1+1i*signal2;
            case  1,
                signal1(1,i+j-1)=0;
                signal2(1,i+j-1)=1;
                symbols=signal1+1i*signal2;
            case  2,
                signal1(1,i+j-1)=-1;
                signal2(1,i+j-1)=0;
                symbols=signal1+1i*signal2;
            otherwise,
                signal1(1,i+j-1)=0;
                signal2(1,i+j-1)=-1;
                symbols=signal1+1i*signal2;
        end
    end
    eo=xor(eo,1);
end
mod_symbols=symbols.*exp(1i*pi/4); 
end