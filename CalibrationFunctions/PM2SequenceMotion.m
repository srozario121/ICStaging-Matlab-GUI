%Serial port magic
obj1 = instrfind('Type', 'serial', 'Port', 'COM5', 'Tag', '');
% Create the serial port object if it does not exist
% otherwise use the object that was found.
if isempty(obj1)
    obj1 = serial('COM5');
else
    fclose(obj1);
    obj1 = obj1 (1);
end

% Connect to instrument object, obj1.
fopen(obj1);
obj1.BaudRate=153600;
data1=[];LengthToMoveTape=10e-2;
TractorStepSize=(pi*24e-3)/60000;
TractorSteps=int32(LengthToMoveTape/TractorStepSize);
TensionOld=[];TensionNew=[];


%Sequence of motions
%Sequence A
%1) Move MS1 right(1) until ADC is at 1000
%2) Move MT2 left(0) until ADC is at 1000
%3) Move MS2 right(1) until ADC is at 1000
tic
SeqA.MT2=MoveMotorMatchADC('MTB',2,1000,10,50,obj1)
pause(0.1)
SeqA.MS2=MoveMotorMatchADC('MSB',3,1000,10,50,obj1)
pause(0.1)
SeqA.MS1=MoveMotorMatchADC('MSA',1,1000,10,50,obj1)
pause(0.1)
toc

%Sequence B
%1) Move MT1 left(0) until ADC is at 2000
%2) Move MS1 left(0) until ADC T1 is at 1000
%Repeat until MT1 has taken L=10mm of steps
%1) Move MT2 left(0) until ADC T2 is at 1000
%2) Move MS2 right(1) until ADC T3 is at 1000
%Repeat until MT2 has taken L=10mm of steps
SeqBSteps=0;SeqBStepSize=1000;TractorSteps_SeqB=TractorSteps/SeqBStepSize;
%Sequence BA
while SeqBSteps<TractorSteps_SeqB
SeqB.MT1=MoveMotorMatchADC('MTA',1,3500,100,SeqBStepSize,obj1) 
SeqBSteps=SeqBSteps+abs(SeqB.MT1.StepCount);
SeqB.MS1=MoveMotorMatchADC('MSA',1,1000,100,SeqBStepSize,obj1)
end
%Sequence BB

SeqB.MT2=MoveMotorMatchADC('MTB',2,1000,50,SeqBStepSize,obj1) 
SeqB.MS2=MoveMotorMatchADC('MSB',3,1000,50,SeqBStepSize,obj1)

%Sequence C
%1) Move MT2 left(0) until ADC T2 is at 3500
%2) Move MS2 righ(0) until ADC T3 is at 2000
%Get tension

fclose(obj1);
fprintf('Tension old is :%i, Tension new is :%i \n',TensionOld,TensionNew);
fprintf('Total step count is %i \n',StepCount);