object ReadmeForm: TReadmeForm
  Left = 125
  Top = 93
  Width = 611
  Height = 580
  BorderStyle = bsSizeToolWin
  Caption = 'Readme'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Memo: TMemo
    Left = 0
    Top = 0
    Width = 603
    Height = 546
    Align = alClient
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Courier New'
    Font.Style = []
    Lines.Strings = (
      #1055#1077#1088#1077#1074#1086#1076' Silent Hill Origins.'
      'http://consolgames.ru/'
      'http://ex-ve.ucoz.ru/')
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
  end
end
