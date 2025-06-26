function [ frame_data,syn_symbol] = rx_frame_sync(receive_data,data_I,data_Q,len)
% receive_data=receive_data';
[xx,PS]=mapminmax(receive_data);
frame_all=xx.';
syn_symbol=syn_time(frame_all);
[s1,s2]=max(syn_symbol(1:length(syn_symbol)/2));
frame_begin=s2+576;
frame_end=frame_begin+len;
%------------找到帧位置后组成一帧数据------------------------------
frame_data_I=data_I(frame_begin:frame_end);
frame_data_Q=data_Q(frame_begin:frame_end);
frame=frame_data_I+1i*frame_data_Q;

frame_data=frame(2:end);
end


