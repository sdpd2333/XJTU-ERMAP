function Y = calcFreqSpectrum(X, omega);


N = size(X, 1);
Y = zeros(length(omega), 1);

for idx = 1 : length(omega)
   for n = 1 : N
       Y(idx) =  Y(idx) +  exp(-1j*omega(idx)*n)*X(n);   
   end    
end
