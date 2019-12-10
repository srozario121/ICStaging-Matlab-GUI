function varargout = SingleMotorControl(varargin)
% SINGLEMOTORCONTROL MATLAB code for SingleMotorControl.fig
%      SINGLEMOTORCONTROL, by itself, creates a new SINGLEMOTORCONTROL or raises the existing
%      singleton*.
%
%      H = SINGLEMOTORCONTROL returns the handle to a new SINGLEMOTORCONTROL or the handle to
%      the existing singleton*.
%
%      SINGLEMOTORCONTROL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SINGLEMOTORCONTROL.M with the given input arguments.
%
%      SINGLEMOTORCONTROL('Property','Value',...) creates a new SINGLEMOTORCONTROL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SingleMotorControl_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SingleMotorControl_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SingleMotorControl

% Last Modified by GUIDE v2.5 03-Nov-2017 13:48:35
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SingleMotorControl_OpeningFcn, ...
                   'gui_OutputFcn',  @SingleMotorControl_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before SingleMotorControl is made visible.
function SingleMotorControl_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SingleMotorControl (see VARARGIN)
    handles.Object=[];
    handles.ConnectToCOMPort=1;
% Initialize COM ports available      
    handles.COMString=[{'COM Ports'};getAvailableComPort()];
    set(handles.COMPortDropDownMenu,'String',handles.COMString);
%Intialize Motor variables
    handles.Motor.ModifySteps=0;handles.Motor.ModifySpeed=0;
    handles.Motor.MS1.NoSteps=0;handles.Motor.MS2.NoSteps=0;handles.Motor.MT1.NoSteps=0;handles.Motor.MT2.NoSteps=0;
    handles.Motor.MS1.Speed=1;handles.Motor.MS2.Speed=1;handles.Motor.MT1.Speed=1;handles.Motor.MT2.Speed=1;
    
    handles.Motor.MS1.NoStepsRange=[1 200000];handles.Motor.MS2.NoStepsRange=[1 200000];
    handles.Motor.MT1.NoStepsRange=[1 200000];handles.Motor.MT2.NoStepsRange=[1 200000];
    
    handles.Motor.MS1.SpeedRange=[10 15000];handles.Motor.MS2.SpeedRange=[10 15000];
    handles.Motor.MT1.SpeedRange=[10 15000];handles.Motor.MT2.SpeedRange=[10 15000];
    
    handles.Motor.MS1.Connect=0;handles.Motor.MS2.Connect=0;
    handles.Motor.MT1.Connect=0;handles.Motor.MT2.Connect=0;
%UART variables
% Just here for reference
% The following keywords are used to parse instructions to the MCU
% Move,Set and Get
% Motor Steps Dir Speed Prescaler Weight MConnect

%Initialize timers
%ADC Read timer
handles.ADC.T1.Mean=0;handles.ADC.T2.Mean=0;handles.ADC.T3.Mean=0;
handles.ADC.T1.Max=0;handles.ADC.T2.Max=0;handles.ADC.T3.Max=0;
handles.ADC.T1.Min=0;handles.ADC.T2.Min=0;handles.ADC.T3.Min=0;
handles.ADC.Sample=[];
handles.ADC.SampleSize=10;
hfigure={handles.figure1};
    handles.timer=timer(...
        'ExecutionMode', 'fixedRate', ...       % Run timer repeatedly
        'Period', 0.1,...
'TimerFcn', @(obj, event) GetADCMeasurement(hObject, eventdata,hfigure)); % Specify callback function
handles.data_ADC=[0,0,0];
% Choose default command line output for SingleMotorControl

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SingleMotorControl wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SingleMotorControl_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in ClearLogBtn.
function handles=ClearLogBtn_Callback(hObject, eventdata, handles)
% hObject    handle to ClearLogBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%If button has not already been pressed
guidata(hObject, handles);



% --- Executes on selection change in COMPortDropDownMenu.
function handles=COMPortDropDownMenu_Callback(hObject, eventdata, handles)
% hObject    handle to COMPortDropDownMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
items = get(hObject,'String');
index_selected = get(hObject,'Value');
COMValue = items{index_selected};
disp(['The following COM port was selected:' COMValue]);
handles.COMValue=COMValue;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function COMPortDropDownMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to COMPortDropDownMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton1



function MS1SpeedInput_Callback(hObject, eventdata, handles)
% hObject    handle to MS1SpeedInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Motor.MS1.Speed=str2double(get(hObject,'String'));
if(handles.Motor.MS1.Speed < handles.Motor.MS1.SpeedRange(1)||handles.Motor.MS1.Speed > handles.Motor.MS1.SpeedRange(2))
    set(hObject,'String','NaN');
else
    CheckOBJ(handles.Object);
    data1=query(handles.Object,sprintf('Set MSA Speed %i \n \r',int32(handles.Motor.MS1.Speed/10)));
    set(hObject,'String',sprintf('%i',handles.Motor.MS1.Speed));
end
guidata(hObject, handles);

% Hints: get(hObject,'String') returns contents of MS1SpeedInput as text
%        str2double(get(hObject,'String')) returns contents of MS1SpeedInput as a double


% --- Executes during object creation, after setting all properties.
function MS1SpeedInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MS1SpeedInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MS1StepsInput_Callback(hObject, eventdata, handles)
% hObject    handle to MS1StepsInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Motor.MS1.NoSteps=str2double(get(hObject,'String'));
if(handles.Motor.MS1.NoSteps < handles.Motor.MS1.NoStepsRange(1)||handles.Motor.MS1.NoSteps > handles.Motor.MS1.NoStepsRange(2))
    set(hObject,'String','NaN');
