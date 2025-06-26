function dout = rx_phase_comp(sig_dsp,local_sync)
barker=[1 -1 1 1 -1 1 1 1 -1 -1 -1];
local_sync=barker*reshape(local_sync,11,length(local_sync)/11);
r1=[sig_dsp(1) sig_dsp(5) sig_dsp(9) sig_dsp(13)...
    sig_dsp(17) sig_dsp(21) sig_dsp(25) sig_dsp(29)];
r2=[local_sync(1) local_sync(5) local_sync(9) local_sync(13)...
    local_sync(17) local_sync(21) local_sync(25) local_sync(29)];
% for i=1:length(r1)
    ang_offset=angle(sum(conj(r2).*r1));
% end
% ang_offset=mean(ang_offset);
dout=sig_dsp*exp(-1i*ang_offset);
dout=dout.*exp(-1i*pi/4);
end

