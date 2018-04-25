{***********UNITE*************************************************
Auteur  ...... :
Créé le ...... : 18/04/2018
Modifié le ... :   /  /
Description .. : Source TOF de la FICHE : YYJNALEVENT ()
Mots clefs ... : TOF;YYJNALEVENT
*****************************************************************}
Unit YYJNALEVENT_TOF ;

Interface

Uses
  StdCtrls
  , Controls
  , Classes
  {$IFNDEF EAGLCLIENT}
  , db
  , uDbxDataSet
  , FE_Main
  {$ENDIF EAGLCLIENT}
  , uTob
  , forms
  , sysutils
  , ComCtrls
  , HCtrls
  , HEnt1
  , HMsgBox
  , UTOF
  , CBPMcd
  , Htb97
  , uTOFComm
  ;


Type
  TOF_YYJNALEVENT = Class (tTOFComm)
  private
    FListe  : THGrid;
    VoirDoc : TToolbarButton97;

    procedure FListe_OnRowEnter(Sender: TObject; Ou: Integer; var Cancel: Boolean; Chg: Boolean);
    procedure VoirDoc_OnClick(Sender : TObject);
    function GetBFilesKey :  string;
    function GetFileName : string;

  public
    procedure OnNew                    ; override ;
    procedure OnDelete                 ; override ;
    procedure OnUpdate                 ; override ;
    procedure OnLoad                   ; override ;
    procedure OnArgument (S : String ) ; override ;
    procedure OnDisplay                ; override ;
    procedure OnClose                  ; override ;
    procedure OnCancel                 ; override ;
  end ;

Implementation

uses
  ShellAPI
  , ParamSoc
  , Windows
  , wCommuns
  ;

procedure TOF_YYJNALEVENT.OnNew ;
begin
  Inherited ;
end ;

procedure TOF_YYJNALEVENT.OnDelete ;
begin
  Inherited ;
end ;

procedure TOF_YYJNALEVENT.OnUpdate ;
begin
  Inherited ;
end ;

procedure TOF_YYJNALEVENT.OnLoad ;
begin
  Inherited ;
end ;

procedure TOF_YYJNALEVENT.OnArgument (S : String ) ;
begin
  Inherited ;
  VoirDoc := TToolbarButton97(GetControl('VOIRDOC'));
  FListe  := THGrid(GetControl('FLISTE'));
  VoirDoc.OnClick   := VoirDoc_OnClick;
  FListe.OnRowEnter := FListe_OnRowEnter;
end ;

procedure TOF_YYJNALEVENT.OnClose ;
begin
  Inherited ;
end ;

procedure TOF_YYJNALEVENT.OnDisplay () ;
begin
  Inherited ;
end ;

procedure TOF_YYJNALEVENT.OnCancel () ;
begin
  Inherited ;
end ;

procedure TOF_YYJNALEVENT.VoirDoc_OnClick(Sender: TObject);
var
  Path : string;
begin
  Path := GetParamSocSecur('SO_BTEMPLFILEREF', '') + '\' + GetFileName;
  if not FileExists(Path) then
    PGIError(Format(TraduireMemoire('Le fichier %s n''existe pas.'), [Path]), Ecran.Caption)
  else
    ShellExecute(0, pchar('open'), pchar(Path), nil, nil, SW_SHOW);
end;

procedure TOF_YYJNALEVENT.FListe_OnRowEnter(Sender: TObject; Ou: Integer; var Cancel: Boolean; Chg: Boolean);
begin
  VoirDoc.Visible := (ExisteSQL('SELECT 1 FROM BFILES WHERE BF0_CODE = "' + GetBFilesKey + '"'));
end;

function TOF_YYJNALEVENT.GetBFilesKey: string;
begin
  Result := 'EVT;RGP;' + GetString('GEV_NUMEVENT') + '"';
end;

function TOF_YYJNALEVENT.GetFileName: string;
var
  Sql : string;
  Qry : TQuery;
begin
  Sql := 'SELECT BF0_FILENAME'
       + ' FROM BFILES'
       + ' WHERE BF0_CODE = "' + GetBFilesKey + '"'
       ;
  Qry := OpenSQL(Sql, True);
  try
    Result := iif(not Qry.EOF, Qry.Fields[0].AsString, '');
  finally
    Ferme(Qry);
  end;
end;

Initialization
  registerclasses ( [ TOF_YYJNALEVENT ] ) ;
end.

