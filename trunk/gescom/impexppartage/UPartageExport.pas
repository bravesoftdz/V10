unit UPartageExport;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, HTB97, StdCtrls, Mask, Hctrls, TntDialogs, TntStdCtrls,ADODB,
  ExtCtrls, TntExtCtrls, HPanel;

const
  ConnectString = 'Provider=SQLOLEDB.1;Password=ADMIN;Persist Security Info=True;User ID=ADMIN;Initial Catalog=%s;Data Source=%s;'+
                  'Use Procedure for Prepare=1;Auto Translate=True;Packet Size=4096;Workstation ID=LOCALST;Use Encryption for Data=False;Tag with column collation when possible=False';

type
  TFExportData = class(TForm)
    Dock971: TDock97;
    PBouton: TToolWindow97;
    BFerme: TToolbarButton97;
    HelpBtn: TToolbarButton97;
    HPanel1: THPanel;
    HPanel2: THPanel;
    HPanel3: THPanel;
    DBNAME: THValComboBox;
    LNomDB: THLabel;
    LBBaseRef: THLabel;
    HPanel4: THPanel;
    SaveFileName: THCritMaskEdit;
    LbSaveFile: THLabel;
    SaveFile: TSaveDialog;
    BLanceExport: TToolbarButton97;
    HLabel1: THLabel;
    SERVERNAME: TEdit;
    BConnect: TToolbarButton97;
    procedure BFermeClick(Sender: TObject);
    procedure SaveFileNameElipsisClick(Sender: TObject);
    procedure BLanceExportClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BConnectClick(Sender: TObject);
  private
    { Déclarations privées }
    procedure ChargeLesMainDB (var TL : TStringList);

  public
    { Déclarations publiques }
  end;

implementation

{$R *.dfm}

procedure TFExportData.BFermeClick(Sender: TObject);
begin
  close;
end;

procedure TFExportData.SaveFileNameElipsisClick(Sender: TObject);
begin
  if SaveFile.Execute then
  begin
    SaveFileName.Text  := SaveFile.FileName;
  end;
end;

procedure TFExportData.BLanceExportClick(Sender: TObject);
begin
  close;
end;

procedure TFExportData.FormShow(Sender: TObject);
begin
  SERVERNAME.Text := '';
end;

procedure TFExportData.ChargeLesMainDB(var TL: TStringList);
begin
  
end;

procedure TFExportData.BConnectClick(Sender: TObject);
var QQ : TADOQuery;
    CNX : TADOConnection;
begin
  DBNAME.Clear;
  if SERVERNAME.Text = '' then exit;
  CNX := TADOConnection.Create(application);
  TRY
    CNX.ConnectionString := format(ConnectString,['master',SERVERNAME.text]);
    CNX.LoginPrompt := false;
    TRY
      CNX.Connected := True;
      QQ := TADOQuery.Create(application);
      QQ.Connection := CNX;
      QQ.SQL.Add('SELECT name, database_id FROM sys.databases where database_id > 4');
      QQ.Prepared := true;
      TRY
        QQ.Open;
        QQ.First;
        while not QQ.Eof do
        begin
          DBName.AddItem(QQ.fields[0].AsString,nil); 
          QQ.next;
        end;
        QQ.Close;
      EXCEPT
        ON E:Exception do
        begin
          MessageBox(application.handle,PAnsiChar(E.Message),PAnsiChar(Application.Name),MB_OK);
          exit;
        end;
      END;
    EXCEPT
      ON E:Exception do
      begin
        MessageBox(application.handle,PAnsiChar(E.Message),PAnsiChar(Application.Name),MB_OK);
        exit;
      end;
    END;
  FINALLY
    CNX.free;
    QQ.Free;
  END;
end;

end.
