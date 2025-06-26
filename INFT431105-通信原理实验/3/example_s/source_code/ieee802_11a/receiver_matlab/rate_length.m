function [data_rate,data_length,signal_error]=rate_length(signal)
signal_error=0;
signal_d=signal(1:17);
for i=1:16
	signal_d(i+1)=xor(signal_d(i),signal_d(i+1));
end
if(signal_d(17)==signal(18) && signal(5)==0)
  data_length=bin2dec(num2str(signal(17:-1:6)));
  if (signal(1:4)==[1,1,0,1])
      data_rate=6; 
  elseif (signal(1:4)==[1,1,1,1])
      data_rate=9;
  elseif (signal(1:4)==[0,1,0,1])
      data_rate=12;
  elseif (signal(1:4)==[0,1,1,1])
      data_rate=18;
  elseif (signal(1:4)==[1,0,0,1])
      data_rate=24;
  elseif (signal(1:4)==[1,0,1,1])
      data_rate=36;
  elseif (signal(1:4)==[0,0,0,1])
      data_rate=48;
  elseif (signal(1:4)==[0,0,1,1])
      data_rate=54;
  else
      disp('Error data_rate');
      data_rate=6;
      signal_error=1;
  end
else
    disp('Error signal');
    signal_error=1;
    data_rate=6;
    data_length=0;
end