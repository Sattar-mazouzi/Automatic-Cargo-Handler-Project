function varargout = redtracking(varargin)
% REDTRACKING MATLAB code for redtracking.fig
%      REDTRACKING, by itself, creates a new REDTRACKING or raises the existing
%      singleton*.
%
%      H = REDTRACKING returns the handle to a new REDTRACKING or the handle to
%      the existing singleton*.
%
%      REDTRACKING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REDTRACKING.M with the given input arguments.
%
%      REDTRACKING('Property','Value',...) creates a new REDTRACKING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before redtracking_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to redtracking_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help redtracking

% Last Modified by GUIDE v2.5 03-May-2019 19:10:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @redtracking_OpeningFcn, ...
                   'gui_OutputFcn',  @redtracking_OutputFcn, ...
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


% --- Executes just before redtracking is made visible.
function redtracking_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to redtracking (see VARARGIN)

% Choose default command line output for redtracking
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes redtracking wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global cam ;
cam = 1;
global Scam ;
Scam =1 ;
display(Scam )



% --- Outputs from this function are returned to the command line.
function varargout = redtracking_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in start.
function start_Callback(hObject, eventdata, handles)
% hObject    handle to start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA) 

global IP ; 
global Sport ;

global rn 
rn = true ; 
 if ~isempty(instrfind)
     fclose(instrfind);
      delete(instrfind);
 end
global s; 

 s=serial(Sport,'Baudrate',9600);%opening serial port
fopen(s);


global mode ;
global cam ;
%}

if (cam == 1)
ipAdress = strcat('http://',IP,':8080/video');
vid=ipcam(ipAdress); 

