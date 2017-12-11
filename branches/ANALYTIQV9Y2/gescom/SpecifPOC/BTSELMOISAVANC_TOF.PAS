{***********UNITE*************************************************
Auteur  ...... : 
Créé le ...... : 22/11/2017
Modifié le ... :   /  /
Description .. : Source TOF de la FICHE : BTSELMOISAVANC ()
Mots clefs ... : TOF;BTSELMOISAVANC
*****************************************************************}
Unit BTSELMOISAVANC_TOF ;

Interface

Uses StdCtrls, 
     Controls, 
     Classes, 
{$IFNDEF EAGLCLIENT}
     db, 
     uDbxDataSet, 
     mul, fe_Main,M3Fp, 
{$else}
     eMul,
{$ENDIF}
     AglInit,
     uTob,
     forms,
     sysutils, 
     ComCtrls,
     HCtrls, 
     HEnt1, 
     HMsgBox, 
     UTOF ; 

Type
  TOF_BTSELMOISAVANC = Class (TOF)
    procedure OnNew                    ; override ;
    procedure OnDelete                 ; override ;
    procedure OnUpdate                 ; override ;
    procedure OnLoad                   ; override ;
    procedure OnArgument (S : String ) ; override ;
    procedure OnDisplay                ; override ;
    procedure OnClose                  ; override ;
    procedure OnCancel                 ; override ;
  end ;

procedure SelectionMoisAvancPoc (Parms : array of variant ; nb : integer);

Implementation

procedure SelectionMoisAvancPoc (Parms : array of variant ; nb : integer);
var SQL,Params : string;
    Naturepiece,Souche,Numero,Indice,Affaire : string;
    TOBP : TOB;
begin
  Naturepiece := Parms[1];
  Souche := Parms[2];
  Numero := Parms[3];
  Indice := Parms[4];
  Affaire := Parms[5];
  Sql := 'SELECT 1 FROM BAVANCTECH WHERE '+
         'BM9_NATUREPIECEG="'+NaturepIece+'" AND '+
         'BM9_SOUCHE="'+Souche+'" AND '+
         'BM9_NUMERO='+Numero+' AND '+
         'BM9_INDICEG='+Indice;
  if ExisteSQL(SQL) then
  begin
    Params :='BM9_NATUREPIECEG='+NaturepIece+';BM9_SOUCHE='+Souche+';BM9_NUMERO='+Numero+';BM9_INDICEG='+Indice;
    AGLLanceFiche('BTP','BTSELMOISAVANC',Params,'','ACTION=MODIFICATION');
  end else
  begin
    TOBP := TOB.Create('LES PARAMS',nil,-1);
    TRY
      TOBP.AddChampSupValeur('NATUREPIECEG',Parms[1]);
      TOBP.AddChampSupValeur('SOUCHE',Parms[2]);
      TOBP.AddChampSupValeur('NUMERO',Parms[3]);
      TOBP.AddChampSupValeur('INDICEG',Parms[4]);
      TOBP.AddChampSupValeur('MOIS','');
      TheTOB := TOBP;
      AGLLanceFiche('BTP','BTSAISMOIAVANC','','','ACTION=MODIFICATION');
      TheTOB := nil;
      if TOBP.GetString('MOIS')<>'' then
      begin
        Params := 'BNATURE='+Parms[1]+';BSOUCHE='+Parms[2]+';BNUMERO='+Parms[3]+';BINDICEG='+Parms[4]+';BMOIS='+TOBP.GetString('MOIS')+';BAFFAIRE='+Parms[5];
        AGLLanceFiche('BTP','BSAISIEAVANCPOC','','','ACTION=MODIFICATION;'+Params);
      end;
    FINALLY
      TOBP.Free;
    END;
  end;
end;

procedure TOF_BTSELMOISAVANC.OnNew ;
begin
  Inherited ;
end ;

procedure TOF_BTSELMOISAVANC.OnDelete ;
begin
  Inherited ;
end ;

procedure TOF_BTSELMOISAVANC.OnUpdate ;
begin
  Inherited ;
end ;

procedure TOF_BTSELMOISAVANC.OnLoad ;
begin
  Inherited ;
end ;

procedure TOF_BTSELMOISAVANC.OnArgument (S : String ) ;
begin
  Inherited ;
end ;

procedure TOF_BTSELMOISAVANC.OnClose ;
begin
  Inherited ;
end ;

procedure TOF_BTSELMOISAVANC.OnDisplay () ;
begin
  Inherited ;
end ;

procedure TOF_BTSELMOISAVANC.OnCancel () ;
begin
  Inherited ;
end ;

Initialization
  RegisterAglProc( 'SelectionMoisAvancPoc',True,5,SelectionMoisAvancPoc);
  registerclasses ( [ TOF_BTSELMOISAVANC ] ) ;
end.
