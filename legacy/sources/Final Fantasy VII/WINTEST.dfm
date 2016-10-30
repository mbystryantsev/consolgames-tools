object Form1: TForm1
  Left = 222
  Top = 96
  Width = 413
  Height = 276
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object WScreen: TDXDraw
    Left = 0
    Top = 0
    Width = 320
    Height = 240
    AutoInitialize = True
    AutoSize = True
    Color = clBtnFace
    Display.FixedBitCount = True
    Display.FixedRatio = True
    Display.FixedSize = False
    Options = [doAllowReboot, doWaitVBlank, doCenter, doDirectX7Mode, doHardware, doSelectDriver]
    SurfaceHeight = 240
    SurfaceWidth = 320
    TabOrder = 0
    OnMouseDown = WScreenMouseDown
    OnMouseMove = WScreenMouseMove
    OnMouseUp = WScreenMouseUp
  end
  object Button1: TButton
    Left = 320
    Top = 0
    Width = 81
    Height = 25
    Caption = 'DrawTest'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 320
    Top = 24
    Width = 81
    Height = 25
    Caption = 'DrawWindow'
    TabOrder = 2
    OnClick = Button2Click
  end
  object weX: TEdit
    Left = 320
    Top = 48
    Width = 41
    Height = 19
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 3
    Text = '40'
  end
  object weY: TEdit
    Left = 360
    Top = 48
    Width = 41
    Height = 19
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 4
    Text = '20'
  end
  object weW: TEdit
    Left = 320
    Top = 64
    Width = 41
    Height = 19
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 5
    Text = '133'
  end
  object weH: TEdit
    Left = 360
    Top = 64
    Width = 41
    Height = 19
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 6
    Text = '41'
  end
  object Button3: TButton
    Left = 320
    Top = 80
    Width = 81
    Height = 25
    Caption = 'BinTest'
    TabOrder = 7
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 320
    Top = 104
    Width = 81
    Height = 25
    Caption = 'FontTest'
    TabOrder = 8
    OnClick = Button4Click
  end
end
