clear;
close all;
clc;
rate=12;
bw=10;
length=1000;
if ceil((length*8+22)/rate/4)*160>7000
    front_gap=7000;
else
    switch rate
        case(6) 
            front_gap=ceil((length*8+22)/rate/4)*(rate*4+137);
        case(9) 
            front_gap=ceil((length*8+22)/rate/4)*(rate*4+125);
        case(12)
            front_gap=ceil((length*8+22)/rate/4)*(rate*4+113);
        case(18)
            front_gap=ceil((length*8+22)/rate/4)*(rate*4+89);
        case(24)
            front_gap=ceil((length*8+22)/rate/4)*(rate*4+65);
        case(36)
            front_gap=ceil((length*8+22)/rate/4)*(rate*4+17);
        case(48)
            front_gap=ceil((length*8+22)/rate/4)*(rate*4+0);
        case(54)
            front_gap=ceil((length*8+22)/rate/4)*(rate*4+0);
    end
end
mbps=(length*8*bw/20)/(ceil((length*8+22)/rate/4)*4+20+1000*1/bw/2+front_gap*1/bw/2);
mbps_new=(length*8*bw/20)/(ceil((length*8+22)/rate/4)*4+20+1800*1/bw/2);
txtime=((ceil((length*8+22)/rate/4) +1)*160+640)*1000/(bw*2);
disp(['transmitter=',num2str(mbps),'mbps; new=',num2str(mbps_new),'mbps']);
disp(['txtime=',num2str(txtime),'ns']);