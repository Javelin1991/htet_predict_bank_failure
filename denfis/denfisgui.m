%
%  Dynamic Evolving Neural Fuzzy Inference System: DENFIS GUI
%=================================================================
%=  Function Name:       denfisgui.m                             =
%=  Algorithm Designer:  Qun Song                                =
%=  Program Developer:   Qun Song                                =
%=  Date:                October, 2001                           =
%=================================================================
%
% Press the DataParameters button on the bottom or File, 
% Parameters or Visualization on the top, a parameter window 
% will open. Enter the data file name(s) and parameters or 
% using the defaults and select the plotting mode(s), then 
% press Apply or OK button. The data set should have the 
% structure the same as the data set used in DENFIS function. 
% Click Start button on the main window to start the training,
% and all of information and results can be displayed 
% dynamically in both numeric and graphic.

%--------------------------------------------------------------------------------
%  denfisgui
%--------------------------------------------------------------------------------
  function denfisgui(varargin)
 
     if length(varargin) < 1
        denfisgui1_f0;
        return;
     end
      FuncName = varargin{1};
     
     [MHandle,NumFig1] = denfisgui_gethandle('DENFIS GUI,   ECOS Toolbox');         
     [PHandle,NumFig2] = denfisgui_gethandle('DENFIS Parameter Panel');
     if NumFig1 < 1
        close(NumFig2);
        return
     end
    
     switch FuncName   
        case 'CLOSE' 
              denfisgui_close;
        case 'CLEAR' 
              denfisgui_clear(MHandle);
        case 'PAUSE' 
              denfisgui_pause(MHandle);
        case 'STOP' 
              denfisgui_stop(MHandle,NumFig2,PHandle);
        case 'START' 
              denfisgui_start(NumFig1,MHandle,NumFig2,PHandle);
        case 'DataParameters'
              denfisgui_parm(NumFig1,MHandle,NumFig2,PHandle);
        case 'Cancel'
              denfisgui_parmcancel(MHandle,NumFig2,PHandle);      
        case 'Clearparm'
              denfisgui_parmclear(PHandle);
        case 'Apply'
              denfisgui_parmapply(NumFig1,MHandle,NumFig2,PHandle);                 
        case 'OK'
              denfisgui_parmapply(NumFig1,MHandle,NumFig2,PHandle); 
              close;
        case 'Demo'
              denfisgui_demo(NumFig1,MHandle,NumFig2,PHandle);
        case 'SamplesName'
              denfisgui_files(FuncName,PHandle);
        case 'InputName'
              denfisgui_files(FuncName,PHandle);
        case 'OutputName'
              denfisgui_files(FuncName,PHandle);
        case 'ABOUT'
              denfisgui_about;
     end    
     
  return;   
%--------------------------------------------------------------------------------
%  denfisgui end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui1_f0
%--------------------------------------------------------------------------------
  function denfisgui1_f0

     % make sure that the DENFIS GUI has not been created already   
     FigName = 'DENFIS GUI,   ECOS Toolbox';  
     [MHandle,NumFig] = denfisgui_gethandle(FigName);
     if NumFig > 0
        figure(NumFig);
        return;
     end   

     h_DenfisGui1F = figure('position',[350 200 480 220],...
                            'numbertitle', 'Off',...
                            'BackingStore','Off',...
                            'resize','On',...
                            'MenuBar','None',...
                            'Name',FigName);

     DG1Handles   = [];
     % create top level menues
     [DG1Handles] = denfisgui1_f1(h_DenfisGui1F, DG1Handles);
     % create frames
     [DG1Handles] = denfisgui1_f2(h_DenfisGui1F, DG1Handles);
     % create toggle buttons and create static text for data info
     [DG1Handles] = denfisgui1_f3(h_DenfisGui1F, DG1Handles);
     % create static text for  implement and training
     [DG1Handles] = denfisgui1_f4(h_DenfisGui1F, DG1Handles);
     % create static text for evaluating with training data
     [DG1Handles] = denfisgui1_f5(h_DenfisGui1F, DG1Handles);
     % Initialize the parameters
     [DG1Handles] = denfisgui1_iniparm(h_DenfisGui1F, DG1Handles);
     
     set(h_DenfisGui1F, 'userdata',DG1Handles);      
  return;   
%--------------------------------------------------------------------------------
%  denfisgui1_f0 end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui1_f1:  create and initialize top level menus
%--------------------------------------------------------------------------------
  function [DG1Handles] = denfisgui1_f1(h_DenfisGui1F, DG1Handles) 
 
     h_menu_file       = uimenu(h_DenfisGui1F,...
                                'Label','File',...
                                'CallBack','denfisgui(''DataParameters'')');
     h_menu_parm       = uimenu(h_DenfisGui1F,...
                                'Label','Parameters',...
                                'CallBack','denfisgui(''DataParameters'')');
     h_menu_visual     = uimenu(h_DenfisGui1F,...
                                'Label','Visualization',...
                                'CallBack','denfisgui(''DataParameters'')');
     h_menu_help       = uimenu(h_DenfisGui1F,'Label','Help');

     h_menu_denfishelp = uimenu(h_menu_help,...
                                'Label','DENFIS Help',...
                                'CallBack','helpwin denfisgui;');
     h_menu_about      = uimenu(h_menu_help,...
                                'Label','About DENFIS',...
                                'CallBack','denfisgui(''ABOUT'')');

  return; 
%--------------------------------------------------------------------------------
%  denfisgui1_f1 end
%--------------------------------------------------------------------------------
   
%--------------------------------------------------------------------------------
%  denfisgui1_f2:  create the frames
%--------------------------------------------------------------------------------
  function [DG1Handles] = denfisgui1_f2(h_DenfisGui1F, DG1Handles)

     FramePosi{1}  = [0.01 0.57 0.32 0.26];
     FramePosi{2}  = [0.01 0.17 0.32 0.32];
     FramePosi{3}  = [0.34 0.17 0.32 0.66];
     FramePosi{4}  = [0.67 0.17 0.32 0.66];
     
     FrameTitle{1} = 'Process Information';
     FrameTitle{2} = 'Data Information';
     FrameTitle{3} = 'Training Information';
     FrameTitle{4} = 'Evaluating Information';
   
     FT_Posi{1}    = [0.07 0.80 0.22 0.07];
     FT_Posi{2}    = [0.07 0.46 0.22 0.07];
     FT_Posi{3}    = [0.39 0.80 0.22 0.07];
     FT_Posi{4}    = [0.71 0.80 0.24 0.07];
    
     for i = 1:4
         Frames = uicontrol(h_DenfisGui1F,...
                            'Style','Frame',...
                            'Units','normalized',...
                            'Position',FramePosi{i});
         FTitle = uicontrol(h_DenfisGui1F,...
                            'Style','Text',...
                            'Units','normalized',...
                            'Position',FT_Posi{i},...
                            'HorizontalAlignment','Center',...
                            'string',FrameTitle{i});
     end
     
     Frames = uicontrol(h_DenfisGui1F,...
                        'Style','Frame',...
                        'Units','normalized',...
                        'Position',[0.01 0.01 0.98 0.14]);
     Title0 = 'Dynamic Evolving Neural Fuzzy Inference System: DENFIS';               
     FTitle = uicontrol(h_DenfisGui1F,...
                            'Style','Text',...
                            'Units','normalized',...
                            'Position',[0.06 0.90 0.89 0.08],...
                            'FontSize',10,...
                            'ForegroundColor',[0 0 1],...
                            'FontWeight','Demi',... 
                            'HorizontalAlignment','Center',...
                            'string',Title0);                
  return; 
%--------------------------------------------------------------------------------
%  denfisgui1_f2 end
%--------------------------------------------------------------------------------
   
%--------------------------------------------------------------------------------
%  demfisgui1_f3: create and initialize Buttons and Data info
%--------------------------------------------------------------------------------
  function [DG1Handles] = denfisgui1_f3(h_DenfisGui1F, DG1Handles)

     TButtons{1}    = 'DataParameters';
     TButtons{2}    = 'CLOSE';
     TButtons{3}    = 'CLEAR';
     TButtons{4}    = 'PAUSE';
     TButtons{5}    = 'STOP';
     TButtons{6}    = 'START';
     ButtonType{1}  = 'PushButton';
     ButtonType{2}  = 'PushButton';
     ButtonType{3}  = 'PushButton';
     ButtonType{4}  = 'PushButton';
     ButtonType{5}  = 'ToggleButton';
     ButtonType{6}  = 'ToggleButton';
     TBCallBack{1}  = 'denfisgui(''DataParameters'')';
     TBCallBack{2}  = 'denfisgui(''CLOSE'')';
     TBCallBack{3}  = 'denfisgui(''CLEAR'')';
     TBCallBack{4}  = 'denfisgui(''PAUSE'')';
     TBCallBack{5}  = 'denfisgui(''STOP'')';
     TBCallBack{6}  = 'denfisgui(''START'')';
     for i = 1:6     
         h_TButtons{i} = uicontrol(h_DenfisGui1F,...
                                 'Style',ButtonType{i},...
                                 'Units','normalized',...
                                 'Position',[i*0.14+0.02 0.03 0.11 0.09],...
                                 'HorizontalAlignment','center',...
                                 'String',TButtons{i},...
                                 'Value',0,...
                                 'CallBack',TBCallBack{i},...
                                 'Interruptible','On'); 
         eval(['DG1Handles.' TButtons{i} ' = h_TButtons{i};']); 
     end
     set(DG1Handles.DataParameters,'Position',[0.03 0.03 0.24 0.09]);
     
     DataInfo{1}   = 'NumSamples';
     DataInfo{2}   = 'NumInputElems';
     DataInfo{3}   = 'NumOutputElems'; 
     
     for i = 1:3
         DI_Text = uicontrol(h_DenfisGui1F,...
                             'Style','Text',...
                             'Units','normalized',...
                             'Position',[0.02 0.47-i*0.09 0.18 0.07],...
                             'HorizontalAlignment','Left',...
                             'string',DataInfo{i});
         h_DataInfo{i} = uicontrol(h_DenfisGui1F,...
                                   'Style','Text',...
                                   'Units','normalized',...
                                   'Position',[0.21 0.47-i*0.09 0.10 0.07],...
                                   'BackGroundColor',[0.8 0.8 0.8],...
                                   'HorizontalAlignment','Right');
         eval(['DG1Handles.' DataInfo{i} ' = h_DataInfo{i};']);                         
      end     
  return;                  
%--------------------------------------------------------------------------------
%  denfisgui1_f3 end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui1_f4:  create and initialize statictext objects for implement info
%                  and training info
%--------------------------------------------------------------------------------
  function [DG1Handles] = denfisgui1_f4(h_DenfisGui1F, DG1Handles) 
  
      ImpInfo{1} = 'ImplementInfo1';
      ImpInfo{2} = 'ImplementInfo2';
      for i = 1:2
          h_ImpInfo{i} = uicontrol(h_DenfisGui1F,...
                                   'Style','Text',...
                                   'Units','normalized',...
                                   'Position',[0.02 0.79-i*0.09 0.30 0.07],...
                                   'BackGroundColor',[0.8 0.8 0.8],...
                                   'HorizontalAlignment','Center');
          eval(['DG1Handles.' ImpInfo{i} ' = h_ImpInfo{i};']);                         
      end    
  
      TrainInfo{1} = 'NumRules';
      TrainInfo{2} = 'NumClusters';
      TrainInfo{3} = 'TraSamples';
      TrainInfo{4} = 'ECMEpochs';
      TrainInfo{5} = 'Objective';
      TrainInfo{6} = 'MaxDistance';
      TrainInfo{7} = 'CpuTime';   
      for i = 1:7
          TrainText = uicontrol(h_DenfisGui1F,...
                                   'Style','Text',...
                                   'Units','normalized',...
                                   'Position',[0.355 0.79-i*0.085 0.14 0.07],...
                                   'HorizontalAlignment','Left',...
                                   'string',TrainInfo{i});
          h_TrainInfo{i} = uicontrol(h_DenfisGui1F,...
                                   'Style','Text',...
                                   'Units','normalized',...
                                   'Position',[0.50 0.79-i*0.085 0.135 0.07],...
                                   'BackGroundColor',[0.8 0.8 0.8],...
                                   'HorizontalAlignment','Right');
 
          eval(['DG1Handles.' TrainInfo{i} ' = h_TrainInfo{i};']);                         
      end    

  return; 
%--------------------------------------------------------------------------------
%  denfisgui1_f4 end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui1_f5: create statictext objects for evaluation with training data
%--------------------------------------------------------------------------------
  function [DG1Handles] = denfisgui1_f5(h_DenfisGui1F, DG1Handles) 

      EvalInfo{1} = 'EvalSamples';
      EvalInfo{2} = 'AbsError';
      EvalInfo{3} = 'PMaxError';
      EvalInfo{4} = 'NMaxError';
      EvalInfo{5} = 'RMSE';
      EvalInfo{6} = 'NDEI';
      for i = 1:6
          EvalText = uicontrol(h_DenfisGui1F,...
                               'Style','Text',...
                               'Units','normalized',...
                               'Position',[0.685 0.78-i*0.095 0.14 0.07],...
                               'HorizontalAlignment','Left',...
                               'string',EvalInfo{i});
          h_EvalInfo{i} = uicontrol(h_DenfisGui1F,...
                                    'Style','Text',...
                                    'Units','normalized',...
                                    'Position',[0.83 0.78-i*0.095 0.135 0.07],...
                                    'BackGroundColor',[0.8 0.8 0.8],...
                                    'HorizontalAlignment','Right');
          eval(['DG1Handles.' EvalInfo{i} ' = h_EvalInfo{i};']);                         
      end    

  return; 
%--------------------------------------------------------------------------------
%  denfisgui1_f5 end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui1_iniparm 
%--------------------------------------------------------------------------------
  function [DG1Handles] = denfisgui1_iniparm(h_DenfisGui1F, DG1Handles) 
  
     SParm = [];
     SParm.Module                = 1;
     SParm.TrainMode             = 1;
     SParm.SamplesName           = '';
     SParm.InputName             = '';
     SParm.OutputName            = '';
     SParm.Partition             = 0;
     SParm.Evaluation            = 0;
     SParm.NumClusters           = 0;
     SParm.Optimization          = 0;
     SParm.AbsoluteError         = 0;
     SParm.RMSE                  = 0;
     SParm.NDEI                  = 0;
     SParm.DistanceThreshold     = 0.1;
     SParm.MofN                  = 3;
     SParm.ECMEpochs             = 0;
     SParm.MLPEpochs             = 10;
     SParm.XData                 = 1;
     SParm.YData                 = 2;
 
     DG1Handles.SParm = SParm;
  return; 
%--------------------------------------------------------------------------------
%  denfisgui1_iniparm end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_gethandle
%--------------------------------------------------------------------------------
  function [FHandle,NumFig] = denfisgui_gethandle(FigName)
 
     FHandle = [];
     NumFig  = 0;
    
     HFigs     = get(0,'Children');
     for fig = HFigs'
         if strcmp(get(fig,'Name'),FigName);
            NumFig  = fig; 
            set(0,'CurrentFigure',NumFig);
            FHandle = get(gcf,'UserData');
            return;
         end
     end  
     
  return;   
