function varargout = TwoStagePMShotGUI(varargin)
% TWOSTAGEPMSHOTGUI MATLAB code for TwoStagePMShotGUI.fig
%      TWOSTAGEPMSHOTGUI, by itself, creates a new TWOSTAGEPMSHOTGUI or raises the existing
%      singleton*.
%
%      H = TWOSTAGEPMSHOTGUI returns the handle to a new TWOSTAGEPMSHOTGUI or the handle to
%      the existing singleton*.
%
%      TWOSTAGEPMSHOTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TWOSTAGEPMSHOTGUI.M with the given input arguments.
%
%      TWOSTAGEPMSHOTGUI('Property','Value',...) creates a new TWOSTAGEPMSHOTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TwoStagePMShotGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TwoStagePMShotGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TwoStagePMShotGUI

% Last Modified by GUIDE v2.5 26-Nov-2017 18:43:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TwoStagePMShotGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @TwoStagePMShotGUI_OutputFcn, ...
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


% --- Executes just before TwoStagePMShotGUI is made visible.
function TwoStagePMShotGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TwoStagePMShotGUI (see VARARGIN)
%PM1 variables
PM1COMPort='COM7';

handles.PM1.SpoolLength=5;

handles.PM1.ADC=zeros(1,3);
handles.PM1.T1=0;handles.PM1.T2=0;handles.PM1.T3=0;

handles.PM1.MS1CorrStep=0;
handles.PM1.MS2CorrStep=0;
handles.PM1.TimeElapsed=0;
handles.PM1.SequenceCounter=0;

handles.PM1.MoveBtnLock=0;
%PM1 variables
PM2COMPort='COM5';

handles.PM2.SpoolLength=5;
handles.PM2.ADC=zeros(3,1);
handles.PM2.T1=0;handles.PM2.T2=0;handles.PM2.T3=0;

handles.PM2.MS1CorrStep=0;
handles.PM2.MS2CorrStep=0;
handles.PM2.TimeElapsed=0;
handles.PM2.SequenceCounter=0;
handles.PM2.MoveBtnLock=0;

%Common variables
handles.BAUDRate=153600;
handles.OutputFilePath='TwoStage_LogFile.txt';
handles.Date=datestr(now);
handles.LastGSN=GetLastGSN();
handles.NewShot=0;

%Get Last shot info
%[Date,PM1SeqLength,PM1MS1Corr,PM1MS2Corr,PM1TimeElapsed,PM1NoSequence,PM2SeqLength,PM2MS1Corr,PM2MS2Corr,PM2TimeElapsed,PM2NoSequence,GSN]=GetLastShotInfo()

[handles.Date,handles.PM1.SpoolLength,handles.PM1.MS1CorrStep,handles.PM1.MS2CorrStep,...
handles.PM1.TimeElapsed,handles.PM1.SequenceCounter,...
handles.PM2.SpoolLength,handles.PM2.MS1CorrStep,handles.PM2.MS2CorrStep,...
handles.PM2.TimeElapsed,handles.PM2.SequenceCounter,handles.LastGSN]=GetLastShotInfo();

%Update fields
handles.SequenceInfo.Data{1,1}=handles.PM1.MS1CorrStep;
handles.SequenceInfo.Data{2,1}=handles.PM1.MS2CorrStep;
handles.SequenceInfo.Data{3,1}=handles.PM1.TimeElapsed;
handles.SequenceInfo.Data{4,1}=handles.PM1.SequenceCounter;
handles.SequenceInfo.Data{1,2}=handles.PM2.MS1CorrStep;
handles.SequenceInfo.Data{2,2}=handles.PM2.MS2CorrStep;
handles.SequenceInfo.Data{3,2}=handles.PM2.TimeElapsed;
handles.SequenceInfo.Data{4,2}=handles.PM2.SequenceCounter;

guidata(hObject, handles);

%Timers
hfigure={handles.figure1};
    handles.timer=timer(...
        'ExecutionMode', 'fixedRate', ...       % Run timer repeatedly
        'Period', 2,...
'TimerFcn', @(obj, event) TensionCheck(hObject, eventdata,hfigure)); % Specify callback function
start(handles.timer);

 handles.timerAutomatePM1=timer(...
        'ExecutionMode', 'fixedRate', ...       % Run timer repeatedly
        'Period',10,...
'TimerFcn', @(obj, event) PMShotCheck(hObject, eventdata,hfigure)); % Specify callback function
start(handles.timerAutomatePM1);

%  handles.timerAutomatePM2=timer(...
%         'ExecutionMode', 'fixedRate', ...       % Run timer repeatedly
%         'Period', 10,...
% 'TimerFcn', @(obj, event) PM2ShotCheck(hObject, eventdata,hfigure)); % Specify callback function
%Initialize COM ports
%handles.obj1=SetupCOM('COM7',handles.BAUDRate);
%handles.obj2=SetupCOM('COM5',handles.BAUDRate);

