function spectrum = direct_spectrum(signal, omega, sample_limit)
%DIRECT_SPECTRUM Evaluate the lab's direct frequency sum with bounded input.
%   Preserve the original n=1 phase convention and frequency grid. Vectorize
%   the inner sum without allocating a samples-by-frequencies matrix.

validateattributes(signal, {'numeric'}, {'vector', 'nonempty', 'finite'});
validateattributes(omega, {'numeric'}, {'real', 'vector', 'nonempty', 'finite'});
validateattributes(sample_limit, {'numeric'}, {'scalar', 'integer', 'positive', 'finite'});
signal = signal(:);
sample_count = min(numel(signal), sample_limit);
signal = signal(1:sample_count);
n = (1:sample_count).';
spectrum = zeros(size(omega));
for index = 1:numel(omega)
    spectrum(index) = signal.' * exp(-1i * omega(index) * n);
end
end
