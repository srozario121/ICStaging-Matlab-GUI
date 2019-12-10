function GSN=GetLastGSN()
filename='Y:\lastShotTime.txt';
formatSpec = '%*8s%8f%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to the format.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string',  'ReturnOnError', false);
GSN=dataArray{1};
%% Close the text file.
fclose(fileID);
end