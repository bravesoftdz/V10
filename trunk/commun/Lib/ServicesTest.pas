unit ServicesTest;

interface

 {$IFDEF APPSRV}
type
  T_SvcTestExecute = class (TObject)
    class procedure SvcBtpY2;
    class procedure SvcBtpToVerdon;
    class procedure SvcVerdonToBtp;
  end;
 {$ENDIF APPSRV}

implementation

uses
   SysUtils
  , CommonTools
  {$IFDEF APPSRV}
  , Forms
  , uExecuteService
  , uMainService
  , uExecuteServiceBtpVerdonImp
  , uMainServiceBtpVerdonImp
  , uExecuteServiceBtpVerdonExp
  , uMainServiceBtpVerdonExp
  {$ENDIF APPSRV}
  ;

{ T_SvcTestExecute }

{$IFDEF APPSRV}
class procedure T_SvcTestExecute.SvcBtpY2;
var
  BTPY2Exec : TSvcSyncBTPY2Execute;
  AppName   : string;
begin
  { Test du service }
  AppName   := ExtractFilePath(Application.ExeName);
  BTPY2Exec := TSvcSyncBTPY2Execute.Create;
  try
    BTPY2Exec.IniFilePath := AppName + 'SvcSynBTPY2.ini';
    BTPY2Exec.AppFilePath := AppName + 'SvcSynBTPY2.exe';
    BTPY2Exec.LogFilePath := AppName + 'SvcSynBTPY2.log';
    BTPY2Exec.CreateObjects;
    try
      BTPY2Exec.InitApplication;
      try
       BTPY2Exec.ServiceExecute;
      finally
      end;
    finally
      BTPY2Exec.FreeObjects;
    end;
  finally
    BTPY2Exec.Free;
  end;
end;
{$ENDIF APPSRV}

{$IFDEF APPSRV}
class procedure T_SvcTestExecute.SvcBtpToVerdon;
var
  BTPVerdonExec : TSvcSyncBTPVerdonExp;
begin
  BTPVerdonExec := TSvcSyncBTPVerdonExp.Create(nil);
  try
    BTPVerdonExec.ServiceExecute(nil);
  finally
    BTPVerdonExec.Free;
  end;

end;
{$ENDIF APPSRV}

{$IFDEF APPSRV}
class procedure T_SvcTestExecute.SvcVerdonToBtp;
var
  BTPVerdonExec : TSvcSyncBTPVerdonImp;
begin
  BTPVerdonExec := TSvcSyncBTPVerdonImp.Create(nil);
  try
    BTPVerdonExec.ServiceExecute(nil);
  finally
    BTPVerdonExec.Free;
  end;
end;
{$ENDIF APPSRV}

end.
