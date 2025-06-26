function [state,mod_symbols] = dqpsk(state,BitStream)
Barker=[1 -1 1 1 -1 1 1 1 -1 -1 -1];
for i=1:2:length(BitStream)
    a=2*BitStream(i)+BitStream(i+1);
    switch a
        case 1,    state=state+1;
        case 2,    state=state+3;
        case 3,    state=state+2;
        otherwise, state=state+0;
    end
    state=rem(state,4);
    switch state,
        case 0,    a=1; b=0;
        case 1,    a=0; b=1;
        case 2,    a=-1;b=0;
        otherwise, a=0; b=-1;
    end
    symbols1(1,(i-1)*11/2+1:(i-1)*11/2+11)=a*Barker;
    symbols2(1,(i-1)*11/2+1:(i-1)*11/2+11)=b*Barker;
end
mod_symbols=(symbols1+1i*symbols2).*exp(1i*pi/4);
end