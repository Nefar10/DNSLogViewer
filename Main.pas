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
    M_File_MSAccess: TMenuItem;
    PB: TProgressBar;
    procedure M_File_OpenClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure M_File_MSAccessClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    stringList: TStringList;
    lineCount: Integer;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  stringList := TStringList.Create;                                             // ������� ��������� TStringList
end;


{
Message logging key (for packets - other items use a subset of these fields):
	Field #  Information         Values
	-------  -----------         ------
	   1     Date
	   2     Time
	   3     Thread ID
	   4     Context
	   5     Internal packet identifier
	   6     UDP/TCP indicator
	   7     Send/Receive indicator
	   8     Remote IP
	   9     Xid (hex)
	  10     Query/Response      R = Response
	                             blank = Query
	  11     Opcode              Q = Standard Query
	                             N = Notify
	                             U = Update
	                             ? = Unknown
	  12     [ Flags (hex)
	  13     Flags (char codes)  A = Authoritative Answer
	                             T = Truncated Response
	                             D = Recursion Desired
	                             R = Recursion Available
	  14     ResponseCode ]
	  15     Question Type
	  16     Question Name
}

    
procedure TMainForm.M_File_MSAccessClick(Sender: TObject); 
var
  openFileDialog: TOpenDialog;
  cat: OLEVariant;
  Connection: TADOConnection;
  Command: TADOCommand;
  Table: TADOTable;
  i,j: longint;
begin
  openFileDialog := TOpenDialog.Create(nil);
  try
    openFileDialog.Filter := '���� MS Access (*.mdb)|*.mdb';
    openFileDialog.DefaultExt := '.mdb';
    if openFileDialog.Execute then begin                                        // ���� ������������ �������� ���� � �������� ������ "�������"
      cat := CreateOleObject('ADOX.Catalog');                                   // ������� ��
      cat.Create('Provider=Microsoft.Jet.OLEDB.4.0;Data Source=' +              // ����������� ��������� �����������
      openFileDialog.FileName + ';Jet OLEDB:Database Password=');
      Connection := TADOConnection.Create(nil);                                 // ������������ � ��
      Connection.ConnectionString := cat.ActiveConnection;                      // ����������� ��������� �����������
      Connection.Open;                                                          // ��������� ����������
      Command := TADOCommand.Create(nil);                                       // ������� ��������� ���������� TADOCommand
      try
        Command.Connection := Connection;                                       // ������������� ���������� ��� ���������� SQL-�������
        Command.CommandText :=                                                  // ��������� SQL-������ ��� �������� �������
          'CREATE TABLE dns_records (ID INT PRIMARY KEY, '+
          'dt DATETIME, thread_id VARCHAR, context VARCHAR, '+
          'packet_id VARCHAR, ut_indicator VARCHAR, '+
          'sr_indicator VARCHAR, remote_ip VARCHAR, '+
          'xid VARCHAR, qr VARCHAR, flags VARCHAR, '+
          'flags_codes VARCHAR, response_code VARCHAR, '+
          'question_type VARCHAR, question_name VARCHAR)';
        Command.Execute;                                                        // ��������� ������
      finally
        Command.Free;
      end;
      Table := TADOTable.Create(nil);
      Table.Connection := Connection;
      Table.TableName := 'dns_records';
      Table.Active := true;
      i:=29;
      PB.Min:=0;
      PB.Max:=(lineCount - 29);
      PB.Visible:=true;
      while i < lineCount do with Table do begin
        Append;
        i:=i+2;
        j:=0;
        FieldByName('ID').AsInteger := i-29;
        FieldByName('dt').AsString := copy(stringlist[i],0,20); 
        if copy(stringlist[i],0,19) = ' ' then j:=j+1;     
        FieldByName('thread_id').AsString := copy(stringlist[i],21+j,4); 
        FieldByName('context').AsString := copy(stringlist[i],26+j,7); 
        FieldByName('packet_id').AsString := copy(stringlist[i],34+j,16); 
        FieldByName('ut_indicator').AsString := copy(stringlist[i],51+j,3); 
        FieldByName('sr_indicator').AsString := copy(stringlist[i],55+j,3); 
        FieldByName('remote_ip').AsString := copy(stringlist[i],59+j,15); 
        FieldByName('xid').AsString := copy(stringlist[i],75+j,4); 
        FieldByName('qr').AsString := copy(stringlist[i],80+j,3); 
        FieldByName('flags').AsString := copy(stringlist[i],85+j,4); 
        FieldByName('flags_codes').AsString := copy(stringlist[i],90+j,5); 
        FieldByName('response_code').AsString := copy(stringlist[i],96+j,7); 
        FieldByName('question_type').AsString := copy(stringlist[i],105+j,6); 
        FieldByName('question_name').AsString := copy(stringlist[i],112+j,length(stringlist[i])); 
        PB.Position:=(i - 29) div 2;
        Application.ProcessMessages;
        Post;
      end;
      pb.Visible:=false;
      Table.Active := False;
      Connection.Close;
      cat := NULL;
    end;    
  finally
    openFileDialog.Free;
    Connection.Free;
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
