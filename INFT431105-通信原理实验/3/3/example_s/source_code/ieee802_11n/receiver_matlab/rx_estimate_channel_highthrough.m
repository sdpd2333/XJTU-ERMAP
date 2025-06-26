function h_est = rx_estimate_channel_highthrough(freq_h_ltf)
% H11 H12 H13 H14            R11 R21 R31 R41    1  1  1 -1
% H21 H22 H23 H24            R12 R22 R32 R42   -1  1  1  1
%                 =1/(4T)*                    *
% H31 H32 H33 H34            R13 R23 R33 R43    1 -1  1  1
% H41 H42 H43 H44            R14 R24 R34 R44    1  1 -1  1
% sum(R .* P_hltf) .* conj(Train)
% H11 = R11 R21 R31 R41 .*  1  -1  1  1 .* (Train)
% 1     1   1   1   1       1  -1  1  1    1 
% 2     2   2   2   2       1  -1  1  1    2
% ..    ..  ..  ..  ..      1  -1  1  1    ..
% 56    56  56  56  56      1  -1  1  1    56
% H12 = R11 R21 R31 R41 .*  1   1 -1  1 .* (Train)
% 1     1   1   1   1       1   1 -1  1    1
% 2     2   2   2   2       1   1 -1  1    2
% ..    ..  ..  ..  ..      1   1 -1  1    ..
% 56    56  56  56  56      1   1 -1  1    56
% H13 = R11 R21 R31 R41 .*  1   1  1 -1 .* (Train)
% 1     1   1   1   1       1   1  1 -1    1
% 2     2   2   2   2       1   1  1 -1    2
% ..    ..  ..  ..  ..      1   1  1 -1    ..
% 56    56  56  56  56      1   1  1 -1    56
% H14 = R11 R21 R31 R41 .* -1   1  1  1 .* (Train)
% 1     1   1   1   1      -1   1  1  1    1
% 2     2   2   2   2      -1   1  1  1    2
% ..    ..  ..  ..  ..     -1   1  1  1    ..
% 56    56  56  56  56     -1   1  1  1    56

global sim_consts;
P_hltf=ones(56*4,4);
P_hltf(56*3+1:56*4,1)=-ones(56,1);
P_hltf(56*0+1:56*1,2)=-ones(56,1);
P_hltf(56*1+1:56*2,3)=-ones(56,1);
P_hltf(56*2+1:56*3,4)=-ones(56,1);
Nrx=size(freq_h_ltf,2);
Nsym=size(freq_h_ltf,1)./56;
for i=1:Nrx
    freq_hltf_sym=reshape(freq_h_ltf(:,i),56,Nsym);
    freq_hltf_grp=repmat(freq_hltf_sym,Nrx,1);
    freq_hltf_grpm=freq_hltf_grp.*P_hltf(1:Nrx*56,1:Nsym);
    if Nrx ==1
        hi=freq_hltf_grpm.';
        hi_est=hi.*(repmat(sim_consts.highthroughlongtraning,1,Nrx))./Nrx;
    elseif Nrx ==3
        hi=sum(freq_hltf_grpm.');
        hi_est=hi.*(repmat(sim_consts.highthroughlongtraning,1,Nrx))./4;
    else
        hi=sum(freq_hltf_grpm.');
        hi_est=hi.*(repmat(sim_consts.highthroughlongtraning,1,Nrx))./Nrx;
    end
    h_est((i-1)*56+1:i*56,:)=reshape(hi_est,56,Nrx);
end
% h_est=
% H11 H12 H13 H14
% 1   1   1   1
% 2   2   2   2
% ..  ..  ..  ..
% 56  56  56  56
% H21 H22 H23 H24
% 1   1   1   1
% 2   2   2   2
% ..  ..  ..  ..
% 56  56  56  56
% H31 H32 H33 H34
% 1   1   1   1
% 2   2   2   2
% ..  ..  ..  ..
% 56  56  56  56
% H41 H42 H43 H44
% 1   1   1   1
% 2   2   2   2
% ..  ..  ..  ..
% 56  56  56  56

