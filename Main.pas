unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.Menus, Vcl.Buttons,
  Vcl.ExtDlgs;

type
  TForm1 = class(TForm)
    StatusBar1: TStatusBar;
    Menu: TMainMenu;
    M_File: TMenuItem;
    M_File_Open: TMenuItem;
    M_File_OpenFolder: TMenuItem;
    M_File_Line1: TMenuItem;
    M_File_Exit: TMenuItem;
    procedure OpenFileClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.OpenFileClick(Sender: TObject);
var
  openFileDialog: TOpenTextFileDialog;
  fileStream: TStreamReader;
  line: string;
begin
  openFileDialog := TOpenTextFileDialog.Create(nil);
  try
    // ����������� ������ ��� �������� ��������� ������
    openFileDialog.Options := [ofReadOnly, ofFileMustExist];
    openFileDialog.Filter := '��������� ����� (*.txt)|*.txt';

    // ���� ������������ �������� ���� � �������� ������ "�������"
    if openFileDialog.Execute then
    begin
      // ��������� ��������� ���� ��� ������
      fileStream := TStreamReader.Create(openFileDialog.FileName);
      try
        // ������ ���� ���������
        while not fileStream.EndOfStream do
        begin
          line := fileStream.ReadLine;

          // ������������ ������ ������
          // ��������, ������� �� ���������� �� �����
          ShowMessage(line);
        end;
      finally
        // ��������� ����
        fileStream.Free;
      end;
    end;
  finally
    openFileDialog.Free;
  end;
end;

end.
