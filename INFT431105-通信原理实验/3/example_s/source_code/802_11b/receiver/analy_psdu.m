function psdu = analy_psdu(signal,state,si,data_rate,DEC_MET)

Si=si;
index=1;
%% 1Mbps DBPSK
if data_rate==1
    State=state;
    m=0;
    while(index<length(signal)-9)
        [b,in,State]=demod_dbpsk(signal(:,index:index+10),State,DEC_MET);
        index=index+in;
        if b>-1
            m=m+1;
            [a,Si]=descramble(b,Si);
            psdu(m)=a;  
        end
    end
%% 2Mbps DQPSK   
elseif data_rate==2
    State=state*2;
    m=-1;
    while(index<length(signal)-9)
        [b,in,State]=demod_dqpsk(signal(:,index:index+10),State,DEC_MET);
        index=index+in;
        if b(1,1)>-1
            m=m+2;
            [b,Si]=descramble(b,Si);
            psdu(m:m+1)=b;  
        end
    end
end

end