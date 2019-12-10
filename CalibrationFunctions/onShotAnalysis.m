%onShotAnalysis script for executing tape movement

% path to a file which contains the last shot string (and only the last
% shot string!). i.e. 20171107r001s001
lastShotFilePath = 'Z:\lastShot.txt';
% folder to store results of analysis
analPath = 'Z:\Analysis\FROGs\';
% folder to look for FROG traces after the server has grabbed them
rootDataPath = 'Z:\';

addpath('../')
%%
fid = fopen(lastShotFilePath);
lastShot = fscanf(fid,'%s');
fclose(fid);
disp(lastShot)

% determine if there has been a new shot by comparing file modified date of
% lastShot.txt
fileInfo = dir(lastShotFilePath);
dateTemp = ''%fileInfo.date;

%% start infinite loop looking for a new shot
n=0;
lCont=1;
while lCont ==1
    n=n+1; % loop counter
    % get modified date of lastShot.txt
    fileInfo = dir(lastShotFilePath);
    % compared to stored value to look for change
    if strcmp(fileInfo.date,dateTemp)
        % disp([num2str(n,'%3i') 'Nothing'])
    else
        
        % get last shot string
        fid = fopen(lastShotFilePath);
        lastShot = fscanf(fid,'%s');
        fclose(fid);
        
        % update stored value of date
        dateTemp = fileInfo.date;
        
        MoveMotorSeqPM1
        fprintf('Last shot: %s',lastShot);
        
    end
    
    % pause to limit loop speed
    pause(1)
    
end