else
    CheckOBJ(handles.Object);
    data1=query(handles.Object,sprintf('Set MSA Steps %i \n \r',int32(handles.Motor.MS1.NoSteps*2)));
    set(hObject,'String',sprintf('%i',handles.Motor.MS1.NoSteps));
end
guidata(hObject, handles);

% Hints: get(hObject,'String') returns contents of MS1StepsInput as text
%        str2double(get(hObject,'String')) returns contents of MS1StepsInput as a double


% --- Executes during object creation, after setting all properties.
function MS1StepsInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MS1StepsInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.


% --- Executes on button press in ConnectComBtn.
function ConnectComBtn_Callback(hObject, eventdata, handles)
% hObject    handle to ConnectComBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if(get(hObject,'Value')==1)
    handles.ConnectToCOMPort=1;
 
   try
        obj1 = instrfind('Type', 'serial', 'Port', handles.COMValue, 'Tag', '');
        % Create the serial port object if it does not exist
        % otherwise use the object that was found.
        if isempty(obj1)
            obj1 = serial(handles.COMValue);
        else
            fclose(obj1);
            obj1 = obj1(1);
        end
        handles.Object=obj1;
        handles.Object.Timeout=2;
        handles.Object.BaudRate=153600;
        fopen(handles.Object);
        pause(0.1);
        disp(['Connection to port:' handles.COMValue ' was succesful']);
        sscanf(query(handles.Object,'Get DevInfo 1 \n \r'),'%s,%s,%s');
        DevIDString=['Currently connected to ' sscanf(query(handles.Object,'Get DevInfo 1 \n \r'),'%s,%s,%s,%s')];
        AppendToLog(DevIDString,handles);
        set(hObject,'BackgroundColor',[0 1 0]);
    catch
        WarnStr=['Could not connect to port:' handles.COMValue];
       warning(WarnStr);
       AppendToLog(WarnStr,handles); 
    end

elseif(get(hObject,'Value')==0)
    if(isempty(handles.Object))
    %Do nothing
    elseif(strcmp(get(handles.Object,'Status'),'open'))
    fclose(handles.Object);
    else
        %Do nothing
    end
    %Stop timer to update GUI
    CloseAllMotors(handles);
    if strcmp(get(handles.timer, 'Running'), 'on')
        stop(handles.timer);
        guidata(hObject, handles);
    else
        warning('COM port is connected but timer is not working');
    end
   AppendToLog(['Connection to port:' handles.COMValue ' was gracefully closed'],handles);
   set(hObject,'BackgroundColor',[1 0 0]);
    disp(['Connection to port:' handles.COMValue ' was gracefully closed']);
    %Also close all open motors
    
end
    guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of ConnectComBtn


% --- Executes on button press in MS1ConnectMotorBtn.
function MS1ConnectMotorBtn_Callback(hObject, eventdata, handles)
% hObject    handle to MS1ConnectMotorBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CheckOBJ(handles.Object);
if(get(hObject,'Value')==1 && handles.ConnectToCOMPort==1)
    data1 = query(handles.Object,'Get MSA MConnect 1 \n \r');
    if(strcmp(data1(3:end-2),'Motor MS1 connection status is: 0'))
        %Motor is not connected go ahead and connect
        data2 = query(handles.Object,'Set MSA MConnect 1 \n \r');
        AppendToLog(data2,handles);
        set(hObject,'BackgroundColor',[0 1 0]);
        %disp(data1)
        handles.Motor.MS1.Connect=1;
    elseif(strcmp(data1(3:end-2),'Motor MS1 connection status is: 1'))
        %Motor is connected but toggle button is pressed. Error. Reset
        %toggle button
        data2 = query(handles.Object,'Set MSA MConnect 0 \n \r');
        AppendToLog(data2,handles);
        %disp(data1)
        handles.Motor.MS1.Connect=0;
    else
        %Shouldnt go in here. But just in case!
        disp(data1);
        warning('Error with motor MS1 connection');
    end
elseif(get(hObject,'Value')==0 && handles.ConnectToCOMPort==1)
    data2 = query(handles.Object,'Move MSA Motor 0 \n \r');
    AppendToLog(data2,handles);
    data2 = query(handles.Object,'Set MSA MConnect 0 \n \r');
    AppendToLog(data2,handles);
    handles.Motor.MS1.Connect=0;
    set(hObject,'BackgroundColor',[1 0 0]);
elseif(handles.ConnectToCOMPort==0)
    warning('COM Port is not connected!');
    AppendToLog('COM Port is not connected!',handles);
end
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of MS1ConnectMotorBtn


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Deal with COM Port
try
    fclose(handles.Object);
    handles.Object=[];
catch
    
end
% Hint: delete(hObject) closes the figure
handles=[];
delete(hObject);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over ConnectComBtn.
function ConnectComBtn_ButtonDownFcn(hObject, eventdata, handles)

%If button has not already been pressed

% hObject    handle to ConnectComBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function CheckOBJ(obj)
try
    if(strcmp(get(obj,'Status'),'open'))
    else
        fopen(obj);
        obj.BaudRate=153600;
    end
catch
   warning('Baud rate could not be set. Check to see if the correct COM Port is selected.') 
end

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over LogTextWindow.
function AppendToLog(String,handles)
% hObject    handle to LogTextWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=guidata(handles.LogTextWindow);
if(size(data.LogTextWindow.String,1)>10)
    data.LogTextWindow.String={String};
else
    data.LogTextWindow.String=[data.LogTextWindow.String;{String}];
end
guidata(handles.LogTextWindow,handles);


