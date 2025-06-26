% 	Convolutional encoding with unipolar data
function coded_bits = tx_conv_encoder(in_bits)
global sim_consts;
number_rows = size(sim_consts.ConvCodeGenPoly, 1);
number_bits = size(sim_consts.ConvCodeGenPoly,2)+length(in_bits)-1;

uncoded_bits = zeros(number_rows, number_bits);

for row=1:number_rows
 uncoded_bits(row,1:number_bits)=rem(conv(in_bits, sim_consts.ConvCodeGenPoly(row,:)),2);
end
uncoded_bits1=uncoded_bits(:,1:length(in_bits));
coded_bits=uncoded_bits1(:);


