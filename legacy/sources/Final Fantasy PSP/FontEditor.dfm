object Form1: TForm1
  Left = 123
  Top = 135
  Width = 696
  Height = 480
  Caption = 'FontEditor'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object DXS: TDXDraw
    Left = 528
    Top = 0
    Width = 153
    Height = 241
    AutoInitialize = True
    AutoSize = True
    Color = clBtnFace
    Display.FixedBitCount = True
    Display.FixedRatio = True
    Display.FixedSize = False
    Options = [doAllowReboot, doWaitVBlank, doCenter, doDirectX7Mode, doHardware, doSelectDriver]
    SurfaceHeight = 241
    SurfaceWidth = 153
    TabOrder = 0
  end
end
