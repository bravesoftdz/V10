{***********UNITE*************************************************
Auteur  ...... : 
Créé le ...... : 18/04/2018
Modifié le ... :   /  /
Description .. : Source TOF de la FICHE : BRGPDREFERENTIEL ()
Mots clefs ... : TOF;BRGPDREFERENTIEL
*****************************************************************}
Unit BRGPDUTILISATMUL_TOF ;

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
  , BRGPDMUL_TOF
  , BRGDPDUtils
  ;

function BLanceFiche_RGPDUtilisatMul(Nat, Cod, Range, Lequel, Argument : string) : string;

Type
  TOF_BRGPDUTILISATMUL = Class (TOF_BRGPDMUL)
  private

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
   BRGPDVALIDTRT_TOF
  , FormsName
  ;

function BLanceFiche_RGPDUtilisatMul(Nat, Cod, Range,Lequel,Argument : string) : string;
begin
  Result := AglLanceFiche(Nat, Cod, Range, Lequel, Argument);
end;

procedure TOF_BRGPDUTILISATMUL.OnNew ;
begin
  Inherited ;
end ;

procedure TOF_BRGPDUTILISATMUL.OnDelete ;
begin
  Inherited ;
end ;

procedure TOF_BRGPDUTILISATMUL.OnUpdate ;
begin
  Inherited ;
end ;

procedure TOF_BRGPDUTILISATMUL.OnLoad ;
begin
  Inherited ;
end ;

procedure TOF_BRGPDUTILISATMUL.OnArgument (S : String ) ;
begin
  sPopulationCode := RGPDUser;
  sFieldCode      := 'US_UTILISATEUR';
  sFieldCode2nd   := '';
  sFieldLabel     := 'US_LIBELLE';
  sFieldLabel2nd  := ''; 
  Inherited ;
end ;

procedure TOF_BRGPDUTILISATMUL.OnClose ;
begin
  Inherited ;
end ;

procedure TOF_BRGPDUTILISATMUL.OnDisplay () ;
begin
  Inherited ;
end ;

procedure TOF_BRGPDUTILISATMUL.OnCancel () ;
begin
  Inherited ;
end ;

Initialization
  registerclasses ( [ TOF_BRGPDUTILISATMUL ] ) ;
end.

