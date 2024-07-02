clear all;

for  idx = 26
    
    filename = sprintf('samples\\trip.wav', idx);
    filenameNoise = sprintf('samples\\%dnoise.wav', idx);

    [xr,fs] = audioread(filename);
    [x,fs] = audioread(filenameNoise);

    omega = -pi : 2*pi/10000 : pi;    
    xDTFT = calcFreqSpectrum(x, omega);
    xrDTFT = calcFreqSpectrum(xr, omega);
    
    figure(3); hold off;
    plot(omega, 20*log10(abs(xDTFT))); hold on;
    plot(omega, 20*log10(abs(xrDTFT)),'r-'); hold on;    
    xlabel('\omega')
    xlim([-pi pi])
    ylabel('20 lg |X(j\omega)|')
    drawnow
    

        
    freqInf1 = input('Nulling freq1 = ');
    freqInf2 = input('Nulling freq2 = ');
    freqInf3 = input('Nulling freq3 = ');

    firCoefh1 = [1 -2*cos(freqInf1) 1];
    firCoefh2= [1 -2*cos(freqInf2) 1];
    firCoefh3= [1 -2*cos(freqInf3) 1];
    firCoefh = conv(firCoefh1, firCoefh2);
    firCoefh = conv(firCoefh, firCoefh3);

    firCoefh = firCoefh/sum(firCoefh);

    xfilter = conv(x, firCoefh);

    xfilterDTFT = calcFreqSpectrum(xfilter, omega);

    plot(omega, 20*log10(abs(xfilterDTFT)),'g-'); hold on;
        

    sound(x, fs);

    pause(3)

    sound(xfilter, fs);

    pause(3)
   
    audiowrite('filternoise.wav', xfilter,  fs);
    
    return
end












