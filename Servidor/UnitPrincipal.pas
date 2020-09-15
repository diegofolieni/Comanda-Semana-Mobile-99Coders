unit UnitPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, uRESTDWBase, uDWAbout;

type
  TFormPrincipal = class(TForm)
    lblStatusServer: TLabel;
    Switch: TSwitch;
    RESTServicePooler: TRESTServicePooler;
    procedure SwitchSwitch(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure ConectarBanco;
  public
    { Public declarations }
  end;

var
  FormPrincipal: TFormPrincipal;

implementation

{$R *.fmx}

uses UnitDM;

procedure TFormPrincipal.ConectarBanco;
begin
  try
    DM.Conn.Params.Values['DriverID']  := 'FB';
    DM.Conn.Params.Values['Database']  := 'C:\Users\Prog-3\Documents\Embarcadero\Studio\Projects\Semana Mobile - Comandas\Servidor\DB\BANCO.FDB';
    DM.Conn.Params.Values['User_Name'] := 'SYSDBA';
    DM.Conn.Params.Values['Password']  := 'masterkey';
    DM.Conn.Connected := True;
  except
    on E:Exception do
      raise Exception.Create('Erro ao Acessar o Banco: ' + E.Message);
  end;
end;

procedure TFormPrincipal.FormShow(Sender: TObject);
begin

  RESTServicePooler.ServerMethodClass := TDM;
  RESTServicePooler.Active := Switch.IsChecked;
end;

procedure TFormPrincipal.SwitchSwitch(Sender: TObject);
begin
  RESTServicePooler.Active := Switch.IsChecked;
end;

end.
