program Comanda;

uses
  System.StartUpCopy,
  FMX.Forms,
  UnitLogin in 'UnitLogin.pas' {FormLogin},
  UnitPrincipal in 'UnitPrincipal.pas' {FormPrincipal},
  UnitResumo in 'UnitResumo.pas' {FormResumo},
  UnitAddItem in 'UnitAddItem.pas' {FormAddItem},
  UnitDM in 'UnitDM.pas' {DM: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TFormLogin, FormLogin);
  Application.Run;
end.
