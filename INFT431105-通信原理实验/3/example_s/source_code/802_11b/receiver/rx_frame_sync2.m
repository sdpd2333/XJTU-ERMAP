function [SFD,index,sig_dsp] = rx_frame_sync(signal)

Si=[1 1 0 1 1 0 0];
barker=[1 -1 1 1 -1 1 1 1 -1 -1 -1];
long_sfd=[0 0 0 0 0 1 0 1 1 1 0 0 1 1 1 1];
short_sfd=[1 1 1 1 0 0 1 1 1 0 1 0 0 0 0 0];
index=1;
State=0;
SFD=-1;
m=0;

len=floor(length(signal)/11);
sig_sync=signal(1:len*11);
sig_dsp=barker*reshape(sig_sync,11,len);

for i=1:length(sig_dsp)
    [b,State]=demod_dbpsk2(sig_dsp(i),State);
    [c,Si]=descramble(b,Si);
    index=index+1;
    m=m+1;
    y(m)=c;
    if m>15
        if y(m-15:m)==long_sfd
            SFD='long'; break;
        elseif y(m-15:m)==short_sfd
            SFD='short'; break;
        else
            m=0; SFD=-1;   
        end
    end
end