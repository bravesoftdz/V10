program SetupLSE;

uses
  Forms,
  UMainControl in 'UMainControl.pas' {Form1},
  UControlInstall in 'UControlInstall.pas' {FControlInstall},
  HManifest in '..\COMMUN\Lib\HManifest.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Setup LSE';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
