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
data=[];
MotorName={'MSA','MSB','MTA','MTB','TD'};
%pause(0.1);
%data1=query(obj1,'Get TD Weight 1 \n \r')
data1=query(obj1,'Set MTA MConnect 1 \n \r')
data1=query(obj1,'Set MTA Steps 1000 \n \r')
data1=query(obj1,'Set MTA Speed 500 \n \r')
data1=query(obj1,'Set MTA Dir 0 \n \r')

data1=query(obj1,'Set MTB MConnect 1 \n \r')
data1=query(obj1,'Set MTB Steps 1000 \n \r')
data1=query(obj1,'Set MTB Speed 500 \n \r')
data1=query(obj1,'Set MTB Dir 0 \n \r')
data1=query(obj1,'Move MTC Motor 1 \n \r')

fclose(obj1);