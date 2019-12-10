%%
% File to see if tape has been moved
%%
addpath('ExternalFunction/tts')
FilePath='PM1_LogFile.txt';
FileData = csvread(FilePath,2,1);
OldSize=size(FileData,1);
fig1=figure;
subplot(2,2,1)
plot(FileData(:,5),'r');
xlabel('Shot number' );ylabel('MS1 correction');grid on;
subplot(2,2,2)
plot(FileData(:,6),'k')
xlabel('Shot number');ylabel('MS2 correction');grid on;
subplot(2,2,3)
plot(FileData(:,7),'b')
xlabel('Shot number');ylabel('Time elapse [s]');grid on;
while(1)
    FileData = csvread(FilePath,2,1);
    if(size(FileData,1)==OldSize)
        %Do nothing
        pause(2);
    else
        OldSize=size(FileData,1);
        tts('Spooling complete. Fire next shot');
        %Plot realtime spool info
        if(OldSize>100)
            InitialIndex=1;
        else
            InitialIndex=OldSize-100;
        end
        subplot(2,2,1)
        plot(FileData(InitialIndex:end,5),'r');
        xlabel('Shot number' );ylabel('MS1 correction');grid on;
        ylim([-50 50]);
        subplot(2,2,2)
        plot(FileData(InitialIndex:end,6),'k')
        xlabel('Shot number');ylabel('MS2 correction');grid on;
        ylim([-50 50]);
        subplot(2,2,3)
        plot(FileData(InitialIndex:end,7),'b')
        xlabel('Shot number');ylabel('Time elapse [s]');grid on;
        ylim([0 20]);
    end
end
