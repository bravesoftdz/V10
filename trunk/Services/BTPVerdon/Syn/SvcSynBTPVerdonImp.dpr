program SvcSynBTPVerdonImp;

uses
  SvcMgr,
  uMainServiceBtpVerdonImp in '..\Lib\uMainServiceBtpVerdonImp.pas' {SvcSyncBTPVerdonImp: TService},
  CommonTools in '..\..\..\commun\Lib\CommonTools.pas',
  Zip in '..\..\..\commun\Lib\Zip.pas',
  ZipDlls in '..\..\..\commun\Lib\ZipDlls.pas',
  uExecuteServiceBtpVerdonImp in '..\Lib\uExecuteServiceBtpVerdonImp.pas',
  Ulog in '..\..\..\commun\Lib\Ulog.pas',
  ConstServices in '..\..\..\commun\Lib\ConstServices.pas',
  UtilBTPVerdon in '..\Lib\UtilBTPVerdon.pas',
  tThreadTiers in '..\Lib\tThreadTiers.pas',
  UConnectWSCEGID in '..\..\..\CONNECTWS\UConnectWSCEGID.pas',
  WinHttp_TLB in '..\..\..\CONNECTWS\WinHttp_TLB.pas',
  UConnectWSConst in '..\..\..\CONNECTWS\UConnectWSConst.pas',
  uLkJSON in '..\..\..\CONNECTWS\uLkJSON.pas',
  tThreadChantiers in '..\Lib\tThreadChantiers.pas',
  tThreadDevis in '..\Lib\tThreadDevis.pas',
  tThreadLignesBR in '..\Lib\tThreadLignesBR.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TSvcSyncBTPVerdonImp, SvcSyncBTPVerdonImp);
  Application.Run;
end.
