unit MDispUtil;

// majstruc umajstruct

interface

// ubob

uses Forms, dialogs,Hpanel,
   Classes
  ;

procedure TraitementEchangesBSV;
procedure InitApplication;

type
  Tgctie = class(TDatamodule)
    procedure FMDispADMCreate(Sender: TObject);
  end;

var
  gctie: Tgctie;
  okArg,OkLogin : boolean;
  st : string;
implementation

{$R *.DFM}

uses windows, MenuOLG, sysutils, Messages, Controls,HEnt1,
     uBTPVerrouilleDossier,HMsgBox,Ent1
  ;
procedure TraitementEchangesBSV;
begin

end;

procedure Dispatch(Num: Integer; PRien: THPanel; var retourforce, sortiehalley: boolean);
var
  CodeRetour : integer;
  stMessage, Versionbase : string;
  Ok1,Ok2 : Boolean;
begin
  case Num of
    10:
      begin
        if (V_PGI.MajStructAuto) and (V_PGI.RunWithParams) then
        begin
          FMenuG.ForceClose := True;
          PostMessage(FMenuG.Handle, WM_CLOSE, 0, 0);
          Application.ProcessMessages;
          Exit;
        end else
        begin
          if (not ISUtilisable) then
          begin
             stMessage := 'Base de données momentanément indisponible (mise à niveau en cours) ';
             stMessage := stMessage +#13#10 +'Veuillez réessayer ultérieurement';
             PGIInfo(stMessage,'Information de connection');
             FMenuG.ForceClose := True;
             PostMessage(FMenuG.Handle, WM_CLOSE, 0, 0);
             Application.ProcessMessages;
             Exit;
          end;
        end;
      end;

    11: ; //Après deconnection
    12: ;  // permet de faire qques chose avant connexion et seria
    13: ;
    15: ;
    16: ;
    100: ; // executer depuis le lanceur

    160001: ;
    
  else HShowMessage('2;?caption?;' + TraduireMemoire('Fonction non disponible : ') + ';W;O;O;O;', TitreHalley, IntToStr(Num));
  end;
end;

procedure DispatchTT(Num: Integer; Action: TActionFiche; Lequel, TT, Range: string);
begin
  case Num of
    1: ;
  end;
end;

procedure AfterChangeModule(NumModule: integer);
var
  VireCompta: Boolean;
begin
  V_PGI.VersionDemo := False;
  VireCompta := True;
  V_PGI.LaSerie := S5;
  if ctxPCL in V_PGI.PGIContexte then
  begin
    // maintenant qu'on peut le lancer en direct
  end else
  begin
    // PCS 13/10/2003 modules compta toujours présents.
    VireCompta := False;
  end;
  //
end;


procedure InitApplication;
begin
  FMenuG.OnDispatch := Dispatch;
  FMenuG.OnChargeMag := ChargeMagHalley;
  FMenuG.OnChangeModule := AfterChangeModule;
  FMenuG.SetModules([160], [39]);
  FMenuG.bSeria.Visible := False;
  V_PGI.DispatchTT := DispatchTT;
  VH^.OkModCompta := True;
  VH^.OkModBudget := True;
  VH^.OkModImmo := True;
  VH^.OkModEtebac := True;
end;

procedure Tgctie.FMDispADMCreate(Sender: TObject);
begin
  PGIAppAlone := True;
  CreatePGIApp;
end;

procedure InitialisationVPGI;
begin

  Apalatys := 'LSE';
  NomHalley := 'UTILSPOC';

  V_PGI.NumVersionBase := 998 ;
  TitreHalley := 'Utilitaires POC    Base ' + IntToStr(V_PGI.NumVersionBase);
  HalSocIni := 'CEGIDPGI.ini';

  Copyright := '© Copyright ' + Apalatys;
  V_PGI.NumVersion := '10.0' ;
  V_PGI.NumBuild := IntToStr(V_PGI.NumVersionBase) + '.161';
  V_PGI.DateVersion := EncodeDate(2018, 10, 10) ;

  V_PGI.LaSerie := S5;

  V_PGI.OutLook := TRUE;
  V_PGI.OfficeMsg := TRUE;
  V_PGI.ToolsBarRight := TRUE;
  ChargeXuelib;

  V_PGI.AlterTable := True;
  V_PGI.VersionDemo := TRUE;
  V_PGI.VersionReseau := true;
  V_PGI.ImpMatrix := True;
  V_PGI.OKOuvert := FALSE;
  V_PGI.Halley := TRUE;
  V_PGI.MenuCourant := 0;
  V_PGI.CodeProduit:='034' ;

  V_PGI.RazForme := TRUE;



  V_PGI.StandardSurDP := True;
  V_PGI.MajPredefini := True;
  V_PGI.CegidApalatys := False;
  V_PGI.CegidBureau := True;
  V_PGI.IsPgiMajVer := True;
  // V_PGI.MajStructAuto := true ;

  v_pgi.enableTableToView:=False;
  V_PGI.RazForme:=TRUE;
	GetInfoMajApplication;

end;

initialization
  InitialisationVPGI;

end.

