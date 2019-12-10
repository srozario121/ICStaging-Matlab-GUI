function varargout = PotentiometerADCGUI(varargin)
% POTENTIOMETERADCGUI MATLAB code for PotentiometerADCGUI.fig
%      POTENTIOMETERADCGUI, by itself, creates a new POTENTIOMETERADCGUI or raises the existing
%      singleton*.
%
%      H = POTENTIOMETERADCGUI returns the handle to a new POTENTIOMETERADCGUI or the handle to
%      the existing singleton*.
%
%      POTENTIOMETERADCGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in POTENTIOMETERADCGUI.M with the given input arguments.
%
%      POTENTIOMETERADCGUI('Property','Value',...) creates a new POTENTIOMETERADCGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PotentiometerADCGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PotentiometerADCGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PotentiometerADCGUI

% Last Modified by GUIDE v2.5 22-Oct-2017 15:43:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PotentiometerADCGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @PotentiometerADCGUI_OutputFcn, ...
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


% --- Executes just before PotentiometerADCGUI is made visible.
function handles=PotentiometerADCGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PotentiometerADCGUI (see VARARGIN)

% Initialize COM ports available
    handles.ConnectToCOMPort=0;
    handles.Object=[];
    handles.COMValue=[];
    handles.COMString=[{'COM Ports'};getAvailableComPort()];
    set(handles.popupmenu1,'String',handles.COMString);

    %Create axes figures;
    set(handles.axes1,'XLim',[0 75],'YLim',[0 30]);
    
    handles.ADC1.Current=0;handles.ADC1.Mean=0;handles.ADC1.Max=0;handles.ADC1.Min=0;
    handles.ADC2.Current=0;handles.ADC2.Mean=0;handles.ADC2.Max=0;handles.ADC2.Min=0;
    handles.ADC3.Current=0;handles.ADC3.Mean=0;handles.ADC3.Max=0;handles.ADC3.Min=0;
    handles.ADCAveragingIndex=int32(1);handles.ADCAverageNSamples=30;
    
    handles.ADC1Samples=zeros(handles.ADCAverageNSamples,1);
    handles.ADC2Samples=zeros(handles.ADCAverageNSamples,1);
    handles.ADC3Samples=zeros(handles.ADCAverageNSamples,1);
    guidata(hObject, handles);
    %Create data value
    handles.data_ADC=0;handles.value_ADC=[0,0,0];
    handles.ADCCH=1;
    handles.indexRecurring=1;
    handles.dataStored1=1;handles.dataStored2=1;handles.dataStored2=1;
    %Create timer function
    hfigure=handles.figure1;
    handles.timer=timer(...
        'ExecutionMode', 'fixedRate', ...       % Run timer repeatedly
        'Period', 0.005,...
        'TimerFcn', @(obj, event) ReadCOMPort(hObject, eventdata,hfigure)); % Specify callback function

    
    % Choose default command line output for PotentiometerADCGUI
    handles.output = hObject;
    
    % Update handles structure
    guidata(hObject, handles);

% UIWAIT makes PotentiometerADCGUI wait for user response (see UIRESUME)
 %uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PotentiometerADCGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
    varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function handles=pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%If button has not already been pressed
if(handles.ConnectToCOMPort==0)
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
        guidata(hObject, handles);
        if strcmp(get(handles.timer, 'Running'), 'off')
            start(handles.timer);
            guidata(hObject, handles);
        else
            warning('COM port is connected but timer is not working');
        end
    catch
       warning(['Could not connect to port:' handles.COMValue]);
       guidata(hObject, handles);
    end
guidata(hObject, handles);
%If button has already been pressed-disconnect from COM port
elseif(handles.ConnectToCOMPort==1)
    fclose(handles.Object);
    handles.Object=[];
    handles.ConnectToCOMPort=0;%Reset com connection value
    disp(['Connection to port:' handles.COMValue ' was closed gracefully']);
    if strcmp(get(handles.timer, 'Running'), 'on')
        stop(handles.timer);
        guidata(hObject, handles);
    else
        warning('COM port is connected but timer is not working');
    end
