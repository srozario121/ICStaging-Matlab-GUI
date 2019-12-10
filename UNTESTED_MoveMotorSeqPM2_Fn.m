%%%
%Script to move the motor one sequence on PM2
%%%
function [TimeElapsed_PM2,SetupMMMT_MS1,SetupMMMT_MT2,SetupMMMT_MS2,FinalMMMT_MS1,FinalMMMT_MT2,FinalMMMT_MS2]= MoveMotorSeqPM2_Fn()
figure(1);
tic
addpath CalibrationFunctions
%% Input section
Diameter_MS=44e-3;Diameter_MT=24e-3;Diameter_MS_Max=5*Diameter_MS;
MT_StepsPerSecond=3000;
Perimeter_MS=pi*Diameter_MS;Perimeter_MS_Max=pi*Diameter_MS_Max;Perimeter_MT=pi*Diameter_MT;
MS_StepsPerRev=120000;MT_StepsPerRev=60000;
SequenceLength=4e-3;Direction=1;%0 is forward 1 is backward
MS1_StepFactor=2;
MS2_StepFactor=5;
MT1_StepFactor=1;
MT2_StepFactor=5;
%% Calculation
%Calculate Length of spool per step of each motor
MS_LengthPerSequence=Perimeter_MS/MS_StepsPerRev;
MS_Max_LengthPerSequence=Perimeter_MS_Max/MS_StepsPerRev;
MT_LengthPerSequence=Perimeter_MT/MT_StepsPerRev;

%Calculate how many steps you have to move each motor
MS_Seq_Steps=int32(SequenceLength/MS_LengthPerSequence);
MS_Max_Seq_Steps=int32(SequenceLength/MS_Max_LengthPerSequence);
MT_Seq_Steps=int32(SequenceLength/MT_LengthPerSequence);

MS_CorrectionStepsize=abs(MS_Seq_Steps-MS_Max_Seq_Steps)/10;
obj1=SetupCOM('COM5',153600);
%The tape moves at initial tension and the last takes a shot at final
%tension
InitialTension=10;FinalTension=75;
%Set initial tensions
BeforeInitTime=toc;
disp('MMMT for MT2')
SetupMMMT_MT2=MoveMotorMatchTension('MTB',2,2,InitialTension,0.1,MS_CorrectionStepsize*20,obj1,0);
disp('MMMT for MS1')
SetupMMMT_MS1=MoveMotorMatchTension('MSA',1,1,InitialTension,0.1,MS_CorrectionStepsize,obj1,0);
disp('MMMT for MS2')
SetupMMMT_MS2=MoveMotorMatchTension('MSB',3,3,InitialTension,0.1,MS_CorrectionStepsize,obj1,1);
AfterInitTime=toc;
%Set up motors
%MSA forward
data1=query(obj1,'Set MSA MConnect 1 \n \r');
data1=query(obj1,sprintf('Set MSA Steps %i \n \r',MS_Seq_Steps*MS1_StepFactor));
data1=query(obj1,'Set MSA Speed 500 \n \r');
data1=query(obj1,sprintf('Set MSA Dir %i \n \r',Direction));

%MSB forward
data1=query(obj1,'Set MSB MConnect 1 \n \r');
data1=query(obj1,sprintf('Set MSB Steps %i \n \r',MS_Seq_Steps*MS2_StepFactor));
data1=query(obj1,'Set MSB Speed 500 \n \r');
data1=query(obj1,sprintf('Set MSB Dir %i \n \r',int32(Direction)))

%MTA forward
data1=query(obj1,'Set MTA MConnect 1 \n \r');
data1=query(obj1,sprintf('Set MTA Steps %i \n \r',MT_Seq_Steps*MT1_StepFactor));
data1=query(obj1,'Set MTA Speed 500 \n \r');
data1=query(obj1,sprintf('Set MTA Dir %i \n \r',int32(~Direction)));

%MTB forward
data1=query(obj1,'Set MTB MConnect 1 \n \r');
data1=query(obj1,sprintf('Set MTB Steps %i \n \r',MT_Seq_Steps*MT2_StepFactor));
data1=query(obj1,'Set MTB Speed 500 \n \r');
data1=query(obj1,sprintf('Set MTB Dir %i \n \r',int32(~Direction)));
%% Move motors
%If moving backwards move motors in different order
disp('Moving all motors');
if(Direction==1)
    %Move MS1
    data1=query(obj1,'Move MSA Motor 1 \n \r');
    pause(0.1);

    %Move MT1 and MT2
    data1=query(obj1,'Move MTC Motor 1 \n \r');
    pause(0.3);

    %Move MS2
    data1=query(obj1,'Move MSB Motor 1 \n \r');
    pause(2);
else
    %Move MS2
    data1=query(obj1,'Move MSB Motor 1 \n \r')
    pause(2);

    %Move MT1 and MT2
    data1=query(obj1,'Move MTC Motor 1 \n \r')
    pause(0.3);

    %Move MS1
    data1=query(obj1,'Move MSA Motor 1 \n \r')
    pause(0.1);
end

BeforeFinalTime=toc;
disp('MMMT for MTB at end of PM2')
FinalMMMT_MT2=MoveMotorMatchTension('MTB',2,2,FinalTension,0.1,MS_CorrectionStepsize*25,obj1,0);
disp('MMMT for MSA at end of PM2')
FinalMMMT_MS1=MoveMotorMatchTension('MSA',1,1,InitialTension,0.1,MS_CorrectionStepsize,obj1,0);
disp('MMMT for MSB at end of PM2')
FinalMMMT_MS2=MoveMotorMatchTension('MSB',3,3,InitialTension,0.1,MS_CorrectionStepsize*2,obj1,1);
AfterFinalTime=toc;
toc
fprintf('Initial matching time for PM2:%.2f s \n',abs(BeforeInitTime-AfterInitTime));
fprintf('Final matching time for PM2:%.2f s \n',abs(BeforeFinalTime-AfterFinalTime));
SetupMMMT_MS1=SetupMMMT_MS1.FinalTension;
SetupMMMT_MS2=SetupMMMT_MS2.FinalTension;
SetupMMMT_MT2=SetupMMMT_MT2.FinalTension;
FinalMMMT_MS1=FinalMMMT_MS1.FinalTension;
FinalMMMT_MS2=FinalMMMT_MS2.FinalTension;
FinalMMMT_MT2=FinalMMMT_MT2.FinalTension;
 figure;
 subplot(2,1,1);
 plot(SetupMMMT_MS1);hold on;plot(SetupMMMT_MS2);plot(SetupMMMT_MT2);legend('Initial MS1','Initial MS2','Initial MT2');
 subplot(2,1,2);
 plot(FinalMMMT_MS1);hold on;plot(FinalMMMT_MS2);plot(FinalMMMT_MT2);legend('Final MS1','Final MS2','Final MT2');
TimeElapsed_PM2=toc;
save('PM2_LastUsedVar.mat','TimeElapsed_PM2','SetupMMMT_MS1','SetupMMMT_MS2',...
'SetupMMMT_MT2','FinalMMMT_MS1','FinalMMMT_MS2','FinalMMMT_MT2');
end