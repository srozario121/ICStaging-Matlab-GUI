tic
LastGSN=GetLastGSN();
NLimit=100000;
%while(1)
    NewGSN=GetLastGSN();
    
    %if(~(NewGSN==LastGSN))
    fprintf('Shot acquired for %i. Initiating sequence \n',NewGSN);
   LastGSN=NewGSN;
   
    parfor i = 1 : 2
        if(i==1)
            disp('Moving Motor Seq PM1');
            MoveMotorSeqPM1_Fn();
        end
        if(i==2)   
            disp('Moving Motor Seq PM2');
            MoveMotorSeqPM2_Fn();
        end
   end
    ShotUpdate=1;
     save('ShotUpdated.mat','ShotUpdate');
    disp('Sequence complete. Fire Next Shot');
    PM1_Last=load('PM1_LastUsedVar.mat');PM2_Last=load('PM2_LastUsedVar.mat');
    fig=figure(1);
    clf(fig);
    subplot(3,1,1)
    plot(PM1_Last.MS2_Correction);hold on;plot(PM1_Last.MS1_Correction);legend('Final MS2','InitialMS2')
    xlabel('Iteration number');ylabel('Tension [N]'); 
    title('Cell 1 initial matching');
    subplot(3,1,2)
    plot(PM2_Last.SetupMMMT_MS1);hold on;plot(PM2_Last.SetupMMMT_MS2);plot(PM2_Last.SetupMMMT_MT2);legend('Final MS1','Final MS2','Final MT2');
    xlabel('Iteration number');ylabel('Tension [N]');ylim([0 100]);
    title('Cell 2 initial matching');
    
    subplot(3,1,3)
    plot(PM2_Last.FinalMMMT_MS1);hold on;plot(PM2_Last.FinalMMMT_MS2);plot(PM2_Last.FinalMMMT_MT2);legend('Initial MS1','Initial MS2','Initial MT2');
    xlabel('Iteration number');ylabel('Tension [N]');
    title('Cell 2 final matching');
     
       
    %end
    pause(1);
%end
toc