function varargout = UserMode(varargin)
% USERMODE MATLAB code for UserMode.fig
%      USERMODE, by itself, creates a new USERMODE or raises the existing
%      singleton*.
%
%      H = USERMODE returns the handle to a new USERMODE or the handle to
%      the existing singleton*.
%
%      USERMODE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in USERMODE.M with the given input arguments.
%
%      USERMODE('Property','Value',...) creates a new USERMODE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before UserMode_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to UserMode_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help UserMode

% Last Modified by GUIDE v2.5 25-Oct-2017 21:18:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @UserMode_OpeningFcn, ...
                   'gui_OutputFcn',  @UserMode_OutputFcn, ...
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


% --- Executes just before UserMode is made visible.
function UserMode_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to UserMode (see VARARGIN)

%handle timer initialization
hfigure={handles.figure1};
    handles.timerUser=timer(...
        'ExecutionMode', 'fixedRate', ...       % Run timer repeatedly
        'Period', 0.1,...
'TimerFcn', @(obj, event) GetMCUVariables(hObject, eventdata,hfigure)); % Specify callback function

%Sequence A check 
handles.timerSeqACheck=timer(...
        'ExecutionMode', 'fixedRate', ...       % Run timer repeatedly
        'Period', 0.1,...
'TimerFcn', @(obj, event) CheckSeqA(hObject, eventdata,hfigure)); % Specify callback function
%Sequence B check 
handles.timerSeqBCheck=timer(...
        'ExecutionMode', 'fixedRate', ...       % Run timer repeatedly
        'Period', 0.1,...
'TimerFcn', @(obj, event) CheckSeqB(hObject, eventdata,hfigure)); % Specify callback function
%Sequence C check 
handles.timerSeqCCheck=timer(...
        'ExecutionMode', 'fixedRate', ...       % Run timer repeatedly
        'Period', 0.11,...
'TimerFcn', @(obj, event) CheckSeqC(hObject, eventdata,hfigure)); % Specify callback function
%Sequence A,B,C check 
handles.timerSeqDCheck=timer(...
        'ExecutionMode', 'fixedRate', ...       % Run timer repeatedly
        'Period', 1,...
'TimerFcn', @(obj, event) CheckSeqD(hObject, eventdata,hfigure)); % Specify callback function

%Lock variables
handles.LockA=[];handles.LockB=[];handles.LockC=[];handles.LockD=[];
%Outer Radii
handles.MS1RadiusOuter=[];
handles.MS2RadiusOuter=[];
handles.MT1RadiusOuter=[];
handles.MT2RadiusOuter=[];

%ADC limit bounds
handles.ADC1Lower=[];handles.ADC2Lower=[];handles.ADC3Lower=[];
handles.ADC1Upper=[];handles.ADC2Upper=[];handles.ADC3Upper=[];

%Sequence tensions
handles.SeqA_ADC=[];handles.SeqC_ADC=[];

%Tape length and spool duration
handles.LTapeMotion=[];handles.TTapeMotion=[];

% Choose default command line output for UserMode
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes UserMode wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = UserMode_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in COMPortDropDownMenu.
function COMPortDropDownMenu_Callback(hObject, eventdata, handles)
% hObject    handle to COMPortDropDownMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns COMPortDropDownMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from COMPortDropDownMenu


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


% --- Executes on button press in ConnecCOMPortBtn.
function ConnecCOMPortBtn_Callback(hObject, eventdata, handles)
% hObject    handle to ConnecCOMPortBtn (see GCBO)
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
        disp(['Connection to port:' handles.COMValue ' was succesful']);
        set(hObject,'BackgroundColor',[0 1 0]);
        
         if(strcmp(get(handles.timerUser, 'Running'), 'off'))
            start(handles.timerUser);
            guidata(hObject, handles);
         else
            warning('COM port is connected but timer is not working');
         end
    
    catch
        WarnStr=['Could not connect to port:' handles.COMValue];
       warning(WarnStr);
    end
elseif(get(hObject,'Value')==0)
    if(isempty(handles.Object))
    %Do nothing
    elseif(strcmp(get(handles.Object,'Status'),'open'))
        fclose(handles.Object);
    end
    set(hObject,'BackgroundColor',[1 0 0]);

    if(strcmp(get(handles.timerUser, 'Running'), 'on'))
        stop(handles.timerUser);
        guidata(hObject, handles);
    else
        warning('COM port is connected but timer is not working');
    end
    disp(['Connection to port:' handles.COMValue ' was gracefully closed']);
