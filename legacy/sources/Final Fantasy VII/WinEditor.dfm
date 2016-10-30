object WForm: TWForm
  Left = 320
  Top = 203
  Width = 490
  Height = 353
  Caption = #1056#1077#1076#1072#1082#1090#1086#1088' '#1086#1082#1086#1085
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnResize = FormResize
  DesignSize = (
    482
    319)
  PixelsPerInch = 96
  TextHeight = 13
  object WScreen: TDXDraw
    Left = 0
    Top = 0
    Width = 400
    Height = 300
    AutoInitialize = True
    AutoSize = True
    Color = clBtnFace
    Display.FixedBitCount = True
    Display.FixedRatio = True
    Display.FixedSize = False
    Options = [doAllowReboot, doWaitVBlank, doCenter, doDirectX7Mode, doHardware, doSelectDriver]
    SurfaceHeight = 300
    SurfaceWidth = 400
    TabOrder = 0
    OnMouseDown = WScreenMouseDown
    OnMouseMove = WScreenMouseMove
    OnMouseUp = WScreenMouseUp
  end
  object weX: TEdit
    Left = 400
    Top = 0
    Width = 41
    Height = 19
    Ctl3D = False
    Enabled = False
    ParentCtl3D = False
    TabOrder = 1
    Text = '40'
    OnChange = weXChange
  end
  object weY: TEdit
    Left = 440
    Top = 0
    Width = 41
    Height = 19
    Ctl3D = False
    Enabled = False
    ParentCtl3D = False
    TabOrder = 2
    Text = '20'
    OnChange = weYChange
  end
  object weW: TEdit
    Left = 400
    Top = 16
    Width = 41
    Height = 19
    Ctl3D = False
    Enabled = False
    ParentCtl3D = False
    TabOrder = 3
    Text = '133'
    OnChange = weWChange
  end
  object weH: TEdit
    Left = 440
    Top = 16
    Width = 41
    Height = 19
    Ctl3D = False
    Enabled = False
    ParentCtl3D = False
    TabOrder = 4
    Text = '41'
    OnChange = weHChange
  end
  object Status: TStatusBar
    Left = 0
    Top = 300
    Width = 482
    Height = 19
    Panels = <
      item
        Width = 128
      end
      item
        Width = 256
      end
      item
        Width = 50
      end>
  end
  object YBar: TScrollBar
    Left = 404
    Top = 32
    Width = 20
    Height = 271
    Anchors = [akLeft, akTop, akBottom]
    Kind = sbVertical
    Max = 480
    PageSize = 0
    TabOrder = 6
    Visible = False
    OnChange = YBarChange
  end
  object chOnTop: TCheckBox
    Left = 425
    Top = 40
    Width = 57
    Height = 17
    Action = AOnTopSet
    State = cbChecked
    TabOrder = 7
  end
  object AList: TActionList
    Left = 432
    Top = 72
    object AOnTopSet: TAction
      Caption = #1042#1074#1077#1088#1093#1091
      Checked = True
      OnExecute = AOnTopSetExecute
    end
  end
end
