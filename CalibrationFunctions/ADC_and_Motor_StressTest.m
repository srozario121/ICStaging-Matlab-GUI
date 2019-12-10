%%
%ADC and motor failure test
% Read ADC, move motor between bounds
%%
NTest=25000;StepIncrement=100;
TensionOld=[];
addpath ../
obj1=SetupCOM('COM7',153600);
data1=query(obj1,'Move MSA Motor 0 \n \r');
data1=query(obj1,'Move MSB Motor 0 \n \r');
data1=query(obj1,'Move MTA Motor 0 \n \r');
data1=query(obj1,'Move MTB Motor 0 \n \r');

data1=query(obj1,'Set MSA MConnect 1 \n \r')
data1=query(obj1,sprintf('Set MSA Steps %i \n \r',StepIncrement));
data1=query(obj1,'Set MSA Speed 50 \n \r')
data1=query(obj1,'Set MSA Dir 0 \n \r');
 
%MSB forward
data1=query(obj1,'Set MSB MConnect 1 \n \r')
data1=query(obj1,sprintf('Set MSB Steps %i \n \r',StepIncrement));
data1=query(obj1,'Set MSB Speed 50 \n \r');
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
        elseif((TensionOld(i,2)>3000))
            data1=query(obj1,'Set MSB Dir 0 \n \r');
        end
        
        data1=query(obj1,'Move MSA Motor 1 \n \r');
        data1=query(obj1,'Move MSB Motor 1 \n \r');
        pause(0.1);
        %Plot every 1000 shots
        if(mod(i,100)==0)
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
    save('Data/PM1_Test1.mat','TensionOld');
    
data1=query(obj1,'Move MSA Motor 0 \n \r');
data1=query(obj1,'Move MSB Motor 0 \n \r');
data1=query(obj1,'Move MTA Motor 0 \n \r');
data1=query(obj1,'Move MTB Motor 0 \n \r');
fclose(obj1);
