function y=MoveMotorMatchADC(Motor,TensionArm,ADC,Tolerance,MotorStepSize,obj1)
%Prep motor
if(strcmp(Motor,'MSA'))
    data1=query(obj1,'Set MSA MConnect 1 \n \r');
    pause(0.1);
    data1=query(obj1,sprintf('Set MSA Steps %i \n \r',MotorStepSize));
    pause(0.1);
    data1=query(obj1,'Set MSA Speed 500 \n \r');
elseif(strcmp(Motor,'MSB'))
    data1=query(obj1,'Set MSB MConnect 1 \n \r');
    pause(0.1);
    data1=query(obj1,sprintf('Set MSB Steps %i \n \r',MotorStepSize));
    pause(0.1);
    data1=query(obj1,'Set MSB Speed 500 \n \r');
elseif(strcmp(Motor,'MTA'))
    data1=query(obj1,'Set MTA MConnect 1 \n \r');
    pause(0.1);
    data1=query(obj1,sprintf('Set MTA Steps %i \n \r',MotorStepSize));
    pause(0.1);
    data1=query(obj1,'Set MTA Speed 500 \n \r');
elseif(strcmp(Motor,'MTB'))
    data1=query(obj1,'Set MTB MConnect 1 \n \r');
    pause(0.1);
    data1=query(obj1,sprintf('Set MTB Steps %i \n \r',MotorStepSize));
    pause(0.1);
    data1=query(obj1,'Set MTB Speed 500 \n \r');
end

if(TensionArm<1||TensionArm>3)
    error('Tension arm number is wrong');
end
StepCount=0;TensionNew=[0;0;0];LoopCounter=0;
while (abs(TensionNew(TensionArm)-ADC)>Tolerance || LoopCounter<2)
    LoopCounter=LoopCounter+1;
    data1=query(obj1,'Get TD Weight 1 \n \r')
    pause(0.1);
    TensionNew=sscanf(data1,'%li,%li,%li');

    if(TensionNew(TensionArm)<ADC)
        %Ready Motor MS1
        if(strcmp(Motor,'MSA'))
            data1=query(obj1,sprintf('Set %s Dir 1 \n \r',Motor));
        elseif(strcmp(Motor,'MSB'))
            data1=query(obj1,sprintf('Set %s Dir 1 \n \r',Motor));
        elseif(strcmp(Motor,'MTA'))
            if(TensionArm==1)
                data1=query(obj1,sprintf('Set %s Dir 0 \n \r',Motor));
            elseif(TensionArm==2)
                data1=query(obj1,sprintf('Set %s Dir 1 \n \r',Motor));
            else
                warning('Error with tension arm number');
            end
        elseif(strcmp(Motor,'MTB'))
            if(TensionArm==2)
                data1=query(obj1,sprintf('Set %s Dir 0 \n \r',Motor));
            elseif(TensionArm==3)
                data1=query(obj1,sprintf('Set %s Dir 1 \n \r',Motor));
            end
        end
        StepCount=StepCount+1;
    else
        if(strcmp(Motor,'MSA'))
            data1=query(obj1,sprintf('Set %s Dir 0 \n \r',Motor));
        elseif(strcmp(Motor,'MSB'))
            data1=query(obj1,sprintf('Set %s Dir 0 \n \r',Motor));
        elseif(strcmp(Motor,'MTA'))
            if(TensionArm==1)
                data1=query(obj1,sprintf('Set %s Dir 1 \n \r',Motor));
            elseif(TensionArm==2)
                data1=query(obj1,sprintf('Set %s Dir 0 \n \r',Motor));
            else
            end
        elseif(strcmp(Motor,'MTB'))
            if(TensionArm==2)
                data1=query(obj1,sprintf('Set %s Dir 1 \n \r',Motor));
            elseif(TensionArm==3)
                data1=query(obj1,sprintf('Set %s Dir 0 \n \r',Motor));
            end
        end
            StepCount=StepCount-1;
    end
    pause(0.1);
    data1=query(obj1,sprintf('Move %s Motor 1 \n \r',Motor));
    pause(0.1);

    if(StepCount>int32(10000/MotorStepSize))
       break; 
    end
end
y.StepCount=StepCount;
y.FinalADC=TensionNew;
if(strcmp(Motor,'MSA'))
    data1=query(obj1,'Set MSA MConnect 1 \n \r');
elseif(strcmp(Motor,'MSB'))
    data1=query(obj1,'Set MSB MConnect 1 \n \r');
elseif(strcmp(Motor,'MTA'))
    data1=query(obj1,'Set MTA MConnect 1 \n \r');
elseif(strcmp(Motor,'MTB'))
    data1=query(obj1,'Set MTB MConnect 1 \n \r');
end
end