while(rn)
    
   

  

     red=0;
    blue=0;
    
    data=snapshot(vid);
    [a, b, c]=size(data);
    y=a;
    x=b-40;
    
    
    diff_imR = imsubtract(data(:,:,1), rgb2gray(data));%subtracting red component
    diff_imB = imsubtract(data(:,:,3), rgb2gray(data));%subtracting blue component
    
    diff_imR = medfilt2(diff_imR, [3 3]);
    diff_imB = medfilt2(diff_imB, [3 3]);
    
    diff_imR = im2bw(diff_imR,0.25);
    diff_imB = im2bw(diff_imB,0.25);
    
    diff_imR = bwareaopen(diff_imR,300);
    diff_imB = bwareaopen(diff_imB,300);
    
     bwR = bwlabel(diff_imR, 8);
    bwB = bwlabel(diff_imB, 8);
    
    statsR = regionprops(bwR,'Area', 'BoundingBox', 'Centroid');
    statsB = regionprops(bwB,'Area', 'BoundingBox', 'Centroid');
    
   % figure(1)
    imshow(data)

    hold on
    
     for g = 1:length(statsR)
        
        bb = statsR(g).BoundingBox;
        centroidR = statsR(g).Centroid;
        red=1;
        rectangle('Position',bb,'EdgeColor','r','LineWidth',2)
        plot(centroidR(1),centroidR(2), '-m+')
        a=text(centroidR(1),centroidR(2), strcat('X: ', num2str(round(centroidR(1))), '    Y: ', num2str(round(centroidR(2)))));
        set(a, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
     hold on;
     end
     
     for v = 1:length(statsB)
        
        dd = statsB(v).BoundingBox;
        centroidB = statsB(v).Centroid;
        blue=1;
        rectangle('Position',dd,'EdgeColor','b','LineWidth',2)
           plot(centroidB(1),centroidB(2), '-m+')
        b=text(centroidB(1),centroidB(2), strcat('X: ', num2str(round(centroidB(1))), '    Y: ', num2str(round(centroidB(2)))));
        set(b, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
        
     hold on 
     end
     hold off
     
    
    
       if  mode == 1
        if red==1 
     
        cenRx=centroidR(1);
        cenRy=centroidR(2);
        X1=x/2+20; 
        Y1=y/2+20;
        X2=x/2-20;
        Y2=y/2-20;
        if (cenRx>X2 && cenRx<X1)
            fprintf(s,'F');
        elseif (cenRx>X1)                             % 1st Quadrant
            fprintf(s,'R');
        elseif (cenRx<X2)                         % 2nd Quadrant
           fprintf(s,'L');
        end
        
        
        elseif (red==0)&&(blue==0)
        fprintf(s,'N');
   
        
         elseif (red==0)&&(blue==1)
      
        cenBx=centroidB(1);
        cenBy=centroidB(2);
        X1=x/2+20; % center region of the frame
        Y1=y/2+20;
        X2=x/2-20;
        Y2=y/2-20;
        if (cenBx>X2 && cenBx<X1)
            fprintf(s,'f');
        elseif (cenBx>X1)                             % 1st Quadrant
            fprintf(s,'r');
        elseif (cenBx<X2)                         % 2nd Quadrant
           fprintf(s,'l');
        end
        
        
        end
       end
 
    
%}

     
     
    
          
   
   
   
 pause(0.05);   
end %while 
end 


% Both the loops end here.

% Stop the video aquisition.


% Clear all variables
clc;



% --- Executes on button press in stop.
function stop_Callback(hObject, eventdata, handles)
% hObject    handle to stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of stop
global rn 
rn = false ;
global s 
close(s);


function getip_Callback(hObject, eventdata, handles)
% hObject    handle to getip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of getip as text
%        str2double(get(hObject,'String')) returns contents of getip as a double
global IP ; 
 IP = get(handles.getip,'String');

% --- Executes during object creation, after setting all properties.
function getip_CreateFcn(hObject, eventdata, handles)
% hObject    handle to getip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SPort.
function SPort_Callback(hObject, eventdata, handles)
% hObject    handle to SPort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SPort contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SPort
global Sport ; 
  switch get(handles.SPort,'Value')   
    case 1
     Sport='COM1'
    case 2
        Sport='COM2'
    case 3
     Sport='COM3'
    case 4
           Sport='COM4'
    case 5
     Sport='COM5'
    case 6
         Sport='COM6'
            case 7
           Sport='COM7'
            case 8
           Sport='COM8'
            case 9
           Sport='COM9'
            case 10
           Sport='COM10'
            case 11
           Sport='COM11'
            case 12
           Sport='COM12'
            case 13
           Sport='COM13'
           
           end  


% --- Executes during object creation, after setting all properties.
function SPort_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SPort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in down.
function down_Callback(hObject, eventdata, handles)
% hObject    handle to down (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global s
fprintf(s,'B');

% --- Executes on button press in right.
function right_Callback(hObject, eventdata, handles)
% hObject    handle to right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global s

fprintf(s,'R');

% --- Executes on button press in up.
function up_Callback(hObject, eventdata, handles)
% hObject    handle to up (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global s

fprintf(s,'F');



% --- Executes on button press in left.
function left_Callback(hObject, eventdata, handles)
% hObject    handle to left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global s
fprintf(s,'L');

% --- Executes on button press in pick.
function pick_Callback(hObject, eventdata, handles)
% hObject    handle to pick (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global s

fprintf(s,'P');


% --- Executes on button press in drop.
function drop_Callback(hObject, eventdata, handles)
% hObject    handle to drop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global s

fprintf(s,'D');


% --- Executes on button press in manual.
function auto_Callback(hObject, eventdata, handles)
% hObject    handle to manual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of manual
global s; 
 fprintf(s,'A');%  sent auto mode to th serial port
  global mode ; 
 mode = 1; 
 
% --- Executes on button press in manual.
function manual_Callback(hObject, eventdata, handles)
% hObject    handle to manual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of manual

 global s; 
 fprintf(s,'M');  % sent to the serial manual mode
 global mode ; 
 mode = 2; 
 


% --- Executes on button press in non.
function non_Callback(hObject, eventdata, handles)
% th is  non pushbutton to set the default value of button group

% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clear all;
close all;


% --- Executes on button press in breaker.
function breaker_Callback(hObject, eventdata, handles)
% hObject    handle to breaker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global s
fprintf(s,'S');


% --- Executes on button press in camuses.
function camuses_Callback(hObject, eventdata, handles)
% hObject    handle to camuses (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of camuses
 global cam ;
  switch get(handles.camuses,'Value')   
    case 1
     set(handles.auto,'visible', 'on');
     set(handles.axes1,'visible', 'on');
     
     cam = 1; 
     
    case 0
         set(handles.auto,'visible', 'off');
         set(handles.axes1,'visible', 'off');
         cam = 2; 
  end
  
  


% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA) 
 global s

switch eventdata.Key
  case 'uparrow'
   fprintf(s,'F');
  case 'rightarrow'
   fprintf(s,'R');
    case 'leftarrow'
   fprintf(s,'L');
  case 'downarrow'
   fprintf(s,'B');
    case 'space'
   fprintf(s,'S');
    case 'shift'
   fprintf(s,'P');
  case 'control'
   fprintf(s,'D');
end 
display(eventdata.Key);