function text7_Callback(hObject, eventdata, handles)
% hObject    handle to LogTextWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LogTextWindow as text
%        str2double(get(hObject,'String')) returns contents of LogTextWindow as a double


% --- Executes during object creation, after setting all properties.
function text9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in MotorMenuSelect.
function MotorMenuSelect_Callback(hObject, eventdata, handles)
% hObject    handle to MotorMenuSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CheckOBJ(handles.Object);
contents = cellstr(get(hObject,'String'));
handles.SelectedMotor=contents{get(hObject,'Value')};
if(strcmp(contents{2},handles.SelectedMotor))
    data1 = query(handles.Object,sprintf('Set MNumber %i \n \r',1));% Set direction to left
elseif(strcmp(contents{3},handles.SelectedMotor))
    data1 = query(handles.Object,sprintf('Set MNumber %i \n \r',2));% Set direction to left
elseif(strcmp(contents{4},handles.SelectedMotor))
    data1 = query(handles.Object,sprintf('Set MNumber %i \n \r',3));% Set direction to left
elseif(strcmp(contents{5},handles.SelectedMotor))
    data1 = query(handles.Object,sprintf('Set MNumber %i \n \r',4));% Set direction to left
end

guidata(hObject,handles);
% Hints: contents = cellstr(get(hObject,'String')) returns MotorMenuSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MotorMenuSelect


% --- Executes during object creation, after setting all properties.
function MotorMenuSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MotorMenuSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MT1SpeedInput_Callback(hObject, eventdata, handles)
% hObject    handle to MT1SpeedInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MT1SpeedInput as text
%        str2double(get(hObject,'String')) returns contents of MT1SpeedInput as a double
handles.Motor.MT1.Speed=str2double(get(hObject,'String'));
if(handles.Motor.MT1.Speed < handles.Motor.MT1.SpeedRange(1)||handles.Motor.MT1.Speed > handles.Motor.MT1.SpeedRange(2))
    set(hObject,'String','NaN');
else
    CheckOBJ(handles.Object);
    data1=query(handles.Object,sprintf('Set MTA Speed %i \n \r',int32(handles.Motor.MT1.Speed/10)));
    set(hObject,'String',sprintf('%i',handles.Motor.MT1.Speed));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function MT1SpeedInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MT1SpeedInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MT1StepsInput_Callback(hObject, eventdata, handles)
% hObject    handle to MT1StepsInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MT1StepsInput as text
%        str2double(get(hObject,'String')) returns contents of MT1StepsInput as a double
handles.Motor.MT1.NoSteps=str2double(get(hObject,'String'));
if(handles.Motor.MT1.NoSteps < handles.Motor.MT1.NoStepsRange(1)||handles.Motor.MT1.NoSteps > handles.Motor.MT1.NoStepsRange(2))
    set(hObject,'String','NaN');
else
    CheckOBJ(handles.Object);
    data1=query(handles.Object,sprintf('Set MTA Steps %i \n \r',int32(handles.Motor.MT1.NoSteps*2)));
    set(hObject,'String',sprintf('%i',handles.Motor.MT1.NoSteps));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function MT1StepsInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MT1StepsInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in MT1ConnectMotorBtn.
function MT1ConnectMotorBtn_Callback(hObject, eventdata, handles)
CheckOBJ(handles.Object);
if(get(hObject,'Value')==1 && handles.ConnectToCOMPort==1)
    data1 = query(handles.Object,'Get MTA MConnect 1 \n \r');
    if(strcmp(data1(3:end-2),'Motor MT1 connection status is: 0'))
        %Motor is not connected go ahead and connect
        data2 = query(handles.Object,'Set MTA MConnect 1 \n \r');
        AppendToLog(data2,handles);
        handles.Motor.MT1.Connect=1;
        set(hObject,'BackgroundColor',[0 1 0]);
    elseif(strcmp(data1(3:end-2),'Motor MT1 connection status is: 1'))
        %Motor is connected but toggle button is pressed. Error. Reset
        %toggle button
        data2 = query(handles.Object,'Set MTA MConnect 0 \n \r');
        AppendToLog(data2,handles);
        handles.Motor.MT1.Connect=0;
    else
        %Shouldnt go in here. But just in case!
        disp(data1);
        warning('Error with motor MT1 connection');
    end
elseif(get(hObject,'Value')==0 && handles.ConnectToCOMPort==1)
    data2 = query(handles.Object,'Move MTA Motor 0 \n \r');
    AppendToLog(data2,handles);
    data2 = query(handles.Object,'Set MTA MConnect 0 \n \r');
    set(hObject,'BackgroundColor',[1 0 0]);
    AppendToLog(data2,handles);
    handles.Motor.MT1.Connect=0;
elseif(handles.ConnectToCOMPort==0)
    warning('COM Port is not connected!');
    AppendToLog('COM Port is not connected!',handles);
end
guidata(hObject, handles);
% hObject    handle to MT1ConnectMotorBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of MT1ConnectMotorBtn


% --- Executes on button press in MT1MoveLeft.
function MT1MoveLeft_Callback(hObject, eventdata, handles)
% hObject    handle to MT1MoveLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(handles.Motor.MT1.Connect==0)
    AppendToLog('MT1 is not connected!',handles);
else
    if(handles.Motor.MT1.NoSteps==0)
        warning('Number of steps has not been set');
    else
        CheckOBJ(handles.Object);
        data = query(handles.Object,sprintf('Set MTA Dir %i \n \r',0));
        AppendToLog(data,handles);
        data = query(handles.Object,sprintf('Move MTA Motor %i \n \r',1));
        AppendToLog(data,handles);
    end