%Check that ports are working
%PM1
% data=query(obj1,'Get DevInfo 1 \n \r');
% try
%     PMName=sscanf(query(handles.obj1,'Get DevInfo 1 \n \r'),'%s,%s,%s,%s');
%     if(strcmp(PMName,'PM1'))
%    %All is good 
%     else
%         error('Incorrect COM port!');
%     end
% catch
%     error('Warning COM port is not working!');
% end
% %PM2
% data=query(obj2,'Get DevInfo 1 \n \r');
% try
%     PMName=sscanf(query(handles.obj1,'Get DevInfo 1 \n \r'),'%s,%s,%s,%s');
%     if(strcmp(PMName,'PM2'))
%    %All is good 
%     else
%         error('Incorrect COM port!');
%     end
% catch
%     error('Warning COM port is not working!');
% end
%PM sequence functions take the following form
%[MS1Corr, MS2Corr, Time]=MoveMotorSeqPM1(2)(obj,Steps)
%
%
% Choose default command line output for TwoStagePMShotGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TwoStagePMShotGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = TwoStagePMShotGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in PM2SingleMoveBtn.
function PM2SingleMoveBtn_Callback(hObject, eventdata, handles)
% hObject    handle to PM2SingleMoveBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(handles.PM2.MoveBtnLock==1)
    %Wait
    disp('Btn is still pressed!');
else
    handles.PM2.MoveBtnLock=1;
    hObject.BackgroundColor=[0 1 0];
    %[handles.PM2.MS1CorrStep,handles.PM2.MS2CorrStep...
        %handles.PM2.TimeElapsed]=...
        %MoveMotorSeqPM2(handles.obj1,handles.PM2.SpoolLength);
    handles.PM2.SequenceCounter=handles.PM2.SequenceCounter+1;
    handles.SequenceInfo.Data{1,2}=handles.PM2.MS1CorrStep;
    handles.SequenceInfo.Data{2,2}=handles.PM2.MS2CorrStep;
    handles.SequenceInfo.Data{3,2}=handles.PM2.TimeElapsed;
    handles.SequenceInfo.Data{4,2}=handles.PM2.SequenceCounter;
    
    pause(3);%For debugging
    hObject.BackgroundColor=[1 0 0];
        handles.PM2.MoveBtnLock=0;
end
guidata(hObject, handles);


function PM2SpoolLengthEdit_Callback(hObject, eventdata, handles)
% hObject    handle to PM2SpoolLengthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=str2double(get(hObject,'String'));
if(~(Value>1 || Value<20))
    Value=5;
end
handles.PM2.SpoolLength=Value;
% Hints: get(hObject,'String') returns contents of PM2SpoolLengthEdit as text
%        str2double(get(hObject,'String')) returns contents of PM2SpoolLengthEdit as a double


% --- Executes during object creation, after setting all properties.
function PM2SpoolLengthEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PM2SpoolLengthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PM2AutomateRadioBtn.
function PM2AutomateRadioBtn_Callback(hObject, eventdata, handles)
% hObject    handle to PM2AutomateRadioBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
BtnState=get(hObject,'Value');
if(BtnState==1)
    %turn on PM1 timer
    AppendToLog('Start automated shot sequence','PM2',handles);
else
    AppendToLog('Stop automated shot sequence','PM2',handles);
end
guidata(hObject, handles);

% Hint: get(hObject,'Value') returns toggle state of PM2AutomateRadioBtn


% --- Executes on button press in PM1SingleMoveBtn.
function PM1SingleMoveBtn_Callback(hObject, eventdata, handles)
% hObject    handle to PM1SingleMoveBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(handles.PM1.MoveBtnLock==1)
    %Wait
    disp('Btn is still pressed!');
else
    handles.PM1.MoveBtnLock=1;
    hObject.BackgroundColor=[0 1 0];
    %[handles.PM1.MS1CorrStep,handles.PM1.MS2CorrStep...
        %handles.PM1.TimeElapsed,handles.PM1.SequenceCounter]=...
        %MoveMotorSeqPM1(handles.obj1,handles.SpoolLength);
    pause(3);%For debugging
    handles.PM1.SequenceCounter=handles.PM1.SequenceCounter+1;
    
    %Update date
    handles.SequenceInfo.Data{1,1}=handles.PM1.MS1CorrStep;
    handles.SequenceInfo.Data{2,1}=handles.PM1.MS2CorrStep;
    handles.SequenceInfo.Data{3,1}=handles.PM1.TimeElapsed;
    handles.SequenceInfo.Data{4,1}=handles.PM1.SequenceCounter;
    
    hObject.BackgroundColor=[1 0 0];
        handles.PM1.MoveBtnLock=0;