%--------------------------------------------------------------------------------
%  denfisgui_gethandle end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_parm: Create parameter-panel
%--------------------------------------------------------------------------------
  function denfisgui_parm(NumFig1,MHandle,NumFig2,PHandle)
 
     % make sure that the DENFIS GUI has not been created already    
     if NumFig2 > 0
        figure(NumFig2);
        return;
     end   
            
     h_DenfisGui1_parmpanel = figure('position',[200 350 620 180],...
                                     'numbertitle', 'Off',...
                                     'BackingStore','Off',...
                                     'resize','On',...
                                     'MenuBar','None',...
                                     'Name','DENFIS Parameter Panel');
     DG2Handles   = [];
     % create frames
     [DG2Handles] = denfisgui1_parmf1(h_DenfisGui1_parmpanel, DG2Handles);
     % create Pop-upMenue objects for demo and default values
     [DG2Handles] = denfisgui1_parmf2(h_DenfisGui1_parmpanel, DG2Handles);
     % create EditText objects for data files
     [DG2Handles] = denfisgui1_parmf3(h_DenfisGui1_parmpanel, DG2Handles);
     % create CheckBox objects for visualization 
     [DG2Handles] = denfisgui1_parmf4(h_DenfisGui1_parmpanel, DG2Handles);
     % create Pop-upMenue and EditText objects for parameters
     [DG2Handles] = denfisgui1_parmf5(h_DenfisGui1_parmpanel, DG2Handles);
     % create EditText objects for option parameters
     [DG2Handles] = denfisgui1_parmf6(h_DenfisGui1_parmpanel, DG2Handles);
     % create PushButton objects for set parameters
     [DG2Handles] = denfisgui1_parmf7(h_DenfisGui1_parmpanel, DG2Handles);
          
     set(h_DenfisGui1_parmpanel, 'userdata',DG2Handles); 
    
     % Set the parameter values
     PHandle = get(h_DenfisGui1_parmpanel, 'userdata');
     denfisgui_parmcancel(MHandle,2,PHandle);

     if get(MHandle.START,'Value') == 1
        denfisgui_parmon('Off',2,PHandle);
     end

  return;   
%--------------------------------------------------------------------------------
%  denfisgui_parm end
%--------------------------------------------------------------------------------
   
%--------------------------------------------------------------------------------
%  denfisgui1_parmf1:  create the frames
%--------------------------------------------------------------------------------
  function [DG2Handles] = denfisgui1_parmf1(h_DenfisGui1_parmpanel, DG2Handles)
  
     FramePosi{1}  = [0.01 0.01 0.29 0.50];
     FramePosi{2}  = [0.31 0.01 0.16 0.91];
     FramePosi{3}  = [0.48 0.23 0.27 0.69];
     FramePosi{4}  = [0.76 0.23 0.23 0.69];
     FrameTitle{1} = 'Data Files';
     FrameTitle{2} = 'Visualization';
     FrameTitle{3} = 'Parameters';
     FrameTitle{4} = 'Option Parameters';
     
     FT_Posi{1}    = [0.10 0.48 0.10 0.07];
     FT_Posi{2}    = [0.33 0.89 0.12 0.07];
     FT_Posi{3}    = [0.55 0.89 0.12 0.07];
     FT_Posi{4}    = [0.785 0.89 0.17 0.07];
     
     for i = 1:4
         Frames = uicontrol(h_DenfisGui1_parmpanel,...
                            'Style','Frame',...
                            'Units','normalized',...
                            'Position',FramePosi{i});
         FTitle = uicontrol(h_DenfisGui1_parmpanel,...
                            'Style','Text',...
                            'Units','normalized',...
                            'Position',FT_Posi{i},...
                            'HorizontalAlignment','Center',...
                            'string',FrameTitle{i});
     end
     
     Frames = uicontrol(h_DenfisGui1_parmpanel,...
                        'Style','Frame',...
                        'Units','normalized',...
                        'Position',[0.48 0.01 0.51 0.19]);    
  return; 
%--------------------------------------------------------------------------------
%  denfisgui1_parmf1 end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui1_parmf2: create popmenus for default parameters and demonstration
%--------------------------------------------------------------------------------
  function [DG2Handles] = denfisgui1_parmf2(h_DenfisGui1_parmpanel, DG2Handles) 

      MenuName{1}     = 'Module';
      MenuName{2}     = 'TrainMode';
      MenuOption{1}   = 'DENFIS  TRAINING | DENFIS  SIMULATING';
      MenuOption{2}   = ['DENFIS ON-LINE TRAINING|'...
                         'DENFIS OFF-LINE TRAINING 1|'...
                         'DENFIS OFF-LINE TRAINING 2']; 
      for i = 1:2
          h_MenuName{i} = uicontrol(h_DenfisGui1_parmpanel,...
                                    'Style','Pop',...
                                    'Units','normalized',...
                                    'String',MenuOption{i},...
                                    'Position',[0.01 0.97-i*0.17 0.29 0.12],...
                                    'HorizontalAlignment','Left');
          eval(['DG2Handles.' MenuName{i} ' = h_MenuName{i};']);                         
      end    
   
      MenuOption3   = ['Demonstration and Defarlts|'...
                       'Demonstration 1|Demonstration 2'...
                       '|Default Parameters 1|Default Parameters 2'];    
      h_MenuName3 = uicontrol(h_DenfisGui1_parmpanel,...
                              'Style','Pop',...
                              'Units','normalized',...
                              'String',MenuOption3,...
                              'Position',[0.49 0.25 0.25 0.12],...
                              'CallBack','denfisgui(''Demo'')',...
                              'HorizontalAlignment','Left');
      DG2Handles.Demo = h_MenuName3;                         
          
  return; 
%--------------------------------------------------------------------------------
%  denfisgui1_parmf2 end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui1_parmf3: create popmenus editable text for data file
%--------------------------------------------------------------------------------
  function [DG2Handles] = denfisgui1_parmf3(h_DenfisGui1_parmpanel, DG2Handles) 
   
      DataName{1}     = 'SamplesName';
      DataName{2}     = 'InputName';
      DataName{3}     = 'OutputName';
      DataCallBack{1} = 'denfisgui(''SamplesName'')';
      DataCallBack{2} = 'denfisgui(''InputName'')';
      DataCallBack{3} = 'denfisgui(''OutputName'')';
      DataFile{1}     = 'SamplesFile';
      DataFile{2}     = 'InputFile';
      DataFile{3}     = 'OutputFile';
       
      for i = 1:3
          h_DataFile{i} = uicontrol(h_DenfisGui1_parmpanel,...
                                    'Style','PushButton',...
                                    'Units','normalized',...
                                    'Position',[0.02 0.47-i*0.14 0.12 0.11],...
                                    'HorizontalAlignment','Left',...
                                    'String',DataFile{i},...
                                    'CallBack',DataCallBack{i});
          eval(['DG2Handles.' DataFile{i} ' = h_DataFile{i};']);
          
          h_DataName{i} = uicontrol(h_DenfisGui1_parmpanel,...
                                    'Style','Edit',...
                                    'Units','normalized',...
                                    'Position',[0.15 0.47-i*0.14 0.14 0.11],...
                                    'BackGroundColor',[1 1 1],...
                                    'HorizontalAlignment','Left');
          eval(['DG2Handles.' DataName{i} ' = h_DataName{i};']);                         
      end    
  return; 
%--------------------------------------------------------------------------------
%  denfisgui1_parmf3 end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui1_parmf4: create checkbox for visualization
%--------------------------------------------------------------------------------
  function [DG2Handles] = denfisgui1_parmf4(h_DenfisGui1_parmpanel, DG2Handles) 

      CBoxName{1} = 'Partition';
      CBoxName{2} = 'Evaluation';
      CBoxName{3} = 'NumClusters';
      CBoxName{4} = 'Optimization';  
      CBoxName{5} = 'AbsoluteError';
      CBoxName{6} = 'RMSE';
      CBoxName{7} = 'NDEI';
             
      for i = 1:7
          h_CBoxName{i} = uicontrol(h_DenfisGui1_parmpanel,...
                                    'Style','CheckBox',...
                                    'Units','normalized',...
                                    'String',CBoxName{i},...
                                    'Position',[0.32 0.88-i*0.12 0.14 0.09],...
                                    'HorizontalAlignment','Left');
          eval(['DG2Handles.' CBoxName{i} ' = h_CBoxName{i};']);                         
      end    

  return; 
%--------------------------------------------------------------------------------
%  denfisgui1_parmf4 end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui1_parmf5: create editable text objects for parameters
%--------------------------------------------------------------------------------
  function [DG2Handles] = denfisgui1_parmf5(h_DenfisGui1_parmpanel, DG2Handles) 

     ParmName{1}   = 'DistanceThreshold';
     for i = 1:1           
         ParmTitle = uicontrol(h_DenfisGui1_parmpanel,...
                               'Style','Text',...
                               'Units','normalized',...
                               'Position',[0.49 0.88-i*0.12 0.15 0.08],...
                               'HorizontalAlignment','Left',...
                               'string',ParmName{i});
         h_ParmName{i} = uicontrol(h_DenfisGui1_parmpanel,...
                                   'Style','Edit',...
                                   'Units','normalized',...
                                   'Position',[0.65 0.86-i*0.12 0.09 0.1],...
                                   'BackGroundColor',[1 1 1],...
                                   'HorizontalAlignment','Left');
         eval(['DG2Handles.' ParmName{i} ' = h_ParmName{i};']);                         
     end    
  return; 
%--------------------------------------------------------------------------------
%  denfisgui1_parmf5 end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui1_parmf6: create editable text objects for  option parameters
%--------------------------------------------------------------------------------
  function [DG2Handles] = denfisgui1_parmf6(h_DenfisGui1_parmpanel, DG2Handles)
  
      ParmName{1} = 'MofN';
      ParmName{2} = 'ECMEpochs';
      ParmName{3} = 'MLPEpochs';
      ParmName{4} = 'XData';
      ParmName{5} = 'YData';
      for i = 1:5
          ParmTitle = uicontrol(h_DenfisGui1_parmpanel,...
                                'Style','Text',...
                                'Units','normalized',...
                                'Position',[0.77 0.87-i*0.12 0.10 0.08],...
                                'HorizontalAlignment','Left',...
                                'string',ParmName{i});
          h_ParmName{i} = uicontrol(h_DenfisGui1_parmpanel,...
                                    'Style','Edit',...
                                    'Units','normalized',...
                                    'Position',[0.88 0.87-i*0.12 0.1 0.1],...
                                    'BackGroundColor',[1 1 1],...
                                    'HorizontalAlignment','Left');
          eval(['DG2Handles.' ParmName{i} ' = h_ParmName{i};']);                         
      end    
  return; 
%--------------------------------------------------------------------------------
%  denfisgui1_parmf6 end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui1_parmf7: create bush buttons for commands
%--------------------------------------------------------------------------------
  function [DG2Handles] = denfisgui1_parmf7(h_DenfisGui1_parmpanel, DG2Handles) 
   
      PBName{1} = 'Cancel';
      PBName{2} = 'Clear';
      PBName{3} = 'Apply';
      PBName{4} = 'OK';
      PBCallBack{1} = 'denfisgui(''Cancel'')';
      PBCallBack{2} = 'denfisgui(''Clearparm'')';
      PBCallBack{3} = 'denfisgui(''Apply'')';
      PBCallBack{4} = 'denfisgui(''OK'')';
      
      for i = 1:4
          h_PBName{i} = uicontrol(h_DenfisGui1_parmpanel,...
                                  'Style','PushButton',...
                                  'Units','normalized',...
                                  'String',PBName{i},...
                                  'Position',[i*0.125+0.37 0.045 0.10 0.12],...
                                  'HorizontalAlignment','Center',...
                                  'CallBack',PBCallBack{i});
          eval(['DG2Handles.' PBName{i} ' = h_PBName{i};']);                         
      end    
  return; 
%--------------------------------------------------------------------------------
%  denfisgui1_parmf7 end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_close
%--------------------------------------------------------------------------------
  function denfisgui_close
           
     HFigs   = get(0,'Children');
     for fig = HFigs'
         if strcmp(get(fig,'Name'),'DENFIS Partition')|...
            strcmp(get(fig,'Name'),'DENFIS NumClusters')|...
            strcmp(get(fig,'Name'),'DENFIS Optimization')|...
            strcmp(get(fig,'Name'),'DENFIS Training Evaluation')|...
            strcmp(get(fig,'Name'),'DENFIS Training AbsoluteError')|...
            strcmp(get(fig,'Name'),'DENFIS Training RMSE')|...
            strcmp(get(fig,'Name'),'DENFIS Training NDEI')|...
            strcmp(get(fig,'Name'),'DENFIS Simulating Evaluation')|...
            strcmp(get(fig,'Name'),'DENFIS Simulating AbsoluteError')|...
            strcmp(get(fig,'Name'),'DENFIS Simulating RMSE')|...
            strcmp(get(fig,'Name'),'DENFIS Simulating NDEI')|...
            strcmp(get(fig,'Name'),'DENFIS Parameter Panel')|...
            strcmp(get(fig,'Name'),'DENFIS GUI,   ECOS Toolbox')
            close(fig); 
         end
     end             

  return; 
%--------------------------------------------------------------------------------
%  denfisgui_close end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_clear
%--------------------------------------------------------------------------------
  function denfisgui_clear(MHandle)
  
     % close all figure plottings
     HFigs     = get(0,'Children');
     for fig = HFigs'
         if strcmp(get(fig,'Name'),'DENFIS Partition')|...
            strcmp(get(fig,'Name'),'DENFIS NumClusters')|...
            strcmp(get(fig,'Name'),'DENFIS Optimization')|...
            strcmp(get(fig,'Name'),'DENFIS Training Evaluation')|...
            strcmp(get(fig,'Name'),'DENFIS Training AbsoluteError')|...
            strcmp(get(fig,'Name'),'DENFIS Training RMSE')|...
            strcmp(get(fig,'Name'),'DENFIS Training NDEI')|...
            strcmp(get(fig,'Name'),'DENFIS Simulating Evaluation')|...
            strcmp(get(fig,'Name'),'DENFIS Simulating AbsoluteError')|...
            strcmp(get(fig,'Name'),'DENFIS Simulating RMSE')|...
            strcmp(get(fig,'Name'),'DENFIS Simulating NDEI')
           
            close(fig); 
         end
     end  

     % clear all information displayings
     
     set(MHandle.STOP,'Enable','Off','Value',0);
     set(MHandle.PAUSE,'Enable','Off','Value',0);
     set(MHandle.ImplementInfo1,'String', '');
     set(MHandle.ImplementInfo2,'String', '');
     set(MHandle.NumInputElems,'String', '');
     set(MHandle.NumOutputElems,'String', '');
     set(MHandle.NumSamples,'String', '');
     set(MHandle.NumRules,'String', '');
     set(MHandle.NumClusters,'String', '');
     set(MHandle.TraSamples,'String', '');
     set(MHandle.ECMEpochs,'String', '');
     set(MHandle.Objective,'String', '');
     set(MHandle.MaxDistance,'String', '');
     set(MHandle.CpuTime,'String', '');
     set(MHandle.EvalSamples,'String', '');
     set(MHandle.AbsError,'String', '');
     set(MHandle.PMaxError,'String', '');
     set(MHandle.NMaxError,'String', '');
     set(MHandle.RMSE,'String', '');
     set(MHandle.NDEI,'String', '');
  return; 
%--------------------------------------------------------------------------------
%  denfisgui_clear end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_pause
%--------------------------------------------------------------------------------
  function denfisgui_pause(MHandle)
  
     if get(MHandle.START,'Value') == 0
        set(MHandle.PAUSE,'Value',0); 
        return;
     end
     waitforbuttonpress

  return; 