end
guidata(hObject, handles);

% --- Executes on button press in MT1MoveRight.
function MT1MoveRight_Callback(hObject, eventdata, handles)
% hObject    handle to MT1MoveRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(handles.Motor.MT1.Connect==0)
    AppendToLog('MT1 is not connected!',handles);
else
    if(handles.Motor.MT1.NoSteps==0)
        warning('Number of steps has not been set');
    else
        CheckOBJ(handles.Object);
        data = query(handles.Object,sprintf('Set MTA Dir %i \n \r',1));
        AppendToLog(data,handles);
        data = query(handles.Object,sprintf('Move MTA Motor %i \n \r',1));
        AppendToLog(data,handles);
    end
end
guidata(hObject, handles);


function MT2SpeedInput_Callback(hObject, eventdata, handles)
% hObject    handle to MT2SpeedInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MT2SpeedInput as text
%        str2double(get(hObject,'String')) returns contents of MT2SpeedInput as a double
handles.Motor.MT2.Speed=str2double(get(hObject,'String'));
if(handles.Motor.MT2.Speed < handles.Motor.MT2.SpeedRange(1)||handles.Motor.MT2.Speed > handles.Motor.MT2.SpeedRange(2))
    set(hObject,'String','NaN');
else
    CheckOBJ(handles.Object);
    data1=query(handles.Object,sprintf('Set MTB Speed %i \n \r',int32(handles.Motor.MT2.Speed/10)));
    set(hObject,'String',sprintf('%i',handles.Motor.MT2.Speed));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function MT2SpeedInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MT2SpeedInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MT2StepsInput_Callback(hObject, eventdata, handles)
% hObject    handle to MT2StepsInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MT2StepsInput as text
%        str2double(get(hObject,'String')) returns contents of MT2StepsInput as a double
handles.Motor.MT2.NoSteps=str2double(get(hObject,'String'));
if(handles.Motor.MT2.NoSteps < handles.Motor.MT2.NoStepsRange(1)||handles.Motor.MT2.NoSteps > handles.Motor.MT2.NoStepsRange(2))
    set(hObject,'String','NaN');
else
    CheckOBJ(handles.Object);
    data1=query(handles.Object,sprintf('Set MTB Steps %i \n \r',int32(handles.Motor.MT2.NoSteps*2)));
    set(hObject,'String',sprintf('%i',handles.Motor.MT2.NoSteps));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function MT2StepsInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MT2StepsInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in MT2ConnectMotorBtn.
function MT2ConnectMotorBtn_Callback(hObject, eventdata, handles)
CheckOBJ(handles.Object);
if(get(hObject,'Value')==1 && handles.ConnectToCOMPort==1)
    data1 = query(handles.Object,'Get MTB MConnect 1 \n \r');
    if(strcmp(data1(3:end-2),'Motor MT2 connection status is: 0'))
        %Motor is not connected go ahead and connect
        data2 = query(handles.Object,'Set MTB MConnect 1 \n \r');
        AppendToLog(data2,handles);
        set(hObject,'BackgroundColor',[0 1 0]);
        %disp(data1)
        handles.Motor.MT2.Connect=1;
    elseif(strcmp(data1(3:end-2),'Motor MT2 connection status is: 1'))
        %Motor is connected but toggle button is pressed. Error. Reset
        %toggle button
        data2 = query(handles.Object,'Set MTB MConnect 0 \n \r');
        AppendToLog(data2,handles);
        handles.Motor.MT2.Connect=0;
    else
        %Shouldnt go in here. But just in case!
        disp(data1);
        warning('Error with motor MT2 connection');
    end
elseif(get(hObject,'Value')==0 && handles.ConnectToCOMPort==1)
    data2 = query(handles.Object,'Move MTB Motor 0 \n \r');
    AppendToLog(data2,handles);
    data2 = query(handles.Object,'Set MTB MConnect 0 \n \r');
    AppendToLog(data2,handles);
    set(hObject,'BackgroundColor',[1 0 0]);
    handles.Motor.MT2.Connect=0;
elseif(handles.ConnectToCOMPort==0)
    warning('COM Port is not connected!');
    AppendToLog('COM Port is not connected!',handles);
end
guidata(hObject, handles);
% hObject    handle to MT2ConnectMotorBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of MT2ConnectMotorBtn


% --- Executes on button press in MT2MoveLeft.
function MT2MoveLeft_Callback(hObject, eventdata, handles)
% hObject    handle to MT2MoveLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(handles.Motor.MT2.Connect==0)
    AppendToLog('MT2 is not connected!',handles);
else
    if(handles.Motor.MT2.NoSteps==0)
        warning('Number of steps has not been set');
        AppendToLog('Number of steps has not been set for MT2',handles);
    else
        CheckOBJ(handles.Object);
        data = query(handles.Object,sprintf('Set MTB Dir %i \n \r',0));
        AppendToLog(data,handles);
        data = query(handles.Object,sprintf('Move MTB Motor %i \n \r',1));
        AppendToLog(data,handles);
    end
end
guidata(hObject, handles);


% --- Executes on button press in MT2MoveRight.
function MT2MoveRight_Callback(hObject, eventdata, handles)
% hObject    handle to MT2MoveRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(handles.Motor.MT2.Connect==0)
    AppendToLog('MT2 is not connected!',handles);
else
    if(handles.Motor.MT2.NoSteps==0)
        warning('Number of steps has not been set');
        AppendToLog('Number of steps has not been set for MT2',handles);
    else
        CheckOBJ(handles.Object);   
        data = query(handles.Object,sprintf('Set MTB Dir %i \n \r',1));
        AppendToLog(data,handles);
        data = query(handles.Object,sprintf('Move MTB Motor %i \n \r',1));
        AppendToLog(data,handles);
    end
