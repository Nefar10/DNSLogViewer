unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.Menus, Vcl.Buttons,
  Vcl.ExtDlgs, Data.DB, Data.Win.ADODB, Vcl.StdCtrls, ComObj, Registry;

type
  TMainForm = class(TForm)
    StatBar: TStatusBar;
    Menu: TMainMenu;
    M_File: TMenuItem;
    M_File_Open: TMenuItem;
    M_File_OpenFolder: TMenuItem;
    M_File_Line1: TMenuItem;
    M_File_Exit: TMenuItem;
    ADOConnection1: TADOConnection;
    M_File_MSAccess: TMenuItem;
    procedure M_File_OpenClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure M_File_MSAccessClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    stringList: TStringList;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  stringList := TStringList.Create;                                             // ������� ��������� TStringList
end;

procedure TMainForm.M_File_MSAccessClick(Sender: TObject); 
var
  openFileDialog: TOpenDialog;
  cat: OLEVariant;
begin
  openFileDialog := TOpenDialog.Create(nil);
  try
    openFileDialog.Filter := '���� MS Access (*.mdb)|*.mdb';
    if openFileDialog.Execute then begin                                        // ���� ������������ �������� ���� � �������� ������ "�������"
      cat := CreateOleObject('ADOX.Catalog');
      cat.Create('Provider=Microsoft.Jet.OLEDB.4.0;Data Source=' 
       + openFileDialog.FileName + ';');
      cat := NULL;
    end;
  finally
    openFileDialog.Free;
  end;  
end;


    //        if (i>29) then 
    //          if (i mod 2 >0) then begin
    //            showmessage(curline);
    //          end;
            
//end;      

procedure TMainForm.M_File_OpenClick(Sender: TObject);
var
  openFileDialog: TOpenTextFileDialog;
  fileStream: TFileStream;
  textStream: TStringStream;
  lineCount: Integer;
  text: String;
  i:int64;
  curline:string;
begin
  openFileDialog := TOpenTextFileDialog.Create(nil);
  try
    openFileDialog.Options := [ofReadOnly, ofFileMustExist];                    // ����������� ������ ��� �������� ��������� ������
    openFileDialog.Filter := '��������� ����� (*.txt)|*.txt';
    if openFileDialog.Execute then begin                                        // ���� ������������ �������� ���� � �������� ������ "�������"
      fileStream := TFileStream.Create(openFileDialog.FileName, fmOpenRead);    // ��������� ���� � ������ ������
      try
        textStream := TStringStream.Create;                                     // ������� ��������� ����� ��� ������ ����������� �����
        try
          textStream.LoadFromStream(fileStream);                                // ��������� ���������� ����� � ��������� �����
          text := textStream.DataString;                                        // �������� ����� �� ������ ������
          stringList.Text := text;                                              // ��������� ����� � TStringList
          lineCount := stringList.Count;                                        // ������� ���������� ����� � ������
          //ShowMessage('���������� �����: ' + IntToStr(lineCount));              // ������� ���������� �����
          for i := 0 to lineCount-1 do begin
            curline := stringList[i];
            if (i=0) then
              if (pos('DNS Server log file creation at',curline)>0)  then begin
                StatBar.Panels[0].text := '--== '+curline+' ==--';
              end
              else begin
                showmessage('�������� ������ �����');
                break;
              end;
          end;
        finally
         textStream.Free;
        end;
      finally
        fileStream.Free;
      end;
    end;
  finally
    openFileDialog.Free;
  end;
end;

end.