%--------------------------------------------------------------------------------
%  denfisgui_pause end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_stop
%--------------------------------------------------------------------------------   
  function denfisgui_stop(MHandle,NumFig2,PHandle);
  
     if get(MHandle.START,'Value') == 0
        set(MHandle.STOP,'Value',0); 
        return;
     end
    
     set(MHandle.PAUSE,'Enable','Off','Value',0);
     set(MHandle.START,'Enable','On','Value',0);
     set(MHandle.CLEAR,'Enable','On');
     set(MHandle.CLOSE,'Enable','On');
     drawnow
     
     denfisgui_parmon('On',NumFig2,PHandle);
 
  return;  
%--------------------------------------------------------------------------------
%  denfisgui_stop end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_files
%--------------------------------------------------------------------------------   
  function denfisgui_files(FileName,PHandle)
     
     if strcmp(FileName,'SamplesName');
        [InputFile] = uigetfile('*.txt');
     else
        [InputFile] = uigetfile('*.mat');
     end   
     if InputFile == 0
        return;
     end
     
     eval(['set(PHandle.' FileName  ',''String'',InputFile);']);  
   
     set(PHandle.Demo,'Value',1);
     
  return; 
%--------------------------------------------------------------------------------
%  denfisgui_files end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_parmcancel
%--------------------------------------------------------------------------------
  function denfisgui_parmcancel(MHandle,NumFig2,PHandle)
  
     SParm = MHandle.SParm;
     if NumFig2 > 0
        set(PHandle.Module,'Value',SParm.Module);
        set(PHandle.TrainMode,'Value',SParm.TrainMode);
        set(PHandle.SamplesName,'String',SParm.SamplesName);
        set(PHandle.InputName,'String',SParm.InputName);
        set(PHandle.OutputName,'String',SParm.OutputName);
        set(PHandle.Partition,'Value',SParm.Partition);
        set(PHandle.Evaluation,'Value',SParm.Evaluation);
        set(PHandle.NumClusters,'Value',SParm.NumClusters);
        set(PHandle.Optimization,'Value',SParm.Optimization);
        set(PHandle.AbsoluteError,'Value',SParm.AbsoluteError);
        set(PHandle.RMSE,'Value',SParm.RMSE);
        set(PHandle.NDEI,'Value',SParm.NDEI);      
        set(PHandle.DistanceThreshold,'String',...
            sprintf('%0.2f',SParm.DistanceThreshold));
        set(PHandle.MofN,'String',int2str(SParm.MofN));
        set(PHandle.ECMEpochs,'String',int2str(SParm.ECMEpochs));
        set(PHandle.MLPEpochs,'String',int2str(SParm.MLPEpochs)); 
        set(PHandle.XData,'String',int2str(SParm.XData));
        set(PHandle.YData,'String',int2str(SParm.YData));
        drawnow
    end
  return; 
%--------------------------------------------------------------------------------
%  denfisgui_parmcancel end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_parmclear
%--------------------------------------------------------------------------------
  function denfisgui_parmclear(PHandle)
 
     set(PHandle.Module,'Value',1);
     set(PHandle.TrainMode,'Value',1);
     set(PHandle.Demo,'Value',1);
     set(PHandle.SamplesName,'String','');
     set(PHandle.InputName,'String','');
     set(PHandle.OutputName,'String','');
     set(PHandle.Partition,'Value',0);
     set(PHandle.Evaluation,'Value',0);
     set(PHandle.NumClusters,'Value',0);
     set(PHandle.Optimization,'Value',0);
     set(PHandle.AbsoluteError,'Value',0);
     set(PHandle.RMSE,'Value',0);
     set(PHandle.NDEI,'Value',0);     
     set(PHandle.DistanceThreshold,'String','');
     set(PHandle.MofN,'String','');
     set(PHandle.ECMEpochs,'String','');
     set(PHandle.MLPEpochs,'String','');
     set(PHandle.XData,'String','');
     set(PHandle.YData,'String','');
    
  return; 
%--------------------------------------------------------------------------------
%  denfisgui_parmclear end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_parmapply
%--------------------------------------------------------------------------------
  function [MHandle] = denfisgui_parmapply(NumFig1,MHandle,NumFig2,PHandle)
  
     module                      = get(PHandle.Module,'Value');
     MHandle.SParm.Module        = module;
     MHandle.SParm.TrainMode     = get(PHandle.TrainMode,'Value');
     MHandle.SParm.SamplesName   = get(PHandle.SamplesName,'String');
     MHandle.SParm.InputName     = get(PHandle.InputName,'String');
     MHandle.SParm.OutputName    = get(PHandle.OutputName,'String');
     MHandle.SParm.Partition     = get(PHandle.Partition,'Value');
     MHandle.SParm.Evaluation    = get(PHandle.Evaluation,'Value');
     MHandle.SParm.NumClusters   = get(PHandle.NumClusters,'Value');
     MHandle.SParm.Optimization  = get(PHandle.Optimization,'Value');
     MHandle.SParm.AbsoluteError = get(PHandle.AbsoluteError,'Value');
     MHandle.SParm.RMSE          = get(PHandle.RMSE,'Value');
     MHandle.SParm.NDEI          = get(PHandle.NDEI,'Value');    
     
     if module < 2 
        % training module
        dthr = str2num(get(PHandle.DistanceThreshold,'String'));
        if length(dthr) > 0
           if dthr < 0.02;   dthr = 0.02;   end;
           if dthr > 0.4;    dthr = 0.4;    end; 
            MHandle.SParm.DistanceThreshold  = dthr; 
        end     
        mofn = str2num(get(PHandle.MofN,'String'));
        if length(mofn) > 0
           if mofn < 1;      mofn = 1;      end;
           if mofn > 10;     mofn = 10;     end;
            MHandle.SParm.MofN          = mofn; 
        end
        ecme = str2num(get(PHandle.ECMEpochs,'String'));
        if length(ecme) > 0
           if ecme < 0;      ecme = 0;      end;
           if ecme > 15;     ecme = 15;     end;
            MHandle.SParm.ECMEpochs     = ecme; 
        end
        mlpe = str2num(get(PHandle.MLPEpochs,'String'));
        if length(mlpe) > 0
           if mlpe < 3;      mlpe = 3;      end;
           if mlpe > 500;    mlpe = 500;    end;
            MHandle.SParm.MLPEpochs     = mlpe;
        end
        xdata = str2num(get(PHandle.XData,'String'));
        if length(xdata) > 0
           MHandle.SParm.XData = xdata; 
        end    
        ydata = str2num(get(PHandle.YData,'String'));
        if length(ydata) > 0
           MHandle.SParm.YData = ydata; 
        end
     else
        % simulating module   
        set(PHandle.Demo,'Value',1);
        set(PHandle.OutputName,'String','');  
        set(PHandle.DistanceThreshold,'String','');
        set(PHandle.MofN,'String','');
        set(PHandle.ECMEpochs,'String','');
        set(PHandle.MLPEpochs,'String','');
     end
     set(NumFig1,'Userdata',MHandle);
  return; 
%--------------------------------------------------------------------------------
%  denfisgui_parmapply end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_parmon end
%--------------------------------------------------------------------------------
  function denfisgui_parmon(Param,NumFig2,PHandle)

     if NumFig2 < 1
        return;
     end
     
     PState = 'On';
     if strcmp(Param,'Off')
        PState = 'Off';
     end   

        set(PHandle.Module,'Enable',PState);
        set(PHandle.TrainMode,'Enable',PState);
        set(PHandle.Demo,'Enable',PState);
        set(PHandle.SamplesFile,'Enable',PState);
        set(PHandle.InputFile,'Enable',PState);
        set(PHandle.OutputFile,'Enable',PState);
        set(PHandle.SamplesName,'Enable',PState);
        set(PHandle.InputName,'Enable',PState);
        set(PHandle.OutputName,'Enable',PState);
        set(PHandle.Partition,'Enable',PState);
        set(PHandle.Evaluation,'Enable',PState);
        set(PHandle.NumClusters,'Enable',PState);
        set(PHandle.Optimization,'Enable',PState);
        set(PHandle.AbsoluteError,'Enable',PState);
        set(PHandle.RMSE,'Enable',PState);
        set(PHandle.NDEI,'Enable',PState);
        set(PHandle.DistanceThreshold,'Enable',PState);
        set(PHandle.MofN,'Enable',PState);
        set(PHandle.ECMEpochs,'Enable',PState);
        set(PHandle.MLPEpochs,'Enable',PState);
        set(PHandle.XData,'Enable',PState);
        set(PHandle.YData,'Enable',PState);
        set(PHandle.Cancel,'Enable',PState);
        set(PHandle.Clear,'Enable',PState);
        set(PHandle.Apply,'Enable',PState);
        set(PHandle.OK,'Enable',PState); 
 
  return;  
%--------------------------------------------------------------------------------
%  denfisgui_parmon end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_demo
%--------------------------------------------------------------------------------
  function denfisgui_demo(NumFig1,MHandle,NumFig2,PHandle)

     NumDemo = get(PHandle.Demo,'Value');
     
     switch NumDemo
        case 2
             [MHandle] = denfisgui_demo2(NumFig1,MHandle);
        case 3
             [MHandle] = denfisgui_demo3(NumFig1,MHandle);
        case 4
             [MHandle] = denfisgui_default2(NumFig1,MHandle);
        case 5
             [MHandle] = denfisgui_default3(NumFig1,MHandle);
        otherwise
             return;
     end

     denfisgui_parmcancel(MHandle,NumFig2,PHandle);
  return; 
%--------------------------------------------------------------------------------
%  denfisgui1_demo end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_demo2
%--------------------------------------------------------------------------------
  function [MHandle] = denfisgui_demo2(NumFig1,MHandle)
  
     MHandle.SParm.Module             = 1;
     MHandle.SParm.TrainMode          = 1;
     MHandle.SParm.SamplesName        = 'gas2.txt';
     MHandle.SParm.InputName          = '';
     MHandle.SParm.OutputName         = 'outgas2.mat';
     MHandle.SParm.Partition          = 1;
     MHandle.SParm.Evaluation         = 1;
     MHandle.SParm.NumClusters        = 0;
     MHandle.SParm.Optimization       = 0;
     MHandle.SParm.AbsoluteError      = 0;
     MHandle.SParm.RMSE               = 0;
     MHandle.SParm.NDEI               = 0;
     MHandle.SParm.DistanceThreshold  = 0.1;
     MHandle.SParm.MofN               = 3;
     MHandle.SParm.ECMEpochs          = 0;
     MHandle.SParm.MLPEpochs          = 0;
     MHandle.SParm.XData              = 1;
     MHandle.SParm.YData              = 2;
     
     set(NumFig1,'Userdata',MHandle);
  return; 
%--------------------------------------------------------------------------------
%  denfisgui_demo2 end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_demo3
%--------------------------------------------------------------------------------
  function [MHandle] = denfisgui_demo3(NumFig1,MHandle)
  
     MHandle.SParm.Module             = 2;
     MHandle.SParm.TrainMode          = 1;
     MHandle.SParm.SamplesName        = 'gas3.txt';
     MHandle.SParm.InputName          = 'outgas2.mat';
     MHandle.SParm.OutputName         = '';
     MHandle.SParm.Partition          = 1;
     MHandle.SParm.Evaluation         = 1;
     MHandle.SParm.NumClusters        = 0;
     MHandle.SParm.Optimization       = 0;
     MHandle.SParm.AbsoluteError      = 0;
     MHandle.SParm.RMSE               = 0;
     MHandle.SParm.NDEI               = 0;
     MHandle.SParm.DistanceThreshold  = 0.06;
     MHandle.SParm.MofN               = 3;
     MHandle.SParm.ECMEpochs          = 0;
     MHandle.SParm.MLPEpochs          = 0;
     MHandle.SParm.XData              = 1;
     MHandle.SParm.YData              = 2;
     
     set(NumFig1,'Userdata',MHandle);
  
  return; 
%--------------------------------------------------------------------------------
%  denfisgui_demo3 end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_default2
%--------------------------------------------------------------------------------
  function [MHandle] = denfisgui_default2(NumFig1,MHandle)
  
     MHandle.SParm.Module             = 1;
     MHandle.SParm.TrainMode          = 1;
     MHandle.SParm.SamplesName        = '';
     MHandle.SParm.InputName          = '';
     MHandle.SParm.OutputName         = '';
     MHandle.SParm.Partition          = 1;
     MHandle.SParm.Evaluation         = 1;
     MHandle.SParm.NumClusters        = 0;
     MHandle.SParm.Optimization       = 0;
     MHandle.SParm.AbsoluteError      = 0;
     MHandle.SParm.RMSE               = 0;
     MHandle.SParm.NDEI               = 0;
     MHandle.SParm.DistanceThreshold  = 0.1;
     MHandle.SParm.MofN               = 3;
     MHandle.SParm.ECMEpochs          = 0;
     MHandle.SParm.MLPEpochs          = 0;
     MHandle.SParm.XData              = 1;
     MHandle.SParm.YData              = 2;
     
     set(NumFig1,'Userdata',MHandle);
  
  return; 
%--------------------------------------------------------------------------------
%  denfisgui_default2 end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_default3
%--------------------------------------------------------------------------------
  function [MHandle] = denfisgui_default3(NumFig1,MHandle)
  
     MHandle.SParm.Module             = 1;
     MHandle.SParm.TrainMode          = 1;
     MHandle.SParm.SamplesName        = '';
     MHandle.SParm.InputName          = '';
     MHandle.SParm.OutputName         = '';
     MHandle.SParm.Partition          = 1;
     MHandle.SParm.Evaluation         = 1;
     MHandle.SParm.NumClusters        = 0;
     MHandle.SParm.Optimization       = 0;
     MHandle.SParm.AbsoluteError      = 0;
     MHandle.SParm.RMSE               = 0;
     MHandle.SParm.NDEI               = 0;
     MHandle.SParm.DistanceThreshold  = 0.1;
     MHandle.SParm.MofN               = 3;
     MHandle.SParm.ECMEpochs          = 0;
     MHandle.SParm.MLPEpochs          = 0;
     MHandle.SParm.XData              = 1;
     MHandle.SParm.YData              = 2;
     
     set(NumFig1,'Userdata',MHandle);
  return; 
%--------------------------------------------------------------------------------
%  denfisgui_default3 end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_about
%--------------------------------------------------------------------------------
  function denfisgui_about
 
   % make sure that the figure has not been created already 
     FigName  = 'About  DENFIS'; 
     [MHandle,NumFig] = denfisgui_gethandle(FigName);
     if NumFig > 0
        figure(NumFig);
        return;
     end 
     
     h_DenfisAboutF = figure('position',[200 300 600 150],...
                             'numbertitle', 'Off',...
                             'BackingStore','Off',...
                             'Resize','Off',...
                             'MenuBar','None',...
                             'Color',[0 0.1 0.3],...
                             'Name',FigName);
     uicontrol(h_DenfisAboutF,'Style','PushButton',...
                              'Units','normalized',...
                              'String','OK',...
                              'CallBack','Close',...
                              'Position',[0.85 0.03 0.10 0.15]);
                          
     AboutText{1} = ['Dynamic Evolving Neural Fuzzy Inference System: '...
                     'DENFIS'];
     AboutText{2} = ['Copyright, 2000-2004, Department of Information '...
                     'Science, University of Otago'];    
     AboutPosi{1} = [0.02 0.50 0.95 0.30];
     AboutPosi{2} = [0.05 0.25 0.90 0.20];
     AboutSize{1} = 14;
     AboutSize{2} = 10;
     for i = 1:2
         Abouts = uicontrol(h_DenfisAboutF,...
                            'Style','Text',...
                            'Units','normalized',...
                            'Position',AboutPosi{i},...
                            'FontSize',AboutSize{i},...
                            'ForegroundColor',[1 1 0],...
                            'BackgroundColor',[0.0  0.1 0.3],...
                            'FontWeight','Demi',... 
                            'HorizontalAlignment','Center',...
                            'string',AboutText{i});                             
     end
  return;   
