object Form1: TForm1
  Left = 192
  Top = 114
  Width = 696
  Height = 480
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object Img: TImage
    Left = 264
    Top = 0
    Width = 240
    Height = 160
  end
  object VList: TValueListEditor
    Left = 520
    Top = 8
    Width = 161
    Height = 177
    Strings.Strings = (
      'Count='
      'Unk1='
      'Unk2='
      'Unk3='
      'TegFFFF='
      'Pointer='
      'Teg1='
      'Teg2=')
    TabOrder = 0
    ColWidths = (
      65
      90)
  end
  object List: TListBox
    Left = 0
    Top = 0
    Width = 105
    Height = 441
    ItemHeight = 13
    TabOrder = 1
    OnClick = ListClick
  end
  object Button1: TButton
    Left = 360
    Top = 176
    Width = 81
    Height = 57
    Caption = 'Button1'
    TabOrder = 2
    OnClick = Button1Click
  end
  object SList: TListBox
    Left = 112
    Top = 0
    Width = 145
    Height = 305
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ItemHeight = 14
    ParentFont = False
    TabOrder = 3
    OnClick = SListClick
  end
  object VSList: TValueListEditor
    Left = 519
    Top = 200
    Width = 161
    Height = 153
    Strings.Strings = (
      'Unk='
      'X='
      'Y='
      'W='
      'H='
      'Unk2='
      'Ptr=')
    TabOrder = 4
    ColWidths = (
      65
      73)
  end
  object LoadPallete: TButton
    Left = 128
    Top = 312
    Width = 65
    Height = 33
    Caption = 'LoadPallete'
    TabOrder = 5
    OnClick = LoadPalleteClick
  end
  object Memo: TMemo
    Left = 272
    Top = 264
    Width = 185
    Height = 49
    Lines.Strings = (
      'Memo')
    TabOrder = 6
  end
  object Button2: TButton
    Left = 384
    Top = 376
    Width = 73
    Height = 65
    Caption = 'Button2'
    TabOrder = 7
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 464
    Top = 376
    Width = 65
    Height = 65
    Caption = 'Button3'
    TabOrder = 8
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 128
    Top = 352
    Width = 65
    Height = 33
    Caption = 'SaveFile'
    TabOrder = 9
    OnClick = Button4Click
  end
  object OD: TOpenDialog
    Filter = 'Act|*.act'
    Left = 256
    Top = 360
  end
  object SP: TSavePictureDialog
    Left = 320
    Top = 368
  end
  object ActionList1: TActionList
    Left = 320
    Top = 192
    object ASPicture: TAction
      Caption = 'ASPicture'
      ShortCut = 16467
      OnExecute = ASPictureExecute
    end
    object Action1: TAction
      Caption = 'Action1'
    end
  end
end