end
    guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of ConnecCOMPortBtn

% --- Executes on button press in SeqA_PushBtn.
function SeqA_PushBtn_Callback(hObject, eventdata, handles)
% hObject    handle to SeqA_PushBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CheckOBJ(handles.Object);
data=query(handles.Object,'Move SeqA 1 \n \r');


% --- Executes on button press in SeqB_PushBtn.
function SeqB_PushBtn_Callback(hObject, eventdata, handles)
% hObject    handle to SeqB_PushBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CheckOBJ(handles.Object);
data=query(handles.Object,'Move SeqB 1 \n \r');

% --- Executes on button press in SeqC_PushBtn.
function SeqC_PushBtn_Callback(hObject, eventdata, handles)
% hObject    handle to SeqC_PushBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CheckOBJ(handles.Object);
data=query(handles.Object,'Move SeqC 1 \n \r');

% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1


% --- Executes on button press in SeqD_PushBtn.
function SeqD_PushBtn_Callback(hObject, eventdata, handles)
% hObject    handle to SeqD_PushBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CheckOBJ(handles.Object);
data=query(handles.Object,'Move SeqD 1 \n \r');
LockDVal=1;pause(1);
while(LockDVal==1)
    data=query(handles.Object,'Get LockD 1 \n \r');
    LockDVal=sscanf(data,'%li');
    disp('Still moving motor')
    pause(1);
end
handles=GetMCUVariables(hObject, eventdata,hfigure);
handles=SaveVariablesToFile(handles);
guidata(hObject,handles);

function CheckOBJ(obj)
    if(strcmp(get(obj,'Status'),'open'))
        else
        fopen(obj);obj.BaudRate=153600;
    end


% --- Executes during object creation, after setting all properties.
function SeqA_PushBtn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SeqA_PushBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


function GetMCUVariables(hObject, eventdata,hfigure)
pause(0.1);% Needed to make sure the program can be closed!
handles=guidata(hfigure);
if(handles.ConnectToCOMPort==1)
    CheckOBJ(handles.Object);
    data1 = query(handles.Object,'Get TD Weight 1 \n \r');
    handles.TensionValues=sscanf(data1,'%li,%li,%li');
    
    handles.data_ADC=data1;
    handles.value_ADC=sscanf(data1,'%li,%li,%li');
    %Tension values
    set(handles.TensionAValues, 'String', sprintf('%03i',WeighingScaleADCToForce(int32(handles.Sample(1),2))));
    set(handles.TensionBValues, 'String', sprintf('%03i',WeighingScaleADCToForce(int32(handles.Sample(2)),3)));
    set(handles.TensionCValues, 'String', sprintf('%03i',WeighingScaleADCToForce(int32(handles.Sample(3)),4)));
    
    %Radius values
    data1 = query(handles.Object,'Get MSAOuter 1 \n \r');
    handles.MS1RadiusOuter=sscanf(data1,'%i');
    set(handles.MS1RadiusInput, 'String', sprintf('%03i',handles.MS1RadiusOuter));
    
    data1 = query(handles.Object,'Get MSBOuter 1 \n \r');
    handles.MS2RadiusOuter=sscanf(data1,'%i');
    set(handles.MS1RadiusInput, 'String', sprintf('%03i',handles.MS2RadiusOuter));
    
    data1 = query(handles.Object,'Get MTAOuter 1 \n \r');
    handles.MT1RadiusOuter=sscanf(data1,'%i');
    set(handles.MS1RadiusInput, 'String', sprintf('%03i',handles.MT1RadiusOuter));
    
    data1 = query(handles.Object,'Get MTBOuter 1 \n \r');
    handles.MT2RadiusOuter=sscanf(data1,'%i');
    set(handles.MS1RadiusInput, 'String', sprintf('%03i',handles.MT2RadiusOuter));
    
    %Sequence tension and upper limit
    data1 = query(handles.Object,'Get ADACUpper 1 \n \r');
    handles.ADC1Lower=sscanf(data1,'%i');
    set(handles.TensionLowerInput, 'String', sprintf('%03i',WeighingScaleADCToForce(handles.ADC1Lower,2)));
    
    data1 = query(handles.Object,'Get ADACHigher 1 \n \r');
    handles.ADC1Upper=sscanf(data1,'%i');
    set(handles.TensionUpperInput, 'String', sprintf('%03i',WeighingScaleADCToForce(handles.ADC1Upper,2)));
    
    %Sequence tension
    data1 = query(handles.Object,'Get SeqAADC 1 \n \r');
    handles.SeqA_ADC=sscanf(data1,'%i');
    set(handles.SeqATensionInput, 'String', sprintf('%03i',handles.SeqA_ADC));
    
    data1 = query(handles.Object,'Get SeqCADC 1 \n \r');
    handles.SeqC_ADC=sscanf(data1,'%i');
    set(handles.SeqCTensionInput, 'String', sprintf('%03i',handles.SeqC_ADC));

    
    %Sequence physical dimensions
    data1 = query(handles.Object,'Get LTapeMotion 1 \n \r');
    handles.LTapeMotion=sscanf(data1,'%i');
    set(handles.TapeLengthInput, 'String', sprintf('%0.2f ',handles.LTapeMotion/1e3));
    
    data1 = query(handles.Object,'Get TTapeMotion 1 \n \r');
    handles.TTapeMotion=sscanf(data1,'%i');
    set(handles.TapeDurationInput, 'String', sprintf('%0.2f',handles.TTapeMotion./1e3));
    
    %Sequence physical dimensions
    data1 = query(handles.Object,'Get CalibSteps 1 \n \r');
    handles.CalibSteps=sscanf(data1,'%i');
    set(handles.CalibStepsInput, 'String', sprintf('%0.2f ',handles.CalibSteps));
    
    data1 = query(handles.Object,'Get CalibADC 1 \n \r');
    handles.CalibADC=sscanf(data1,'%i');
    set(handles.CalibrationTensionInput, 'String', sprintf('%0.2f',handles.CalibADC./1e3));
   
    data1 = query(handles.Object,'Get SeqErrorCode 1 \n \r');
    handles.SeqErrorCode=sscanf(data1,'%i');
    set(handles.SequenceStatusInput, 'String', sprintf('%0.2f',handles.SeqErrorCode));
   
    guidata(hObject,handles);
