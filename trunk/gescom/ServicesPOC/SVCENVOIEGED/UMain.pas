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
    { D�clarations priv�es }
  public
    function GetServiceController: TServiceController; override;
    { D�clarations publiques }
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
begin
//
end;

procedure TSVCENREGBASTGED.ServiceStart(Sender: TService;var Started: Boolean);
begin
  LogMessage('D�marrage du service d''envoi des BAST dans GED.', EVENTLOG_INFORMATION_TYPE);
end;

procedure TSVCENREGBASTGED.ServiceStop(Sender: TService;var Stopped: Boolean);
begin
  CoUnInitialize;
  LogMessage('Arr�t du service d''envoi des BAST dans GED.', EVENTLOG_INFORMATION_TYPE);
end;

end.
