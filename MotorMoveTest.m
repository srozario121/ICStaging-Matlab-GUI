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
%%
% i=4;
% tic
% data1 = query(obj1,['Set ' MotorName{i} ' MConnect 1 \n \r'])
% pause(0.1);
% data1 = query(obj1,['Set '  MotorName{i} ' Speed 100 \n \r'])%1000=100 mu periodicity
% pause(0.1);
% data1 = query(obj1,['Set '  MotorName{i} ' Dir 0 \n \r'])%4000 Steps is a revolution.
% pause(0.1);
% data1 = query(obj1,['Set '  MotorName{i} ' Steps 4000 \n \r'])%4000 Steps is a revolution.
% pause(0.1);
% data1 = query(obj1,'Get Prescaler 5 right\n');
% data1 = query(obj1,sprintf(['Move '  MotorName{i} ' Motor %i \n \r'],1));
% pause(0.1);
% disp(data1);
% toc-0.5
%i=5;
% GetList={'SeqAADC','SeqCADC','CalibADC','CalibSteps','SeqErrorCode','LTapeMotion','TTapeMotion','SequenceCount','LockA'};
% SetList={'SeqAADC','SeqCADC','CalibADC','CalibSteps','LTapeMotion','TTapeMotion','SeqErrorCode'};
% MoveList={'SeqA','SeqB','SeqC','SeqD'};
% 
% SetValList={1000,2000,1500,10,0,30000,2000};
% for i=1:length(GetList)
%     data1 = query(obj1,['Get ' GetList{i} ' 1 \n \r'])
%     pause(0.1);
% end
%sscanf(data1,'%li,%li,%li')
%pause(0.1);
data1=query(obj1,'Get TD Weight 1 \n \r')
%data1=query(obj1,'Set MSB MConnect 1 \n \r')
%data1=query(obj1,'Set MSB Steps 40000 \n \r')
%data1=query(obj1,'Set MSB Speed 500 \n \r')
%data1=query(obj1,'Set MSB Dir 0 \n \r')
%data1=query(obj1,'Move MSB Motor 1 \n \r')

fclose(obj1);