end
guidata(hObject, handles);


function MS2SpeedInput_Callback(hObject, eventdata, handles)
% hObject    handle to MS2SpeedInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MS2SpeedInput as text
%        str2double(get(hObject,'String')) returns contents of MS2SpeedInput as a double
handles.Motor.MS2.Speed=str2double(get(hObject,'String'));
if(handles.Motor.MS2.Speed < handles.Motor.MS2.SpeedRange(1)||handles.Motor.MS2.Speed > handles.Motor.MS2.SpeedRange(2))
    set(hObject,'String','NaN');
else
    CheckOBJ(handles.Object);
    data1=query(handles.Object,sprintf('Set MSB Speed %i \n \r',int32(handles.Motor.MS2.Speed/10)));
    set(hObject,'String',sprintf('%i',handles.Motor.MS2.Speed));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function MS2SpeedInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MS2SpeedInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MS2StepsInput_Callback(hObject, eventdata, handles)
% hObject    handle to MS2StepsInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MS2StepsInput as text
%        str2double(get(hObject,'String')) returns contents of MS2StepsInput as a double
handles.Motor.MS2.NoSteps=str2double(get(hObject,'String'));
if(handles.Motor.MS2.NoSteps < handles.Motor.MS2.NoStepsRange(1)||handles.Motor.MS2.NoSteps > handles.Motor.MS2.NoStepsRange(2))
    set(hObject,'String','NaN');
else
    CheckOBJ(handles.Object);
    data1=query(handles.Object,sprintf('Set MSB Steps %i \n \r',int32(handles.Motor.MS2.NoSteps*2)));
    set(hObject,'String',sprintf('%i',handles.Motor.MS2.NoSteps));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function MS2StepsInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MS2StepsInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in MS2ConnectMotorBtn.
function MS2ConnectMotorBtn_Callback(hObject, eventdata, handles)
CheckOBJ(handles.Object);
if(get(hObject,'Value')==1 && handles.ConnectToCOMPort==1)
    data1 = query(handles.Object,'Get MSB MConnect 1 \n \r');
    if(strcmp(data1(3:end-2),'Motor MS2 connection status is: 0'))
        %Motor is not connected go ahead and connect
        data2 = query(handles.Object,'Set MSB MConnect 1 \n \r');
        AppendToLog(data2,handles);
        set(hObject,'BackgroundColor',[0 1 0]);
        %disp(data1)
        handles.Motor.MS2.Connect=1;
    elseif(strcmp(data1(3:end-2),'Motor MS2 connection status is: 1'))
        %Motor is connected but toggle button is pressed. Error. Reset
        %toggle button
        data2 = query(handles.Object,'Set MSB MConnect 0 \n \r');
        AppendToLog(data2,handles);
        %disp(data1)
        handles.Motor.MS2.Connect=0;
    else
        %Shouldnt go in here. But just in case!
        disp(data1);
        warning('Error with motor MS2 connection');
    end
elseif(get(hObject,'Value')==0 && handles.ConnectToCOMPort==1)
    data2 = query(handles.Object,'Move MSB Motor 0 \n \r');
    AppendToLog(data2,handles);
    data2 = query(handles.Object,'Set MSB MConnect 0 \n \r');
    AppendToLog(data2,handles);
    set(hObject,'BackgroundColor',[1 0 0]);
    handles.Motor.MS2.Connect=0;
elseif(handles.ConnectToCOMPort==0)
    warning('COM Port is not connected!');
    AppendToLog('COM Port is not connected!',handles);
end
guidata(hObject, handles);
% hObject    handle to MS2ConnectMotorBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of MS2ConnectMotorBtn


% --- Executes on button press in MS2MoveLeft.
function MS2MoveLeft_Callback(hObject, eventdata, handles)
% hObject    handle to MS2MoveLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(handles.Motor.MS2.Connect==0)
    AppendToLog('MS2 is not connected!',handles);
else
    if(handles.Motor.MS2.NoSteps==0)
        warning('Number of steps has not been set');
        AppendToLog('Number of steps has not been set for MS2',handles);
    else
        CheckOBJ(handles.Object);
        data = query(handles.Object,sprintf('Set MSB Dir %i \n \r',0));
        AppendToLog(data,handles);
        data = query(handles.Object,sprintf('Move MSB Motor %i \n \r',1));
        AppendToLog(data,handles);
    end
end
guidata(hObject, handles);

% --- Executes on button press in MS2MoveRight.
function MS2MoveRight_Callback(hObject, eventdata, handles)
% hObject    handle to MS2MoveRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(handles.Motor.MS2.Connect==0)
    AppendToLog('MS2 is not connected!',handles);
else
    if(handles.Motor.MS2.NoSteps==0)
        warning('Number of steps has not been set');
        AppendToLog('Number of steps has not been set for MS2',handles);
    else
        CheckOBJ(handles.Object);
        data = query(handles.Object,sprintf('Set MSB Dir %i \n \r',1));
        AppendToLog(data,handles);
        data = query(handles.Object,sprintf('Move MSB Motor %i \n \r',1));
        AppendToLog(data,handles);
    end
end
guidata(hObject, handles);

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over LogTextWindow.
function LogTextWindow_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to LogTextWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in MS1MoveLeft.
function MS1MoveLeft_Callback(hObject, eventdata, handles)
% hObject    handle to MS1MoveLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(handles.Motor.MS1.Connect==0)
    AppendToLog('MS1 is not connected!',handles);