end
guidata(hObject, handles);


% --- Executes on selection change in popupmenu1.
function handles=popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
items = get(hObject,'String');
index_selected = get(hObject,'Value');
COMValue = items{index_selected};
disp(['The following COM port was selected:' COMValue]);
handles.COMValue=COMValue;
guidata(hObject, handles);

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1

% --- Executes during object creation, after setting all properties.
function handles=popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
   
end


% --- Executes during object creation, after setting all properties.
function handles=ADC1_Current_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ADC1_Current (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function ReadCOMPort(hObject, eventdata, hfigure)
% hObject    Sends a char to the COM port specified and stores the
% resulting ADC value in the handle structure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
%Send a char to the microcontroller. This triggers an response on UART.
pause(0.005);% Needed to make sure the program can be closed!

handles=guidata(hfigure);
if(handles.ConnectToCOMPort==1)
    if(strcmp(get(handles.Object,'Status'),'open'))
    else
    fopen(handles.Object);
    end

    data1 = query(handles.Object,'Get TD Weight 1 \n \r');
    
    if(0)%COMPARE ADCS
        %Do nothing
        %disp('Same data as before');
    else
        handles.data_ADC=data1;
        
        %disp([ 'New data' handles.data_ADC]);
        handles.value_ADC=sscanf(data1,'%li,%li,%li');
        handles.ADC1.Current=handles.value_ADC(1);
        handles.ADC2.Current=handles.value_ADC(2);
        handles.ADC3.Current=handles.value_ADC(3);
        
        %Set current values
        set(handles.ADC1_Current, 'String', sprintf('%.2f',double(handles.ADC1.Current).*(5/2^(12))));
        set(handles.ADC2_Current, 'String', sprintf('%.2f',double(handles.ADC2.Current).*(5/2^(12))));
        set(handles.ADC3_Current, 'String', sprintf('%.2f',double(handles.ADC3.Current).*(5/2^(12))));
    
        guidata(hObject,handles);
        
        hfigure=handles.figure1;
        handles=CalculateStats(hObject,eventdata,handles);
        handles=StoreDataInHandle(hObject, eventdata, hfigure);
        handles=UpdateStatsFields(hObject,eventdata,handles);
        PlotToFigure(hObject, eventdata, handles);
        
    end
    
else
   disp('COM port is unconnected'); 
end

function handles=CalculateStats(hObject,eventdata,handles)

handles.ADCAveragingIndex=int32(handles.ADCAveragingIndex+1);

if(isempty(handles.ADC1Samples)||isempty(handles.ADC2Samples)||isempty(handles.ADC3Samples))
    %Do nothing
elseif(int32(handles.ADCAveragingIndex)==int32(handles.ADCAverageNSamples))
    handles.ADCAveragingIndex=mod(int32(handles.ADCAveragingIndex+1),handles.ADCAverageNSamples);
    %Calculate mean
    handles.ADC1.Mean=mean(handles.ADC1Samples);
    handles.ADC2.Mean=mean(handles.ADC2Samples);
    handles.ADC3.Mean=mean(handles.ADC3Samples);
    
    %Calculate max
    handles.ADC1.Max=max(handles.ADC1Samples);
    handles.ADC2.Max=max(handles.ADC2Samples);
    handles.ADC3.Max=max(handles.ADC3Samples);
    
    %Calculate min
    handles.ADC1.Min=min(handles.ADC1Samples);
    handles.ADC2.Min=min(handles.ADC2Samples);
    handles.ADC3.Min=min(handles.ADC3Samples);
    
    handles.ADC1Samples(1:end-1)=[];
    handles.ADC2Samples(1:end-1)=[];
    handles.ADC3Samples(1:end-1)=[];
else
    handles.ADC1Samples(handles.ADCAveragingIndex)=handles.ADC1.Current;
    handles.ADC2Samples(handles.ADCAveragingIndex)=handles.ADC2.Current;
    handles.ADC3Samples(handles.ADCAveragingIndex)=handles.ADC3.Current;
end
guidata(hObject,handles);


function handles=UpdateStatsFields(hObject,eventdata,handles)

set(handles.ADC1_Mean, 'String', sprintf('%.2f',double(handles.ADC1.Mean).*(5/2^(12))));
set(handles.ADC2_Mean, 'String', sprintf('%.2f',double(handles.ADC2.Mean).*(5/2^(12))));
set(handles.ADC3_Mean, 'String', sprintf('%.2f',double(handles.ADC3.Mean).*(5/2^(12))));

set(handles.ADC1_Min, 'String', sprintf('%.2f',double(handles.ADC1.Min).*(5/2^(12))));
set(handles.ADC2_Min, 'String', sprintf('%.2f',double(handles.ADC2.Min).*(5/2^(12))));
set(handles.ADC3_Min, 'String', sprintf('%.2f',double(handles.ADC3.Min).*(5/2^(12))));

set(handles.ADC1_Max, 'String', sprintf('%.2f',double(handles.ADC1.Max).*(5/2^(12))));
set(handles.ADC2_Max, 'String', sprintf('%.2f',double(handles.ADC2.Max).*(5/2^(12))));
set(handles.ADC3_Max, 'String', sprintf('%.2f',double(handles.ADC3.Max).*(5/2^(12))));
guidata(hObject,handles);



%----Function stores 1000 points in the memory of the handle object
function handles=StoreDataInHandle(hObject, eventdata, hfigure)
handles=guidata(hfigure);
if(isempty(handles.ADC1.Current))
    %Do nothing
elseif(handles.indexRecurring==100)
        handles.indexRecurring=mod(handles.indexRecurring+1,100);
        handles.dataStored1(2:end)=[];handles.dataStored2(2:end)=[];handles.dataStored3(2:end)=[];
else
     handles.indexRecurring=handles.indexRecurring+1;
    handles.dataStored1(int32(handles.indexRecurring))=int32(handles.ADC1.Current);
    handles.dataStored2(int32(handles.indexRecurring))=int32(handles.ADC2.Current);
    handles.dataStored3(int32(handles.indexRecurring))=int32(handles.ADC3.Current);
end
    
%---- Function plots to axes on GUIa
function PlotToFigure(hObject, eventdata, handles)
pause(0.005)
cla(handles.axes1);
handles.pl1=plot(1:length(handles.dataStored1),WeighingScaleADCToForce(double(handles.dataStored1),5),'r');hold on;
handles.pl2=plot(1:length(handles.dataStored2),WeighingScaleADCToForce(double(handles.dataStored2),6),'b');hold on;
handles.pl3=plot(1:length(handles.dataStored3),WeighingScaleADCToForce(double(handles.dataStored3),7),'g');

xlabel('Measurement');ylabel('Tension [N]');legend('ADC1','ADC2','ADC3');
axes(handles.axes1);
if(isempty(min(handles.dataStored1(handles.dataStored1~=0))) || isempty(max(handles.dataStored1)) )
else
set(handles.axes1,'XLim',[0 100],'YLim',[-1 30],...
    'XGrid','on','YGrid','on',...
    'XMinorGrid','on','YMinorGrid','on',...
    'Visible' ,'on');
end
pause(0.005);
guidata(hObject,handles);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    if strcmp(get(handles.timer, 'Running'), 'on')
        stop(handles.timer);
    end
    % Destroy timer
    delete(handles.timer)
catch
    warning('timer has been deleted');
end
try
%Deal with COM Port
if(isempty(handles.Object))
    %Do nothing
else
    if(strcmp(get(handles.Object,'Status'),'open'))
    fclose(handles.Object);
    else
        %Do nothing
    end
end
catch
    warning('COM is not around anymore.')
end

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1


% --- Executes during object creation, after setting all properties.
function ADCChannel_Dropdown_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ADCChannel_Dropdown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over ADC1_Current.
function ADC1_Current_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to ADC1_Current (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

