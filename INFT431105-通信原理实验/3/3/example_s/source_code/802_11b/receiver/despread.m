function symbols = despread(signal,frame_type,data_rate)

barker=[1 -1 1 1 -1 1 1 1 -1 -1 -1];
sig_dsp=barker*reshape(signal,11,length(signal)/11);
c1=max([abs(real(sig_dsp)),abs(imag(sig_dsp))]);
sig_dsp=sig_dsp./c1;
sig_dsp=sig_dsp./sqrt(2);

if ~isempty(strfind(frame_type, 'long'))
    symbol_1=sig_dsp(1:192).*exp(-1i*pi/4);  
    if data_rate==1
        symbol_2=sig_dsp(193:end).*exp(-1i*pi/4);
    else
        symbol_2=sig_dsp(193:end);
    end
elseif ~isempty(strfind(frame_type, 'short'))
    symbol_1=sig_dsp(1:72).*exp(-1i*pi/4);
    symbol_2=sig_dsp(73:end);
end

symbols=[symbol_1 symbol_2];
    
end