end
guidata(hObject, handles);


function PM1SpoolLengthEdit_Callback(hObject, eventdata, handles)
% hObject    handle to PM1SpoolLengthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value=str2double(get(hObject,'String'));
if(~(Value>1 || Value<20))
    Value=5;
end
handles.PM1.SpoolLength=Value;

% Hints: get(hObject,'String') returns contents of PM1SpoolLengthEdit as text
%        str2double(get(hObject,'String')) returns contents of PM1SpoolLengthEdit as a double


% --- Executes during object creation, after setting all properties.
function PM1SpoolLengthEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PM1SpoolLengthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PM1AutomateRadioBtn.
function PM1AutomateRadioBtn_Callback(hObject, eventdata, handles)
% hObject    handle to PM1AutomateRadioBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
BtnState=get(hObject,'Value');
if(BtnState==1)
    %turn on PM1 timer
    AppendToLog('Start automated shot sequence','PM1',handles,0);
else
    AppendToLog('Stop automated shot sequence','PM1',handles,0);
end
guidata(hObject, handles);


% Hint: get(hObject,'Value') returns toggle state of PM1AutomateRadioBtn
function TensionCheck(hObject, eventdata,hfigure)
pause(0.1);% Needed to make sure the program can be closed!
handles=guidata(hfigure{1});

%data1 = query(handles.obj1,'Get TD Weight 1 \n \r');
%data2 = query(handles.obj2,'Get TD Weight 1 \n \r');
% try
%     handles.PM1.ADC(1,:)=sscanf(data1,'%li,%li,%li');
%     handles.PM2.ADC(1,:)=sscanf(data1,'%li,%li,%li');
% catch
%     handles.PM1.ADC(1,:)=[nan,nan,nan];
%     handles.PM2.ADC(1,:)=[nan,nan,nan];
% end

handles.TensionCheck.Data{1,1}=handles.PM1.T1;
handles.TensionCheck.Data{2,1}=handles.PM1.T2;
handles.TensionCheck.Data{3,1}=handles.PM1.T3;

handles.TensionCheck.Data{1,2}=handles.PM2.T1;
handles.TensionCheck.Data{2,2}=handles.PM2.T2;
handles.TensionCheck.Data{3,2}=handles.PM2.T3;

guidata(hObject, handles);

function PMShotCheck(hObject, eventdata,hfigure)
pause(1);% Needed to make sure the program can be closed!
handles=guidata(hfigure{1});
%Check for new shot
NewGSN=GetLastGSN();
if(NewGSN==handles.LastGSN)
    handles.NewShot=1;
    handles.LastGSN=NewGSN;
end

if(handles.NewShot)%Function which returns 1 when there is a new shot
   handles.NewShot=0--;
    if(handles.PM1AutomateRadioBtn.Value==1 && handles.PM2AutomateRadioBtn.Value==0 && handles.PM1.MoveBtnLock==0)
        handles.PM1.MoveBtnLock=1;
    handles.PM1SingleMoveBtn.BackgroundColor=[0 1 0];
    handles=AppendToLog('Moving PM1','PM1',handles,0);
    %[handles.PM1.MS1CorrStep,handles.PM1.MS2CorrStep...
    %    ,handles.PM1.TimeElapsed]=...
    %    MoveMotorSeqPM1(handles.obj1,handles.PM1.SpoolLength);
