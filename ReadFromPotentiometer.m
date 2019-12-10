%%
% Script to read the ADC value of the potentiometer on the micro-controller
%%
% Find a serial port object.
obj1 = instrfind('Type', 'serial', 'Port', 'COM5', 'Tag', '');

% Create the serial port object if it does not exist
% otherwise use the object that was found.
if isempty(obj1)
    obj1 = serial('COM5');
else
    fclose(obj1);
    obj1 = obj1(1);
end

% Connect to instrument object, obj1.
fopen(obj1);

%% Instrument Configurations and Control

% Communicating with instrument object, obj1.
data=[];
%data1 = query(obj1,'Set Prescaler 2 right\n');
pause(0.5);
%data1 = query(obj1,'Set Speed 1000 right\n');
pause(0.5);
%data1 = query(obj1,'Get Prescaler 5 right\n');
data1 = query(obj1,sprintf('Get Weight %i \n',1));
pause(0.5);
disp(data1);
pause(0.5);
for i=1:20000
    
    data2=fscanf(obj1,'1');
    if(strcmp(data,data1))
        %Do nothing
    else
        %Update command window w]ith new ADC value
%        data=data2;
        disp(data2);
        pause(0.5);
    end
end

fclose(obj1);
%clearvars;

