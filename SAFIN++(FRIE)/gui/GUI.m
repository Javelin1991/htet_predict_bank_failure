function varargout = GUI(varargin)
% GUI MATLAB code for GUI.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI

% Last Modified by GUIDE v2.5 02-Dec-2017 15:45:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GUI_OpeningFcn, ...
    'gui_OutputFcn',  @GUI_OutputFcn, ...
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


% --- Executes just before GUI is made visible.
function GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI (see VARARGIN)

% Choose default command line output for GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function traininglink_Callback(hObject, eventdata, handles)
% hObject    handle to traininglink (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.traininglink = get(hObject,'String');
% Hints: get(hObject,'String') returns contents of traininglink as text
%        str2double(get(hObject,'String')) returns contents of traininglink as a double


% --- Executes during object creation, after setting all properties.
function traininglink_CreateFcn(hObject, eventdata, handles)
% hObject    handle to traininglink (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.testinglink = get(hObject, 'String');
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ieButton.
function ieButton_Callback(hObject, eventdata, handles)
button_state = get(hObject, 'Value');
if button_state == get(hObject,'Max')
    display('I/E On');
    handles.interpolation = 1;
elseif button_state == get(hObject,'Min')
    display('I/E Off');
    handles.interpolation = 0;
end
% hObject    handle to ieButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ieButton


% --- Executes on selection change in experimentList.
function experimentList_Callback(hObject, eventdata, handles)

% hObject    handle to experimentList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns experimentList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from experimentList
items = get(hObject, 'String');
index_selected = get(hObject, 'Value')
item_selected = items{index_selected}

% --- Executes during object creation, after setting all properties.
function experimentList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to experimentList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in runButton.
function runButton_Callback(hObject, eventdata, handles)
% hObject    handle to runButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
experiment = handles.experimentList.Value;
switch(experiment)
    case 1
        train_data = load('Nakanishi1_train.txt');
        train_IN = load('Nakanishi1_train_IN.txt');
        IND = size(train_IN,2);
        train_OUT = load('Nakanishi1_train_OUT.txt');
        OUTD = size(train_OUT,2);
        test_data = load('Nakanishi1_test.txt');
        set(handles.IND, 'String',IND);
        set(handles.OUTD, 'String',OUTD);
%         Epochs = 300;
%         Eta = 0.05;
%         Sigma0 = sqrt(0.16);
%         Forgetfactor = 0.99;
%         Lamda = 0.8;
%         Rate = 0.25;
%         Omega = 0.7;
%         Gamma = 0.1;
%         decay = 1;
%         tau = 0.5; 
         Epochs = handles.epoch;
        Eta = handles.eta;
        Sigma0 = handles.sigma0;
        Forgetfactor = handles.ff;
        Lamda = handles.lamda;
        Rate = handles.rate;
        Omega = handles.omega;
        Gamma = handles.gamma;
        decay = handles.decay;
        tau = handles.tau;
%         Epochs = str2double(handles.epoch);
%         Eta = str2double(handles.eta);
%         Sigma0 = str2double(handles.sigma0);
%         Forgetfactor = str2double(handles.ff);
%         Lamda = str2double(handles.lamda);
%         Epochs = str2double(handles.epoch);
%         Rate = str2double(handles.rate);
%         Omega = str2double(handles.omega);
%         Gamma = str2double(handles.gamma);
%         tau = str2double(handles.tau);
%         decay = 1;
        [net_out, system] = Run_SaFIN(1, train_data,test_data,IND,OUTD,Epochs,Eta,Sigma0,Forgetfactor, decay,Lamda,tau,Rate, Omega, Gamma);
        set(handles.rmse,'String',system.RMSE);
        set(handles.R,'String',system.R);
        set(handles.ruleNumber,'String',system.ruleCount);
        set(handles.numberIE,'String',system.interpolateCount);
        TestData = test_data;
        TrainData = train_data;
        axes(handles.axes);
        hold on
        max_output = max(TestData(:,IND+1));
        min_output = min(TestData(:,IND+1));
        unit = (max_output - min_output) / 5;
        plot(1:1:size(TestData,1),TestData(:,1+IND),'b');
        plot(1:1:size(TestData,1),net_out(:,1),'r');
        plot(1:1:size(TrainData,1), unit*system.interpolated(1,:),'g');
        legend('Actual','Predicted', 'I/E Points', '#Rules');
        axes(handles.axes2);
        plot(1:1:size(TrainData,1), unit*system.interpolated(1,:),'g');
        plot(1:1:size(TrainData,1), system.ruleCountDiary(:,1),'m');
        legend('#Rules');
        clear workspace;
    case 2
        train_data = load('Nakanishi2_train.txt');
        test_data = load('Nakanishi2_test.txt');
        IND = 2;
        OUTD = 1;
        %ONLINE TRAINING FOLLOWED BY TESTING
        %%%%%%%offline training & testing
        Epochs = 300;
        Eta = 0.05;
        Sigma0 = sqrt(0.16);
        Forgetfactor = 0.99;
        Lamda = 0.8;
        Rate = 0.25;
        Omega = 0.7;
        Gamma = 0.1;
        forget = 1;
        tau = 0.5;
        set(handles.IND, 'String',IND);
        set(handles.OUTD, 'String',OUTD);
        [net_out, system] = Run_SaFIN(1, train_data,test_data,IND,OUTD,Epochs,Eta,Sigma0,forget, Forgetfactor,Lamda,tau,Rate, Omega, Gamma);
        set(handles.rmse,'String',system.RMSE);
        set(handles.R,'String',system.R);
        set(handles.ruleNumber,'String',system.ruleCount);
        set(handles.numberIE,'String',system.interpolateCount);
        TestData = test_data;
        TrainData = train_data;
        axes(handles.axes);
        hold on
        max_output = max(TestData(:,IND+1));
        min_output = min(TestData(:,IND+1));
        unit = (max_output - min_output) / 5;
        plot(1:1:size(TestData,1),TestData(:,1+IND),'b');
        plot(1:1:size(TestData,1),net_out(:,1),'r');
        plot(1:1:size(TrainData,1), unit*system.interpolated(1,:),'g');
        legend('Actual','Predicted', 'I/E Points', '#Rules');
        axes(handles.axes2);
        plot(1:1:size(TrainData,1), system.ruleCountDiary(:,1),'m');
        legend('#Rules');
        clear workspace;
    case 3
        train_data = load('Nakanishi3_train.txt');
        train_IN = train_data(:,1:3);
        IND = size(train_IN, 2);
        train_OUT = train_data(:,4);
        OUTD = size(train_OUT,2);
        test_data = load('Nakanishi3_test.txt');
        Epochs = 1;
        Eta = 0.05;
        Sigma0 = sqrt(0.16);
        Forgetfactor = 0.99;
        Lamda = 0.45;
        Rate = 0.25;
        Omega = 0.7;
        Gamma = 0.1;
        forget = 1;
        tau = 0.2;
        set(handles.IND, 'String',IND);
        set(handles.OUTD, 'String',OUTD);
        [net_out, system] = Run_SaFIN(1, train_data,test_data,IND,OUTD,Epochs,Eta,Sigma0,forget, Forgetfactor,Lamda,tau,Rate, Omega, Gamma);
        set(handles.rmse,'String',system.RMSE);
        set(handles.R,'String',system.R);
        set(handles.ruleNumber,'String',system.ruleCount);
        set(handles.numberIE,'String',system.interpolateCount);
        TestData = test_data;
        TrainData = train_data;
        axes(handles.axes);
        hold on
        max_output = max(TestData(:,IND+1));
        min_output = min(TestData(:,IND+1));
        unit = (max_output - min_output) / 5;
        plot(1:1:size(TestData,1),TestData(:,1+IND),'b');
        plot(1:1:size(TestData,1),net_out(:,1),'r');
        plot(1:1:size(TrainData,1), unit*system.interpolated(1,:),'g');
        legend('Actual','Predicted', 'I/E Points', '#Rules');
        axes(handles.axes2);
        plot(1:1:size(TrainData,1), system.ruleCountDiary(:,1),'m');
        legend('#Rules');
        clear workspace;
    case 4
        data = load('Iris.mat');
        input = data.iris_input;
        output = data.iris_target;
        train_data = [input, output];
        test_data = [input, output];
        IND = size(input, 2);
        OUTD = size(output, 2);
        Epochs = 1;
        Eta = 0.05;
        Sigma0 = sqrt(0.16);
        Forgetfactor = 0.99;
        Lamda = 0.45;
        Rate = 0.25;
        Omega = 0.7;
        Gamma = 0.1;
        forget = 1;
        tau = 0.2;
        set(handles.IND, 'String',IND);
        set(handles.OUTD, 'String',OUTD);
        [net_out, system] = Run_SaFIN(2, train_data,test_data,IND,OUTD,Epochs,Eta,Sigma0,forget, Forgetfactor,Lamda,tau,Rate, Omega, Gamma);
        set(handles.rmse,'String',system.RMSE);
        set(handles.R,'String',system.R);
        set(handles.ruleNumber,'String',system.ruleCount);
        set(handles.numberIE,'String',system.interpolateCount);
        TestData = test_data;
        TrainData = train_data;
        axes(handles.axes);
        hold on
        max_output = max(TestData(:,IND+1));
        min_output = min(TestData(:,IND+1));
        unit = (max_output - min_output) / 5;
        plot(1:1:size(TestData,1),TestData(:,1+IND),'b');
        plot(1:1:size(TestData,1)-1,net_out(:,1),'r');
        plot(1:1:size(TrainData,1), unit*system.interpolated(1,:),'g');
        legend('Actual','Predicted', 'I/E Points', '#Rules');
        axes(handles.axes2);
        plot(1:1:size(TrainData,1), unit*system.interpolated(1,:),'g');
        plot(1:1:size(TrainData,1), system.ruleCountDiary(:,1),'m');
        legend('#Rules');
        clear workspace;
    case 5
        data = load('S&P500.mat');
        input = data.snp500_input;
        output = data.snp500_target;
        train_data = [input, output];
        test_data = train_data;
        IND = size(input, 2);
        OUTD = size(output,2);
        Epochs = 1;
        Eta = 0.05;
        Sigma0 = sqrt(0.16);
        Forgetfactor = 0.99;
        Lamda = 0.8;
        Rate = 0.25;
        Omega = 0.7;
        Gamma = 0.1;
        tau = 0.5;
        forget = 1;
        set(handles.IND, 'String',IND);
        set(handles.OUTD, 'String',OUTD);
        [net_out, system] = Run_SaFIN(2, train_data,test_data,IND,OUTD,Epochs,Eta,Sigma0,forget, Forgetfactor,Lamda,tau,Rate, Omega, Gamma);
        set(handles.rmse,'String',system.RMSE);
        set(handles.R,'String',system.R);
        set(handles.ruleNumber,'String',system.ruleCount);
        set(handles.numberIE,'String',system.interpolateCount);
        TestData = test_data;
        TrainData = train_data;
        axes(handles.axes);
        hold on
        max_output = max(TestData(:,IND+1));
        min_output = min(TestData(:,IND+1));
        unit = (max_output - min_output) / 5;
        plot(1:1:size(TestData,1),TestData(:,1+IND),'b');
        plot(1:1:size(TestData,1)-1,net_out(:,1),'r');
        plot(1:1:size(TrainData,1), unit*system.interpolated(1,:),'g');
        legend('Actual','Predicted', 'I/E Points', '#Rules');
        axes(handles.axes2);
        plot(1:1:size(TrainData,1), unit*system.interpolated(1,:),'g');
        plot(1:1:size(TrainData,1), system.ruleCountDiary(:,1),'m');
        legend('#Rules');
        clear workspace;
    case 6
        data = load('citibank.mat');
        IND = 4;
        OUTD = 1;
        input = data.citibank(:,1:IND);
        output = data.citibank(:,1:IND+OUTD);
        data = [input, output];
        dataSize = size(data,1);
        %ONLINE-TRAINING FOLLOWED BY TESTING
        train_data = data;
        test_data = data;
        Alpha = 0.25;
        Beta = 0.65;
        Eta = 0.05;
        Sigma0 = sqrt(0.16);
        Forgetfactor = 0.99;
        Lamda = 0.5;
        tau = 0.05;
        Rate = 0.25;
        Omega = 0.7;
        Gamma = 0.1;
        Epochs = 1;
        forget = 1;
        set(handles.IND, 'String',IND);
        set(handles.OUTD, 'String',OUTD);
        [net_out, system] = Run_SaFIN(2, train_data,test_data,IND,OUTD,Epochs,Eta,Sigma0,forget, Forgetfactor,Lamda,tau,Rate, Omega, Gamma);
        set(handles.rmse,'String',system.RMSE);
        set(handles.R,'String',system.R);
        set(handles.ruleNumber,'String',system.ruleCount);
        set(handles.numberIE,'String',system.interpolateCount);
        TestData = test_data;
        TrainData = train_data;
        axes(handles.axes);
        hold on
        max_output = max(TestData(:,IND+1));
        min_output = min(TestData(:,IND+1));
        unit = (max_output - min_output) / 5;
        plot(1:1:size(TestData,1),TestData(:,1+IND),'b');
        plot(1:1:size(TestData,1)-1,net_out(:,1),'r');
        plot(1:1:size(TrainData,1), unit*system.interpolated(1,:),'g');
        legend('Actual','Predicted', 'I/E Points', '#Rules');
        axes(handles.axes2);
        plot(1:1:size(TrainData,1), unit*system.interpolated(1,:),'g');
        plot(1:1:size(TrainData,1), system.ruleCountDiary(:,1),'m');
        legend('#Rules');
        clear workspace;
    case 7
        voldata = load('volatilitydata1.txt');  % is a column matrix with volatility data of all days
        
        vdata = [];
        
        for i = 1:(size(voldata,1) - 10)
            
            for j=0:9
                
                vdata(i,j+1) = voldata(j+i);
            end
            vdata(i,11) = voldata(10+i);
        end
        vdata %----vdata ready -- cook volumdata
        %load('citibank.mat');
        IND = 9;
        OUTD = 1;
        input = vdata(:,1:9);
        output = vdata(:,10);
        data = [input, output];
        dataSize = size(data,1);
        train_data = data;
        test_data = data;
        Epochs = 1;
        Eta = 0.05;
        Sigma0 = sqrt(0.16);
        forget = 0;
        Forgetfactor = 0.99;
        Lamda = 0.45;
        Rate = 0.25;
        Omega = 0.7;
        Gamma = 0.1;
        tau = 0.2;
        set(handles.IND, 'String',IND);
        set(handles.OUTD, 'String',OUTD);
        [net_out, system] = Run_SaFIN(2, train_data,test_data,IND,OUTD,Epochs,Eta,Sigma0,forget, Forgetfactor,Lamda,tau,Rate, Omega, Gamma);
        set(handles.rmse,'String',system.RMSE);
        set(handles.R,'String',system.R);
        set(handles.ruleNumber,'String',system.ruleCount);
        set(handles.numberIE,'String',system.interpolateCount);
        TestData = test_data;
        TrainData = train_data;
        axes(handles.axes);
        hold on
        max_output = max(TestData(:,IND+1));
        min_output = min(TestData(:,IND+1));
        unit = (max_output - min_output) / 5;
        plot(1:1:size(TestData,1),TestData(:,1+IND),'b');
        plot(1:1:size(TestData,1)-1,net_out(:,1),'r');
        plot(1:1:size(TrainData,1), unit*system.interpolated(1,:),'g');
        legend('Actual','Predicted', 'I/E Points', '#Rules');
        axes(handles.axes2);
        plot(1:1:size(TrainData,1), unit*system.interpolated(1,:),'g');
        plot(1:1:size(TrainData,1), system.ruleCountDiary(:,1),'m');
        legend('#Rules');
        
    case 8
        load('optiontrading')   %LOAD TRAIN_IN = 486*5, train_OUT = 486*1 => 486 days of volatility
        predictedvol = [];    %predicted volatility
        k = 1;      % signifies row no. of the  option dataset
        status = 0;    % 0 - neutral, 1 - long, -1 - short     %trading action
        tradeduration = 0;
        tradesignal = 0;
        R = 0;
        investment = 0;
        rstildeSum = 0;
        DR = 0;
        S = 0;
        numdays = 0;
        exitcon = 0;
        macdtplus1array = [];   %MACD T+1
        macdEmaplus1array = [];    %MACD EMA+1
        rsiarray = [];              %RSI
        dataset = [];
        rstildeArray = [];
        dataset = load('fulldataset1.txt'); %370 DAYS OF TRADING DAY
        %hsi index future
        test = train_IN;
        % train_OUT = train_IN(:,5);
        % train_IN = train_IN(:,1:4);
        % start_test = 488;
        % window = 120;
        %PREDICT THE VOLATILITY OF 485 DAYS
        IND = 4;
        OUTD = 1;
        Epochs = 1;
        Eta = 0.05;
        Sigma0 = sqrt(0.16);
        Forgetfactor = 0.99;
        Lamda = 0.3;
        Rate = 0.25;
        Omega = 0.7;
        Gamma = 0.1;
        forget = 1;
        tau = 0.2;
        set(handles.IND, 'String',IND);
        set(handles.OUTD, 'String',OUTD);
        [net_out, system] = Run_SaFIN(2, train_IN,test,IND,OUTD,Epochs,Eta,Sigma0,Forgetfactor, forget,Lamda, tau,Rate, Omega, Gamma);
        %DISPLAY PERFORMANCE MEASURE
        set(handles.rmse,'String',system.RMSE);
        set(handles.R,'String',system.R);
        set(handles.ruleNumber,'String',system.ruleCount);
        set(handles.numberIE,'String',system.interpolateCount);
        %%PLOT DATA ON THE GRAPH
        TestData = test;
        TrainData = train_IN;
        axes(handles.axes);
        hold on
        max_output = max(TestData(:,IND+1));
        min_output = min(TestData(:,IND+1));
        unit = (max_output - min_output) / 5;
        plot(1:1:size(TestData,1),TestData(:,1+IND),'b');
        plot(1:1:size(TestData,1)-1,net_out(:,1),'r');
        plot(1:1:size(TrainData,1), unit*system.interpolated(1,:),'g');
        legend('Actual','Predicted', 'I/E Points', '#Rules');
        axes(handles.axes2);
        plot(1:1:size(TrainData,1), unit*system.interpolated(1,:),'g');
        plot(1:1:size(TrainData,1), system.ruleCountDiary(:,1),'m');
        legend('#Rules');
        %GET THE VOLATILITY FROM DAY 111 to DAY 485 ACCORDING TO 375 DAYS OF TRADING
        net_out=net_out(111:485,1);
        
        for i=1:size(dataset,1)  %FOR EACH ROW IN OPTION DATA SET
            
            predicted = net_out(i);   %PREDICTED VOLATILITY OF THE DAY
            dataset(k,6) = net_out(i);  % ADD PREDICTED VOLATILITY TO 6TH-COLUMN IN DATASET
            predictedvol = [predictedvol;predicted];   %ADD PREDICTED VOLUMN TO IT
            
            if k>=35
                
                %-------------------------------Trading------------------------------------
                
                % at k = 35, trading begins, ieButton 1st trading day
                
                %-------------- check if last day of trading--------------
                
                
                if i == 859
                    
                    switch status
                        
                        case -1   %selling
                            
                            status = 0;
                            buyprice = dataset(k,5);
                            
                            
                            rs = (sellprice - buyprice);
                            
                            rstilde = rs/sellprice *100;
                            rstildeSum = rstildeSum + rstilde;
                            rstildeArray = [rstildeArray; rstilde];
                            DR = DR + rstilde/(tradeduration+1);
                            S = S + 1;
                            
                            R = R + rs;
                            
                            trade = ['neutral last day - buy ', num2str(dataset(k,1)), ' ', num2str(dataset(k,4)), ' ', num2str(buyprice)]
                            
                            rs
                            R
                            
                        case 1
                            
                            status = 0;
                            sellprice = dataset(k,5);
                            
                            rs = (sellprice - buyprice);
                            
                            rstilde = rs/buyprice *100;
                            rstildeSum = rstildeSum + rstilde;
                            rstildeArray = [rstildeArray; rstilde];
                            DR = DR + rstilde/(tradeduration+1);
                            S = S + 1;
                            
                            R = R + rs;
                            
                            trade = ['neutral last day - sell ', num2str(dataset(k,1)), ' ', num2str(dataset(k,4)), ' ', num2str(sellprice)]
                            
                            rs
                            R
                            
                            
                    end
                    
                else
                    
                    
                    
                    today = dataset(k,1);   % stores date of current trading day
                    
                    expiryday = dataset(k,3);   % stores date of expiry day
                    
                    
                    data = predictedvol(((k-35)+1):k); % passing the last 35 future volatility, including the one predicted today
                    
                    [macdvec, nineperma] = macd(data);
                    
                    macdtplus1 = macdvec(end);
                    macdEmaplus1 = nineperma(end);
                    rsi = rsindex(data);
                    
                    macdtplus1array = [macdtplus1array; macdtplus1];
                    macdEmaplus1array = [macdEmaplus1array; macdEmaplus1];
                    rsiarray = [rsiarray; rsi(end)];
                    rstildeArray = [];
                    
                    switch status
                        
                        case -1
                            
                            %--------exit condition
                            
                            if dataset(k,5) > sellprice
                                numdays = numdays + 1;
                                
                                if numdays == 5
                                    
                                    exitcon = 1;
                                    
                                end
                                
                            else
                                numdays = 0;
                                
                            end
                            
                            
                            if dataset(k,5) >= 1.1*sellprice || dataset(k,5) <= 0.9*sellprice
                                
                                exitcon = 1;
                                
                            end
                            
                            if exitcon == 1
                                
                                % close position
                                
                                
                                status = 0;
                                buyprice = dataset(k,5);
                                
                                rs = (sellprice - buyprice);
                                
                                rstilde = rs/sellprice *100;
                                rstildeSum = rstildeSum + rstilde;
                                rstildeArray = [rstildeArray; rstilde];
                                DR = DR + rstilde/(tradeduration+1);
                                S = S + 1;
                                
                                R = R + rs;
                                
                                trade = ['neutral - buy exitcon',  num2str(dataset(k,1)), ' ', num2str(dataset(k,4)), ' ', num2str(buyprice)]
                                
                                rs
                                R
                                
                                numdays = 0;
                                exitcon = 0;
                                
                                k = k+1;
                                
                                predicted
                                continue
                                
                            end
                            
                            %--------------------------------
                            
                            if macdtplus1 >= 1.2 * macdEmaplus1
                                tradesignal = 1;
                                
                            else
                                tradesignal = 0;
                                
                            end
                            
                            if rsi(end) < 8
                                tradesignal = 1;
                            end
                            
                            %-------------trading signal is generated for the day
                            
                            
                            switch tradesignal
                                
                                case 1
                                    
                                    status = 0;
                                    buyprice = dataset(k,5);
                                    
                                    
                                    rs = (sellprice - buyprice);
                                    
                                    rstilde = rs/sellprice *100;
                                    rstildeSum = rstildeSum + rstilde;
                                    rstildeArray = [rstildeArray; rstilde];
                                    DR = DR + rstilde/(tradeduration+1);
                                    S = S + 1;
                                    
                                    R = R + rs;
                                    
                                    trade = ['neutral - buy ', num2str(dataset(k,1)), ' ',  num2str(dataset(k,4)), ' ', num2str(buyprice)]
                                    
                                    rs
                                    R
                                    
                                case 0
                                    
                                    %check if straddle is expiring
                                    
                                    if expiryday - today == 1  %dataset(k,2) is TTM  ; means straddle is expiring
                                        buyprice = dataset(k,5);
                                        
                                        status = 0;
                                        
                                        rs = (sellprice - buyprice);
                                        
                                        rstilde = rs/sellprice *100;
                                        rstildeSum = rstildeSum + rstilde;
                                        rstildeArray = [rstildeArray, rstilde];
                                        DR = DR + rstilde/(tradeduration+1);
                                        S = S + 1;
                                        
                                        R = R + rs;
                                        
                                        trade = ['neutral - expiring buy ', num2str(dataset(k,1)), ' ', num2str(dataset(k,4)), ' ', num2str(buyprice)]
                                        
                                        rs
                                        R
                                        %else status will remain -1
                                        
                                    end
                                    
                                    
                            end
                            
                            %----------------------
                            
                        case 0
                            
                            numdays = 0;
                            
                            
                            if macdEmaplus1 > 0
                                
                                if macdtplus1 <= 0.8 * macdEmaplus1
                                    
                                    tradesignal = -1;
                                    
                                elseif macdtplus1 >= 1.2 * macdEmaplus1
                                    
                                    tradesignal = 1;
                                    
                                else
                                    tradesignal = 0;
                                    
                                end
                                
                                
                            elseif macdEmaplus1 < 0
                                
                                if macdtplus1 <= 1.2 * macdEmaplus1
                                    
                                    tradesignal = -1;
                                    
                                elseif macdtplus1 >= 0.8 * macdEmaplus1
                                    
                                    tradesignal = 1;
                                    
                                else
                                    tradesignal = 0;
                                    
                                end
                                
                                
                            elseif macdEmaplus1 == 0
                                
                                if macdtplus1 <= -0.2
                                    tradesignal = -1;
                                    
                                elseif macdtplus1 >= 0.2
                                    tradesignal = 1;
                                    
                                else
                                    tradesignal = 0;
                                    
                                end
                                
                                
                            end
                            
                            if rsi(end) > 80
                                tradesignal = 1;
                            elseif rsi(end) < 10
                                tradesignal = -1;
                            end
                            
                            %-------------------trading signal is generated for the day
                            
                            
                            switch tradesignal
                                
                                case 1
                                    
                                    status = 1;
                                    buyprice = dataset(k,5);
                                    
                                    trade = ['long ', num2str(dataset(k,1)), ' ', num2str(dataset(k,4)), ' ', num2str(buyprice)]
                                    
                                    begindate = dataset(k,1);
                                    tradeduration = 0;
                                    investment = investment + buyprice;
                                case -1
                                    
                                    status = -1;
                                    sellprice = dataset(k,5);
                                    
                                    trade = ['short ', num2str(dataset(k,1)), ' ', num2str(dataset(k,4)), ' ', num2str(sellprice)]
                                    
                                    begindate = dataset(k,1);
                                    tradeduration = 0;
                                    investment = investment + sellprice;
                                    %else status will remain 0
                            end
                            
                            %--------------------
                            
                        case 1
                            
                            %--------exit condition
                            
                            if dataset(k,5) < buyprice
                                numdays = numdays + 1;
                                
                                if numdays == 5    %consecutive 5 days
                                    
                                    exitcon = 1;
                                    
                                end
                                
                            else
                                numdays = 0;
                                
                            end
                            
                            
                            if dataset(k,5) <= 0.9*buyprice || dataset(k,5) >= 1.1*buyprice
                                
                                exitcon = 1;
                                
                            end
                            
                            if exitcon == 1
                                
                                % close position
                                status = 0;
                                sellprice = dataset(k,5);
                                
                                
                                rs = (sellprice - buyprice);
                                
                                rstilde = rs/buyprice *100;
                                rstildeSum = rstildeSum + rstilde;
                                rstildeArray = [rstildeArray; rstilde];
                                DR = DR + rstilde/(tradeduration+1);
                                S = S + 1;
                                
                                R = R + rs;
                                
                                trade = ['neutral - sell exitcon', num2str(dataset(k,1)), ' ', num2str(dataset(k,4)), ' ', num2str(sellprice)]
                                
                                rs
                                R
                                
                                numdays = 0;
                                exitcon = 0;
                                
                                k = k+1;
                                
                                predicted
                                continue
                                
                            end
                            
                            %--------------------------------
                            
                            if macdtplus1 <= 1.2 * macdEmaplus1
                                tradesignal = -1;
                                
                            else
                                tradesignal = 0;
                                
                            end
                            
                            if rsi(end) > 80
                                tradesignal = -1;
                            end
                            
                            %-----------------trading signal is generated for the day
                            
                            switch tradesignal
                                
                                case -1
                                    
                                    status = 0;
                                    sellprice = dataset(k,5);
                                    
                                    
                                    rs = (sellprice - buyprice);
                                    
                                    rstilde = rs/buyprice *100;
                                    rstildeSum = rstildeSum + rstilde;
                                    rstildeArray = [rstildeArray; rstilde];
                                    
                                    DR = DR + rstilde/(tradeduration+1);
                                    S = S + 1;
                                    
                                    R = R + rs;
                                    
                                    trade = ['neutral - sell ', num2str(dataset(k,1)), ' ', num2str(dataset(k,4)), ' ', num2str(sellprice)]
                                    
                                    rs
                                    R
                                    
                                case 0
                                    
                                    %check if straddle is expiring
                                    
                                    if expiryday - today == 1   %dataset(k,2) is TTM  ; means straddle is expiring
                                        sellprice = dataset(k,5);
                                        
                                        status = 0;
                                        
                                        rs = (sellprice - buyprice);
                                        
                                        rstilde = rs/buyprice *100;
                                        rstildeSum = rstildeSum + rstilde;
                                        
                                        rstildeArray = [rstildeArray; rstilde];
                                        
                                        DR = DR + rstilde/(tradeduration+1);
                                        S = S + 1;
                                        
                                        R = R + rs;
                                        
                                        trade = ['neutral expiry - sell ', num2str(dataset(k,1)), ' ', num2str(dataset(k,4)), ' ', num2str(sellprice)]
                                        
                                        rs
                                        R
                                        
                                        %else status will remain 1
                                        
                                    end
                                    
                                    
                            end
                            
                            
                    end
                    
                    
                    
                    
                    
                    %----------------------------end of daily trading algo-------------------
                end
                
            end
            
            
            k = k+1;
            
            tradeduration = tradeduration + 1;
            
            predicted
            
            
        end
        
        
        S
        Raverage = rstildeSum/S;
        
        Roverall = (R/investment) * 100;
        
        DR = DR/S;
        ot.DR=DR;
        ot.net_out=net_out;
        ot.Raverage=Raverage;
        ot.Roverall=Roverall;
        handles.raverage.Value = Raverage;
        set(handles.raverage,'String',Raverage);
        handles.roverall.Value = Roverall;
        set(handles.roverall,'String',Roverall);
        handles.dailyreturn.Value = DR;
        set(handles.dailyreturn,'String',DR);
        
end

function rmse_Callback(hObject, eventdata, handles)
% hObject    handle to rmse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rmse as text
%        str2double(get(hObject,'String')) returns contents of rmse as a double


% --- Executes during object creation, after setting all properties.
function rmse_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rmse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function R_Callback(hObject, eventdata, handles)
% hObject    handle to R (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of R as text
%        str2double(get(hObject,'String')) returns contents of R as a double


% --- Executes during object creation, after setting all properties.
function R_CreateFcn(hObject, eventdata, handles)
% hObject    handle to R (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ruleNumber_Callback(hObject, eventdata, handles)
% hObject    handle to ruleNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ruleNumber as text
%        str2double(get(hObject,'String')) returns contents of ruleNumber as a double


% --- Executes during object creation, after setting all properties.
function ruleNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ruleNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function raverage_Callback(hObject, eventdata, handles)
% hObject    handle to raverage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of raverage as text
%        str2double(get(hObject,'String')) returns contents of raverage as a double


% --- Executes during object creation, after setting all properties.
function raverage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to raverage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function roverall_Callback(hObject, eventdata, handles)
% hObject    handle to roverall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of roverall as text
%        str2double(get(hObject,'String')) returns contents of roverall as a double


% --- Executes during object creation, after setting all properties.
function roverall_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roverall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dailyreturn_Callback(hObject, eventdata, handles)
% hObject    handle to dailyreturn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dailyreturn as text
%        str2double(get(hObject,'String')) returns contents of dailyreturn as a double


% --- Executes during object creation, after setting all properties.
function dailyreturn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dailyreturn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function alpha_Callback(hObject, eventdata, handles)
% hObject    handle to alpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
alpha = str2double(get(handles.alpha, 'String'));
disp(alpha);
handles.alpha = alpha;
% Hints: get(hObject,'String') returns contents of alpha as text
%        str2double(get(hObject,'String')) returns contents of alpha as a double


% --- Executes during object creation, after setting all properties.
function alpha_CreateFcn(hObject, eventdata, handles)
% hObject    handle to alpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function beta_Callback(hObject, eventdata, handles)
beta = str2double(get(handles.beta, 'String'));
handles.beta = beta;
disp(beta);
% hObject    handle to beta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of beta as text
%        str2double(get(hObject,'String')) returns contents of beta as a double


% --- Executes during object creation, after setting all properties.
function beta_CreateFcn(hObject, eventdata, handles)
% hObject    handle to beta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function eta_Callback(hObject, eventdata, handles)
eta = str2double(get(handles.edit, 'String'));
handles.eta = eta;
disp(eta);
% hObject    handle to eta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eta as text
%        str2double(get(hObject,'String')) returns contents of eta as a double


% --- Executes during object creation, after setting all properties.
function eta_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ff_Callback(hObject, eventdata, handles)
% hObject    handle to ff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ff = str2double(get(handles.beta, 'String'));
handles.ff = ff;
disp(ff);

% Hints: get(hObject,'String') returns contents of ff as text
%        str2double(get(hObject,'String')) returns contents of ff as a double


% --- Executes during object creation, after setting all properties.
function ff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lamda_Callback(hObject, eventdata, handles)
% hObject    handle to lamda (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lamda as text
%        str2double(get(hObject,'String')) returns contents of lamda as a double
lamda = str2double(get(handles.lamda, 'String'));
handles.lamda = lamda;
disp(lamda);

% --- Executes during object creation, after setting all properties.
function lamda_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lamda (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rate_Callback(hObject, eventdata, handles)
% hObject    handle to rate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rate as text
%        str2double(get(hObject,'String')) returns contents of rate as a double
rate = str2double(get(handles.rate, 'String'));
handles.rate = rate;
disp(rate);

% --- Executes during object creation, after setting all properties.
function rate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function omega_Callback(hObject, eventdata, handles)
% hObject    handle to omega (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of omega as text
%        str2double(get(hObject,'String')) returns contents of omega as a double
omega = str2double(get(handles.omega, 'String'));
handles.omega = omega;
disp(omega);

% --- Executes during object creation, after setting all properties.
function omega_CreateFcn(hObject, eventdata, handles)
% hObject    handle to omega (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gamma_Callback(hObject, eventdata, handles)
% hObject    handle to gamma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gamma as text
%        str2double(get(hObject,'String')) returns contents of gamma as a double
gamma = str2double(get(handles.gamma, 'String'));
handles.gamma = gamma;
disp(gamma);

% --- Executes during object creation, after setting all properties.
function gamma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gamma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in configButton.
function configButton_Callback(hObject, eventdata, handles)
alpha = 0.25;
beta = 0.65;
epoch = 1;
eta = 0.05;
sigma0 = sqrt(0.16);
ff = 0.99;
lamda = 0.3;
rate = 0.25;
omega = 0.7;
gamma = 0.1;
forget = 1;
tau = 0.2;
decay = 1;
episodic = 1;
ie = 1;
iepp = 1;
reinforcement = 1;
set(handles.alpha,'String',alpha);
set(handles.beta,'String',beta);
set(handles.eta,'String',eta);
set(handles.ff,'String',ff);
set(handles.lamda,'String',lamda);
set(handles.rate,'String',rate);
set(handles.omega,'String',omega);
set(handles.gamma,'String',gamma);
set(handles.epoch,'String',epoch);
set(handles.tau,'String',tau);
set(handles.sigma0,'String',sigma0);
handles.alpha = 0.25;
handles.beta  = 0.65;
handles.epoch = 1;
handles.eta = 0.05;
handles.sigma0 = sqrt(0.16);
handles.ff = 0.99;
handles.lamda = 0.3;
handles.rate = 0.25;
handles.omega = 0.7;
handles.gamma = 0.1;
handles.forget = 1;
handles.tau = 0.2;
handles.decay = 1;
handles.episodic = 1;
handles.ie = 1;
handles.iepp = 1;
handles.reinforcement = 1;

% hObject    handle to configButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function IND_Callback(hObject, eventdata, handles)
handles.IND = str2double(get(hObject, 'String'));
% hObject    handle to IND (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of IND as text
%        str2double(get(hObject,'String')) returns contents of IND as a double


% --- Executes during object creation, after setting all properties.
function IND_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IND (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function OUTD_Callback(hObject, eventdata, handles)
handles.OUTD = str2double(get(hObject, 'String'));
% hObject    handle to OUTD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of OUTD as text
%        str2double(get(hObject,'String')) returns contents of OUTD as a double


% --- Executes during object creation, after setting all properties.
function OUTD_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OUTD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object deletion, before destroying properties.
function beta_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to beta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function epoch_Callback(hObject, eventdata, handles)
% hObject    handle to epoch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of epoch as text
%        str2double(get(hObject,'String')) returns contents of epoch as a double
epoch = str2double(get(handles.beta, 'String'));
handles.epoch = epoch;
disp(epoch);

% --- Executes during object creation, after setting all properties.
function epoch_CreateFcn(hObject, eventdata, handles)
% hObject    handle to epoch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tau_Callback(hObject, eventdata, handles)
% hObject    handle to tau (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tau as text
%        str2double(get(hObject,'String')) returns contents of tau as a double
tau = str2double(get(handles.beta, 'String'));
handles.tau = tau;
disp(tau);

% --- Executes during object creation, after setting all properties.
function tau_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tau (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function testinglink_Callback(hObject, eventdata, handles)
% hObject    handle to testinglink (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of testinglink as text
%        str2double(get(hObject,'String')) returns contents of testinglink as a double


% --- Executes during object creation, after setting all properties.
function testinglink_CreateFcn(hObject, eventdata, handles)
% hObject    handle to testinglink (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sigma0_Callback(hObject, eventdata, handles)
sigma0 = str2double(get(handles.sigma0, 'String'));
handles.sigma0 = sigma0;
disp(sigma0);
% hObject    handle to sigma0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sigma0 as text
%        str2double(get(hObject,'String')) returns contents of sigma0 as a double


% --- Executes during object creation, after setting all properties.
function sigma0_CreateFcn(hObject, eventdata, handles)

% hObject    handle to sigma0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in runMode.
function runMode_Callback(hObject, eventdata, handles)
% hObject    handle to runMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns runMode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from runMode
items = get(hObject, 'String');
index_selected = get(hObject, 'Value')
runMode = index_selected
handles.runMode = runMode;

% --- Executes during object creation, after setting all properties.
function runMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to runMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function numberIE_Callback(hObject, eventdata, handles)
% hObject    handle to numberIE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numberIE as text
%        str2double(get(hObject,'String')) returns contents of numberIE as a double


% --- Executes during object creation, after setting all properties.
function numberIE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numberIE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function axes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes


% --- Executes during object creation, after setting all properties.
function uibuttongroup1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uibuttongroup1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in decayButton.
function decayButton_Callback(hObject, eventdata, handles)
button_state = get(hObject, 'Value');
if button_state == get(hObject,'Max')
    display('Decay On');
    handles.decay = 1;
elseif button_state == get(hObject,'Min')
    display('Decay Off');
    handles.decay = 0;
end
% hObject    handle to decayButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of decayButton


% --- Executes on button press in episodicButton.
function episodicButton_Callback(hObject, eventdata, handles)
button_state = get(hObject, 'Value');
if button_state == get(hObject,'Max')
    display('Episodic On');
    handles.episodicButton = 1;
elseif button_state == get(hObject,'Min')
    display('Episodic Off');
    handles.episodicButton = 0;
end
% hObject    handle to episodicButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of episodicButton


% --- Executes on button press in ieppButton.
function ieppButton_Callback(hObject, eventdata, handles)
button_state = get(hObject, 'Value');
if button_state == get(hObject,'Max')
    display('I/E Post-Processing On');
    handles.iepp = 1;
elseif button_state == get(hObject,'Min')
    display('I/E Post-Processing Off');
    handles.iepp = 0;
end
% hObject    handle to ieppButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ieppButton


% --- Executes on button press in reinforcementButton.
function reinforcementButton_Callback(hObject, eventdata, handles)
button_state = get(hObject, 'Value');
if button_state == get(hObject,'Max')
    display('Reinforcement On');
    handles.reinforcement = 1;
elseif button_state == get(hObject,'Min')
    display('Reinforcement Off');
    handles.reinforcement = 0;
end
% hObject    handle to reinforcementButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of reinforcementButton


% --- Executes on button press in iepp.
function iepp_Callback(hObject, eventdata, handles)
% hObject    handle to iepp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of iepp
button_state = get(hObject, 'Value');
if button_state == get(hObject,'Max')
    display('I/E PP On');
    handles.iepp = 1;
elseif button_state == get(hObject,'Min')
    display('I/E PP Off');
    handles.iepp = 0;
end
