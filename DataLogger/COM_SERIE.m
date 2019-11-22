function varargout = COM_SERIE(varargin)
% COM_SERIE MATLAB code for COM_SERIE.fig
%      COM_SERIE, by itself, creates a new COM_SERIE or raises the existing
%      singleton*.
%
%      H = COM_SERIE returns the handle to a new COM_SERIE or the handle to
%      the existing singleton*.
%
%      COM_SERIE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COM_SERIE.M with the given input arguments.
%
%      COM_SERIE('Property','Value',...) creates a new COM_SERIE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before COM_SERIE_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to COM_SERIE_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help COM_SERIE

% Last Modified by GUIDE v2.5 11-Oct-2016 14:40:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @COM_SERIE_OpeningFcn, ...
                   'gui_OutputFcn',  @COM_SERIE_OutputFcn, ...
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


% UIWAIT makes COM_SERIE wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = COM_SERIE_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%_________________________________________________________________________



% --- Executes just before COM_SERIE is made visible.
function COM_SERIE_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to COM_SERIE (see VARARGIN)


%Valores por defecto

set(handles.popCom,'Value',2);  % Valor por defecto COM3
set(handles.popVelocidad,'Value',3);    % Valor por defecto 9600
set(handles.lblEstadoPuerto,'BackgroundColor',[1,0,0]);
clc;

% Choose default command line output for COM_SERIE
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);









% --- Executes on button press in cmdAbrir.
function cmdAbrir_Callback(hObject, eventdata, handles)
% hObject    handle to cmdAbrir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global SerPIC


% Cierra los puertos que se hayan podido quedar abiertos
Puertos_Activos=instrfind; % Lee los puertos activos
if isempty(Puertos_Activos)==0 % Comprueba si hay puertos activos
    fclose(Puertos_Activos); % Cierra los puertos activos
    delete(Puertos_Activos) % Borra la variable Puertos_Activos
    clear Puertos_Activos % Destruye la variable Puertos_Activos
end

puerto=get(handles.popCom,'String');
puerto=puerto{get(handles.popCom,'Value')};
velocidad=get(handles.popVelocidad,'String');
velocidad=str2double(velocidad{get(handles.popVelocidad,'Value')});

SerPIC = serial(puerto);
set(SerPIC,'BaudRate',velocidad);
set(SerPIC,'DataBits',8);
set(SerPIC,'Parity','none');
set(SerPIC,'StopBits',1);
set(SerPIC,'FlowControl','none');
set(SerPIC,'BytesAvailableFcnCount',200); % Se configura en n? de bytes que debe haber en el buffer de recepci?n para disparar el evento Rx_Callback
set(SerPIC, 'BytesAvailableFcnMode' ,'byte');
set(SerPIC,'BytesAvailableFcn',{@Rx_Callback,handles});
fopen(SerPIC);

set(handles.lblEstadoPuerto,'BackgroundColor',[0,1,0]);
set(handles.lblEstadoPuerto,'String','PUERTO ABIERTO');



function Rx_Callback(hObject, eventdata, handles)

global SerPIC contador x y z
       
num=SerPIC.BytesAvailable;
if num>190
    data=fread(SerPIC,200);
    
    for i=1:200
      contador=contador+1;
      x(contador)=contador;
      y(contador)=data(i);
    end
    
    plot(handles.pltGrafica1,x,y,'-r','LineWidth',5);
    plot(handles.pltGrafica2,x,z,'-r','LineWidth',5);
end


function Timer(hObject, eventdata, handles)

global SerPIC

fwrite(SerPIC,'1');



% --- Executes on button press in cmdSalir.
function cmdSalir_Callback(hObject, eventdata, handles)
% hObject    handle to cmdSalir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global SerPIC

opc=questdlg('?Desea salir del programa?','SALIR','Si','No','No');
if strcmp(opc,'No')
    return;
end

fwrite(SerPIC,'0');

% Cierra los puertos abiertos
Puertos_Activos=instrfind; % Lee los puertos activos
if isempty(Puertos_Activos)==0 % Comprueba si hay puertos activos
    fclose(Puertos_Activos); % Cierra los puertos activos
    delete(Puertos_Activos) % Borra la variable Puertos_Activos
    clear Puertos_Activos % Destruye la variable Puertos_Activos
end

clear
clc
close all


% --- Executes on button press in tglMuestrear.
function tglMuestrear_Callback(hObject, eventdata, handles)
% hObject    handle to tglMuestrear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tglMuestrear

global x y z contador Temporizador

isDown = get(hObject,'Value');

if isDown
    
    Temporizador=timer;
    set(Temporizador,'Period',0.1)
    set(Temporizador,'ExecutionMode','fixedRate')
    set(Temporizador,'TimerFcn',{@Timer,handles}) 
    contador=0; x=0; y=0; z=0;
    %plot(handles.pltGrafica1,x,y)
    %plot(handles.pltGrafica2,x,z)
    start(Temporizador)
    
    set(handles.tglMuestrear, 'String', 'PARAR')
else
    stop(Temporizador)
    set(handles.tglMuestrear, 'String', 'MUESTREAR')
end


%______________________________________________________________________




% --- Executes on selection change in popCom.
function popCom_Callback(hObject, eventdata, handles)
% hObject    handle to popCom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popCom contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popCom

%contents = get(hObject,'String'); 
%selectedText = contents{get(hObject,'Value')};
%handles.puerto = selectedText;
%guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function popCom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popCom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popVelocidad.
function popVelocidad_Callback(hObject, eventdata, handles)
% hObject    handle to popVelocidad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popVelocidad contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popVelocidad

%contents = get(hObject,'String'); 
%selectedText = contents{get(hObject,'Value')};
%handles.velocidad = str2double(selectedText);
%guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function popVelocidad_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popVelocidad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end