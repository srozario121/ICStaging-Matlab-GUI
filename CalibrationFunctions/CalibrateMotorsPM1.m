%%
%ADC and motor failure test
% Read ADC, move motor between bounds
%%
%functiony=CalibrateMotorsPM1
tic
TestTime=datestr(now);
OutputFile='Data/PM1_Calibration.mat';
if(~exist(OutputFile))
    save(OutputFile);
end
NTest=5000;StepIncrement=100;
TensionOld=[];PlotOn=1;
addpath ../
obj1=SetupCOM('COM7',153600);
data1=query(obj1,'Move MSA Motor 0 \n \r');
data1=query(obj1,'Move MSB Motor 0 \n \r');
data1=query(obj1,'Move MTA Motor 0 \n \r');
data1=query(obj1,'Move MTB Motor 0 \n \r');

data1=query(obj1,'Set MSA MConnect 1 \n \r')
data1=query(obj1,sprintf('Set MSA Steps %i \n \r',StepIncrement));
data1=query(obj1,'Set MSA Speed 500 \n \r')
data1=query(obj1,'Set MSA Dir 0 \n \r');
 
%MSB forward
data1=query(obj1,'Set MSB MConnect 1 \n \r')
data1=query(obj1,sprintf('Set MSB Steps %i \n \r',StepIncrement));
data1=query(obj1,'Set MSB Speed 500 \n \r');
data1=query(obj1,'Set MSB Dir 1 \n \r');
%Create real time figure of status
fig1=figure;
for i=1:NTest
    try
        data1=query(obj1,'Get TD Weight 1 \n \r');
        TensionOld(i,:)=sscanf(data1,'%li,%li,%li');
        flushinput(obj1);flushoutput(obj1);
        if((TensionOld(i,1)<1000))
            data1=query(obj1,'Set MSA Dir 1 \n \r');
        elseif((TensionOld(i,1)>2000))
            data1=query(obj1,'Set MSA Dir 0 \n \r');
        end
        
        if((TensionOld(i,2)<1000))
            data1=query(obj1,'Set MSB Dir 1 \n \r');
        elseif((TensionOld(i,2)>2000))
            data1=query(obj1,'Set MSB Dir 0 \n \r');
        end
        
        data1=query(obj1,'Move MSA Motor 1 \n \r');
        data1=query(obj1,'Move MSB Motor 1 \n \r');
        %Plot every 1000 shots
        if(mod(i,1000)==0)
        plot(1:size(TensionOld,1),TensionOld(:,1),'r');hold on;
        plot(1:size(TensionOld,1),TensionOld(:,2),'b');
        plot(1:size(TensionOld,1),TensionOld(:,3),'g');
        xlabel('N samples');ylabel('Tension value');legend('T1','T2','T3');hold off;
        title('ADC and motor stress test');
        drawnow; 
        end
    catch
        
       break; 
    end
    fprintf('Currently at %i \n',i);
end
[pks,locs1]=findpeaks(TensionOld(:,1),(1:length(TensionOld(:,1)))*StepIncrement,'MinPeakDistance',5000,'MinPeakHeight',2000);
[pks,locs2]=findpeaks(TensionOld(:,2),(1:length(TensionOld(:,2)))*StepIncrement,'MinPeakDistance',5000,'MinPeakHeight',2000);
NoSteps=(1:length(TensionOld(:,1)))*StepIncrement;
NoPeaks1=1:length(locs1);NoPeaks2=1:length(locs2);

% Set up fittype and options.
ft = fittype( 'poly1' );
[xData1, yData1] = prepareCurveData( NoPeaks1, locs1 );

% Fit model to data.
[fitresult1, gof1] = fit( xData1, yData1, ft );

[xData2, yData2] = prepareCurveData( NoPeaks2, locs2 );

% Fit model to data.
[fitresult2, gof2] = fit( xData2, yData2, ft );

% Plot fit with data.
if(PlotOn==1)
figure( 'Name', 'Calibration results' );
plot( xData1,yData1,'r');hold on;
plot( xData2,yData2,'b');
legend(  'locs1 vs. NoPeaks1', 'locs2 vs. NoPeaks2', 'Location', 'NorthEast' );
% Label axes
xlabel NoPeaks
ylabel('Steps per cycle');
grid on
end
RadiusRatio_MS1_MS2=fitresult2.p1/fitresult1.p1;
OPut=[];
load(OutputFile);
OPut.TensionData{end+1}=TensionOld;
OPut.TimeStamp{end+1}=TestTime;
OPut.RadiusRatio_MS1_MS2(end+1)=RadiusRatio_MS1_MS2;
save(OutputFile,'OPut');
    
data1=query(obj1,'Move MSA Motor 0 \n \r');
data1=query(obj1,'Move MSB Motor 0 \n \r');
data1=query(obj1,'Move MTA Motor 0 \n \r');
data1=query(obj1,'Move MTB Motor 0 \n \r');
fclose(obj1);
toc
%end