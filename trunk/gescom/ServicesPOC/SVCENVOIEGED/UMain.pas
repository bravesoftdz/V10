unit UMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, SvcMgr, Dialogs;

type
  TSVCENREGBASTGED = class(TService)
    procedure ServiceAfterInstall(Sender: TService);
    procedure ServiceExecute(Sender: TService);
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
  private
    { Déclarations privées }
  public
    function GetServiceController: TServiceController; override;
    { Déclarations publiques }
  end;

var
  SVCENREGBASTGED: TSVCENREGBASTGED;

implementation

uses
  Registry
  , CommonTools
  , ActiveX
  , WinSVC
  , ShellAPI
  , ConstServices
  , HEnt1, Hdb
  ;

{$R *.DFM}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  SVCENREGBASTGED.Controller(CtrlCode);
end;

function TSVCENREGBASTGED.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TSVCENREGBASTGED.ServiceAfterInstall(Sender: TService);
var
  Reg : TRegistry;
begin                                                                               
  Reg := TRegistry.Create(KEY_READ or KEY_WRITE);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('\SYSTEM\CurrentControlSet\Services\' + Sender.Name, false) then
    try
      Reg.WriteString('Description', 'LSE-Enregistrement des BAST dans GED BSV');
    finally
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

procedure TSVCENREGBASTGED.ServiceExecute(Sender: TService);
var
  Count     : Integer;
//  BTPY2Exec : TSvcSyncBTPY2Execute;
  IniPath   : string;
  AppPath   : string;
  LogPath   : string;
  FirstExec : boolean;
  TimeOut : Integer;
begin
  TimeOut := 10;
  IniPath := TServicesLog.GetAppDataFileName(ServiceName_BTPY2, 'ini');
  AppPath := TServicesLog.GetFilePath(ServiceName_BTPY2, 'exe');
  LogPath := TServicesLog.GetAppDataFileName(ServiceName_BTPY2, 'log');
  if not FileExists(IniPath) then
  begin
    LogMessage(Format('Impossible d''initialiser le service %s. Le fichier de configuration "%s" est inexistant.', [ServiceName_BTPY2, TServicesLog.GetFilePath(ServiceName_BTPY2, 'ini')]), EVENTLOG_ERROR_TYPE);
  end else
  begin
    FirstExec := True;
//    BTPY2Exec := TSvcSyncBTPY2Execute.Create;
    try
//      BTPY2Exec.CreateObjects;
      try
//        BTPY2Exec.IniFilePath := IniPath;
//        BTPY2Exec.AppFilePath := AppPath;
//        BTPY2Exec.LogFilePath := LogPath;
//        BTPY2Exec.InitApplication;
        try
          Count := 0;
          while not Terminated do
          begin
            Inc(Count);
            if (Count >= Timeout) or (FirstExec) then
            begin
              FirstExec := False;
              Count     := 0;
              try
                LogMessage('Début d''exécution du service.', EVENTLOG_INFORMATION_TYPE);
//                BTPY2Exec.ServiceExecute;
                try
//                  BTPY2Exec.LogFilePath := LogPath;
                finally
                  LogMessage('Fin d''exécution du service.', EVENTLOG_INFORMATION_TYPE);
                end;
              except
                on E: Exception do
                  LogMessage(Format('Fin exécution du service avec erreur : %s', [E.Message]), EVENTLOG_ERROR_TYPE);
              end;
            end;
            Sleep(1000);
          end;
        finally
        end;
      finally
//        BTPY2Exec.FreeObjects;
      end;
    finally
//      BTPY2Exec.Free;
    end;
  end;
end;

procedure TSVCENREGBASTGED.ServiceStart(Sender: TService;var Started: Boolean);
begin
  LogMessage('Démarrage du service d''envoi des BAST dans GED.', EVENTLOG_INFORMATION_TYPE);
end;

procedure TSVCENREGBASTGED.ServiceStop(Sender: TService;var Stopped: Boolean);
begin
  CoUnInitialize;
  LogMessage('Arrêt du service d''envoi des BAST dans GED.', EVENTLOG_INFORMATION_TYPE);
end;

end.