else
    if(handles.Motor.MS1.NoSteps==0)
        warning('Number of steps has not been set');
    else
    CheckOBJ(handles.Object);
    data = query(handles.Object,sprintf('Set MSA Dir %i \n \r',0));
    AppendToLog(data,handles);
    data = query(handles.Object,sprintf('Move MSA Motor %i \n \r',1));
    AppendToLog(data,handles);
    end
end
guidata(hObject, handles);
% --- Executes on button press in MS1MoveRight.
function MS1MoveRight_Callback(hObject, eventdata, handles)
% hObject    handle to MS1MoveRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(handles.Motor.MS1.Connect==0)
    AppendToLog('MS1 is not connected!',handles);
else
    if(handles.Motor.MS1.NoSteps==0)
        warning('Number of steps has not been set');
    else
    CheckOBJ(handles.Object);
    data = query(handles.Object,sprintf('Set MSA Dir %i \n \r',1));
    AppendToLog(data,handles);
    data = query(handles.Object,sprintf('Move MSA Motor %i \n \r',1));
    AppendToLog(data,handles);
    end
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function MS1ConnectMotorBtn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MS1ConnectMotorBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'BackgroundColor',[1 0 0]);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function MT1ConnectMotorBtn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MT1ConnectMotorBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'BackgroundColor',[1 0 0]);
guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function MS2ConnectMotorBtn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MS2ConnectMotorBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'BackgroundColor',[1 0 0]);
guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function MT2ConnectMotorBtn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MT2ConnectMotorBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'BackgroundColor',[1 0 0]);
guidata(hObject, handles)

%data=guidata(handles.LogTextWindow);
function CloseAllMotors(handles)
if(handles.ConnectToCOMPort==1)
    CheckOBJ(handles.Object);
    pause(0.1);
    %Check all motors to see if they are still active.
    %MS1
    data1 = query(handles.Object,'Get MSA MConnect 1 \n \r');
    if(strcmp(data1(3:end-2),'Motor MS1 connection status is: 1'))
        data2 = query(handles.Object,'Move MSA Motor 0 \n \r');
        data2 = query(handles.Object,'Set MSA MConnect 0 \n \r');
        handles.Motor.MS1.Connect=0;
        handles.MS1ConnectMotorBtn.BackgroundColor=[1 0 0];
        handles.MS1ConnectMotorBtn.Value=0;
        set(handles.MS1StepsInput,'String',0);
    end
    guidata(handles.MS1ConnectMotorBtn,handles);
    data1 = query(handles.Object,'Get MSB MConnect 1 \n \r');
    if(strcmp(data1(3:end-2),'Motor MS2 connection status is: 1'))
        data2 = query(handles.Object,'Move MSB Motor 0 \n \r');
        data2 = query(handles.Object,'Set MSB MConnect 0 \n \r');
        handles.Motor.MS2.Connect=0;
        handles.MS2ConnectMotorBtn.BackgroundColor=[1 0 0];
        handles.MS2ConnectMotorBtn.Value=0;
        set(handles.MS2StepsInput,'String',0);
    end
    guidata(handles.MS2ConnectMotorBtn,handles);
    data1 = query(handles.Object,'Get MTA MConnect 1 \n \r');
    if(strcmp(data1(3:end-2),'Motor MT1 connection status is: 1'))
        data2 = query(handles.Object,'Move MTA Motor 0 \n \r');
        data2 = query(handles.Object,'Set MTA MConnect 0 \n \r');
        handles.Motor.MT1.Connect=0;
        handles.MT1ConnectMotorBtn.BackgroundColor=[1 0 0];
        handles.MT1ConnectMotorBtn.Value=0;
        set(handles.MT1StepsInput,'String',0);
    end
    guidata(handles.MT1ConnectMotorBtn,handles);
    data1 = query(handles.Object,'Get MTB MConnect 1 \n \r');
    if(strcmp(data1(3:end-2),'Motor MT2 connection status is: 1'))
        data2 = query(handles.Object,'Move MTB Motor 0 \n \r');
        data2 = query(handles.Object,'Set MTB MConnect 0 \n \r');
        handles.Motor.MT2.Connect=0;
        handles.MT2ConnectMotorBtn.BackgroundColor=[1 0 0];
        handles.MT2ConnectMotorBtn.Value=0;
        set(handles.MT2StepsInput,'String',0);
    end
    guidata(handles.MT2ConnectMotorBtn,handles);
    guidata(handles.ConnectComBtn,handles);
end


function GetADCMeasurement(hObject, eventdata,hfigure)
pause(0.1);% Needed to make sure the program can be closed!
handles=guidata(hfigure{1});
if(handles.ConnectToCOMPort==1)
    CheckOBJ(handles.Object);
    %tic
    handles.Sample=zeros(handles.ADC.SampleSize,3);
    for i=1:handles.ADC.SampleSize
        data1 = query(handles.Object,'Get TD Weight 1 \n \r');
        %data1 = '0,0,0';
        try
            handles.Sample(i,:)=sscanf(data1,'%li,%li,%li');
        catch
            handles.Sample(i,:)=[nan,nan,nan]
        end
    end
    %toc
    handles.data_ADC=data1;
    handles.value_ADC=sscanf(data1,'%li,%li,%li');
    set(handles.TensionArm1MeanInput, 'String', sprintf('%03i',int32(mean(handles.Sample(:,1)))));
    set(handles.TensionArm2MeanInput, 'String', sprintf('%03i',int32(mean(handles.Sample(:,2)))));
    set(handles.TensionArm3MeanInput, 'String', sprintf('%03i',int32(mean(handles.Sample(:,3)))));
    
    set(handles.TensionArm1MaxInput, 'String', sprintf('%03i',int32(max(handles.Sample(:,1)))));
    set(handles.TensionArm2MaxInput, 'String', sprintf('%03i',int32(max(handles.Sample(:,2)))));
    set(handles.TensionArm3MaxInput, 'String', sprintf('%03i',int32(max(handles.Sample(:,3)))));
    
    set(handles.TensionArm1MinInput, 'String', sprintf('%03i',int32(min(handles.Sample(:,1)))));
    set(handles.TensionArm2MinInput, 'String', sprintf('%03i',int32(min(handles.Sample(:,2)))));
    set(handles.TensionArm3MinInput, 'String', sprintf('%03i',int32(min(handles.Sample(:,3)))));
    guidata(hObject,handles);
