program SVCEnvoiBASTGed;

uses
  SvcMgr,
  UMain in '..\ServicesPOC\SVCENVOIEGED\UMain.pas' {SVCENREGBASTGED: TService},
  CommonTools in '..\..\commun\Lib\CommonTools.pas',
  Zip in '..\..\commun\Lib\Zip.pas',
  ZipDlls in '..\..\COMMUN\LIB\ZipDlls.pas',
  UconnectBSV in '..\..\CONNECTWS\UconnectBSV.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Service envoie BAST dans GED POC';
  Application.CreateForm(TSVCENREGBASTGED, SVCENREGBASTGED);
  Application.Run;
end.
