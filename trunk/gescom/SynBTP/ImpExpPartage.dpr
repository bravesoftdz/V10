program ImpExpPartage;

uses
  SysUtils,
  Forms,
  Hent1,
  Assist {FAssist},
  edtQR {EditQR},
  Fiche {FFiche},
  FichGrid {FFicheGrid},
  FichList {FFicheListe},
  GRS1 {FGRS1},
  MenuOLG {FMenuG},
  Mul {FMul},
  QRS1 {FQRS1},
  SplashG {SplashScreen},
  Tablette {FTablette},
  Vierge {FVierge},
  UPrincipale in '..\impexppartage\UPrincipale.pas' {Fprincipale},
  UPartageExport in '..\impexppartage\UPartageExport.pas' {FExportData},
  UImportDatas in '..\impexppartage\UImportDatas.pas' {FImportDatas};

//

// FIN NEW

{$R *.RES}

begin
{$ifdef MEMCHECK}
  MemCheckLogFileName:=ChangeFileExt(Application.exename,'.log');
  MemChk;
{$endif}
  Application.Initialize;
  Application.Title := 'Import Export Partage CEGID';
  Application.CreateForm(TFprincipale, Fprincipale);
  Application.Run;
end.
