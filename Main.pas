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
  stringList := TStringList.Create;                                             // Создаем экземпляр TStringList
end;

function ParseDN(str:shortstring):shortstring;
var
  i:byte;
  res:shortstring;
begin
  res:='';
  for i := 1 to length(str)-3 do begin
    if str[i]='(' then begin
      if i>1 then res:=res+'.';
      res:=res+copy(str,i+3,strtoint(str[i+1]));
    end;
  end;
  showmessage(res);
  result:=res;
end;

procedure TMainForm.M_File_MSAccessClick(Sender: TObject); 
var
  openFileDialog: TOpenDialog;
  cat: OLEVariant;
  Connection: TADOConnection;
  Command: TADOCommand;
  Table: TADOTable;
  i,j: longint;
  tempstr:shortstring;
begin
  openFileDialog := TOpenDialog.Create(nil);
  try
    openFileDialog.Filter := 'Файл MS Access (*.mdb)|*.mdb';
    openFileDialog.DefaultExt := '.mdb';
    if openFileDialog.Execute then begin                                        // Если пользователь выбирает файл и нажимает кнопку "Открыть"
      cat := CreateOleObject('ADOX.Catalog');                                   // Создаем БД
      cat.Create('Provider=Microsoft.Jet.OLEDB.4.0;Data Source=' +              // Настраиваем параметры подключения
      openFileDialog.FileName + ';Jet OLEDB:Database Password=');
      Connection := TADOConnection.Create(nil);                                 // Подключаемся к БД
      Connection.ConnectionString := cat.ActiveConnection;                      // Настраиваем параметры подключения
      Connection.Open;                                                          // Открываем соединение
      Command := TADOCommand.Create(nil);                                       // Создаем экземпляр компонента TADOCommand
      try
        Command.Connection := Connection;                                       // Устанавливаем соединение для выполнения SQL-запроса
        Command.CommandText :=                                                  // Формируем SQL-запрос для создания таблицы
          'CREATE TABLE dns_records (ID INT PRIMARY KEY, '+
          'dt DATETIME, thread_id VARCHAR(4), context VARCHAR(7), '+
          'packet_id VARCHAR(16), ut_indicator VARCHAR(3), '+
          'sr_indicator VARCHAR(3), remote_ip VARCHAR(39), '+
          'xid VARCHAR(4), qr VARCHAR(3), flags VARCHAR(4), '+
          'flags_codes VARCHAR(4), response_code VARCHAR(8), '+
          'question_type VARCHAR(6), question_name VARCHAR)';
        Command.Execute;                                                        // Выполняем запрос
      finally
        Command.Free;
      end;
      Table := TADOTable.Create(nil);
      Table.Connection := Connection;
      Table.TableName := 'dns_records';
      Table.Active := true;
      i:=29;
      PB.Min:=0;
      PB.Max:=(lineCount - 29) div 2;
      PB.Visible:=true;
      while i < lineCount -2 do with Table do begin
        Append;
        i:=i+2;
        j:=0;
        FieldByName('ID').AsInteger := i-29;
        FieldByName('dt').AsString := copy(stringlist[i],0,19); 
        if copy(stringlist[i],19,1) <> ' ' then j:=j+1;
        FieldByName('thread_id').AsString := copy(stringlist[i],20+j,4); 
        FieldByName('context').AsString := copy(stringlist[i],25+j,7); 
        FieldByName('packet_id').AsString := copy(stringlist[i],33+j,16); 
        FieldByName('ut_indicator').AsString := copy(stringlist[i],50+j,3);
        FieldByName('sr_indicator').AsString := copy(stringlist[i],54+j,3);
        if pos('.',copy(stringlist[i],58+j,15)) > 0  then
         FieldByName('remote_ip').AsString := copy(stringlist[i],58+j,15)
        else begin
         tempstr:= copy(stringlist[i],58+j,39);
         if Pos(' ',tempstr)>15 then j:=j+Pos(' ',tempstr)-16;
         FieldByName('remote_ip').AsString := copy(tempstr,0,Pos(' ',tempstr)-1);
        end;
        FieldByName('xid').AsString := copy(stringlist[i],74+j,4);
        FieldByName('qr').AsString := copy(stringlist[i],79+j,3); 
        FieldByName('flags').AsString := copy(stringlist[i],84+j,4); 
        FieldByName('flags_codes').AsString := copy(stringlist[i],89+j,4); 
        FieldByName('response_code').AsString := copy(stringlist[i],94+j,8); 
        FieldByName('question_type').AsString := copy(stringlist[i],104+j,6); 
        FieldByName('question_name').AsString := ParseDN(copy(stringlist[i],111+j,length(stringlist[i])));
        if i mod 19 = 0 then begin 
          PB.Position:=(i - 29) div 2;
          Application.ProcessMessages;
        end;
        Post;
      end;
      pb.Visible:=false;
      Table.Active := False;
      Connection.Close;
      cat := NULL;
      Connection.Free;
    end;    
  finally
    openFileDialog.Free;
  end;  
end;
     
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
    openFileDialog.Options := [ofReadOnly, ofFileMustExist];                    // Настраиваем диалог для открытия текстовых файлов
    openFileDialog.Filter := 'Текстовые файлы (*.txt)|*.txt';
    if openFileDialog.Execute then begin                                        // Если пользователь выбирает файл и нажимает кнопку "Открыть"
      fileStream := TFileStream.Create(openFileDialog.FileName, fmOpenRead);    // Открываем файл в режиме чтения
      try
        textStream := TStringStream.Create;                                     // Создаем строковый поток для чтения содержимого файла
        try
          textStream.LoadFromStream(fileStream);                                // Загружаем содержимое файла в строковый поток
          text := textStream.DataString;                                        // Получаем текст из строки потока
          stringList.Text := text;                                              // Загружаем текст в TStringList
          lineCount := stringList.Count;                                        // Считаем количество строк в тексте
          for i := 0 to lineCount-1 do begin
            curline := stringList[i];
            if (i=0) then
              if (pos('DNS Server log file creation at',curline)>0)  then begin
                StatBar.Panels[0].text := '--== '+curline+' ==--';
              end
              else begin
                showmessage('Неверный формат файла');
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
