%%
% Function to move PM1 by a set amount
% Move both motors one step, if tension goes out of bound move either 
% MS1 or MS2 to correct.
%%
%Initialization step[handles.PM2.MS1CorrStep,handles.PM2.MS2CorrStep...
        %handles.PM2.TimeElapsed]
function [MS1_Correction,MS2_Correction,TimeElapsed_PM1]=MoveMotorSeqPM1_Fn()
addpath CalibrationFunctions

%User input section
Diameter_MS_PM1=44e-3;Diameter_MS_Max_PM1=60e-3;
MS_StepsPerRev_PM1=100000;SequenceLength_PM1=5e-3;%m

SpoolDirection=0;%0 is forward 1 is back/
PlotOn=1;
InitialTension=2.5;% N

tic
%% Step estimate calculation
Perimeter_MS_MS1=pi*Diameter_MS_PM1;Perimeter_MS_Max_MS1=pi*Diameter_MS_Max_PM1;
%Calculate Length of spool per step of each motor
MS_LengthPerSequence_PM1=Perimeter_MS_MS1/MS_StepsPerRev_PM1;
MS_Max_LengthPerSequence_PM1=Perimeter_MS_Max_MS1/MS_StepsPerRev_PM1;

%Calculate how many steps you have to move each motor
MS_Seq_Steps=4*int32(SequenceLength_PM1/MS_LengthPerSequence_PM1);
MS_Max_Seq_Steps=4*int32(SequenceLength_PM1/MS_Max_LengthPerSequence_PM1);
%Note there is a factor of 2 difference between actual steps and the MCU
%step variable!!
MaximalDifferenceInSteps=MS_Seq_Steps-MS_Max_Seq_Steps;
MS_CorrectionStepsize=MaximalDifferenceInSteps/10;
%Initialize variables and setup COM
StepCount=1;
MaxStepCount=(MS_Seq_Steps-MS_Max_Seq_Steps)/MS_CorrectionStepsize;
obj1=SetupCOM('COM7',153600);
OutputFilePath='PM1_LogFile.txt';
if(isfile(OutputFilePath))
    fileID=fopen(OutputFilePath,'a');
else
    fileID=fopen(OutputFilePath,'w');
    fprintf(fileID,'%s,%s,%s,%s,%s,%s,%s,%s,%s \r','Date','SequenceLength',...
        'MS_CorrectionStepsize','SpoolDirection','InitialTension',...
        'MS1 Correction Step size','MS2 Correction Step size','Sequence time');
end

%Get tension
MSADir=0;MSBDir=1;
if(SpoolDirection==1)
    MSADir=1;MSBDir=0;
end
disp('Matching tension initial');
SetupMMMT_MS2=MoveMotorMatchTension('MSB',2,6,InitialTension,0.1,MS_CorrectionStepsize*10,obj1,1);
SetupMMMT_MS1=MoveMotorMatchTension('MSA',1,5,InitialTension,0.1,MS_CorrectionStepsize*10,obj1,1);
pause(0.3);
data1=query(obj1,'Get TD Weight 1 \n \r');
TensionOld=sscanf(data1,'%li,%li,%li');

%% Ready Motor MS1
disp('Set motor A');
data1=query(obj1,'Set MSA MConnect 1 \n \r');%29
data1=query(obj1,sprintf('Set MSA Steps %i \n \r',MS_Seq_Steps));
data1=query(obj1,'Set MSA Speed 500 \n \r');
data1=query(obj1,sprintf('Set MSA Dir %i \n \r',MSADir));
data1=query(obj1,'Move MSA Motor 1 \n \r');
pause(0.3);
%% Ready Motor MS2
disp('Set motor B');
data1=query(obj1,'Set MSB MConnect 1 \n \r');%-31
data1=query(obj1,sprintf('Set MSB Steps %i \n \r',MS_Seq_Steps));
data1=query(obj1,'Set MSB Speed 500 \n \r');
data1=query(obj1,sprintf('Set MSB Dir %i \n \r',MSBDir));

data1=query(obj1,'Move MSB Motor 1 \n \r');

pause(1);
disp('Matching tension final');
FinalMMMT_MS1=MoveMotorMatchTension('MSA',1,5,InitialTension,0.1,MS_CorrectionStepsize*10,obj1,1);
FinalMMMT_MS2=MoveMotorMatchTension('MSB',2,6,InitialTension,0.1,MS_CorrectionStepsize*10,obj1,1);
pause(0.2);
%Stop Motors
data1=query(obj1,'Move MSA Motor 0 \n \r');
data1=query(obj1,'Move MSB Motor 0 \n \r');
data1=query(obj1,'Move MTA Motor 0 \n \r'); 
data1=query(obj1,'Move MTB Motor 0 \n \r');
TimeElapsed_PM1=toc;
fclose(obj1);
% if(PlotOn==1)
%     plot(SetupMMMT_MS2.FinalTension);hold on;
%     plot(FinalMMMT_MS2.FinalTension);
%     plot(FinalMMMT_MS1.FinalTension);
%     xlabel('Steps');ylabel('Tension');
%     legend('T2 initial','T2 final','T1 final');
% end
MS2_Correction=FinalMMMT_MS2.FinalTension;
MS1_Correction=FinalMMMT_MS1.FinalTension;
%fprintf(fileID,'%s,%s,%s,%s,%s,%s,%s,%s \n','Date','SequenceLength',...
%'MS_CorrectionStepsize','SpoolDirection','InitialTension',...
%'MS1 Correction Step size','MS2 Correction Step size');
fprintf(fileID,'%s,%d,%d,%d,%d,%d,%d,%d \n',datestr(now),SequenceLength_PM1/1e-3,...
    MS_CorrectionStepsize,SpoolDirection,InitialTension,int32(MS1_Correction),int32(MS2_Correction),int32(TimeElapsed_PM1)); 
fclose(fileID);
save('PM1_LastUsedVar.mat','MS2_Correction','MS1_Correction');

end