else
    %Do nothing
end

function handles=SaveVariablesToFile(handles)
OutputMatrix=[handles.MS1RadiusOuter,handles.MS2RadiusOuter,handles.MT1RadiusOuter,handles.MT2RadiusOuter,...
    handles.MS1RadiusOuter,handles.ADC1Upper,handles.SeqA_ADC,handles.SeqC_ADC,...
    handles.LTapeMotion,handles.TTapeMotion,handles.CalibSteps,handles.CalibADC,handles.SeqErrorCode];
dlmwrite('UserModeData.csv',OutputMatrix,'-append','precision','%i');

%Sequence A timer callback check
function CheckSeqA(hObject, eventdata,hfigure)
pause(0.1);% Needed to make sure the program can be closed!
handles=guidata(hfigure);
data1 = query(handles.Object,'Get LockA 1 \n \r');
handles.LockA=sscanf(data1,'%i');
set(hObject,'BackgroundColor',[1 0 0]);
if(handles.LockA==0)
    stop(handles.timerSeqACheck)
end

%Sequence B timer callback check
function CheckSeqB(hObject, eventdata,hfigure)
pause(0.1);% Needed to make sure the program can be closed!
handles=guidata(hfigure);
data1 = query(handles.Object,'Get LockB 1 \n \r');
handles.LockB=sscanf(data1,'%i');
set(hObject,'BackgroundColor',[1 0 0]);
if(handles.LockB==0)
    stop(handles.timerSeqBCheck)
end

%Sequence B timer callback check
function CheckSeqC(hObject, eventdata,hfigure)
pause(0.1);% Needed to make sure the program can be closed!
handles=guidata(hfigure);
data1 = query(handles.Object,'Get LockC 1 \n \r');
handles.LockC=sscanf(data1,'%i');
set(hObject,'BackgroundColor',[1 0 0]);
if(handles.LockC==0)
    stop(handles.timerSeqCCheck)
end

%Sequence A,B and C timer callback check
function CheckSeqD(hObject, eventdata,hfigure)
pause(0.1);% Needed to make sure the program can be closed!
handles=guidata(hfigure);
data1 = query(handles.Object,'Get LockD 1 \n \r');
handles.LockD=sscanf(data1,'%i');
set(hObject,'BackgroundColor',[1 0 0]);
if(handles.LockD==0)
    stop(handles.timerSeqDCheck)
end
