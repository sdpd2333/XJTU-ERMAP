function ret = crc32_new(bits)
% G(x) is "0x04C11DB7"  x32+x26+x23+x22+x16+x12+x11+x10+x8+x7+x5+x4+x2+x+1 (big-endian)
%      or "0xEDB88320"  1+x+x2+x4+x5+x7+x8+x10+x11+x12+x16+x22+x23+x26+x32 (little-endian)
poly = [1 de2bi(hex2dec('04c11db7'), 32, 'left-msb')]'; %% is left-msb, poly(0) for x32 , poly(33) for x0
bits = reshape(bits, [], 1);

rem = ones(32,1); %%% rem(1:32) is left-msb, rem(1) is transmited first
for i = 1:length(bits) %%% loop for the CRC32
    fb = xor(rem(1), bits(i));
    if fb == 1
%         rem = [mod(rem(2:32) + poly(2:32), 2); fb];
        rem = [xor(rem(2:32),poly(2:32)); fb];
    else
        rem = [rem(2:32); fb];
    end
end

ret = 1 - rem(1:32);  %%% Flip the remainder before returning it
% ret = dec2hex(bi2de(ret.', 'left-msb'), 8);