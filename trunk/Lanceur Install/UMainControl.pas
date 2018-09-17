unit UMainControl;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    procedure FormShow(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
    function LSEVERSION10 : Boolean;
  end;

var
  Form1: TForm1;

implementation
uses UControlInstall;

{$R *.dfm}

procedure TForm1.FormShow(Sender: TObject);
var XX : TFControlInstall;
begin
  XX := TFControlInstall.Create(application);
  XX.Show;
  if not LSEVERSION10 then
  begin
    XX.Refresh;
    Sleep(10000);
  end else
  begin

  end;
  XX.free;
  Application.Terminate;
end;

function TForm1.LSEVERSION10: Boolean;
var Reg : TRegistry;
begin
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('\SOFTWARE\Wow6432Node\Cegid\LSE Business\LSE Business Place BTP', false) then
    try
      Reg.WriteString('Description', 'LSE Enregistrement des BAST dans GED BSV');
    finally
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

end.
