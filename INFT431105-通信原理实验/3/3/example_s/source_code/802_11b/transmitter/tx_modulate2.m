function mod_symbols = tx_modulate2(scramble_bits,sim_options)
state=0;
if  sim_options.frame_type==1
    %% for long frame preamble of PLCP , must use DBPSK to modulate
    [state_plcp,mod_plcp(:,1)]=dbpsk(state,scramble_bits(1:192));
elseif sim_options.frame_type==0
    %% for short frame preamble of PLCP, must use DBPSK to modulate
    [state1,mod_plcp1(:,1)]=dbpsk(state,scramble_bits(1:72));
    %% for header must use DQPSK to modulate
    [state_plcp,mod_plcp2(:,1)]=dqpsk(state1*2,scramble_bits(73:120));
    mod_plcp=[mod_plcp1;mod_plcp2];
end
%% for PSDU, the way of modulation based on sim_options.rate 
%% long frame support 1,2,5.5,11Mbps
if  sim_options.frame_type==1
    if  sim_options.rate==1
        [~,mod_psdu(:,1)]=dbpsk(state_plcp,scramble_bits(193:end));
    elseif sim_options.rate==2
        [~,mod_psdu(:,1)]=dqpsk(state_plcp*2,scramble_bits(193:end));
    elseif sim_options.rate==5.5
        mod_psdu(:,1)=cck55(state_plcp*2,scramble_bits(193:end));
    elseif sim_options.rate==11
        mod_psdu(:,1)=cck11(state_plcp*2,scramble_bits(193:end));
    end
%% short frame support 2,5.5,11Mbps
elseif sim_options.frame_type==0
    if  sim_options.rate==2
        [~,mod_psdu(:,1)]=dqpsk(state_plcp,scramble_bits(121:end));
    elseif sim_options.rate==5.5
        mod_psdu(:,1)=cck55(state_plcp,scramble_bits(121:end));
    elseif sim_options.rate==11
        mod_psdu(:,1)=cck11(state_plcp,scramble_bits(121:end));
    end
end

mod_symbols=[mod_plcp;mod_psdu];

end