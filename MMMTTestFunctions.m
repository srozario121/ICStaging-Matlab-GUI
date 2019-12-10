% MMMTMaxLoopCounter,MMMTDirec,MMMTADC,MMMTTol,MMMTSequenceSteps,MMMTLock
obj1=SetupCOM('COM5',153600);
%Check MMMT variables for every motors
MMMTVariableList={ 'MTNo','MMMTMaxLoopCounter','MMMTDirec','MMMTADC','MMMTTol','MMMTSequenceSteps','MMMTLock'};
MotorsList={'MSA','MSB','MTA','MTB'};
for i=1:length(MMMTVariableList)
    for j=1:length(MotorsList)
        data1=query(obj1,sprintf('Get %s %s 1 \n \r',MotorsList{j},MMMTVariableList{i}))
    end
end