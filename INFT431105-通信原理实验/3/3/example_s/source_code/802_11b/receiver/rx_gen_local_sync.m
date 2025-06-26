function local_sync =rx_gen_local_sync(frame_type)

if ~isempty(findstr(frame_type, 'long'))   
    pream_sync=ones(1,128);
    scramble_int=[1,1,0,1,1,0,0];
    scramble_bits=scramble(scramble_int,pream_sync);
    [~,local_sync(:,1)]=DBPSK(0,scramble_bits); 
elseif ~isempty(findstr(frame_type, 'short'))      
    %% ...................
    pream_sync=zeros(1,56);
    scramble_int=[0,0,1,1,0,1,1];
    scramble_bits=scramble(scramble_int,pream_sync);
    [~,local_sync(:,1)]=DBPSK(0,scramble_bits); 
    %% ...................
end

end

