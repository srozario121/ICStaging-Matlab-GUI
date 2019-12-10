%%
%ADC failure test
% Read ADC an absurd amount of times to see if it fails
%%
NTest=100000;
TensionOld1=[];TensionOld2=[];
addpath ../
obj1=SetupCOM('COM7',153600);
% obj2=SetupCOM('COM5',153600);
 query(obj1,'Move MSA Motor 0 \n \r');
 query(obj1,'Move MSB Motor 0 \n \r');
 query(obj1,'Move MTA Motor 0 \n \r');
 query(obj1,'Move MTB Motor 0 \n \r');

% query(obj2,'Move MSA Motor 0 \n \r');
% query(obj2,'Move MSB Motor 0 \n \r');
% query(obj2,'Move MTA Motor 0 \n \r');
% query(obj2,'Move MTB Motor 0 \n \r');
for i=1:NTest
    try
         data1=query(obj1,'Get TD Weight 1 \n \r');  
%         data2=query(obj2,'Get TD Weight 1 \n \r');
        
         TensionOld1(i,:)=sscanf(data1,'%li,%li,%li');
%         TensionOld2(size(TensionOld2,1)+1,:)=sscanf(data2,'%li,%li,%li');
         if(mod(i,100)==0)
%             plot(1:size(TensionOld2,1),TensionOld2(:,1),'k-');hold on;
%             plot(1:size(TensionOld2,1),TensionOld2(:,2),'c-');
%             plot(1:size(TensionOld2,1),TensionOld2(:,3),'m-');
%             xlabel('N samples');ylabel('Tension value');
            grid on;
             plot(1:size(TensionOld1,1),TensionOld1(:,1),'r-');
             plot(1:size(TensionOld1,1),TensionOld1(:,2),'b-');
             plot(1:size(TensionOld1,1),TensionOld1(:,3),'g-');
             xlabel('N samples');ylabel('Tension value');
            %legend('PM2 T1','PM2 T2','PM2 T3','PM1 T1','PM1 T2','PM1 T3');hold off;
            %legend('PM2 T1','PM2 T2','PM2 T3');
            legend('PM1 T1','PM1 T2','PM1 T3');
            title('ADC stress test');
            drawnow; 
         end

            
    catch
       break; 
    end
    fprintf('Currently at %i \n',i);
end
 query(obj1,'Move MSA Motor 0 \n \r');
 query(obj1,'Move MSB Motor 0 \n \r');
 query(obj1,'Move MTA Motor 0 \n \r');
 query(obj1,'Move MTB Motor 0 \n \r');

% query(obj2,'Move MSA Motor 0 \n \r');
% query(obj2,'Move MSB Motor 0 \n \r');
% query(obj2,'Move MTA Motor 0 \n \r');
% query(obj2,'Move MTB Motor 0 \n \r');
fclose(obj1);
% fclose(obj2);