else
    %Do nothing
end


% --- Executes on button press in ADCTimerSettings.
function ADCTimerSettings_Callback(hObject, eventdata, handles)
% hObject    handle to ADCTimerSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(get(hObject,'Value')==1)
    if(strcmp(get(handles.timer, 'Running'), 'off'))
        start(handles.timer);
        guidata(hObject, handles);
    else
        warning('COM port is connected but timer is not working');
    end
else
    if strcmp(get(handles.timer, 'Running'), 'on')
        stop(handles.timer);
        guidata(hObject, handles);
    else
        warning('COM port is connected but timer is not working');
    end
end
% Hint: get(hObject,'Value') returns toggle state of ADCTimerSettings

function SetADCPeriod_Callback(hObject, eventdata, handles)
% hObject    handle to SetADCPeriod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SetADCPeriod as text
%        str2double(get(hObject,'String')) returns contents of SetADCPeriod as a double
    if strcmp(get(handles.timer, 'Running'), 'on')
        stop(handles.timer);
        handles.timer.Period=str2double(get(hObject,'String'));  
        guidata(hObject, handles);
    else
        handles.timer.Period=str2double(get(hObject,'String'));  
        guidata(hObject, handles);
    end


% --- Executes during object creation, after setting all properties.
function SetADCPeriod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SetADCPeriod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SetADCSampleSize_Callback(hObject, eventdata, handles)
% hObject    handle to SetADCSampleSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.ADC.SampleSize=str2double(get(hObject,'String'));
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of SetADCSampleSize as text
%        str2double(get(hObject,'String')) returns contents of SetADCSampleSize as a double


% --- Executes during object creation, after setting all properties.
function SetADCSampleSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SetADCSampleSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in UserModeCallBack.
function UserModeCallBack_Callback(hObject, eventdata, handles)
% hObject    handle to UserModeCallBack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gui2fig=open('UserMode.fig');

% --- Executes on button press in ADCViewerCallBack.
function ADCViewerCallBack_Callback(hObject, eventdata, handles)
% hObject    handle to ADCViewerCallBack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gui2fig=open('PotentiometerADCGUI.fig');



function MT1_2SpeedInput_Callback(hObject, eventdata, handles)
% hObject    handle to MT1_2SpeedInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Motor.MT1.Speed=str2double(get(hObject,'String'));
if(handles.Motor.MT1.Speed < handles.Motor.MT1.SpeedRange(1)||handles.Motor.MT1.Speed > handles.Motor.MT1.SpeedRange(2))
    set(hObject,'String','NaN');
else
    CheckOBJ(handles.Object);
    data1=query(handles.Object,sprintf('Set MTA Speed %i \n \r',int32(handles.Motor.MT1.Speed/10)));
    set(hObject,'String',sprintf('%i',handles.Motor.MT1.Speed));
end
guidata(hObject, handles);

handles.Motor.MT2.Speed=str2double(get(hObject,'String'));
if(handles.Motor.MT2.Speed < handles.Motor.MT2.SpeedRange(1)||handles.Motor.MT2.Speed > handles.Motor.MT2.SpeedRange(2))
    set(hObject,'String','NaN');
else
    CheckOBJ(handles.Object);
    data1=query(handles.Object,sprintf('Set MTB Speed %i \n \r',int32(handles.Motor.MT2.Speed/10)));
    set(hObject,'String',sprintf('%i',handles.Motor.MT2.Speed));
end
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of MT1_2SpeedInput as text
%        str2double(get(hObject,'String')) returns contents of MT1_2SpeedInput as a double


% --- Executes during object creation, after setting all properties.
function MT1_2SpeedInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MT1_2SpeedInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MT1_2StepsInput_Callback(hObject, eventdata, handles)
% hObject    handle to MT1_2StepsInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Motor.MT1.NoSteps=str2double(get(hObject,'String'));
if(handles.Motor.MT1.NoSteps < handles.Motor.MT1.NoStepsRange(1)||handles.Motor.MT1.NoSteps > handles.Motor.MT1.NoStepsRange(2))
    set(hObject,'String','NaN');
else
    CheckOBJ(handles.Object);
    data1=query(handles.Object,sprintf('Set MTA Steps %i \n \r',int32(handles.Motor.MT1.NoSteps*2)));
    set(hObject,'String',sprintf('%i',handles.Motor.MT1.NoSteps));
end
guidata(hObject, handles);

handles.Motor.MT2.NoSteps=str2double(get(hObject,'String'));
if(handles.Motor.MT2.NoSteps < handles.Motor.MT2.NoStepsRange(1)||handles.Motor.MT2.NoSteps > handles.Motor.MT2.NoStepsRange(2))
    set(hObject,'String','NaN');
