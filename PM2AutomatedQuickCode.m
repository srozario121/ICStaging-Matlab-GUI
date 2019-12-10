LastGSN=GetLastGSN();
NLimit=100000;
while(1)
    NewGSN=GetLastGSN();
    if(~(NewGSN==LastGSN))
        disp('Moving Motor Seq PM2');
        MoveMotorSequencePM2
    end
    pause(1);
end