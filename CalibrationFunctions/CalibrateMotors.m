%Setup Com port
obj1=SetupCOM('COM5',153600);
TensionOld=[];TensionNew=[];
%function y=CalibrateMotors(obj1,CalibADC,CalibSteps)
TractorOuterRadius=24;%mm
CalibSteps=1000;MS_CorrectionStepsize_Initial=3;MS_CorrectionStepsize=3;
%Get to  10N everywhere
InitialTension=5;
%Set initial tensions
disp('MMMT for MS1')
SetupMMMT_MS1=MoveMotorMatchTension('MSA',1,1,InitialTension,0.01,MS_CorrectionStepsize_Initial,obj1,0);
disp('MMMT for MT2')
SetupMMMT_MT2=MoveMotorMatchTension('MTB',2,2,InitialTension,0.01,MS_CorrectionStepsize_Initial,obj1,0);
disp('MMMT for MS2')
SetupMMMT_MS2=MoveMotorMatchTension('MSB',3,3,InitialTension,0.01,MS_CorrectionStepsize_Initial,obj1,1);
pause(1);
%MS1 Outer Radius
%Move MS1 left(0) by CalibSteps and record ADC
data1=query(obj1,'Get TD Weight 1 \n \r');
TensionOld=sscanf(data1,'%li,%li,%li');
data1=query(obj1,'Set MSA MConnect 1 \n \r');
data1=query(obj1,sprintf('Set MSA Steps %i \n \r',CalibSteps));
data1=query(obj1,'Set MSA Speed 500 \n \r');
data1=query(obj1,'Set MSA Dir 1 \n \r');
pause(0.1);
data1=query(obj1,'Move MSA Motor 1 \n \r');
pause(2);
%Calib1=MoveMotorMatchADC('MTA',1,TensionOld(1),10,CalibTSteps,obj1)
SetupMMMT_MT1=MoveMotorMatchTension('MTA',1,1,InitialTension,0.01,MS_CorrectionStepsize,obj1,0);
MS1InnerRadius=abs(((CalibSteps)/(SetupMMMT_MT1.StepCount)))*TractorOuterRadius
pause(0.1);
data1=query(obj1,'Set MSA MConnect 0 \n \r');
fclose(obj1);
%end