pause(3);
    handles=AppendToLog('Finished moving PM1','PM1',handles,1);%pause(2);
    handles.PM1.SequenceCounter=handles.PM1.SequenceCounter+1;
    handles.SequenceInfo.Data{1,1}=handles.PM1.MS1CorrStep;
    handles.SequenceInfo.Data{2,1}=handles.PM1.MS2CorrStep;
    handles.SequenceInfo.Data{3,1}=handles.PM1.TimeElapsed;
    handles.SequenceInfo.Data{4,1}=handles.PM1.SequenceCounter;
    
    handles.PM1SingleMoveBtn.BackgroundColor=[1 0 0];
        handles.PM1.MoveBtnLock=0;
        
    elseif(handles.PM1AutomateRadioBtn.Value==0 && handles.PM2AutomateRadioBtn.Value==1 && handles.PM2.MoveBtnLock==0)
        handles.PM2.MoveBtnLock=1;
    handles.PM2SingleMoveBtn.BackgroundColor=[0 1 0];
    AppendToLog('Moving PM2','PM2',handles,0);
    %[handles.PM2.MS1CorrStep,handles.PM2.MS2CorrStep...
        %handles.PM2.TimeElapsed]=...
        %MoveMotorSeqPM2(handles.obj1,handles.PM2.SpoolLength);
    AppendToLog('Finished moving PM2','PM2',handles,1);
    handles.PM2.SequenceCounter=handles.PM2.SequenceCounter+1;
    handles.SequenceInfo.Data{1,2}=handles.PM2.MS1CorrStep;
    handles.SequenceInfo.Data{2,2}=handles.PM2.MS2CorrStep;
    handles.SequenceInfo.Data{3,2}=handles.PM2.TimeElapsed;
    handles.SequenceInfo.Data{4,2}=handles.PM2.SequenceCounter;
    
    pause(3);%For debugging
    handles.PM2SingleMoveBtn.BackgroundColor=[1 0 0];
        handles.PM2.MoveBtnLock=0;
    elseif(handles.PM1AutomateRadioBtn.Value==1 && handles.PM2AutomateRadioBtn.Value==1 && handles.PM1.MoveBtnLock==0 && handles.PM2.MoveBtnLock==0)
        handles.PM1.MoveBtnLock=1;
        handles.PM1SingleMoveBtn.BackgroundColor=[0 1 0];
        handles.PM2.MoveBtnLock=1;
        handles.PM2SingleMoveBtn.BackgroundColor=[0 1 0];
        AppendToLog('Moving PM1 and PM2','PM1',handles,0);    
    %[handles.PM1.MS1CorrStep,handles.PM1.MS2CorrStep...
    %    handles.PM1.TimeElapsed]=...
    %    MoveMotorSeqPM1(handles.obj1,handles.PM1.SpoolLength);
    AppendToLog('Finished moving PM1','PM1',handles,0);
    handles.PM1.SequenceCounter=handles.PM1.SequenceCounter+1;
    handles.SequenceInfo.Data{1,1}=handles.PM1.MS1CorrStep;
    handles.SequenceInfo.Data{2,1}=handles.PM1.MS2CorrStep;
    handles.SequenceInfo.Data{3,1}=handles.PM1.TimeElapsed;
    handles.SequenceInfo.Data{4,1}=handles.PM1.SequenceCounter;
    
    pause(3);
    handles.PM1SingleMoveBtn.BackgroundColor=[1 0 0];
        handles.PM1.MoveBtnLock=0;

    pause(3);%For debugging
    
    %[handles.PM2.MS1CorrStep,handles.PM2.MS2CorrStep...
        %handles.PM2.TimeElapsed]=...
        %MoveMotorSeqPM2(handles.obj1,handles.PM2.SpoolLength);
    AppendToLog('Finished moving PM2','PM2',handles,1);
    handles.PM2.SequenceCounter=handles.PM2.SequenceCounter+1;
    handles.SequenceInfo.Data{1,2}=handles.PM2.MS1CorrStep;
    handles.SequenceInfo.Data{2,2}=handles.PM2.MS2CorrStep;
    handles.SequenceInfo.Data{3,2}=handles.PM2.TimeElapsed;
    handles.SequenceInfo.Data{4,2}=handles.PM2.SequenceCounter;
    
    pause(3);%For debugging
    handles.PM2SingleMoveBtn.BackgroundColor=[1 0 0];
    handles.PM2.MoveBtnLock=0;
        
    end
else
   %As you were. 
end

guidata(hObject, handles);


function  handles=AppendToLog(String,PM,handles,Save)
% hObject    handle to LogTextWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(strcmp(PM,'PM1'))
    data=guidata(handles.LogPM1);
    if(size(data.LogPM1.String,1)>6)
        data.LogPM1.String={String};
    else
        data.LogPM1.String=[data.LogPM1.String;{String}];
    end
    guidata(handles.LogPM1,handles);
elseif(strcmp(PM,'PM2'))
    data=guidata(handles.LogPM2);
    if(size(data.LogPM2.String,1)>7)
        data.LogPM2.String={String};
    else
        data.LogPM2.String=[data.LogPM2.String;{String}];
    end
    guidata(handles.LogPM2,handles);
end
if(Save==1)
    handles.fileID=fopen(handles.OutputFilePath,'a');
    fprintf(handles.fileID,'\n %s,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d'...
        ,datestr(now),handles.PM1.SpoolLength,handles.PM2.SpoolLength,...
        handles.PM1.MS1CorrStep,handles.PM1.MS2CorrStep,handles.PM1.TimeElapsed...
    ,handles.PM1.SequenceCounter,handles.PM2.MS1CorrStep,handles.PM2.MS2CorrStep...
    ,handles.PM2.TimeElapsed,handles.PM2.SequenceCounter,handles.LastGSN); 
    fclose(handles.fileID);
end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
stop(handles.timer);
stop(handles.timerAutomatePM1);

% Hint: delete(hObject) closes the figure
delete(hObject);
