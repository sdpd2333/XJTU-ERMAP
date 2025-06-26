function freq_data = rx_timed_to_freqd(time_signal)
global sim_consts;
Nrx=size(time_signal,2);
reorder = [33:64 1:32];
for i=1:Nrx
    time_ch1=time_signal(:,i);
    Nsym=length(time_ch1)./80;
    time_sym=reshape(time_ch1,80,Nsym);
    time_sym(1:16,:)=[];
    freq_time=fft(time_sym);
    freq_time(reorder,:)=freq_time;
    freq_time_use=freq_time(sim_consts.HTUsedSubcIdx,:);
    freq_data(:,i)=freq_time_use(:);
end

