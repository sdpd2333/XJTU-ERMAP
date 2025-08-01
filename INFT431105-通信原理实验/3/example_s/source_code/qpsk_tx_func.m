function txdata = qpsk_tx_func
%% train sequence
seq_sync=tx_gen_m_seq([1 0 0 0 0 0 1]);
sync_symbols=tx_modulate(seq_sync, 'BPSK');
%% message 128-4 byte
msgStr=[
    'aaaabbbbccccddddeeee',...
    'ffffgggghhhhiiii',...
    'jjjjkkkkllllmmmm',...
    'nnnnooooppppqqqq',...
    'rrrrssssttttuuuu',...
    'vvvvwwwwxxxxyyyy',...
    'zzzz000011112222',...
    '333344445555',...
    ];
%% string to bits
mst_bits=str_to_bits(msgStr);
%% crc32
% ret=crc32(mst_bits);
% inf_bits=[mst_bits ret.'];
inf_bits=mst_bits;
%% scramble
scramble_int=[1,1,0,1,1,0,0];
sym_bits=scramble(scramble_int, inf_bits);
% sym_bits=inf_bits;
%% modulate
mod_symbols=tx_modulate(sym_bits, 'QPSK');
figure(1);clf;
axis equal;
plot(real(sym_bits),imag(sym_bits),'b.');
grid on;
hold on;
%% insert pilot
% data_symbols=insert_pilot(mod_symbols);
data_symbols=mod_symbols;
trans_symbols=[sync_symbols data_symbols];
figure(2);clf;
axis equal;
plot(real(trans_symbols),imag(trans_symbols),'b.');
grid on;
hold on;
%% srrc
fir=rcosdesign(1,128,4);
tx_frame=upfirdn(trans_symbols,fir,4);
% tx_frame=upfirdn(trans_symbols,fir,1);
% tx_frame=[tx_frame, zeros(1, ceil(length(tx_frame)/2))];
txdata = tx_frame.';
%% display
figure(3);clf;
axis equal;
plot(real(txdata),imag(txdata),'b.');
grid on;
hold on;
end

