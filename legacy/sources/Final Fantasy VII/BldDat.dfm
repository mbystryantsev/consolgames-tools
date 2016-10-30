object BDForm: TBDForm
  Left = 419
  Top = 170
  BorderStyle = bsToolWindow
  Caption = 'Building DAT-files...'
  ClientHeight = 80
  ClientWidth = 511
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Progress: TProgressBar
    Left = 8
    Top = 8
    Width = 497
    Height = 25
    Smooth = True
    Step = 1
    TabOrder = 0
  end
  object Panel: TPanel
    Left = 8
    Top = 40
    Width = 417
    Height = 33
    BevelOuter = bvLowered
    TabOrder = 1
  end
  object bCancel: TBitBtn
    Left = 432
    Top = 40
    Width = 73
    Height = 33
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 2
    OnClick = bCancelClick
    Glyph.Data = {
      F6000000424DF600000000000000760000002800000010000000100000000100
      04000000000080000000120B0000120B00001000000000000000FF60600000FF
      FF00FF00FF000000FF00FFFF000000FF0000FF00000000000000E663E6007000
      0000EE8B00007BE65A002139FE00FEFEFE00636363001818180000000FFFFFF0
      0000000FFFFFFFFFF00000FFFFFFFFFFFF000FFFCFFFFFFCFFF00FFCCCFFFFCC
      CFF0FFFFCCCFFCCCFFFFFFFFFCCCCCCFFFFFFFFFFFCCCCFFFFFFFFFFFFCCCCFF
      FFFFFFFFFCCCCCCFFFFFFFFFCCCFFCCCFFFF0FECCCFFFFCCCFF00FFDCFFFFFFC
      FFF000FFEFFFFFFFFF00000FFFFFFFFFF00000000FFFFFF00000}
  end
end
