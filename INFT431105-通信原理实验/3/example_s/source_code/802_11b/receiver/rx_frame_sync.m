function [SFD,frame_begin_index] = rx_frame_sync(signal,DEC_MET)

Si=[1 1 0 1 1 0 0];
long_sfd=[0 0 0 0 0 1 0 1 1 1 0 0 1 1 1 1];
short_sfd=[1 1 1 1 0 0 1 1 1 0 1 0 0 0 0 0];
index=1;
State=0;
SFD=-1;
Pi=0;

while(SFD==-1&&(index<length(signal)-9))
    [a,in,State]=demod_dbpsk(signal(:,index:index+10),State,DEC_MET);
    index=index+in;
    if a>-1
        Pi=Pi+1;
        [a,Si]=descramble(a,Si);
        y(Pi)=a;
        if Pi>15
            if (y(Pi-15:Pi)==long_sfd)
                SFD='long';
                frame_begin_index=index-(128+16)*11;
                break;
            elseif (y(Pi-15:Pi)==short_sfd)
                SFD='short';
                frame_begin_index=index-(56+16)*11;
                break;
            end
        end
    end
end


end