function obj1=SetupCOM(COMPort,BaudRate)
    obj1 = instrfind('Type', 'serial', 'Port', COMPort, 'Tag', '');

    % Create the serial port object if it does not exist
    % otherwise use the object that was found.
    if isempty(obj1)
        obj1 = serial(COMPort);
    else
        fclose(obj1);
        obj1 = obj1 (1);
    end

    % Connect to instrument object, obj1.
    fopen(obj1);
    obj1.BaudRate=BaudRate;
    obj1.Timeout=2;
    data=[];
end