else
    CheckOBJ(handles.Object);
    data1=query(handles.Object,sprintf('Set MTB Steps %i \n \r',int32(handles.Motor.MT2.NoSteps*2)));
    set(hObject,'String',sprintf('%i',handles.Motor.MT2.NoSteps));
end
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of MT1_2StepsInput as text
%        str2double(get(hObject,'String')) returns contents of MT1_2StepsInput as a double


% --- Executes during object creation, after setting all properties.
function MT1_2StepsInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MT1_2StepsInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in MT1_2ConnectMotorBtn.
function MT1_2ConnectMotorBtn_Callback(hObject, eventdata, handles)
% hObject    handle to MT1_2ConnectMotorBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CheckOBJ(handles.Object);
if(get(hObject,'Value')==1 && handles.ConnectToCOMPort==1)
    data1 = query(handles.Object,'Get MTA MConnect 1 \n \r');
    data2 = query(handles.Object,'Get MTB MConnect 1 \n \r');
    if(strcmp(data1(3:end-2),'Motor MT1 connection status is: 0') || strcmp(data2(3:end-2),'Motor MT2 connection status is: 0'))
        %Motor is not connected go ahead and connect
        data3 = query(handles.Object,'Set MTA MConnect 1 \n \r');
        AppendToLog(data3,handles);
        handles.Motor.MT1.Connect=1;
        data4 = query(handles.Object,'Set MTB MConnect 1 \n \r');
        AppendToLog(data4,handles);
        handles.Motor.MT2.Connect=1;
        set(hObject,'BackgroundColor',[0 1 0]);
    elseif(strcmp(data1(3:end-2),'Motor MT1 connection status is: 1')||strcmp(data1(3:end-2),'Motor MT2 connection status is: 1'))
        %Motor is connected but toggle button is pressed. Error. Reset
        %toggle button
        data3 = query(handles.Object,'Set MTA MConnect 0 \n \r');
        AppendToLog(data3,handles);
        handles.Motor.MT1.Connect=0;
        
        data4 = query(handles.Object,'Set MTB MConnect 0 \n \r');
        AppendToLog(data4,handles);
        handles.Motor.MT2.Connect=0;
    else
        %Shouldnt go in here. But just in case!
        disp(data1);
        warning('Error with motor MT1 or MT2 connection');
    end
elseif(get(hObject,'Value')==0 && handles.ConnectToCOMPort==1)
    data2 = query(handles.Object,'Move MTA Motor 0 \n \r');
    AppendToLog(data2,handles);
    data2 = query(handles.Object,'Set MTA MConnect 0 \n \r');
    AppendToLog(data2,handles);
    handles.Motor.MT1.Connect=0;
    
    set(hObject,'BackgroundColor',[1 0 0]);
    
    data3 = query(handles.Object,'Move MTB Motor 0 \n \r');
    AppendToLog(data3,handles);
    data4 = query(handles.Object,'Set MTB MConnect 0 \n \r');
    AppendToLog(data4,handles);
    handles.Motor.MT2.Connect=0;
    
elseif(handles.ConnectToCOMPort==0)
    warning('COM Port is not connected!');
    AppendToLog('COM Port is not connected!',handles);
end
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of MT1_2ConnectMotorBtn


% --- Executes on button press in MT1_2MoveLeft.
function MT1_2MoveLeft_Callback(hObject, eventdata, handles)
% hObject    handle to MT1_2MoveLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(handles.Motor.MT1.Connect==0)
    AppendToLog('MT1 is not connected!',handles);
else
    if(handles.Motor.MT1.NoSteps==0)
        warning('Number of steps has not been set');
    else
        CheckOBJ(handles.Object);
        data = query(handles.Object,sprintf('Set MTA Dir %i \n \r',0));
        AppendToLog(data,handles);
        data = query(handles.Object,sprintf('Move MTA Motor %i \n \r',1));
        AppendToLog(data,handles);
    end
end
guidata(hObject, handles);
if(handles.Motor.MT2.Connect==0)
    AppendToLog('MT2 is not connected!',handles);
else
    if(handles.Motor.MT2.NoSteps==0)
        warning('Number of steps has not been set');
    else
        CheckOBJ(handles.Object);
        data = query(handles.Object,sprintf('Set MTB Dir %i \n \r',0));
        AppendToLog(data,handles);
        data = query(handles.Object,sprintf('Move MTB Motor %i \n \r',1));
        AppendToLog(data,handles);
    end
end
guidata(hObject, handles);

% --- Executes on button press in MT1_2MoveRight.
function MT1_2MoveRight_Callback(hObject, eventdata, handles)
% hObject    handle to MT1_2MoveRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(handles.Motor.MT1.Connect==0)
    AppendToLog('MT1 is not connected!',handles);
else
    if(handles.Motor.MT1.NoSteps==0)
        warning('Number of steps has not been set');
    else
        CheckOBJ(handles.Object);
        data = query(handles.Object,sprintf('Set MTA Dir %i \n \r',1));
        AppendToLog(data,handles);
        data = query(handles.Object,sprintf('Move MTA Motor %i \n \r',1));
        AppendToLog(data,handles);
    end
end
guidata(hObject, handles);
if(handles.Motor.MT2.Connect==0)
    AppendToLog('MT2 is not connected!',handles);
else
    if(handles.Motor.MT2.NoSteps==0)
        warning('Number of steps has not been set');
    else
        CheckOBJ(handles.Object);
        data = query(handles.Object,sprintf('Set MTB Dir %i \n \r',1));
        AppendToLog(data,handles);
        data = query(handles.Object,sprintf('Move MTB Motor %i \n \r',1));
        AppendToLog(data,handles);
    end
end
guidata(hObject, handles);
