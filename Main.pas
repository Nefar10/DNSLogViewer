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
  stringList := TStringList.Create;                                             // Создаем экземпляр TStringList
end;

procedure TMainForm.M_File_MSAccessClick(Sender: TObject); 
var
  openFileDialog: TOpenDialog;
  cat: OLEVariant;
begin
  openFileDialog := TOpenDialog.Create(nil);
  try
    openFileDialog.Filter := 'Файл MS Access (*.mdb)|*.mdb';
    if openFileDialog.Execute then begin                                        // Если пользователь выбирает файл и нажимает кнопку "Открыть"
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
          //ShowMessage('Количество строк: ' + IntToStr(lineCount));              // Выводим количество строк
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
