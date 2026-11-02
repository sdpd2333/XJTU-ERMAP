function test_matlab
%TEST_MATLAB Run focused helper regressions in MATLAB (no hardware required).
%   From the repository root: addpath('tests'); test_matlab

root = fileparts(fileparts(mfilename('fullpath')));
old_path = path;
path_cleanup = onCleanup(@() path(old_path)); %#ok<NASGU>
signal_dir = dir(fullfile(root, 'INFT430605-*'));
mimo_dir = dir(fullfile(root, 'INFT431005-*'));
addpath(fullfile(root, signal_dir(1).name, 'lab1'));
addpath(fullfile(root, mimo_dir(1).name, 'code'));

omega = [-pi, -0.7, 0, 0.4, pi];
actual = direct_spectrum([1; 0; 0], omega, 40000);
assert(max(abs(actual - exp(-1i * omega))) < 1e-12);
actual = direct_spectrum([0; 1; 99], omega, 2);
assert(max(abs(actual - exp(-2i * omega))) < 1e-12);
actual = direct_spectrum([1; 2], omega.', 40000);
assert(isequal(size(actual), size(omega.')));
assert(max(abs(actual - (exp(-1i * omega.') + 2*exp(-2i * omega.')))) < 1e-12);

temp_dir = tempname;
mkdir(temp_dir);
file_cleanup = onCleanup(@() rmdir(temp_dir, 's')); %#ok<NASGU>
filename = fullfile(temp_dir, 'curve.mat');
EsN0 = [0; 2; 4];
ber1 = [0.3; 0.2; 0.1];
save(filename, 'EsN0', 'ber1');
[snr, rate] = load_ber_curve(filename, 'ber2');
assert(isequal(snr, EsN0.') && isequal(rate, ber1.'));
ber2 = [0.4, 0.3, 0.2];
save(filename, 'EsN0', 'ber1', 'ber2');
[~, rate] = load_ber_curve(filename, 'ber2');
assert(isequal(rate, ber2));
ber2 = [0.4, 0.3];
save(filename, 'EsN0', 'ber2');
expect_error(@() load_ber_curve(filename, 'ber2'), 'ERMAP:CurveLength');
save(filename, 'EsN0');
expect_error(@() load_ber_curve(filename, 'ber2'), 'ERMAP:MissingBER');
save(filename, 'ber1');
expect_error(@() load_ber_curve(filename, 'ber1'), 'ERMAP:MissingSNR');
disp('OK: direct-spectrum and BER-loading regression checks.');
end

function expect_error(callback, identifier)
try
    callback();
catch exception
    assert(strcmp(exception.identifier, identifier));
    return;
end
error('ERMAP:ExpectedError', 'Expected error %s.', identifier);
end
