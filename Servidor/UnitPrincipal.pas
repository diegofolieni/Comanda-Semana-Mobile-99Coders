unit UnitPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, uRESTDWBase, uDWAbout, UnitDM;

type
  TFormPrincipal = class(TForm)
    lblStatusServer: TLabel;
    Switch: TSwitch;
    RESTServicePooler: TRESTServicePooler;
    procedure SwitchSwitch(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    DM : TDM;
  private
    procedure ConectarBanco;
  public
    { Public declarations }
  end;

var
  FormPrincipal: TFormPrincipal;

implementation

{$R *.fmx}

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
    begin
      Switch.IsChecked := False;
      raise Exception.Create('Erro ao Acessar o Banco: ' + E.Message);
    end;
  end;
end;

procedure TFormPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  DM.DisposeOf;
end;

procedure TFormPrincipal.FormCreate(Sender: TObject);
begin
  DM := TDM.Create(Self);
end;

procedure TFormPrincipal.FormShow(Sender: TObject);
begin
  ConectarBanco;
  RESTServicePooler.ServerMethodClass := TDM;
  RESTServicePooler.Active := Switch.IsChecked;
end;

procedure TFormPrincipal.SwitchSwitch(Sender: TObject);
begin
  if(DM.Conn.Connected)then
  begin
    DM.Conn.Connected := not DM.Conn.Connected;
  end else
  begin
    try
      DM.Conn.Connected := True;
    except
      on E:Exception do
      begin
        raise Exception.Create('Ocorreu um Erro ao Iniciar o Servidor');
      end
    end;
  end;
  RESTServicePooler.Active := Switch.IsChecked;
end;

end.
