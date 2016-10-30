object Form1: TForm1
  Left = 266
  Top = 126
  Width = 696
  Height = 504
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
  object Button1: TButton
    Left = 0
    Top = 0
    Width = 65
    Height = 25
    Caption = 'AssignDat'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 0
    Top = 24
    Width = 65
    Height = 25
    Caption = 'GetBack'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 0
    Top = 48
    Width = 65
    Height = 25
    Caption = 'LoadText'
    TabOrder = 2
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 0
    Top = 72
    Width = 65
    Height = 25
    Caption = 'TextExtract'
    TabOrder = 3
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 0
    Top = 96
    Width = 65
    Height = 25
    Caption = 'BuildDat'
    TabOrder = 4
    OnClick = Button5Click
  end
  object Button6: TButton
    Left = 0
    Top = 120
    Width = 65
    Height = 25
    Caption = 'PasteText'
    TabOrder = 5
    OnClick = Button6Click
  end
  object Button7: TButton
    Left = 0
    Top = 144
    Width = 65
    Height = 25
    Caption = 'InsertText'
    TabOrder = 6
    OnClick = Button7Click
  end
  object Button8: TButton
    Left = 0
    Top = 168
    Width = 65
    Height = 25
    Caption = 'Decompress'
    TabOrder = 7
    OnClick = Button8Click
  end
  object Button9: TButton
    Left = 0
    Top = 192
    Width = 65
    Height = 25
    Caption = 'Decompile'
    TabOrder = 8
    OnClick = Button9Click
  end
  object SList: TListBox
    Left = 72
    Top = 0
    Width = 153
    Height = 289
    ItemHeight = 13
    TabOrder = 9
    OnClick = SListClick
  end
  object Button10: TButton
    Left = 0
    Top = 216
    Width = 65
    Height = 25
    Caption = 'GetPart'
    TabOrder = 10
    OnClick = Button10Click
  end
  object Button11: TButton
    Left = 0
    Top = 240
    Width = 65
    Height = 25
    Caption = 'OpenText'
    TabOrder = 11
    OnClick = Button11Click
  end
  object Memo: TMemo
    Left = 232
    Top = 0
    Width = 305
    Height = 289
    Lines.Strings = (
      'Memo')
    ScrollBars = ssVertical
    TabOrder = 12
  end
  object Button12: TButton
    Left = 0
    Top = 264
    Width = 65
    Height = 25
    Caption = 'WinView'
    TabOrder = 13
    OnClick = Button12Click
  end
  object Button13: TButton
    Left = 0
    Top = 288
    Width = 65
    Height = 25
    Caption = 'LoadField'
    TabOrder = 14
    OnClick = Button13Click
  end
  object Button14: TButton
    Left = 0
    Top = 312
    Width = 65
    Height = 25
    Caption = 'GLib_Unc'
    TabOrder = 15
    OnClick = Button14Click
  end
  object Button15: TButton
    Left = 0
    Top = 336
    Width = 65
    Height = 25
    Caption = 'GZip_Com'
    TabOrder = 16
    OnClick = Button15Click
  end
  object Button16: TButton
    Left = 0
    Top = 360
    Width = 65
    Height = 25
    Caption = 'Compress'
    TabOrder = 17
    OnClick = Button16Click
  end
  object edGetBack: TEdit
    Left = 544
    Top = 8
    Width = 49
    Height = 21
    TabOrder = 18
    Text = '6'
  end
  object Button17: TButton
    Left = 544
    Top = 48
    Width = 65
    Height = 25
    Caption = 'LZ_GetBack'
    TabOrder = 19
    OnClick = Button17Click
  end
  object edPos: TEdit
    Left = 616
    Top = 8
    Width = 49
    Height = 21
    TabOrder = 20
    Text = '19'
  end
  object Button18: TButton
    Left = 0
    Top = 384
    Width = 65
    Height = 25
    Caption = 'AssignGZip'
    TabOrder = 21
    OnClick = Button18Click
  end
  object Button19: TButton
    Left = 0
    Top = 408
    Width = 65
    Height = 25
    Caption = 'KernelText'
    TabOrder = 22
    OnClick = Button19Click
  end
  object Button20: TButton
    Left = 544
    Top = 224
    Width = 73
    Height = 25
    Caption = 'LBA_List'
    TabOrder = 23
    OnClick = Button20Click
  end
  object Button21: TButton
    Left = 72
    Top = 296
    Width = 73
    Height = 25
    Caption = 'LoadDat'
    TabOrder = 24
    OnClick = Button21Click
  end
  object Button22: TButton
    Left = 72
    Top = 320
    Width = 73
    Height = 25
    Caption = 'SaveDat'
    TabOrder = 25
    OnClick = Button22Click
  end
  object edLBAOffset: TEdit
    Left = 616
    Top = 224
    Width = 65
    Height = 21
    TabOrder = 26
    Text = '00047D50'
  end
  object edLBAFile: TEdit
    Left = 544
    Top = 256
    Width = 137
    Height = 21
    TabOrder = 27
    Text = 'BATTLE\BATTLE.X/'
  end
  object Button23: TButton
    Left = 616
    Top = 200
    Width = 65
    Height = 25
    Caption = 'Select'
    TabOrder = 28
    OnClick = Button23Click
  end
  object edLBACount: TEdit
    Left = 544
    Top = 200
    Width = 65
    Height = 21
    TabOrder = 29
    Text = '205'
  end
  object edLBAStep: TEdit
    Left = 576
    Top = 176
    Width = 57
    Height = 21
    TabOrder = 30
    Text = '8'
  end
  object Button24: TButton
    Left = 136
    Top = 392
    Width = 49
    Height = 33
    Caption = 'Button24'
    TabOrder = 31
  end
  object Button25: TButton
    Left = 144
    Top = 344
    Width = 73
    Height = 25
    Caption = 'OverToBMP'
    TabOrder = 32
    OnClick = Button25Click
  end
  object Edit1: TEdit
    Left = 144
    Top = 320
    Width = 41
    Height = 21
    TabOrder = 33
  end
  object OpenDialog1: TOpenDialog
    Left = 544
    Top = 168
  end
end
