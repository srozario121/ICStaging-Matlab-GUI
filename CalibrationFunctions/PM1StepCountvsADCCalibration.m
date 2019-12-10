%%
% Script to move the motors from untension to full tension for PM1 and
% return a curve for step vs adc count.
%%
addpath ../
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
data1=[];
TensionOld=[];Tension1_New_Mean_MS1=[];


%Get tension
data1=query(obj1,'Get TB Weight 1 \n \r');
TensionOld=sscanf(data1,'%li');
StepCount=0;
%Calibrate tension vs step number

%Ready Motor MS1
data1=query(obj1,'Set MSA MConnect 1 \n \r');
data1=query(obj1,'Set MSA Steps 10 \n \r')
data1=query(obj1,'Set MSA Speed 500 \n \r')
data1=query(obj1,'Set MSA Dir 1 \n \r')

StepCount=0;Tension1_Curr=0;TensionSamples=50;
tic
%Start loop
while Tension1_Curr<4090
    pause(0.05)
    data1=query(obj1,'Move MSA Motor 1 \n \r');
    Tension1_SampleValues=[];Tension2_SampleValues=[];
    for i =1:TensionSamples
        pause(0.01);
        data1=query(obj1,'Get TD Weight 1 \n \r');
        TensionAllValues=sscanf(data1,'%li,%li,%li');
        Tension1_SampleValues(i)=TensionAllValues(1);        
        Tension2_SampleValues(i)=TensionAllValues(2);
    end
    StepCount=StepCount+1;
    Tension1_Curr=mean(Tension1_SampleValues);Tension2_Curr=mean(Tension2_SampleValues);
    
    Tension1_New_Mean_MS1(StepCount)=mean(Tension1_SampleValues);    Tension1_New_Std_MS1(StepCount)=std(Tension1_SampleValues);
    Tension2_New_Mean_MS1(StepCount)=mean(Tension2_SampleValues);    Tension2_New_Std_MS2(StepCount)=std(Tension2_SampleValues);
    
    if(StepCount>1000)
       break; 
    end
    fprintf('Currently at step %i, Current tension is %.2f \n',StepCount,Tension1_Curr);
end
toc
%Move motor back by the same number of steps
data1=query(obj1,sprintf('Set MSA Steps %i \n \r',StepCount*10));
data1=query(obj1,'Set MSA Dir 0 \n \r');
data1=query(obj1,'Move MSA Motor 1 \n \r');
figure;scatter((1:length(Tension1_New_Mean_MS1)).*10,Tension1_New_Mean_MS1);hold on;scatter((1:length(Tension2_New_Mean_MS1)).*10,Tension2_New_Mean_MS1);
xlabel('Step number');ylabel('ADC value');grid on;legend('T1','T2');
title('Step vs tension for MS1');

%% Motor 2 calibration
data1=query(obj1,'Set MSB MConnect 1 \n \r');
data1=query(obj1,'Set MSB Steps 10 \n \r')
data1=query(obj1,'Set MSB Speed 500 \n \r')
data1=query(obj1,'Set MSB Dir 1 \n \r')


StepCount=0;Tension2_Curr=0;TensionSamples=50;
tic
%Start loop for MS2
while Tension2_Curr<4090
    pause(0.05)
    data1=query(obj1,'Move MSB Motor 1 \n \r');
    Tension1_SampleValues=[];Tension2_SampleValues=[];
    for i =1:TensionSamples
        pause(0.01);
        data1=query(obj1,'Get TD Weight 1 \n \r');
        TensionAllValues=sscanf(data1,'%li,%li,%li');
        Tension1_SampleValues(i)=TensionAllValues(1);        
        Tension2_SampleValues(i)=TensionAllValues(2);
    end
    StepCount=StepCount+1;
    Tension1_Curr=mean(Tension1_SampleValues);Tension2_Curr=mean(Tension2_SampleValues);
    
    Tension1_New_Mean_MS2(StepCount)=mean(Tension1_SampleValues);    Tension1_New_Std_MS2(StepCount)=std(Tension1_SampleValues);
    Tension2_New_Mean_MS2(StepCount)=mean(Tension2_SampleValues);    Tension2_New_Std_MS2(StepCount)=std(Tension2_SampleValues);
    
    if(StepCount>1000)
       break; 
    end
    fprintf('Currently at step %i, Current tension is %.2f \n',StepCount,Tension2_Curr);
end
toc
%Move motor back by the same number of steps
data1=query(obj1,sprintf('Set MSB Steps %i \n \r',(StepCount)*10));
data1=query(obj1,'Set MSB Dir 0 \n \r');
data1=query(obj1,'Move MSB Motor 1 \n \r');

figure;scatter((1:length(Tension1_New_Mean_MS2)).*10,Tension1_New_Mean_MS2);hold on;scatter((1:length(Tension2_New_Mean_MS2)).*10,Tension2_New_Mean_MS2);
xlabel('Step number');ylabel('ADC value');grid on;legend('T1','T2');
title('Step vs tension for MS2');

fclose(obj1);
fprintf('Tension old is :%i, Tension new is :%i',TensionOld,Tension1_New_Mean_MS1);
fprintf('Total step count is %i',StepCount);