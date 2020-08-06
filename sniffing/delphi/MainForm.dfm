object FormMain: TFormMain
  Left = 0
  Top = 0
  Caption = 'Computrainer Sniffer - Stephen Done 2020'
  ClientHeight = 779
  ClientWidth = 1198
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMaximized
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel3: TPanel
    Left = 1038
    Top = 0
    Width = 160
    Height = 779
    Align = alRight
    TabOrder = 0
    ExplicitLeft = 1039
    ExplicitTop = 7
    object grpDebug: TGroupBox
      AlignWithMargins = True
      Left = 7
      Top = 106
      Width = 144
      Height = 311
      Margins.Left = 6
      Margins.Top = 0
      Margins.Right = 8
      Margins.Bottom = 0
      Align = alTop
      Caption = 'Debug'
      TabOrder = 0
      object chkDebugRaw: TCheckBox
        Left = 14
        Top = 25
        Width = 150
        Height = 17
        Caption = 'Debug Raw Data'
        TabOrder = 0
      end
      object chkDebugRawPackets: TCheckBox
        Left = 14
        Top = 48
        Width = 150
        Height = 17
        Caption = 'Debug Raw Packets'
        TabOrder = 1
      end
      object chkDebugFields: TCheckBox
        Left = 14
        Top = 71
        Width = 150
        Height = 17
        Caption = 'Debug Packet Fields'
        TabOrder = 2
      end
      object chkDebugState: TCheckBox
        Left = 14
        Top = 94
        Width = 150
        Height = 17
        Caption = 'Debug State'
        Checked = True
        State = cbChecked
        TabOrder = 3
      end
      object chkDebugStateChanges: TCheckBox
        Left = 14
        Top = 125
        Width = 150
        Height = 17
        Caption = 'Debug State Changes'
        Checked = True
        State = cbChecked
        TabOrder = 4
      end
      object btnClearDebug: TButton
        Left = 14
        Top = 225
        Width = 100
        Height = 25
        Caption = 'Clear Debug'
        TabOrder = 5
        OnClick = btnClearDebugClick
      end
      object chkDebugSpinscanValues: TCheckBox
        Left = 22
        Top = 148
        Width = 97
        Height = 17
        Caption = 'SpinScan Values'
        TabOrder = 6
        OnClick = chkDebugSpinscanValuesClick
      end
      object chkDebugParamValues: TCheckBox
        Left = 22
        Top = 171
        Width = 97
        Height = 17
        Caption = 'Parameter Values'
        TabOrder = 7
        OnClick = chkDebugParamValuesClick
      end
      object chkDebugButtonValues: TCheckBox
        Left = 22
        Top = 194
        Width = 97
        Height = 17
        Caption = 'Button Values'
        TabOrder = 8
        OnClick = chkDebugButtonValuesClick
      end
      object btnClearState: TButton
        Left = 14
        Top = 256
        Width = 99
        Height = 25
        Caption = 'Clear State'
        TabOrder = 9
        OnClick = btnClearStateClick
      end
    end
    object grpPort: TGroupBox
      AlignWithMargins = True
      Left = 7
      Top = 1
      Width = 144
      Height = 105
      Margins.Left = 6
      Margins.Top = 0
      Margins.Right = 8
      Margins.Bottom = 0
      Align = alTop
      Caption = 'Port'
      TabOrder = 1
      object Close: TButton
        Left = 14
        Top = 58
        Width = 100
        Height = 25
        Caption = 'Close'
        TabOrder = 0
        OnClick = btnCloseClick
      end
      object btnOpen: TButton
        Left = 14
        Top = 27
        Width = 100
        Height = 25
        Caption = 'Open'
        TabOrder = 1
        OnClick = btnOpenClick
      end
    end
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 1038
    Height = 779
    ActivePage = TabSheet2
    Align = alClient
    TabOrder = 1
    OnResize = PageControl1Resize
    object TabSheet1: TTabSheet
      Caption = 'Data'
      ExplicitLeft = 0
      ExplicitTop = 23
      ExplicitWidth = 777
      ExplicitHeight = 436
      object memoCtData: TMemo
        Left = 481
        Top = 0
        Width = 549
        Height = 751
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
        ScrollBars = ssVertical
        TabOrder = 0
        ExplicitLeft = 438
        ExplicitTop = -3
        ExplicitWidth = 345
        ExplicitHeight = 436
      end
      object memoPcData: TMemo
        Left = 0
        Top = 0
        Width = 481
        Height = 751
        Align = alLeft
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
        ScrollBars = ssVertical
        TabOrder = 1
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'State'
      ImageIndex = 1
      ExplicitWidth = 281
      ExplicitHeight = 165
      object Splitter2: TSplitter
        Left = 0
        Top = 430
        Width = 1030
        Height = 5
        Cursor = crVSplit
        Align = alTop
        ExplicitTop = 351
      end
      object Panel5: TPanel
        Left = 0
        Top = 0
        Width = 1030
        Height = 430
        Align = alTop
        TabOrder = 0
        object memoPcState: TMemo
          Left = 1
          Top = 1
          Width = 584
          Height = 428
          Align = alLeft
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -22
          Font.Name = 'Courier New'
          Font.Style = [fsBold]
          ParentFont = False
          ScrollBars = ssVertical
          TabOrder = 0
        end
        object memoCtState: TMemo
          Left = 585
          Top = 1
          Width = 444
          Height = 428
          Align = alClient
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -22
          Font.Name = 'Courier New'
          Font.Style = [fsBold]
          ParentFont = False
          ScrollBars = ssVertical
          TabOrder = 1
          ExplicitLeft = 431
          ExplicitTop = 2
          ExplicitWidth = 597
          ExplicitHeight = 420
        end
      end
      object Panel4: TPanel
        Left = 0
        Top = 435
        Width = 1030
        Height = 316
        Align = alClient
        TabOrder = 1
        ExplicitTop = 351
        ExplicitHeight = 400
        object memoPcStateChange: TMemo
          Left = 1
          Top = 1
          Width = 584
          Height = 314
          Align = alLeft
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -22
          Font.Name = 'Courier New'
          Font.Style = [fsBold]
          ParentFont = False
          ScrollBars = ssVertical
          TabOrder = 0
        end
        object memoCtStateChange: TMemo
          Left = 585
          Top = 1
          Width = 444
          Height = 314
          Align = alClient
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -22
          Font.Name = 'Courier New'
          Font.Style = [fsBold]
          ParentFont = False
          ScrollBars = ssVertical
          TabOrder = 1
          ExplicitLeft = 431
          ExplicitTop = 0
          ExplicitWidth = 597
          ExplicitHeight = 393
        end
      end
    end
  end
end
