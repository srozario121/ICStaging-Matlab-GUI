%%
%ADC and motor failure test
% Read ADC, move motor between bounds
%%
NTest=5000;StepIncrement=10;
TensionOld=[];TensionLower=2000;TensionUpper=3000;
MSADirGrad=1;MSBDirGrad=0;
addpath ../
obj2=SetupCOM('COM5',153600);
data1=query(obj2,'Move MSA Motor 0 \n \r');
data1=query(obj2,'Move MSB Motor 0 \n \r');
data1=query(obj2,'Move MTA Motor 0 \n \r');
data1=query(obj2,'Move MTB Motor 0 \n \r');

%MSA forward
data1=query(obj2,'Set MSA MConnect 1 \n \r')
data1=query(obj2,sprintf('Set MSA Steps %i \n \r',StepIncrement));
data1=query(obj2,'Set MSA Speed 500 \n \r')
data1=query(obj2,'Set MSA Dir 0 \n \r');
 
%MSB forward
data1=query(obj2,'Set MSB MConnect 1 \n \r')
data1=query(obj2,sprintf('Set MSB Steps %i \n \r',StepIncrement));
data1=query(obj2,'Set MSB Speed 500 \n \r');
data1=query(obj2,'Set MSB Dir 1 \n \r');
%% Test MS1 and 2
%Create real time figure of status
fig1=figure;clf;
for i=1:NTest
    try
        data1=query(obj2,'Get TD Weight 1 \n \r');
        TensionOld(i,:)=sscanf(data1,'%li,%li,%li');
        flushinput(obj2);flushoutput(obj2);
        if((TensionOld(i,1)<TensionLower))
            data1=query(obj2,'Set MSA Dir 0 \n \r');
        elseif((TensionOld(i,1)>TensionUpper))
            data1=query(obj2,'Set MSA Dir 1 \n \r');
        end
        
        if((TensionOld(i,3)<TensionLower))
            data1=query(obj2,'Set MSB Dir 1 \n \r');
        elseif((TensionOld(i,3)>TensionUpper))
            data1=query(obj2,'Set MSB Dir 0 \n \r');
        end
        
        data1=query(obj2,'Move MSA Motor 1 \n \r');
        data1=query(obj2,'Move MSB Motor 1 \n \r');
        %Plot every 1000 shots
        if(mod(i,100)==0)
        scatter(1:size(TensionOld,1),TensionOld(:,1),'r.');hold on;
        scatter(1:size(TensionOld,1),TensionOld(:,2),'b.');
        scatter(1:size(TensionOld,1),TensionOld(:,3),'g.');grid on;
        xlabel('N samples');ylabel('Tension value');legend('T1','T2','T3');hold off;
        title('ADC and motor stress test: Moving MS1 and MS2');
        drawnow; 
        end
    catch
        
       break; 
    end
    fprintf('Currently at %i \n',i);
end
data1=query(obj2,'Move MSA Motor 0 \n \r');
data1=query(obj2,'Move MSB Motor 0 \n \r');
save('Data/Test1.mat','TensionOld');
%% Test MT1
%MTA forward
StepIncrement_MT1=50;NTest_MT1=5000;
data1=query(obj2,'Set MTA MConnect 1 \n \r')
data1=query(obj2,sprintf('Set MTA Steps %i \n \r',StepIncrement_MT1));
data1=query(obj2,'Set MTA Speed 500 \n \r');
data1=query(obj2,'Set MTA Dir 1 \n \r');
fig2=figure;TensionOld=[];
for i=1:NTest_MT1
    pause(0.1);
    try
        data1=query(obj2,'Get TD Weight 1 \n \r');
        TensionOld(i,:)=sscanf(data1,'%li,%li,%li');
        flushinput(obj2);flushoutput(obj2);
        if((TensionOld(i,2)<TensionLower))
            data1=query(obj2,'Set MTA Dir 1 \n \r');
        elseif((TensionOld(i,2)>TensionUpper))
            data1=query(obj2,'Set MTA Dir 0 \n \r');
        end
        pause(0.1)
        data1=query(obj2,'Move MTA Motor 1 \n \r');
        %Plot every 1000 shots
        if(mod(i,100)==0)
        scatter(1:size(TensionOld,1),TensionOld(:,1),'r.');hold on;
        scatter(1:size(TensionOld,1),TensionOld(:,2),'b.');
        scatter(1:size(TensionOld,1),TensionOld(:,3),'g.');grid on;
        xlabel('N samples');ylabel('Tension value');legend('T1','T2','T3');hold off;
        title('ADC and motor stress test: Moving MT1');
        drawnow; 
        end
    catch
        
       break; 
    end
    fprintf('Currently at %i \n',i);
end
data1=query(obj2,'Move MTA Motor 0 \n \r');
save('Data/Test2.mat','TensionOld');
%% Test MT2
%MTB forward
StepIncrement_MT2=50;NTest_MT2=5000;
data1=query(obj2,'Set MTB MConnect 1 \n \r')
data1=query(obj2,sprintf('Set MTB Steps %i \n \r',StepIncrement_MT2));
data1=query(obj2,'Set MTB Speed 50 \n \r');
data1=query(obj2,'Set MTB Dir 1 \n \r');
fig2=figure;TensionOld=[];
for i=1:NTest_MT2
    try
        data1=query(obj2,'Get TD Weight 1 \n \r');
        TensionOld(i,:)=sscanf(data1,'%li,%li,%li');
        flushinput(obj2);flushoutput(obj2);
        if((TensionOld(i,2)<TensionLower))
            data1=query(obj2,'Set MTB Dir 0 \n \r');
        elseif((TensionOld(i,2)>TensionUpper))
            data1=query(obj2,'Set MTB Dir 1 \n \r');
        end
        pause(0.1)
        data1=query(obj2,'Move MTB Motor 1 \n \r');
        %Plot every 1000 shots
        if(mod(i,1000)==0)
        scatter(1:size(TensionOld,1),TensionOld(:,1),'r.');hold on;
        scatter(1:size(TensionOld,1),TensionOld(:,2),'b.');
        scatter(1:size(TensionOld,1),TensionOld(:,3),'g.');grid on;
        xlabel('N samples');ylabel('Tension value');legend('T1','T2','T3');hold off;
        title('ADC and motor stress test: Moving MT2');
        drawnow; 
        end
    catch  
       break; 
    end
    fprintf('Currently at %i \n',i);
end
data1=query(obj2,'Move MTB Motor 0 \n \r');
save('Data/Test3.mat','TensionOld');
data1=query(obj2,'Move MSA Motor 0 \n \r');
data1=query(obj2,'Move MSB Motor 0 \n \r');
data1=query(obj2,'Move MTA Motor 0 \n \r');
data1=query(obj2,'Move MTB Motor 0 \n \r');
fclose(obj2);

