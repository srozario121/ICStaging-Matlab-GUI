function y=MoveMotorMatchTension(Motor,TensionNo,AmplifierNo,Weight,Tolerance,MotorStepSize,obj1,TensionDirection)
%%
% This function moves the motor and checks the tension. If the tension gets
% too high it changes direction. It does this until the tension matches the
% input tension within a certain tolerance
%
% Motor- MSA,MSB,MTA or MTB arguments work
% TensionNo- 1,2 or 3 currently work
% Weight- Force in N to be reached by tension sensor
% Tolerance- Sequence stops when abs(Weight-Measurement)<Tolerance*Weight
% MotorStepSize- Size of the steps to move the motor each iteration
% obj1- Serial object via which communication is occuring
% TensionDirection- Motor direction in which the gradient of tension in
% increasing
%%
%DebugLine
%Motor='MSA';TensionNo=1;AmplifierNo=3;Weight=5;Tolerance=0.1;MotorStepSize=50;TensionDirection=1;%
addpath ../
%Prep motor
data1=query(obj1,sprintf('Set %s MConnect 1 \n \r',Motor));
data1=query(obj1,sprintf('Set %s Steps %i \n \r',Motor,MotorStepSize));
data1=query(obj1,sprintf('Set %s Speed 500 \n \r',Motor));
%Error check inputs
if(TensionNo<1||TensionNo>8||Weight <0.1 ||Weight>80||TensionDirection>1||TensionDirection<0)
    error('Check input arguments');
end

StepCount=0;TensionNew=0;LoopCounter=1;ADCNew=[];
DirectionFlipCounter=0;InitialDirec=TensionDirection;
PauseDuration=0.2;
while (abs(TensionNew(LoopCounter)-Weight)>Weight*Tolerance || LoopCounter<2)
    LoopCounter=LoopCounter+1;
    pause(PauseDuration);
    data1=query(obj1,'Get TD Weight 1 \n \r');
    ADCNew(LoopCounter,:)=sscanf(data1,'%li,%li,%li');
    TensionNew(LoopCounter)=WeighingScaleADCToForce(ADCNew(LoopCounter,TensionNo),AmplifierNo);
    if(TensionNew(LoopCounter)<Weight)
        data1=query(obj1,sprintf('Set %s Dir %i \n \r',Motor,TensionDirection));
        StepCount=StepCount+1;
        if(InitialDirec~=TensionDirection)
            DirectionFlipCounter=DirectionFlipCounter+1;
            InitialDirec=TensionDirection;
            if(DirectionFlipCounter>1)
             MotorStepSize=int32(MotorStepSize/2.5);
             PauseDuration=PauseDuration/1.5;
                data1=query(obj1,sprintf('Set %s Steps %i \n \r',Motor,MotorStepSize));
            end
        end
    else
        data1=query(obj1,sprintf('Set %s Dir %i \n \r',Motor,int32(~TensionDirection)));
        StepCount=StepCount-1;
        if(InitialDirec==TensionDirection)
            DirectionFlipCounter=DirectionFlipCounter+1;
            InitialDirec=int32(~TensionDirection);
            if(DirectionFlipCounter>1)
                 MotorStepSize=int32(MotorStepSize/2.5);
                 PauseDuration=PauseDuration/1.5;
                data1=query(obj1,sprintf('Set %s Steps %i \n \r',Motor,MotorStepSize));
            end
        end
    end
    data1=query(obj1,sprintf('Move %s Motor 1 \n \r',Motor));
    pause(0.1);

    if(StepCount>int32(100000/MotorStepSize))
        warning('Stepcount over critical threshold. Risk of tape breakage')
       break; 
    elseif(TensionNew(end)>210)
        warning('Tension over critical threshold. Risk of tape breakage. Check input.')
       break;
    end
end
y.StepCount=StepCount*MotorStepSize;y.FinalTension=TensionNew;y.ADCValue=ADCNew;
y.DirectionFlipCounter=DirectionFlipCounter;
data1=query(obj1,sprintf('Move %s Motor 0 \n \r',Motor));
data1=query(obj1,sprintf('Set %s MConnect 0 \n \r',Motor));

end