%--------------------------------------------------------------------------------
%  denfisgui_about
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_start
%--------------------------------------------------------------------------------   
  function denfisgui_start(NumFig1,MHandle,NumFig2,PHandle)

     if NumFig2 > 0
        fname     = get(PHandle.SamplesName,'String');
        [MHandle] = denfisgui_parmapply(NumFig1,MHandle,NumFig2,PHandle);
        module    = get(PHandle.Module,'Value');
     else
        fname  = MHandle.SParm.SamplesName;
        module = MHandle.SParm.Module;
     end   
     
     fidsamples = fopen(fname,'r'); 
     if fidsamples < 0 
        denfisgui_disp(MHandle,'ImplementInfo',''); 
        set(MHandle.START,'Value',0);
        return;
     end 
     fclose(fidsamples);
     data0 = load(fname);
     
     denfisgui_enable('Off',MHandle,NumFig2,PHandle); 
     if module == 1
        denfisgui_disp(MHandle,'ImplementInfo','DENFIS Training');  
        [DF] = denfisgui_ini(data0,MHandle);
     
        if DF.TrainMode > 1 
           denfisgui_disp(MHandle,'ImplementInfo',...
                           'DENFIS Off-line Training','First-Order TSK');  
           if DF.FuzzyType == 2
              denfisgui_disp(MHandle,'ImplementInfo',...
                              'DENFIS Off-line Training','High-Order TSK');  
           end    
           [DF] = denfisgui_offlinetrain(MHandle,DF); 
        else
           denfisgui_disp(MHandle,'ImplementInfo',...
                           'DENFIS On-line Training','First-Order TSK'); 
           [DF] = denfisgui_onlinetrain(MHandle,DF);   
        end  
        
        if get(MHandle.STOP,'Value') > 0
           denfisgui_disp(MHandle,'ImplementInfo','DENFIS Training Stop'); 
        else
           denfisgui_save(MHandle,DF);
           denfisgui_disp(MHandle,'ImplementInfo','DENFIS Training Complete'); 
        end    
     else 
        denfisgui_disp(MHandle,'ImplementInfo','DENFIS Simulating'); 
        [Res] = denfisgui_simulating(data0,NumFig1,MHandle,NumFig2,PHandle);
        if Res.FileError > 0
           denfisgui_enable('On',MHandle,NumFig2,PHandle); 
           return;
        end   
        if get(MHandle.STOP,'Value') > 0
           denfisgui_disp(MHandle,'ImplementInfo','DENFIS Simulating Stop'); 
        else
           denfisgui_disp(MHandle,'ImplementInfo','DENFIS Simulating Complete'); 
        end   
     end 
     denfisgui_enable('On',MHandle,NumFig2,PHandle);
           
  return;  
%--------------------------------------------------------------------------------
%  denfisgui_start end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_enable
%--------------------------------------------------------------------------------
  function denfisgui_enable(PBEnable,MHandle,NumFig2,PHandle)
  
     switch PBEnable
        case 'Off'
             set(MHandle.START,'Enable','Off');
             set(MHandle.CLEAR,'Enable','Off');
             set(MHandle.CLOSE,'Enable','Off');
             set(MHandle.STOP,'Enable','On','Value',0); 
             set(MHandle.PAUSE,'Enable','On','Value',0);
             
             set(MHandle.EvalSamples,'String', '');
             set(MHandle.AbsError,'String', '');
             set(MHandle.PMaxError,'String', '');
             set(MHandle.NMaxError,'String', '');
             set(MHandle.RMSE,'String', '');
             set(MHandle.NDEI,'String', '');
        case 'On'
             set(MHandle.START,'Enable','On','Value',0);
             set(MHandle.CLEAR,'Enable','On');
             set(MHandle.CLOSE,'Enable','On');
             set(MHandle.STOP,'Enable','Off','Value',0); 
             set(MHandle.PAUSE,'Enable','Off','Value',0);
     end     % PBEnable
     drawnow
     denfisgui_parmon(PBEnable,NumFig2,PHandle);   
  return;  
%--------------------------------------------------------------------------------
%  denfisgui_enable end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_ini
%--------------------------------------------------------------------------------
  function [DF] = denfisgui_ini(data0,MHandle)
  
     DF = [];
     [DF.Nd, DF.Nx]   = size(data0);    
     DF.Ine           = DF.Nx - 1;
     DF.Oute          = 1;
     DF.OriInput      = data0(:,1:DF.Ine);
     DF.OriTeach      = data0(:,DF.Ine+1:DF.Nx);
     DF.Time0         = cputime;
     denfisgui_disp(MHandle,'DataInfo',DF);
     
     DF.Partition     = MHandle.SParm.Partition ;
     DF.Evaluation    = MHandle.SParm.Evaluation;
     DF.NumClusters   = MHandle.SParm.NumClusters;
     DF.Optimization  = MHandle.SParm.Optimization;
     DF.AbsoluteError = MHandle.SParm.AbsoluteError;
     DF.RMSE          = MHandle.SParm.RMSE;
     DF.NDEI          = MHandle.SParm.NDEI;
     DF.Dthr          = MHandle.SParm.DistanceThreshold;
     DF.EcmEpochs     = MHandle.SParm.ECMEpochs;
     DF.EcmImp        = 0.0001;
     DF.EcmTol        = 0.0001;
     DF.TrainMode     = MHandle.SParm.TrainMode;
     DF.ExtRegion     = 0.05;
     DF.Overlap       = DF.Dthr*1.2;
     DF.Mofn          = MHandle.SParm.MofN;
     DF.Wh            = DF.Dthr/sqrt(-2*log(0.6));
     DF.ForgetFact    = 0.9;
     DF.NumNeuron     = 3;
     DF.MLPEpochs     = MHandle.SParm.MLPEpochs;
     DF.MLPGoal       = 1E-8;
     DF.MinNumSap     = DF.Ine + 6;
     DF.XData         = MHandle.SParm.XData;
     DF.YData         = MHandle.SParm.YData;
     
     DF.FuzzyType     = 1;   
     if DF.TrainMode == 3
        DF.FuzzyType  = 2; 
        DF.TrainMode  = 2;
     end   
     
     DF.Crn        = [];
     DF.Clas1      = [];  
     DF.Radius     = [];
     DF.Forget     = [];
     DF.Cobj       = [];
     DF.Out        = [];
     DF.Abe        = [];
     DF.Rmse       = [];
     DF.Ndei       = [];
     DF.Obj        = 0;
     DF.MaxD       = 0;
     DF.EcmEpochs0 = 0;
     DF.NumR       = 0;
     DF.StopState  = 0;
     DF.PMaxAbse   = 0;
     DF.NMaxAbse   = 0;
     
     % data normalizing
     for i = 1:DF.Ine               
         max0          = max(DF.OriInput(:,i));
         min0          = min(DF.OriInput(:,i));
         DF.Maxi(i)    = max0 + (max0 - min0) * DF.ExtRegion;
         DF.Mini(i)    = min0 - (max0 - min0) * DF.ExtRegion;       
         DF.Input(:,i) = (DF.OriInput(:,i)-DF.Mini(i))/(DF.Maxi(i)-DF.Mini(i));
     end                                               % nd-by-ine

     for i = 1:DF.Oute               
         max0          = max(DF.OriTeach(:,i));
         min0          = min(DF.OriTeach(:,i));
         DF.Maxt(i)    = max0 + (max0 - min0) * DF.ExtRegion;
         DF.Mint(i)    = min0 - (max0 - min0) * DF.ExtRegion;       
         DF.Teach(:,i) = (DF.OriTeach(:,i)-DF.Mint(i))/(DF.Maxt(i)-DF.Mint(i));
     end 
  return;  
