function [plcp,State,Si] = rx_plcp_demod(signal)

barker=[1 -1 1 1 -1 1 1 1 -1 -1 -1];
Si=[1 1 0 1 1 0 0];
State=0;
m=0;
n=-1;
y=0;

%% despread
sig_dsp=barker*reshape(signal,11,length(signal)/11);
%% long frame
if length(signal)==192*11
    %% demodulation and descramble
    for i=1:length(sig_dsp)
        [b,State]=demod_dbpsk2(sig_dsp(i),State);
        [c,Si]=descramble(b,Si);
        m=m+1;
        y(m)=c;  
    end   
%% short frame
elseif length(signal)==1056
    short_preamble=sig_dsp(1:72);
    short_header=sig_dsp(73:end);
    %% demodulation and descramble of preammle
    for i=1:length(short_preamble)
        [b,State]=demod_dbpsk2(short_preamble(i),State);
        [c,Si]=descramble(b,Si);
        m=m+1;
        y_p(m)=c;  
    end   
    %% demodulation and descramble of header
    State=State*2;
    for i=1:length(short_header)
        [e,State]=demod_dqpsk(short_header(i),State);
        [f,Si]=descramble(e,Si);
        n=n+2;
        y_h(n:n+1)=f;  
    end 
    y=[y_p y_h];
end

plcp=y;

end