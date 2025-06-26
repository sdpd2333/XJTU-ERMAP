function fine_time_est_long=rx_fine_time_sync(input_signal)
input_signal=input_signal.';
global sim_consts;
start_search=1;
end_search=400;   
% get time domain long training symbols
long_tr = sim_consts.LongTrainingSymbols;
long_tr_symbols = tx_freqd_to_timed(long_tr,1);
long_trs = [long_tr_symbols(33:64) long_tr_symbols(1:32)];
realp=round(real(long_trs)*1024);
imagp=round(imag(long_trs)*1024);
for k=1:length(realp)
    if realp(k) ==0
        realp2(k)=0;
    elseif realp(k)==1
        realp2(k)=1; 
    elseif realp(k)==2
        realp2(k)=2; 
    elseif realp(k)>=3 && realp(k)<6
        realp2(k)=4;        
    elseif realp(k)>=6 && realp(k)<12
        realp2(k)=8;           
    elseif realp(k)>=12 && realp(k)<24
        realp2(k)=16;
    elseif realp(k)>=24 && realp(k)<48
        realp2(k)=32;
    elseif realp(k)>=48 && realp(k)<96
        realp2(k)=64;
    elseif realp(k)>=96
        realp2(k)=128;
    elseif realp(k)==-1
        realp2(k)=-1; 
    elseif realp(k)==-2
        realp2(k)=-2; 
    elseif realp(k)>-6 && realp(k)<=-3
        realp2(k)=-4;        
    elseif realp(k)>-12 && realp(k)<=-6
        realp2(k)=-8;           
    elseif realp(k)>-24 && realp(k)<=-12
        realp2(k)=-16;
    elseif realp(k)>-48 && realp(k)<=-24
        realp2(k)=-32;
    elseif realp(k)>-96 && realp(k)<=-48
        realp2(k)=-64;
    elseif realp(k)<=-96
        realp2(k)=-128;
    end
    if imagp(k) ==0
        imagp2(k)=0;
    elseif imagp(k)==1
        imagp2(k)=1; 
    elseif imagp(k)==2
        imagp2(k)=2; 
    elseif imagp(k)>=3 && imagp(k)<6
        imagp2(k)=4;        
    elseif imagp(k)>=6 && imagp(k)<12
        imagp2(k)=8;           
    elseif imagp(k)>=12 && imagp(k)<24
        imagp2(k)=16;
    elseif imagp(k)>=24 && imagp(k)<48
        imagp2(k)=32;
    elseif imagp(k)>=48 && imagp(k)<96
        imagp2(k)=64;
    elseif imagp(k)>=96
        imagp2(k)=128;
    elseif imagp(k)==-1
        imagp2(k)=-1; 
    elseif imagp(k)==-2
        imagp2(k)=-2; 
    elseif imagp(k)>-6 && imagp(k)<=-3
        imagp2(k)=-4;        
    elseif imagp(k)>-12 && imagp(k)<=-6
        imagp2(k)=-8;           
    elseif imagp(k)>-24 && imagp(k)<=-12
        imagp2(k)=-16;
    elseif imagp(k)>-48 && imagp(k)<=-24
        imagp2(k)=-32;
    elseif imagp(k)>-96 && imagp(k)<=-48
        imagp2(k)=-64;
    elseif imagp(k)<=-96
        imagp2(k)=-128;
    end
end
realp3=realp2./128;
imagp3=imagp2./128;
i=1;
j=1;
time=1;
while i<end_search
% 	time_corr_long(i) = abs(sum((input_signal(i:i+63).*conj(long_trs))));
%  	time_pwr_long(i) = abs(abs(abs(sum(input_signal(i:i+63)))-abs(sum(input_signal(1:64)))));
    time_corr_real(i)=abs(sum(real(input_signal(i:i+63)).*realp3+imag(input_signal(i:i+63)).*imagp3));
    time_corr_imag(i)=abs(sum(-real(input_signal(i:i+63)).*imagp3+imag(input_signal(i:i+63)).*realp3));
    if time_corr_real(i)>time_corr_imag(i)
        time_corr_long(i)=time_corr_real(i)+time_corr_imag(i)/2;
    else
        time_corr_long(i)=time_corr_imag(i)+time_corr_real(i)/2;
    end
     time_pwr_real(i)=abs(sum(real(input_signal(i:i+63)).*ones(1,64)));
     time_pwr_imag(i)=abs(sum(imag(input_signal(i:i+63)).*ones(1,64)));
    if time_pwr_real(i)>time_pwr_imag(i)
        time_pwr_long(i)=time_pwr_real(i)+time_pwr_imag(i)/2;
    else
        time_pwr_long(i)=time_pwr_imag(i)+time_pwr_real(i)/2;
    end
    if i>1
        time_pwr_long(i)=abs(time_pwr_long(i)-time_pwr_long(1));
    end 
    if i>63
        time_corr_mean(i)=mean(time_corr_long(i-63:i));
        if i==64
            time_corr_min=time_corr_mean(i);
        else
            if time_corr_mean(i)<time_corr_min
                time_corr_min=time_corr_mean(i);
            end
        end
        time_corr_ratio(i)=time_corr_long(i)/time_pwr_long(i);
        time_min_ratio(i)=time_corr_long(i)/time_corr_min;
%         i=i+1;
        if   time_min_ratio(i)>4 && time_corr_ratio(i)>2
            ratio(j)=i;
            if j==2
                if ratio(2)-ratio(1)==64
                    break
                else
                    j=1;
                end
            else
                i=i+64;
                j=j+1;
            end
        else
            i=i+1;
            j=1;
        end
    else
        i=i+1;
	end
end
fine_time_est_long = i-64;
figure(4);clf;
set(gcf,'name','¾«Í¬²½');
plot(time_corr_long,'r');
hold on
plot(time_pwr_long,'g');
hold on
plot(time_corr_mean,'b');
figure(1);
   