%--------------------------------------------------------------------------------
%  denfisgui_ini end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%    subfunction denfisgui_onlinetrain
%--------------------------------------------------------------------------------  
  function [DF] = denfisgui_onlinetrain(MHandle,DF);

     warning off
     % create the first node
     DF.rn         = 1;
     DF.Crn        = [DF.Crn; 1];
     DF.Clas1{1}   = [DF.Input(1,:); DF.Input(1,:)];  
     DF.Radius(1)  = 0; 
     DF.NumSap     = 1;
     ind1          = [1]; 
     rn0           = 1;
     
     denfisgui_plotnumc(DF);
     denfisgui_plotpart(DF);
     
     % create the first m fuzzy rules
     for i = 2:DF.Nd
         [DF,ind1]  = denfisgui_ec11(DF,ind1,i);   
         if DF.rn > rn0
            rn0    = DF.rn;
            DF.Crn = [DF.Crn; i];            
         end     
         DF.Cent = [];
         for j = 1:DF.rn
             DF.Cent(j,:) = DF.Clas1{j}(1,:);
         end
         
         DF.NumSap = i;
         denfisgui_disp(MHandle,'TrainingInfo',DF);
         denfisgui_plotnumc(DF);
         denfisgui_plotpart(DF);
         if get(MHandle.STOP,'Value') > 0
            return; 
         end
         if DF.rn >= DF.Mofn & i >= DF.MinNumSap
            ini  = i;
            break;
         end
     end                           % i = 2:nd

     for i = 1:DF.rn 
         f1   = 0;
         rcr0 = DF.Overlap;
         for j = 1:ini
             D(j) = norm(DF.Cent(i,:) - DF.Input(j,:))/sqrt(DF.Ine);
         end          % j = 1:ini

         while (f1 == 0)
               X  = [];
               Y  = [];
               for j = 1:ini
                   if D(j) <= rcr0
                      X = [X; 1 DF.Input(j,:)];
                      Y = [Y; DF.Teach(j,:)];
                   end
               end
               [Ne Ne0] = size(Y);
               if Ne < DF.MinNumSap
                  rcr0 = rcr0 * 1.05;
               else
                  f1 = 1;
               end
         end          % while (f1 == 0)

         P0     = inv(X'*X);
         K{i}.P = P0;
         K{i}.Q = P0 * X' * Y;
         
         DF.Forget(i) = 1; 
         DF.NumR      = i;
         denfisgui_disp(MHandle,'TrainingInfo',DF);
         if get(MHandle.STOP,'Value') > 0
            return; 
         end
     end              % i = 1:rn

     for i = 1:ini
         [DF] = denfisgui_ev1(DF,K,i);  
         
         DF.NumSap = i;
         denfisgui_disp(MHandle,'EvaluatingInfo',DF);
         denfisgui_plottrain(DF);
         denfisgui_plottabse(DF);
         denfisgui_plottrmse(DF);
         denfisgui_plottndei(DF);
         if get(MHandle.STOP,'Value') > 0
            return; 
         end
     end
   
     % create new nodes and update nodes
     for i = ini+1:DF.Nd
        
         [DF] = denfisgui_ev1(DF,K,i); 
        
         % update the functions
         [K,w1,inw1] = denfisgui_ec12(DF,K,i);

         % create or update the cluster    
         [DF,ind1]  = denfisgui_ec11(DF,ind1,i);      
         if DF.rn > rn0
            rn0    = DF.rn;
            DF.Crn = [DF.Crn; i];
            % create a function
            [DF,K] = denfisgui_ec13(DF,K,i,w1,inw1);
         end     
 
         DF.Cent = [];
         for j = 1:DF.rn
             DF.Cent(j,:) = DF.Clas1{j}(1,:);
         end
 
         %if i == DF.Nd
         %   [DF.Obj, DF.MaxD] =  denfisgui_ec14(DF); 
         %   denfisgui_disp(MHandle,'ImplementInfo',...
         %                  'DENFIS On-line Training',...
         %                  'Obj and MaxD calculating'); 
         %end    
         
         DF.NumSap = i;
         DF.NumR   = DF.rn;
         denfisgui_disp(MHandle,'TrainingInfo',DF);
         denfisgui_disp(MHandle,'EvaluatingInfo',DF);
         denfisgui_plotnumc(DF);
         denfisgui_plotpart(DF);
         denfisgui_plottrain(DF);
         denfisgui_plottabse(DF);
         denfisgui_plottrmse(DF);
         denfisgui_plottndei(DF);
         if get(MHandle.STOP,'Value') > 0
            return; 
         end
     end                           % i = ini:nd
 
     for j = 1:DF.rn
         DF.Fun{j} = K{j}.Q;
     end
    
     DF.Time0 = cputime - DF.Time0;
     warning on 
  return;
%--------------------------------------------------------------------------------
%    function denfisgui_onlinetrain end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%    subfunction denfisfui_ec11
%--------------------------------------------------------------------------------
  function [DF,ind1] = denfisgui_ec11(DF,ind1,i)
  
     EX = DF.Input(i,:);
     for j = 1:DF.rn          
         D(j) = norm(EX - DF.Clas1{j}(1,:))/sqrt(DF.Ine) + DF.Radius(j);   
     end;
     [mina1,inda1] = min(D);
     if mina1 - DF.Radius(inda1) <= DF.Radius(inda1)
        return;
     end 

     if mina1 > 2*DF.Dthr
        DF.rn            = DF.rn + 1;         % create a new class
        DF.Clas1{DF.rn}  = [EX; EX];
        DF.Radius(DF.rn) = 0;    
        ind1             = [ind1; i]; 
     else
        D0   = mina1 - DF.Radius(inda1);
        R0   = mina1 / 2;
        dist = EX - DF.Clas1{inda1}(1,:);

        for k = 1:DF.Ine
            dx  = abs(dist(k)) * R0/D0;
            if dist(k) > 0
               DF.Clas1{inda1}(1,k) = EX(k) - dx;
            else
               DF.Clas1{inda1}(1,k) = EX(k) + dx;
            end
        end

        DF.Radius(inda1) = R0;
        DF.Clas1{inda1}  = [DF.Clas1{inda1}; EX];

     end                                 % if mina1 > 2 * DF.Dthr
  return;
%--------------------------------------------------------------------------------
%   subfunction denfisgui_ec11 end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%   subfunction denfisfui_ec12
%--------------------------------------------------------------------------------
  function  [K,w1,inw1] = denfisgui_ec12(DF,K,i)

     ex1 = [1 DF.Input(i,:)];
    
     for j = 1:DF.rn         
         D(j) = norm(DF.Input(i,:) - DF.Cent(j,:))/sqrt(DF.Ine);  
     end

     [w1 inw1] = min(D);

     for j = 1:DF.Mofn
         [w0 inw0]     = min(D);
         D(inw0)       = 1;
         w(j)          = 1 - w0;
         inw(j)        = inw0;

         P0  = K{inw0}.P;
         Q0  = K{inw0}.Q;
  
         pp1 = w(j) * P0 * ex1' * ex1 * P0;
         pp2 = DF.Forget(inw0) + w(j) * ex1 * P0 * ex1';
         %P1  = (P0 - pp1/pp2)/DF.Forget(inw0);
         P1  = (P0 - pp1/pp2)/DF.ForgetFact;

         K{inw0}.P  = P1;
         K{inw0}.Q  = Q0 + w(j) * P1 * ex1' * (DF.Teach(i,:) - ex1 * Q0);

     end
  return;
%--------------------------------------------------------------------------------
%   subfunction denfisfui_ec12 end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%   subfunction denfisfui_ec13 
%--------------------------------------------------------------------------------
  function [DF,K] = denfisgui_ec13(DF,K,i,w0,inda1)

     DF.Forget(DF.rn) = DF.ForgetFact;
     ex1              = [1 DF.Input(i,:)];
     P0               = K{inda1}.P;
     Q0               = K{inda1}.Q; 
     pp1              = w0 * P0 * ex1' * ex1 * P0;
     pp2              = DF.ForgetFact + w0 * ex1 * P0 * ex1';
     P1               = (P0 - pp1/pp2)/DF.ForgetFact;
     K{DF.rn}.P       = P1;
     K{DF.rn}.Q       = Q0 + w0 * P1 * ex1' * (DF.Teach(i,:) - ex1 * Q0);
     
  return;
%--------------------------------------------------------------------------------
%   subfunction denfisgui_ec13 end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%   subfunction denfisgui_ec14
%--------------------------------------------------------------------------------
  function [obj0,maxD] = denfisgui_ec14(DF)

      U     = zeros(DF.rn,DF.Nd);  
      obj0  = 0;

      for j = 1:DF.Nd
          for i = 1:DF.rn
              D(i,j) = norm(DF.Input(j,:) - DF.Cent(i,:))/sqrt(DF.Ine);
          end

          [min0,ind0] = min(D(:,j));
          U(ind0,j)   = 1;
          %obj0 = obj0 + sum(U(:,j).*D(:,j));
          obj0  = obj0 + min0;
      end
  
      for i = 1:DF.rn
          for j = 1:DF.Nd
              D(i,j) = D(i,j) * U(i,j);
          end
      end
      maxD   = max(max(D));
      
  return;  
%--------------------------------------------------------------------------------
%   subfunction denfisgui_ec14 end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%    function denfisgui_ev1
%--------------------------------------------------------------------------------
  function  [DF] = denfisgui_ev1(DF,K,i)

     EX        = DF.Input(i,:);
     
     for j = 1:DF.rn  
         D(j) = norm(EX - DF.Cent(j,:))/sqrt(DF.Ine); 
     end
     for j = 1:DF.Mofn
         [mina(j) inda(j)] = min(D);
         D(j)              = 1;
         frg(j,:)          = DF.Cent(inda(j),:);
     end

     for j = 1:DF.Mofn
         mind    = inda(j);           
         out0(j) = satlin([1 EX] * K{mind}.Q);
         r(j) = 1;
         for k = 1:DF.Ine
             r(j) = r(j) * gaussmf(EX(k),[DF.Wh frg(j,k)]);
         end     % k = 1:ine
     end         % j = 1:mofn

     y0  = sum(r .* out0);
     y1  = sum(r);
     if y1 < 0.0001        
        Y0 = 0;          
        for k = 1:DF.Mofn
            Y0 = Y0 + out0(k) * (1 - mina(k));
        end         
        out1 = Y0 / sum((1 - mina));      
     else
        out1 = y0 / y1;
     end    % if y1 < 0.0001       

     DF.Out(i)  = out1 * (DF.Maxt - DF.Mint) + DF.Mint;
     DF.Abe(i)  = DF.Out(i) - DF.OriTeach(i);
     DF.Rmse(i) = norm(DF.Abe(1:i))/sqrt(i);

     if i == 1
        DF.Ndei(1) = 0;
     else
        DF.Ndei(i) = DF.Rmse(i)./std(DF.OriTeach(1:i));
     end
     if i == 2
        DF.Ndei(1) = DF.Ndei(2);
     end   
     
     if DF.PMaxAbse < DF.Abe(i);   DF.PMaxAbse = DF.Abe(i);   end   
     if DF.NMaxAbse > DF.Abe(i);   DF.NMaxAbse = DF.Abe(i);   end
  return;
%--------------------------------------------------------------------------------
%    function denfisgui_ev1 end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%    subfunction denfisgui_offlinetrain
%-------------------------------------------------------------------------------- 
  function [DF] = denfisgui_offlinetrain(MHandle,DF)
  
     warning off     
     % create the first node
     DF.rn         = 1;
     DF.Crn        = [DF.Crn; 1];
     DF.Clas1{1}   = [DF.Input(1,:); DF.Input(1,:)];  
     DF.Radius(1)  = 0; 
     DF.NumSap     = 1;
     ind1          = [1]; 
     rn0           = 1;
     
     denfisgui_plotnumc(DF);
     denfisgui_plotpart(DF);
     
     % create new nodes and update nodes
     for i = 2:DF.Nd
         [DF,ind1] = denfisgui_ec11(DF,ind1,i);   
        
         if DF.rn > rn0
            rn0    = DF.rn;
            DF.Crn = [DF.Crn; i];
         end            
         DF.Cent = [];
         for j = 1:DF.rn
             DF.Cent(j,:) = DF.Clas1{j}(1,:);
         end        
         if i == DF.Nd 
            [DF.Obj, DF.MaxD] = denfisgui_ec14(DF);
            denfisgui_disp(MHandle,'ImplementInfo',...
                           'DENFIS Off-line Training',...
                           'Obj and MaxD calculating'); 
         end         
        
         DF.NumSap = i;
         denfisgui_disp(MHandle,'TrainingInfo',DF);
         denfisgui_plotnumc(DF);
         denfisgui_plotpart(DF);
         if get(MHandle.STOP,'Value') > 0
            return; 
         end
     end                           % i = 2:nd

     if DF.EcmEpochs > 0  
        denfisgui_disp(MHandle,'ImplementInfo','DENFIS Off-line Training',...
                        'Cluster Optimizing');  
        obj1               = DF.Obj;
        DF.Cobj(1)         = DF.Obj; 
        DF.Radius(1:DF.rn) = DF.Dthr;

        for i = 1:DF.EcmEpochs
            [DF] = denfisgui_ec23(DF);
            DF.Cobj(i+1) = DF.Obj;
            DF.Imp       = obj1 - DF.Obj;
          
            DF.EcmEpochs0 = i;
            denfisgui_disp(MHandle,'TrainingInfo',DF);
            denfisgui_plotopti(DF);
            denfisgui_plotpart(DF);
            
            if get(MHandle.STOP,'Value') > 0
               return; 
            end
            if DF.Imp < DF.EcmImp
               break;
            end
            obj1 = DF.Obj;
         end         % for i = 1:epoch
     end             % if epoch > 0
     
     denfisgui_disp(MHandle,'ImplementInfo',...
                     'DENFIS Off-line Training','Rule Creating');
     for i = 1:DF.rn
         DF.NumR = i;
         [DF] = denfisgui_cr2(DF);       
         denfisgui_disp(MHandle,'TrainingInfo',DF);
         denfisgui_plotpart(DF);
         if get(MHandle.STOP,'Value') > 0
            return; 
         end
     end
     
     denfisgui_disp(MHandle,'ImplementInfo',...
                     'DENFIS Training Completes','TrainingData Evaluating');
     for i = 1:DF.Nd        
         DF.NumSap = i;
         [DF] = denfisgui_ev2(DF);
         denfisgui_disp(MHandle,'EvaluatingInfo',DF);
         denfisgui_plottrain(DF);
         denfisgui_plottabse(DF);
         denfisgui_plottrmse(DF);
         denfisgui_plottndei(DF);
         if get(MHandle.STOP,'Value') > 0
            return; 
         end
     end
     DF.Time0 = cputime - DF.Time0;
     warning on   
  return;
%--------------------------------------------------------------------------------
%    function denfisgui_offlinetrain end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%   subfunction denfisgui_ecf23 
%--------------------------------------------------------------------------------
  function [DF] = denfisgui_ec23(DF)

     %global fundata
     DF.Obj  = 0;
     DF.MaxD = 0;
 
     for i = 1:DF.rn
         DF.Clas1{i} = [DF.Cent(i,:)];
     end 
     for j = 1:DF.Nd
         for i = 1:DF.rn
             D(i,j) = norm(DF.Input(j,:) - DF.Clas1{i}(1,:)) / sqrt(DF.Ine);
         end
         [min0,ind0] = min(D(:,j));
         DF.Clas1{ind0} = [DF.Clas1{ind0}; DF.Input(j,:)];
     end

     OPTIONS = optimset('LargeScale', 'off', 'Display', 'off');       
     lb = zeros(1,DF.Ine);
     ub = ones(1,DF.Ine);
 
     for i = 1:DF.rn
         [mn mn0] = size(DF.Clas1{i});
         D0       = zeros(mn,1);
  
         if mn > 1      
            %fundata.mn0  = mn-1;
            %fundata.Md   = Md;
            %fundata.ine  = ine;      
            %undata.data = clus{i}(2:mn,1:ine);
               
            fido = fopen('fundata.txt','w');
            fprintf(fido, ' %8.4f  %8.4f  %8.4f \n', mn-1,DF.Dthr,DF.Ine);
            for fi = 1:mn-1
                for fj = 1:DF.Ine
                    fprintf(fido, ' %8.4f',DF.Clas1{i}(fi+1,fj));
                end
                fprintf(fido, '\n');
            end
            fclose(fido);
  
            x0 = DF.Clas1{i}(1,:);
            x = fmincon('denfis_fun', x0, [], [], [], [], lb, ub,...
                        'denfis_con', OPTIONS);

            for j = 1:DF.Ine
                DF.Clas1{i}(1,j) = x(j);
                DF.Cent(i,j)     = x(j);
            end     
            for j = 2:mn
                D0(j)  = norm(DF.Clas1{i}(1,:)-DF.Clas1{i}(j,:))/sqrt(DF.Ine);
                DF.Obj = DF.Obj + D0(j);
            end
            MaxD0 = max(D0);
            if MaxD0 > DF.MaxD
               DF.MaxD = MaxD0;
            end
         end         % mn > 1
     end             % i = 1:rn 
     delete fundata.txt;
 
  return;
%--------------------------------------------------------------------------------
%   subfunction denfisgui_ec23.m
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%    function denfisgui_cr2
%--------------------------------------------------------------------------------
  function   [DF] = denfisgui_cr2(DF);
  
         rcr  = DF.Overlap;
         i    = DF.NumR; 
         f1   = 0;
         rcr0 = rcr;
         for j = 1:DF.Nd
             D(j) = norm(DF.Cent(i,:) - DF.Input(j,:))/sqrt(DF.Ine);
         end          % j = 1:nd

         while (f1 == 0)
               X  = [];
               Y  = [];
               for j = 1:DF.Nd
                   if D(j) <= rcr0              
                      if DF.TrainMode == 2 & DF.FuzzyType == 2
                         X = [X; DF.Input(j,:)];  
                      else   
                         X = [X; 1 DF.Input(j,:)]; 
                      end               
                      Y = [Y; DF.Teach(j,:)];
                   end
               end
               [Ne Ne0] = size(Y);

               if Ne < DF.MinNumSap
                  rcr0 = rcr0 * 1.05;
               else
                  f1 = 1;
               end
         end          % while (f1 == 0)

         if DF.TrainMode == 2 & DF.FuzzyType == 2
            DF.Net{i} = newff([zeros(DF.Ine,1) ones(DF.Ine,1)],...
                              [DF.NumNeuron 1],{'tansig' 'purelin'});
            DF.Net{i}.trainParam.epochs = DF.MLPEpochs;
            DF.Net{i}.trainParam.goal   = DF.MLPGoal;
            DF.Net{i}.trainParam.show   = Inf;
            DF.Net{i} = train(DF.Net{i},X',Y'); 
         else   
            DF.Fun{i} = inv(X'*X) * X' * Y;
         end            
  return;
%--------------------------------------------------------------------------------
%    function denfisgui_cr2 end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%    function denfisgui_ev2
%--------------------------------------------------------------------------------
  function  [DF] = denfisgui_ev2(DF)
 
         i  = DF.NumSap;
         EX = DF.Input(i,:);
         for j = 1:DF.rn  
             D(j) = norm(EX - DF.Cent(j,:))/sqrt(DF.Ine); 
         end
         for j = 1:DF.Mofn
             [mina(j) inda(j)] = min(D);
             D(j)              = 1;
             frg(j,:)          = DF.Cent(inda(j),:);
         end

         for j = 1:DF.Mofn
             mind = inda(j);
             if DF.TrainMode == 2 & DF.FuzzyType == 2
                out0(j) = satlin(sim(DF.Net{mind},EX'));
             else   
                out0(j) = satlin([1 EX] * DF.Fun{mind});  
             end      
             
             r(j) = 1;
             for k = 1:DF.Ine
                 r(j) = r(j) * gaussmf(EX(k),[DF.Wh frg(j,k)]);
              end     % k = 1:ine
         end         % j = 1:mofn

         y0  = sum(r .* out0);
         y1  = sum(r);
         if y1 < 0.0001
            Y0 = 0;
            for k = 1:DF.Mofn
                Y0 = Y0 + out0(k) * (1 - mina(k));
            end
            out1 = Y0 / sum((1 - mina));
         else
            out1 = y0 / y1;
         end    % if y1 < 0.0001       

         DF.Out(i)  = out1 * (DF.Maxt - DF.Mint) + DF.Mint;
         DF.Abe(i)  = DF.Out(i) - DF.OriTeach(i);
         DF.Rmse(i) = norm(DF.Abe(1:i))/sqrt(i);
         if i == 1
            DF.Ndei(1) = 0;
         else
            DF.Ndei(i) = DF.Rmse(i)./std(DF.OriTeach(1:i));
         end
         if i == 2
            DF.Ndei(1) = DF.Ndei(2);
         end
         
         if DF.PMaxAbse < DF.Abe(i);   DF.PMaxAbse = DF.Abe(i);   end   
         if DF.NMaxAbse > DF.Abe(i);   DF.NMaxAbse = DF.Abe(i);   end
  return;
%--------------------------------------------------------------------------------
%    function denfisgui_ev2 end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_save
%--------------------------------------------------------------------------------  
  function denfisgui_save(MHandle,DF)
 
     outname0 = MHandle.SParm.OutputName;
     if length(outname0)<1|length(findstr(outname0,' '))>0|strcmp(outname0,'.')
           return;
     end 
    
     indxp = findstr(outname0, '.');
     if isempty(indxp)
        outname1 = outname0;
     else
        outname1 = outname0(1:indxp-1);  
     end 
     Results = DF;
     save(outname1,'Results');
    
  return;
%--------------------------------------------------------------------------------
%   denfisgui_save end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%   denfisgui_simulating
%--------------------------------------------------------------------------------
  function [Res] = denfisgui_simulating(data0,NumFig1,MHandle,NumFig2,PHandle)
  
     Res           = [];
     Res.FileError = 0;
     if NumFig2 > 0
        fname = get(PHandle.InputName,'String');
     else
        fname = MHandle.SParm.InputName;
     end
   
     fidinput = fopen(fname,'r'); 
     if fidinput < 0 
        Res.FileError = 1; 
        return;
     end 
     fclose(fidinput);
     df0 = load(fname);
     DF  = df0.Results;
       
     [Res] = denfisgui_sini(data0,DF,NumFig1,MHandle,NumFig2,PHandle);
     denfisgui_enable('Off',MHandle,NumFig2,PHandle);
     
     switch DF.FuzzyType 
        case 1
             denfisgui_disp(MHandle,'ImplementInfo',...
                            'DENFIS Simulating','First-Order TSK FIS');               
        case 2
             denfisgui_disp(MHandle,'ImplementInfo',...
                            'DENFIS Simulating','High-Order TSK FIS');        
     end  
     [Res] = denfisgui_sev1(Res,DF,MHandle);
  return;   
%================================================================================
%   denfisgui_simulating                                                           =
%================================================================================

%--------------------------------------------------------------------------------
%    subfunction denfisgui_sini
%--------------------------------------------------------------------------------
  function [Res] = denfisgui_sini(data0,DF,NumFig1,MHandle,NumFig2,PHandle)
  
     Res.FileError    = 0;
     Res.Time0        = cputime;
     [Res.Nd Res.Nx]  = size(data0);        
     Res.OriTeach     = data0(:,DF.Ine+1:DF.Nx);
     Res.OriInput     = data0(:,1:DF.Ine);
     Res.Ine          = DF.Ine;
     Res.Oute         = DF.Oute;
     Res.Mint         = DF.Mint;
     Res.Maxt         = DF.Maxt;
     Res.Input        = [];
     
     MHandle.SParm.Module             = 2;
     MHandle.SParm.TrainMode          = DF.TrainMode;
     if DF.FuzzyType == 2
        MHandle.SParm.TrainMode       = 3; 
     end    
     MHandle.SParm.DistanceThreshold  = DF.Dthr;
     MHandle.SParm.MofN               = DF.Mofn;
     MHandle.SParm.ECMEpochs          = DF.EcmEpochs;
     MHandle.SParm.MLPEpochs          = DF.MLPEpochs;
     Res.XData                        = MHandle.SParm.XData ;
     Res.YData                        = MHandle.SParm.YData ;  
     Res.Partition                    = MHandle.SParm.Partition ;
     Res.Evaluation                   = MHandle.SParm.Evaluation ;
     Res.NumClusters                  = MHandle.SParm.NumClusters ;
     Res.Optimization                 = MHandle.SParm.Optimization ;
     Res.AbsoluteError                = MHandle.SParm.AbsoluteError;
     Res.RMSE                         = MHandle.SParm.RMSE;
     Res.NDEI                         = MHandle.SParm.NDEI;    
     
     for i = 1:DF.Ine               
         Res.Input(:,i) = (data0(:,i) - DF.Mini(i))/(DF.Maxi(i) - DF.Mini(i));
     end    % nd-by-ine
     
     denfisgui_disp(MHandle,'DataInfo',Res);
     denfisgui_disp(MHandle,'TrainingInfo',DF);
     set(NumFig1,'Userdata',MHandle);
     denfisgui_parmcancel(MHandle,NumFig2,PHandle);
  return;
%--------------------------------------------------------------------------------
%    subfunction denfisgui_sini  end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%    function denfisgui_sev1
%--------------------------------------------------------------------------------
  function   [res] = denfisgui_sev1(res,DF,MHandle)
  
     res.Out      = [];
     res.Abe      = [];
     res.Rmse     = [];
     res.Ndei     = [];
     res.PMaxAbse = 0;
     res.NMaxAbse = 0;
     
     for i = 1:res.Nd
         EX = res.Input(i,:);
         for j = 1:DF.rn  
             D(j) = norm(EX - DF.Cent(j,:))/sqrt(res.Ine); 
         end
         for j = 1:DF.Mofn
             [mina(j) inda(j)] = min(D);
             D(j)              = 1;
             frg(j,:)          = DF.Cent(inda(j),:);
         end

         for j = 1:DF.Mofn
             mind = inda(j);
             if DF.TrainMode == 2 & DF.FuzzyType == 2
                out0(j) = satlin(sim(DF.Net{mind},EX'));
             else   
                out0(j) = satlin([1 EX] * DF.Fun{mind});  
             end
             
             r(j) = 1;
             for k = 1:res.Ine
                 r(j) = r(j) * gaussmf(EX(k),[DF.Wh frg(j,k)]);
              end     % k = 1:ine
         end         % j = 1:mofn

         y0  = sum(r .* out0);
         y1  = sum(r);
         if y1 < 0.0001
            Y0 = 0;
            for k = 1:DF.Mofn
                Y0 = Y0 + out0(k) * (1 - mina(k));
            end
            out1 = Y0 / sum((1 - mina));
         else
            out1 = y0 / y1;
         end    % if y1 < 0.0001       

         res.Out(i)  = out1 * (DF.Maxt - DF.Mint) + DF.Mint;
         res.Abe(i)  = res.Out(i) - res.OriTeach(i);
         res.Rmse(i) = norm(res.Abe(1:i))/sqrt(i);
         if i == 1
            res.Ndei(1) = 0;
         else
            res.Ndei(i) = res.Rmse(i)./std(res.OriTeach(1:i));
         end
         if i == 2
            res.Ndei(1) = res.Ndei(2);
         end
         
         if res.PMaxAbse < res.Abe(i);   res.PMaxAbse = res.Abe(i);   end   
         if res.NMaxAbse > res.Abe(i);   res.NMaxAbse = res.Abe(i);   end 
         res.NumSap = i;
         denfisgui_disp(MHandle,'EvaluatingInfo',res);
         denfisgui_plotsimulate(res);
         denfisgui_plotsabse(res);
         denfisgui_plotsrmse(res);
         denfisgui_plotsndei(res);
         if get(MHandle.STOP,'Value') > 0
            return; 
         end
     end        % i = 1:nd
     res.Time0 = cputime-res.Time0;
  return;
%--------------------------------------------------------------------------------
%    function denfisgui_sev1 end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%    function denfisgui_disp: display data information
%--------------------------------------------------------------------------------
  function denfisgui_disp(MHandle,SDisp,varargin)
  
     switch SDisp
        case 'ImplementInfo'
             set(MHandle.ImplementInfo1,'String',varargin{1});
             if length(varargin) > 1
                set(MHandle.ImplementInfo2,'String',varargin{2}); 
             else
                set(MHandle.ImplementInfo2,'String',''); 
             end 
             
        case 'DataInfo'
             set(MHandle.ImplementInfo2,'String','Data Normalization')
             set(MHandle.NumSamples,'String',int2str(varargin{1}.Nd));
             set(MHandle.NumInputElems,'String',int2str(varargin{1}.Ine));
             set(MHandle.NumOutputElems,'String',int2str(varargin{1}.Oute)); 
         
        case 'TrainingInfo'
             set(MHandle.NumRules,'String',int2str(varargin{1}.NumR));
             set(MHandle.NumClusters,'String',int2str(varargin{1}.rn));
             set(MHandle.TraSamples,'String',int2str(varargin{1}.NumSap));
             set(MHandle.ECMEpochs,'String',int2str(varargin{1}.EcmEpochs0));
             if MHandle.SParm.Module < 2
                set(MHandle.CpuTime,'String',...
                    sprintf('%0.1f',cputime-varargin{1}.Time0));
             else
                set(MHandle.CpuTime,'String',...
                    sprintf('%0.1f',varargin{1}.Time0));
             end   
             set(MHandle.Objective,'String','');
             set(MHandle.MaxDistance,'String','');
             if varargin{1}.EcmEpochs0 > 0 
                set(MHandle.Objective,'String',...
                    sprintf('%0.3f',varargin{1}.Obj));
                set(MHandle.MaxDistance,'String',...
                    sprintf('%0.3f',varargin{1}.MaxD));
             end 
             
        case 'EvaluatingInfo' 
             n = varargin{1}.NumSap;
             set(MHandle.EvalSamples,'String',int2str(n));
             set(MHandle.AbsError,'String',sprintf('%0.3f',varargin{1}.Abe(n)));
             set(MHandle.PMaxError,'String',...
                 sprintf('%0.3f',varargin{1}.PMaxAbse));
             set(MHandle.NMaxError,'String',...
                 sprintf('%0.3f',varargin{1}.NMaxAbse));
             set(MHandle.RMSE,'String',sprintf('%0.3f',varargin{1}.Rmse(n)));
             set(MHandle.NDEI,'String',sprintf('%0.3f',varargin{1}.Ndei(n)));
        
     end     % switch SDisp 
     drawnow
  return;
%--------------------------------------------------------------------------------
%    function denfisgui_disp end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_plotpart
%--------------------------------------------------------------------------------
  function denfisgui_plotpart(DF);
     
     if DF.Partition == 0
        return;
     end   
 
     if DF.NumSap == 1
        % create the figure object for plotting partition
        denfisgui_plotpart1(DF); 
     else        
        [FHandle,NumFig] = denfisgui_gethandle('DENFIS Partition');
        if NumFig < 1
           return;
        end 
        
        if DF.TrainMode == 1 
           dengisgui_plotpart2(DF);
        else
           dengisgui_plotpart3(DF);
        end
     end
     
  return;  
%--------------------------------------------------------------------------------
%  denfisgui_plotpart
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_plotpart1:  create the figure object for plotting partition
%--------------------------------------------------------------------------------
  function denfisgui_plotpart1(DF)
    
     [FHandle,NumFig] = denfisgui_gethandle('DENFIS Partition');
     if NumFig > 0
        close(NumFig) 
     end
     
     r = DF.Dthr * sqrt(2);
     hdfg1_partition = figure('position',[8 35 440 480],...
                              'numbertitle', 'off',...
                              'BackingStore','off',...
                              'resize','on',...
                              'MenuBar','none',...
                              'Name','DENFIS Partition',...
                              'Color', [0.4, 0.4, 0.4 ]);

     %  Create the axes object
     hdfg1_partitiona1L1  = line([-200 -200],[-200 -200]);
     hdfg1_partitiona1L2  = line([-200 -200],[-200 -200]);
     hdfg1_partitiona1L3  = line([-200 -200],[-200 -200]);
     hdfg1_partitiona1L4  = line([-200 -200],[-200 -200]);
     hdfg1_partitiona1L5  = line([-200 -200],[-200 -200]);
        
     hdfg1_partitiona1 = gca;
     set(hdfg1_partitiona1,'Position',[0.02 0.09 0.96 0.88],...
                           'Color',[0.1 0.1 0.3],...
                           'NextPlot','add',...
                           'XColor','w','YColor','w',...
                           'Box','on',...
                           'DrawMode','fast',...
                           'FontSize',9,...
                           'XTick',[],'YTick',[],...
                           'XLim',[-r 1+r],...
                           'YLim',[-r 1+r],...
                           'Tag','DENFIS RuleNode Axes',...
                           'Parent',hdfg1_partition);  
     axis('square');
     
     set(hdfg1_partitiona1L1,...
                             'LineStyle','none','LineWidth',1,...
                             'Marker','o','MarkerSize',4,...
                             'Color',[0.7 0.7 0.7],...
                             'EraseMode','none',...
                             'Tag','DENFIS SampleNodes',...
                             'Parent',hdfg1_partitiona1);
     set(hdfg1_partitiona1L2,...
                             'LineStyle','none','LineWidth',2,...
                             'Marker','+','MarkerSize',5,...
                             'Color','m',...
                             'EraseMode','background',...
                             'Tag','DENFIS RuleNodes',...
                             'Parent',hdfg1_partitiona1);
     set(hdfg1_partitiona1L3,...
                             'LineStyle','none','LineWidth',2,...
                             'Marker','o','MarkerSize',8,...
                             'Color',[1.0 1.0 0.0],...
                             'EraseMode','background',...
                             'Tag','DENFIS CurrentSample',...
                             'Parent',hdfg1_partitiona1);
     set(hdfg1_partitiona1L4,...
                             'LineStyle','none','LineWidth',2,...
                             'Marker','square','MarkerSize',8,...
                             'Color','g',...
                             'EraseMode','background',...
                             'Tag','DENFIS LastRuleNode',...
                             'Parent',hdfg1_partitiona1);
     set(hdfg1_partitiona1L5,...
                             'LineStyle','none','LineWidth',1,...
                             'Marker','square','MarkerSize',r*800,...
                             'Color',[0 0.6 0.6],...
                             'EraseMode','background',...
                             'Clipping','on');             
    
     yp = -r - 0.05 * (1+2*r);
     text(-r + 0.02 * (1+2*r), yp,'Sample','Color','w');
     text(-r + 0.19 * (1+2*r), yp,'Centre','Color','w');        
     text(-r + 0.56 * (1+2*r), yp,'CurrnetSample','Color','w');
     text(-r + 0.85 * (1+2*r), yp,'LastCentre','Color','w');
        
     line('XData',-r,'YData',yp,...
          'LineStyle','none','LineWidth',1,...
          'Marker','o','MarkerSize',4,...
          'Color',[1 1 1],...
          'EraseMode','none',...
          'Clipping','off');
     line('XData',-r+0.17*(1+2*r),'YData',yp,...
          'LineStyle','none','LineWidth',1,...
          'Marker','+','MarkerSize',5,...
          'Color','m',...
          'EraseMode','background',...
          'Clipping','off');
     line('XData',-r+0.54*(1+2*r),'YData',yp,...
          'LineStyle','none','LineWidth',2,...
          'Marker','o','MarkerSize',8,...
          'Color','y',...
          'EraseMode','background',...
          'Clipping','off');
     line('XData',-r+0.82*(1+2*r),'YData',yp,...
          'LineStyle','none','LineWidth',2,...
          'Marker','square','MarkerSize',8,...
          'Color','g',...
          'EraseMode','background',...
          'Clipping','off');
          
     text(-r + 0.39 * (1+2*r), yp,'Region','Color','w');      
     xp  = -r + 0.35 * (1+2*r);
     rx  = 0.02;
     ry  = 0.02;
     x   = [xp-rx xp+rx xp+rx xp-rx xp-rx];
     y   = [yp+ry yp+ry yp-ry yp-ry yp+ry];        
     line('XData',x,'YData',y,...
          'LineStyle',':','LineWidth',1,...
          'Color',[0 1 1],...
          'EraseMode','background',...
          'Clipping','off');

     drawnow 
  return;  
%--------------------------------------------------------------------------------
%  denfisgui_plotpart1
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_plotpart2: for on-line training 
%--------------------------------------------------------------------------------
  function dengisgui_plotpart2(DF);
           
     h_pta1   = findobj('Tag','DENFIS RuleNode Axes');
     h_pta1L1 = findobj('Tag','DENFIS SampleNodes');
     h_pta1L2 = findobj('Tag','DENFIS RuleNodes');
     h_pta1L3 = findobj('Tag','DENFIS CurrentSample');
     h_pta1L4 = findobj('Tag','DENFIS LastRuleNode');
  
     rn    = DF.rn;
     xd    = DF.XData;
     yd    = DF.YData;
     xdat  = DF.Cent(:,xd);
     ydat  = DF.Cent(:,yd);
     xdat0 = DF.Input(1:DF.NumSap,xd); 
     ydat0 = DF.Input(1:DF.NumSap,yd);
     
     set(h_pta1L3,'Xdata',xdat0(DF.NumSap),'YData',ydat0(DF.NumSap));
     set(h_pta1L4,'Xdata',xdat(DF.rn),'YData',ydat(DF.rn));
     if DF.NumSap == DF.Nd 
        set(h_pta1L1,'Xdata',xdat0(DF.NumSap),'YData',ydat0(DF.NumSap));
        set(h_pta1L2,'Xdata',xdat(DF.rn),'YData',ydat(DF.rn)); 
        set(h_pta1L3,'Xdata',[-200 -200],'YData',[-200 -200]);
        set(h_pta1L4,'Xdata',[-200 -200],'YData',[-200 -200]);
        
        r = DF.Dthr * sqrt(2);
        for i = 1:DF.rn
            rx  = DF.Cent(i,xd);
            ry  = DF.Cent(i,yd);
            x   = [rx-r rx+r rx+r rx-r rx-r];
            y   = [ry-r ry-r ry+r ry+r ry-r];        
            line('XData',x,'YData',y,...
                 'LineStyle',':','LineWidth',1,...
                 'Color',[0 0.7 0.7],...
                 'EraseMode','background',...
                 'Clipping','off');
        end     
 
     end        % if Num = nd
     set(h_pta1L1,'Xdata',xdat0,'YData',ydat0);
     set(h_pta1L2,'Xdata',xdat,'YData',ydat);
     drawnow            

  return;  
%--------------------------------------------------------------------------------
%  denfisgui_plotpart2
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_plotpart3: for off-line training 
%--------------------------------------------------------------------------------
  function dengisgui_plotpart3(DF);
  
     h_pta1   = findobj('Tag','DENFIS RuleNode Axes');
     h_pta1L1 = findobj('Tag','DENFIS SampleNodes');
     h_pta1L2 = findobj('Tag','DENFIS RuleNodes');
     h_pta1L3 = findobj('Tag','DENFIS CurrentSample');
     h_pta1L4 = findobj('Tag','DENFIS LastRuleNode');
     
     rn    = DF.rn;
     xd    = DF.XData;
     yd    = DF.YData;
     xdat  = DF.Cent(:,xd);
     ydat  = DF.Cent(:,yd);
     xdat0 = DF.Input(1:DF.NumSap,xd); 
     ydat0 = DF.Input(1:DF.NumSap,yd);
 
     if DF.NumSap < DF.Nd
        set(h_pta1L1,'Xdata',xdat0,'YData',ydat0);
        set(h_pta1L3,'Xdata',xdat0(DF.NumSap),'YData',ydat0(DF.NumSap));
        set(h_pta1L2,'Xdata',xdat,'YData',ydat);
        set(h_pta1L4,'Xdata',xdat(DF.rn),'YData',ydat(DF.rn));
     end
     if DF.NumSap == DF.Nd & DF.EcmEpochs0 == 0 & DF.NumR == 0
        set(h_pta1L1,'Xdata',xdat0(DF.NumSap),'YData',ydat0(DF.NumSap)); 
        set(h_pta1L2,'Xdata',xdat(DF.rn),'YData',ydat(DF.rn));
        set(h_pta1L4,'Xdata',100,'YData',100)
        set(h_pta1L3,'Xdata',100,'YData',100);
        set(h_pta1L1,'Xdata',xdat0,'YData',ydat0);
        set(h_pta1L2,'Xdata',xdat,'YData',ydat);       
     end
     if DF.NumSap == DF.Nd & DF.NumR == 0 & DF.EcmEpochs0 > 0
        set(h_pta1L2,'Xdata',xdat,'YData',ydat);    
     end    
     if DF.NumR > 0
        r   = DF.Dthr * sqrt(2);        
        rx  = DF.Cent(DF.NumR,xd);
        ry  = DF.Cent(DF.NumR,yd);
        x   = [rx-r rx+r rx+r rx-r rx-r];
        y   = [ry-r ry-r ry+r ry+r ry-r];        
        line('XData',x,'YData',y,...
             'LineStyle',':','LineWidth',1,...
             'Color',[0 0.7 0.7],...
             'EraseMode','background',...
             'Clipping','off');

     end        % if NumR  > 0
     drawnow            

  return;  
%--------------------------------------------------------------------------------
%  denfisgui_plotpart3
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_plotnumc
%--------------------------------------------------------------------------------
  function denfisgui_plotnumc(DF)
 
     if DF.NumClusters == 0
        return;
     end   
     if DF.rn == 1 & DF.NumSap == 1
        % create the figure object for plotting clusters   
        denfisgui_plotnumc1(DF);      
     else       
        [MaxNum,NumFig] = denfisgui_gethandle('DENFIS NumClusters');
        if NumFig < 1
           return;
        end
        h_pca1            = findobj('Tag','DENFIS NumClusters Axes');
        h_pca1L1          = findobj('Tag','DENFIS NumClusters Line');  
        if MaxNum < 1.1 * DF.rn 
           MaxNum = DF.rn*1.2;
           set(h_pca1,'YLim',[0 MaxNum]);
        end
        set(h_pca1L1,'Xdata',DF.Crn(1:DF.rn),'YData',1:DF.rn);
     end    
     drawnow
  return;  
%--------------------------------------------------------------------------------
%  denfisgui_plotnumc
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_plotnumc1: create the figure object for plotting clusters 
%--------------------------------------------------------------------------------
  function denfisgui_plotnumc1(DF)
 
     [FHandle,NumFig] = denfisgui_gethandle('DENFIS NumClusters');
     if NumFig > 0
        close(NumFig) 
     end
   
     h_pc = figure('position',[8 500 440 240],...
                   'numbertitle', 'off',...
                   'BackingStore','off',...
                   'resize','on',...
                   'MenuBar','none',...
                   'Name','DENFIS NumClusters',...
                   'Color', [0.4, 0.4, 0.4 ]);

     h_pca1L1  = line([1 1],[1 1]);
     
     h_pca1 = gca;
     set(h_pca1,'Position',[0.10 0.18 0.86 0.77],...
                'Color',[0.1 0.1 0.3],...
                'NextPlot','add',...
                'XColor','w','YColor','w',...
                'Box','on',...
                'DrawMode','fast',...
                'FontSize',9,...
                'XLim',[0,DF.Nd],...
                'YLim',[0,10],...
                'Tag','DENFIS NumClusters Axes',...
                'Parent',h_pc);  
     XLabel('Samples','Color',[0 1 1]);
     YLabel('NumClusters','Color',[0 1 1]);
     set(h_pca1L1,...
                  'LineStyle','none','LineWidth',2,...
                  'Marker','+','MarkerSize',4,...
                  'Color',[1 0.0 1],...
                  'EraseMode','BackGround',...
                  'Tag','DENFIS NumClusters Line',...
                  'Parent',h_pca1);   
     set(h_pc,'Userdata',10);         
     drawnow
  return;  
%--------------------------------------------------------------------------------
%  denfisgui_plotnumc1
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_plotopti
%--------------------------------------------------------------------------------
  function denfisgui_plotopti(DF)
  
     if DF.Optimization == 0
        return;
     end   
     
     if DF.EcmEpochs0 == 1
        % create the figure object for plotting optimization  
        denfisgui_plotopti1(DF);
     end    
        [MinOpti,NumFig] = denfisgui_gethandle('DENFIS Optimization');
        if NumFig < 1
           return;
        end
        h_poa1            = findobj('Tag','DENFIS Optimization Axes');
        h_poa1L1          = findobj('Tag','DENFIS Optimization Line');  
        MaxOpti           = DF.Cobj(1);
        if MinOpti > 0.96 * DF.Cobj(DF.EcmEpochs0+1)
           MinOpti = DF.Cobj(DF.EcmEpochs0+1) * 0.94;
           set(h_poa1,'YLim',[MinOpti MaxOpti]); 
        end
        set(h_poa1L1,'Xdata',0:DF.EcmEpochs0,...
            'Ydata',DF.Cobj(1:DF.EcmEpochs0+1));      
       
     drawnow
  return;  
%--------------------------------------------------------------------------------
%  denfisgui_plotopti
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui1_plotopti: create the figure object for plotting optimization 
%--------------------------------------------------------------------------------
  function denfisgui_plotopti1(DF)
 
     [FHandle,NumFig] = denfisgui_gethandle('DENFIS Optimization');
     if NumFig > 0
        close(NumFig) 
     end
   
     h_po = figure('position',[120 460 360 200],...
                   'numbertitle', 'off',...
                   'BackingStore','off',...
                   'resize','on',...
                   'MenuBar','none',...
                   'Name','DENFIS Optimization',...
                   'Color', [0.4, 0.4, 0.4 ]);

     h_poa1L1  = line([1 1],[1 1]);    
     h_poa1 = gca;
     set(h_poa1,'Position',[0.13 0.20 0.83 0.76],...
                'Color',[0.1 0.1 0.3],...
                'NextPlot','add',...
                'XColor','w','YColor','w',...
                'Box','on',...
                'DrawMode','fast',...
                'FontSize',9,...
                'XLim',[0,DF.EcmEpochs],...
                'XTick',[0:1:DF.EcmEpochs],...
                'YLim',[0.97*DF.Cobj(1) DF.Cobj(1)],...
                'Tag','DENFIS Optimization Axes',...
                'Parent',h_po);  
     XLabel('Epochs','Color',[1 1 0]);
     YLabel('Objective','Color',[1 1 0]);
     set(h_poa1L1,...
                  'LineStyle','-','LineWidth',1,...
                  'Color',[0 1 0],...
                  'EraseMode','BackGround',...
                  'Tag','DENFIS Optimization Line',...
                  'Parent',h_poa1);         
     set(h_po,'Userdata', 0.97*DF.Cobj(1));        
     drawnow
  return;  
%--------------------------------------------------------------------------------
%  denfisgui_plotopti1 end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_plottrain
%--------------------------------------------------------------------------------
  function denfisgui_plottrain(DF)
 
     if DF.Evaluation == 0
        return;
     end   
     if DF.NumSap == 2       
        % create the figure object for evaluation   
        denfisgui_plottrain1(DF);       
     else       
        [FHandle,NumFig] = denfisgui_gethandle('DENFIS Training Evaluation');
        if NumFig < 1
           return;
        end
        h_psea1   = findobj('Tag','Training Evaluation Axes');
        h_psea1L1 = findobj('Tag','Training Evaluation Line');      
        set(h_psea1L1,'XData',1:DF.NumSap,'YData',DF.Out(1:DF.NumSap));      
     end 
     
     drawnow
  return;  
%--------------------------------------------------------------------------------
%  denfisgui_plottrain
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_plottrain1: create the figure object for plotting evaluation 
%--------------------------------------------------------------------------------
  function denfisgui_plottrain1(DF)
 
     [FHandle,NumFig] = denfisgui_gethandle('DENFIS Training Evaluation');
     if NumFig > 0
        close(NumFig) 
     end
   
     h_pse = figure('position',[420 420 600 330],...
                   'numbertitle', 'off',...
                   'BackingStore','off',...
                   'resize','on',...
                   'MenuBar','none',...
                   'Name','DENFIS Training Evaluation',...
                   'Color', [0.4, 0.4, 0.4 ]);

     h_psea1L1  = line([-1000 1],[1 -1000]);
     
     MM      = DF.Maxt - DF.Mint;
     h_psea1 = gca;
     set(h_psea1,'Position',[0.08 0.12 0.88 0.85],...
                'Color',[0.1 0.1 0.3],...
                'NextPlot','add',...
                'XColor','w','YColor','w',...
                'Box','on',...
                'DrawMode','fast',...
                'FontSize',9,...
                'XLim',[1,DF.Nd],...
                'YLim',[DF.Mint-0.05*MM DF.Maxt+0.05*MM],...
                'Tag','Training Evaluation Axes',...
                'Parent',h_pse);  
     XLabel('Samples','Color',[0 1 1]);
     YLabel('Actual & Required','Color',[0 1 1]);
     set(h_psea1L1,...
                  'LineStyle','-','LineWidth',1,...
                  'Color',[0 1 0],...
                  'EraseMode','BackGround',...
                  'Tag','Training Evaluation Line',...                  
                  'Parent',h_psea1); 
     line('XData',1:DF.Nd,'YData',DF.OriTeach,...
                  'LineStyle','--','LineWidth',1,...
                  'Color',[1 0 1],...
                  'EraseMode','BackGround',...
                  'Parent',h_psea1);         
     drawnow
  return;  
%--------------------------------------------------------------------------------
%  denfisgui_plottrain1
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_plottabse
%--------------------------------------------------------------------------------
  function denfisgui_plottabse(DF)

     if DF.AbsoluteError == 0
        return;
     end   
     if DF.NumSap == 2
        % create the figure object for evaluation   
        denfisgui_plottabse1(DF);
     else       
        [MaxErr,NumFig] = denfisgui_gethandle('DENFIS Training AbsoluteError');
        if NumFig < 1
           return;
        end
        h_psaa1   = findobj('Tag','Training AbsErr Axes');
        h_psaa1L1 = findobj('Tag','Training AbsErr Line');
       
        MaxErr0 = max([MaxErr 1.2*max(DF.Abe) 1.2*abs(min(DF.Abe))]);
        if MaxErr < MaxErr0
           MaxErr = MaxErr0;
           set(NumFig,'Userdata',MaxErr);
           set(h_psaa1,'YLim',[-MaxErr MaxErr]);
        end
        set(h_psaa1L1,'XData',1:DF.NumSap,'YData',DF.Abe(1:DF.NumSap));
     end 
     
     drawnow
  return;  
%--------------------------------------------------------------------------------
%  denfisgui_plottabse end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_plottabse1: create the figure object for plotting absolute errors 
%--------------------------------------------------------------------------------
  function denfisgui_plottabse1(DF)
 
     [FHandle,NumFig] = ...
         denfisgui_gethandle('DENFIS Training AbsoluteError');
     if NumFig > 0
        close(NumFig) 
     end
   
     h_psa = figure('position',[420 280 600 150],...
                   'numbertitle', 'off',...
                   'BackingStore','off',...
                   'resize','on',...
                   'MenuBar','none',...
                   'Name','DENFIS Training AbsoluteError',...
                   'Color', [0.4, 0.4, 0.4 ]);

     h_psaa1L1  = line([-1000 1],[1 -1000]);
 
     h_psaa1 = gca;
     set(h_psaa1,'Position',[0.08 0.25 0.88 0.70],...
                'Color',[0.1 0.1 0.3],...
                'NextPlot','add',...
                'XColor','w','YColor','w',...
                'Box','on',...
                'DrawMode','fast',...
                'FontSize',9,...
                'XLim',[1,DF.Nd],...
                'YLim',[-0.01 0.01],...
                'Tag','Training AbsErr Axes',...
                'Parent',h_psa);  
     XLabel('Samples','Color',[0 1 1]);
     YLabel('AbsoluteError','Color',[0 1 1]);
     set(h_psaa1L1,...
                  'LineStyle','-','LineWidth',1,...
                  'Color',[1 1 0],...
                  'EraseMode','BackGround',...
                  'Tag','Training AbsErr Line',...
                  'Parent',h_psaa1); 
     line('XData',[1 DF.Nd],'YData',[0 0],...
                  'LineStyle',':','LineWidth',1,...
                  'Color',[0.5 0.5 0.5],...
                  'EraseMode','BackGround',...
                  'Parent',h_psaa1);
              
     set(h_psa,'Userdata',0.01);         
     drawnow
  return;  
%--------------------------------------------------------------------------------
%  denfisgui_plottabse1
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_plottrmse
%--------------------------------------------------------------------------------
  function denfisgui_plottrmse(DF)
 
     if DF.RMSE == 0
        return;
     end   
     if DF.NumSap == 2
        % create the figure object for evaluation   
        denfisgui_plottrmse1(DF);
     else       
        [FHandle,NumFig] = denfisgui_gethandle('DENFIS Training RMSE');
        if NumFig < 1
           return;
        end
        h_psra1   = findobj('Tag','Training RMSE Axes');
        h_psra1L1 = findobj('Tag','Training RMSE Line');
        
        if FHandle < 1.1 * max(DF.Rmse)
           FHandle = 1.2 * max(DF.Rmse);
           set(NumFig,'Userdata',FHandle);
           set(h_psra1,'YLim',[0 FHandle]);
        end
        set(h_psra1L1,'XData',1:DF.NumSap,'YData',DF.Rmse(1:DF.NumSap));
     end 
     
     drawnow
  return;  
%--------------------------------------------------------------------------------
%  denfisgui_plottrmse
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_plottrmse1: create the figure object for plotting rmse 
%--------------------------------------------------------------------------------
  function denfisgui_plottrmse1(DF)
 
     [FHandle,NumFig] = denfisgui_gethandle('DENFIS Training RMSE');
     if NumFig > 0
        close(NumFig) 
     end
   
     h_psr = figure('position',[220 560 320 150],...
                   'numbertitle', 'off',...
                   'BackingStore','off',...
                   'resize','on',...
                   'MenuBar','none',...
                   'Name','DENFIS Training RMSE',...
                   'Color', [0.4, 0.4, 0.4 ]);

     h_psra1L1  = line([-1000 1],[1 -1000]);
 
     h_psra1 = gca;
     set(h_psra1,'Position',[0.15 0.25 0.80 0.70],...
                'Color',[0.1 0.1 0.3],...
                'NextPlot','add',...
                'XColor','w','YColor','w',...
                'Box','on',...
                'DrawMode','fast',...
                'FontSize',9,...
                'XLim',[1,DF.Nd],...
                'YLim',[0 0.001],...
                'Tag','Training RMSE Axes',...
                'Parent',h_psr);  
     XLabel('Samples','Color',[0 1 1]);
     YLabel('RMSE','Color',[0 1 1]);
     
     set(h_psra1L1,...
                  'LineStyle','-','LineWidth',1,...
                  'Color',[1 1 0],...
                  'EraseMode','BackGround',...
                  'Tag','Training RMSE Line',...
                  'Parent',h_psra1); 
              
     set(h_psr,'Userdata',0.001);
     drawnow
  return;  
%--------------------------------------------------------------------------------
%  denfisgui_plottrmse1
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_plottndei
%--------------------------------------------------------------------------------
  function denfisgui_plottndei(DF)

     if DF.NDEI == 0
        return;
     end   
     if DF.NumSap == 2
        % create the figure object for evaluation   
        denfisgui_plottndei1(DF);
     else        
        [FHandle,NumFig] = denfisgui_gethandle('DENFIS Training NDEI');
        if NumFig < 1
           return;
        end
        h_psna1   = findobj('Tag','Training NDEI Axes');
        h_psna1L1 = findobj('Tag','Training NDEI Line');
       
        if FHandle < 1.1 * max(DF.Ndei)
           FHandle = 1.2 * max(DF.Ndei);
           set(NumFig,'Userdata',FHandle);
           set(h_psna1,'YLim',[0 FHandle]);
        end
        set(h_psna1L1,'XData',1:DF.NumSap,'YData',DF.Ndei(1:DF.NumSap));
     end 
     
     drawnow
  return;  
%--------------------------------------------------------------------------------
%  denfisgui_plottndei
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_plottndei1: create the figure object for plotting ndei 
%--------------------------------------------------------------------------------
  function denfisgui_plottndei1(DF)
 
     [FHandle,NumFig] = denfisgui_gethandle('DENFIS Training NDEI');
     if NumFig > 0
        close(NumFig) 
     end
   
     h_psn = figure('position',[250 400 320 150],...
                   'numbertitle', 'off',...
                   'BackingStore','off',...
                   'resize','on',...
                   'MenuBar','none',...
                   'Name','DENFIS Training NDEI',...
                   'Color', [0.4, 0.4, 0.4 ]);

     h_psna1L1  = line([-1000 1],[1 -1000]);
 
     h_psna1 = gca;
     set(h_psna1,'Position',[0.15 0.25 0.80 0.70],...
                'Color',[0.1 0.1 0.3],...
                'NextPlot','add',...
                'XColor','w','YColor','w',...
                'Box','on',...
                'DrawMode','fast',...
                'FontSize',9,...
                'XLim',[1,DF.Nd],...
                'YLim',[0 0.001],...
                'Tag','Training NDEI Axes',...
                'Parent',h_psn);  
     XLabel('Samples','Color',[0 1 1]);
     YLabel('NDEI','Color',[0 1 1]);
     
     set(h_psna1L1,...
                  'LineStyle','-','LineWidth',1,...
                  'Color',[1 1 0],...
                  'EraseMode','BackGround',...
                  'Tag','Training NDEI Line',...
                  'Parent',h_psna1); 
     drawnow

     set(h_psn,'Userdata',0.001);
  return;  
%--------------------------------------------------------------------------------
%  denfisgui_plottndei1
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_plotsimulate
%--------------------------------------------------------------------------------
  function denfisgui_plotsimulate(DF)
 
     if DF.Evaluation == 0
        return;
     end   
     if DF.NumSap == 2
        % create the figure object for evaluation   
        denfisgui_plotsimulate1(DF);       
     else       
        [FHandle,NumFig] = denfisgui_gethandle('DENFIS Simulating Evaluation');
        if NumFig < 1
           return;
        end
        h_psea1   = findobj('Tag','Simulating Evaluation Axes');
        h_psea1L1 = findobj('Tag','Simulating Evaluation Line');      
        set(h_psea1L1,'XData',1:DF.NumSap,'YData',DF.Out(1:DF.NumSap));      
     end 
     
     drawnow
  return;  
%--------------------------------------------------------------------------------
%  denfisgui_plotsimulate
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_plotsimulate1: create the figure object for plotting evaluation 
%--------------------------------------------------------------------------------
  function denfisgui_plotsimulate1(DF)
 
     [FHandle,NumFig] = denfisgui_gethandle('DENFIS Simulating Evaluation');
     if NumFig > 0
        close(NumFig) 
     end
   
     h_pse = figure('position',[420 420 600 330],...
                   'numbertitle', 'off',...
                   'BackingStore','off',...
                   'resize','on',...
                   'MenuBar','none',...
                   'Name','DENFIS Simulating Evaluation',...
                   'Color', [0.4, 0.4, 0.4 ]);
     h_psea1L1  = line([-1000 1],[1 -1000]);
     
     max0 = max(DF.OriTeach);
     min0 = min(DF.OriTeach);
     MM   = max0 - min0;
     h_psea1 = gca;
     set(h_psea1,'Position',[0.08 0.12 0.88 0.85],...
                'Color',[0.1 0.1 0.3],...
                'NextPlot','add',...
                'XColor','w','YColor','w',...
                'Box','on',...
                'DrawMode','fast',...
                'FontSize',9,...
                'XLim',[1,DF.Nd],...
                'YLim',[min0-0.1*MM max0+0.1*MM],...
                'Tag','Simulating Evaluation Axes',...
                'Parent',h_pse);  
     XLabel('Samples','Color',[0 1 1]);
     YLabel('Actual & Required','Color',[0 1 1]);
     set(h_psea1L1,...
                  'LineStyle','-','LineWidth',1,...
                  'Color',[0 1 0],...
                  'EraseMode','BackGround',...
                  'Tag','Simulating Evaluation Line',...                  
                  'Parent',h_psea1); 
     line('XData',1:DF.Nd,'YData',DF.OriTeach,...
                  'LineStyle','--','LineWidth',1,...
                  'Color',[1 0 1],...
                  'EraseMode','BackGround',...
                  'Parent',h_psea1);         
     drawnow
  return;  
%--------------------------------------------------------------------------------
%  denfisgui_plotsimulate1
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_plotsabse
%--------------------------------------------------------------------------------
  function denfisgui_plotsabse(DF)

     if DF.AbsoluteError == 0
        return;
     end   
     if DF.NumSap == 2
        % create the figure object for evaluation   
        denfisgui_plotsabse1(DF);
     else       
        [MaxErr,NumFig] = denfisgui_gethandle('DENFIS Simulating AbsoluteError');
        if NumFig < 1
           return;
        end
        h_psaa1   = findobj('Tag','Simulating AbsErr Axes');
        h_psaa1L1 = findobj('Tag','Simulating AbsErr Line');
       
        MaxErr0 = max([MaxErr 1.2*max(DF.Abe) 1.2*abs(min(DF.Abe))]);
        if MaxErr < MaxErr0
           MaxErr = MaxErr0;
           set(NumFig,'Userdata',MaxErr);
           set(h_psaa1,'YLim',[-MaxErr MaxErr]);
        end
        set(h_psaa1L1,'XData',1:DF.NumSap,'YData',DF.Abe(1:DF.NumSap));
     end 
     
     drawnow
  return;  
%--------------------------------------------------------------------------------
%  denfisgui_plotsabse end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_plotsabse1: create the figure object for plotting absolute errors 
%--------------------------------------------------------------------------------
  function denfisgui_plotsabse1(DF)
 
     [FHandle,NumFig] = ...
         denfisgui_gethandle('DENFIS Simulating AbsoluteError');
     if NumFig > 0
        close(NumFig) 
     end
   
     h_psa = figure('position',[420 280 600 150],...
                   'numbertitle', 'off',...
                   'BackingStore','off',...
                   'resize','on',...
                   'MenuBar','none',...
                   'Name','DENFIS Simulating AbsoluteError',...
                   'Color', [0.4, 0.4, 0.4 ]);

     h_psaa1L1  = line([-1000 1],[1 -1000]);
 
     h_psaa1 = gca;
     set(h_psaa1,'Position',[0.08 0.25 0.88 0.70],...
                'Color',[0.1 0.1 0.3],...
                'NextPlot','add',...
                'XColor','w','YColor','w',...
                'Box','on',...
                'DrawMode','fast',...
                'FontSize',9,...
                'XLim',[1,DF.Nd],...
                'YLim',[-0.01 0.01],...
                'Tag','Simulating AbsErr Axes',...
                'Parent',h_psa);  
     XLabel('Samples','Color',[0 1 1]);
     YLabel('AbsoluteError','Color',[0 1 1]);
     set(h_psaa1L1,...
                  'LineStyle','-','LineWidth',1,...
                  'Color',[1 1 0],...
                  'EraseMode','BackGround',...
                  'Tag','Simulating AbsErr Line',...
                  'Parent',h_psaa1); 
     line('XData',[1 DF.Nd],'YData',[0 0],...
                  'LineStyle',':','LineWidth',1,...
                  'Color',[0.5 0.5 0.5],...
                  'EraseMode','BackGround',...
                  'Parent',h_psaa1);
              
     set(h_psa,'Userdata',0.01);         
     drawnow
  return;  
%--------------------------------------------------------------------------------
%  denfisgui_plotsabse1
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_plotsrmse
%--------------------------------------------------------------------------------
  function denfisgui_plotsrmse(DF)
 
     if DF.RMSE == 0
        return;
     end   
     if DF.NumSap == 2
        % create the figure object for evaluation   
        denfisgui_plotsrmse1(DF);
     else       
        [FHandle,NumFig] = denfisgui_gethandle('DENFIS Simulating RMSE');
        if NumFig < 1
           return;
        end
        h_psra1   = findobj('Tag','Simulating RMSE Axes');
        h_psra1L1 = findobj('Tag','Simulating RMSE Line');
        
        if FHandle < 1.1 * max(DF.Rmse)
           FHandle = 1.2 * max(DF.Rmse);
           set(NumFig,'Userdata',FHandle);
           set(h_psra1,'YLim',[0 FHandle]);
        end
        set(h_psra1L1,'XData',1:DF.NumSap,'YData',DF.Rmse(1:DF.NumSap));
     end 
     
     drawnow
  return;  
%--------------------------------------------------------------------------------
%  denfisgui_plotsrmse
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_plotsrme1: create the figure object for plotting rmse 
%--------------------------------------------------------------------------------
  function denfisgui_plotsrmse1(DF)
 
     [FHandle,NumFig] = denfisgui_gethandle('DENFIS Simulating RMSE');
     if NumFig > 0
        close(NumFig) 
     end
   
     h_psr = figure('position',[220 560 320 150],...
                   'numbertitle', 'off',...
                   'BackingStore','off',...
                   'resize','on',...
                   'MenuBar','none',...
                   'Name','DENFIS Simulating RMSE',...
                   'Color', [0.4, 0.4, 0.4 ]);

     h_psra1L1  = line([-1000 1],[1 -1000]);
 
     h_psra1 = gca;
     set(h_psra1,'Position',[0.15 0.25 0.80 0.70],...
                'Color',[0.1 0.1 0.3],...
                'NextPlot','add',...
                'XColor','w','YColor','w',...
                'Box','on',...
                'DrawMode','fast',...
                'FontSize',9,...
                'XLim',[1,DF.Nd],...
                'YLim',[0 0.001],...
                'Tag','Simulating RMSE Axes',...
                'Parent',h_psr);  
     XLabel('Samples','Color',[0 1 1]);
     YLabel('RMSE','Color',[0 1 1]);
     
     set(h_psra1L1,...
                  'LineStyle','-','LineWidth',1,...
                  'Color',[1 1 0],...
                  'EraseMode','BackGround',...
                  'Tag','Simulating RMSE Line',...
                  'Parent',h_psra1); 
              
     set(h_psr,'Userdata',0.001);
     drawnow
  return;  
%--------------------------------------------------------------------------------
%  denfisgui_plotsrmse1
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_plotsndei
%--------------------------------------------------------------------------------
  function denfisgui_plotsndei(DF)

     if DF.NDEI == 0
        return;
     end   
     if DF.NumSap == 2
        % create the figure object for evaluation   
        denfisgui_plotsndei1(DF);
     else        
        [FHandle,NumFig] = denfisgui_gethandle('DENFIS Simulating NDEI');
        if NumFig < 1
           return;
        end
        h_psna1   = findobj('Tag','Simulating NDEI Axes');
        h_psna1L1 = findobj('Tag','Simulating NDEI Line');
       
        if FHandle < 1.1 * max(DF.Ndei)
           FHandle = 1.2 * max(DF.Ndei);
           set(NumFig,'Userdata',FHandle);
           set(h_psna1,'YLim',[0 FHandle]);
        end
        set(h_psna1L1,'XData',1:DF.NumSap,'YData',DF.Ndei(1:DF.NumSap));
     end 
     
     drawnow
  return;  
%--------------------------------------------------------------------------------
%  denfisgui_plotsndei
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%  denfisgui_plotsndei1: create the figure object for plotting ndei 
%--------------------------------------------------------------------------------
  function denfisgui_plotsndei1(DF)
 
     [FHandle,NumFig] = denfisgui_gethandle('DENFIS Simulating NDEI');
     if NumFig > 0
        close(NumFig) 
     end
   
     h_psn = figure('position',[250 400 320 150],...
                   'numbertitle', 'off',...
                   'BackingStore','off',...
                   'resize','on',...
                   'MenuBar','none',...
                   'Name','DENFIS Simulating NDEI',...
                   'Color', [0.4, 0.4, 0.4 ]);

     h_psna1L1  = line([-1000 1],[1 -1000]);
 
     h_psna1 = gca;
     set(h_psna1,'Position',[0.15 0.25 0.80 0.70],...
                'Color',[0.1 0.1 0.3],...
                'NextPlot','add',...
                'XColor','w','YColor','w',...
                'Box','on',...
                'DrawMode','fast',...
                'FontSize',9,...
                'XLim',[1,DF.Nd],...
                'YLim',[0 0.001],...
                'Tag','Simulating NDEI Axes',...
                'Parent',h_psn);  
     XLabel('Samples','Color',[0 1 1]);
     YLabel('NDEI','Color',[0 1 1]);
     
     set(h_psna1L1,...
                  'LineStyle','-','LineWidth',1,...
                  'Color',[1 1 0],...
                  'EraseMode','BackGround',...
                  'Tag','Simulating NDEI Line',...
                  'Parent',h_psna1); 
     drawnow

     set(h_psn,'Userdata',0.001);
  return;  
%--------------------------------------------------------------------------------
%  denfisgui_plotsndei1
%--------------------------------------------------------------------------------
