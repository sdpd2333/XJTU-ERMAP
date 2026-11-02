function [EsN0, ber] = load_ber_curve(filename, preferred_name)
%LOAD_BER_CURVE Read a historical or regenerated BER curve without workspace leakage.
%   Historical single-RX files can use ber1, ber2 or ber3. Prefer the field
%   selected by the caller and fall back to ber1 for the older files.

data = load(filename);
if ~isfield(data, 'EsN0')
    error('ERMAP:MissingSNR', 'Missing EsN0 in %s.', filename);
end
if isfield(data, preferred_name)
    ber = data.(preferred_name);
elseif isfield(data, 'ber1')
    ber = data.ber1;
else
    error('ERMAP:MissingBER', 'Missing %s / ber1 in %s.', preferred_name, filename);
end
validateattributes(data.EsN0, {'numeric'}, {'real', 'vector', 'nonempty', 'finite'});
validateattributes(ber, {'numeric'}, {'real', 'vector', 'nonempty', 'finite', '>=', 0, '<=', 1});
EsN0 = data.EsN0(:).';
ber = ber(:).';
if numel(EsN0) ~= numel(ber)
    error('ERMAP:CurveLength', 'SNR and BER lengths differ in %s.', filename);
end
end
