object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 565
  ClientWidth = 1005
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = Menu
  TextHeight = 15
  object StatusBar1: TStatusBar
    Left = 0
    Top = 546
    Width = 1005
    Height = 19
    Panels = <>
    ExplicitTop = 537
    ExplicitWidth = 999
  end
  object Menu: TMainMenu
    Left = 8
    Top = 8
    object M_File: TMenuItem
      Caption = #1060#1072#1081#1083
      object M_File_Open: TMenuItem
        Caption = #1054#1090#1082#1088#1099#1090#1100' '#1092#1072#1081#1083
        OnClick = OpenFileClick
      end
      object M_File_OpenFolder: TMenuItem
        Caption = #1054#1090#1082#1088#1099#1090#1100' '#1087#1072#1087#1082#1091
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
