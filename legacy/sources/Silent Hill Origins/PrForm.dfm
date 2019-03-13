object ProgressForm: TProgressForm
  Left = 133
  Top = 56
  Width = 801
  Height = 600
  Caption = 'ProgressForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Screen: TDXDraw
    Left = 0
    Top = 0
    Width = 793
    Height = 549
    AutoInitialize = True
    AutoSize = True
    Color = clBtnFace
    Display.FixedBitCount = True
    Display.FixedRatio = True
    Display.FixedSize = False
    Options = [doAllowReboot, doWaitVBlank, doCenter, doDirectX7Mode, doHardware, doSelectDriver]
    SurfaceHeight = 549
    SurfaceWidth = 793
    OnInitialize = ScreenInitialize
    Align = alClient
    TabOrder = 0
    Traces = <>
  end
  object Button1: TButton
    Left = 648
    Top = 488
    Width = 129
    Height = 49
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = Button1Click
  end
  object ProgressBar: TProgressBar
    Left = 0
    Top = 549
    Width = 793
    Height = 17
    Align = alBottom
    Min = 50
    Position = 75
    Smooth = True
    TabOrder = 2
  end
  object eLevel0: TTrackBar
    Left = 528
    Top = 416
    Width = 249
    Height = 25
    PageSize = 1
    TabOrder = 3
    TickMarks = tmBoth
    TickStyle = tsNone
    OnChange = eLevel0Change
  end
  object eLevel1: TTrackBar
    Left = 528
    Top = 440
    Width = 249
    Height = 25
    TabOrder = 4
    TickMarks = tmBoth
    TickStyle = tsNone
    OnChange = eLevel1Change
  end
  object Timer1: TTimer
    Interval = 10000
    OnTimer = Timer1Timer
    Left = 112
    Top = 24
  end
end
