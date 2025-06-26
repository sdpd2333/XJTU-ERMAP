function [ y,index,z] = rx_frame_coarse_sync(rx_samples)
temp=6;
barker=[1 -1 1 1 -1 1 1 1 -1 -1 -1];
signal=rx_samples.*exp(-1i*pi/4);
index=1;

qi=0;
ri=0;
while(index<length(signal)-9)
    sig_despread=signal(:,index:index+10)*barker';
    if abs(sig_despread)<temp
        step=1;
        b=0;
        ri=ri+1;
        z(ri)=b;
    else
        step=11;
        a=1;
        qi=qi+1;
        y(qi)=a;
    end
    index=index+step;
    if qi>8&length(z)>500
        if y(qi-7:qi)==ones(1,8)
            break;
        end
    end
    
end
    

% index=index-16*11;
end

