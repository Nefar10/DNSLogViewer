object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'DNSLogViwer'
  ClientHeight = 61
  ClientWidth = 377
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = Menu
  OnCreate = FormCreate
  TextHeight = 15
  object StatBar: TStatusBar
    Left = 0
    Top = 42
    Width = 377
    Height = 19
    Panels = <
      item
        Width = 50
      end>
    ExplicitTop = 33
    ExplicitWidth = 371
  end
  object PB: TProgressBar
    Left = 8
    Top = 8
    Width = 361
    Height = 25
    TabOrder = 1
    Visible = False
  end
  object Menu: TMainMenu
    Left = 272
    Top = 24
    object M_File: TMenuItem
      Caption = #1060#1072#1081#1083
      object M_File_Open: TMenuItem
        Caption = #1054#1090#1082#1088#1099#1090#1100' '#1092#1072#1081#1083
        OnClick = M_File_OpenClick
      end
      object M_File_OpenFolder: TMenuItem
        Caption = #1054#1090#1082#1088#1099#1090#1100' '#1087#1072#1087#1082#1091
      end
      object M_File_MSAccess: TMenuItem
        Caption = #1069#1082#1089#1087#1086#1088#1090' '#1074' MS Access'
        OnClick = M_File_MSAccessClick
      end
      object M_File_Line1: TMenuItem
        Caption = '-'
      end
      object M_File_Exit: TMenuItem
        Caption = #1042#1099#1093#1086#1076
      end
    end
  end
end
