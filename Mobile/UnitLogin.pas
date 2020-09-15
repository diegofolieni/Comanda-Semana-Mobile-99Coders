unit UnitLogin;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit, FMX.Layouts, FMX.TabControl, UnitDM
  ,REST.Types;

type
  TFormLogin = class(TForm)
    RecToolbar: TRectangle;
    lblTitulo: TLabel;
    LayoutLogin: TLayout;
    Label2: TLabel;
    EditLogin: TEdit;
    RecAcessar: TRectangle;
    Label3: TLabel;
    TabControl: TTabControl;
    TabLogin: TTabItem;
    TabConfig: TTabItem;
    LayoutConfig: TLayout;
    Label4: TLabel;
    EditServidor: TEdit;
    RecSaveConfig: TRectangle;
    Label5: TLabel;
    LblConfig: TLabel;
    procedure RecAcessarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure LblConfigClick(Sender: TObject);
    procedure RecSaveConfigClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public
    { Public declarations }
  end;

var
  FormLogin: TFormLogin;

implementation

{$R *.fmx}

uses UnitPrincipal;

procedure TFormLogin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
  FormLogin := nil;
end;

procedure TFormLogin.FormShow(Sender: TObject);
begin
  DM.QryConfig.Active := False;
  DM.QryConfig.SQL.Clear;
  DM.QryConfig.SQL.Add('SELECT * FROM Tab_Usuario');
  DM.QryConfig.Active := True;

  if(DM.QryConfig.FieldByName('servidor').AsString<>'')then
  begin
    EditServidor.Text := DM.QryConfig.FieldByName('servidor').AsString;
    TabControl.ActiveTab := TabLogin;
  end else
  begin
    lblTitulo.Text      := 'Configurações';
    TabControl.ActiveTab := TabConfig;
  end;
end;

procedure TFormLogin.LblConfigClick(Sender: TObject);
begin
  TabControl.GotoVisibleTab(1,TTabTransition.Slide);
  lblTitulo.Text := 'Configurações';
end;

procedure TFormLogin.RecAcessarClick(Sender: TObject);
var
  Erro: String;
begin
  //Configurar o Endereço IP do Server;
  DM.RESTClient.BaseURL := EditServidor.Text;
  if(DM.ValidaLogin(EditLogin.Text,Erro))then
  begin
    if not(Assigned(FormPrincipal))then
      Application.CreateForm(TFormPrincipal, FormPrincipal);
    FormPrincipal.Show;

    Application.MainForm := FormPrincipal; //Altera o Formulário Principal da Aplicação

    FormLogin.Close;
  end else
  begin
    TabControl.GotoVisibleTab(1,TTabTransition.Slide);
    ShowMessage('Erro do Servidor ' + Erro);
  end;
end;

procedure TFormLogin.RecSaveConfigClick(Sender: TObject);
begin
  if(Trim(EditServidor.Text)='')then
  begin
    ShowMessage('Informe o Servidor');
    exit;
  end;

  with DM.QryConfig do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add('DELETE FROM Tab_Usuario');
    ExecSQL;

    Active := False;
    SQL.Clear;
    SQL.Add('INSERT INTO Tab_Usuario(servidor)');
    SQL.Add('VALUES(:servidor)');
    ParamByName('servidor').AsString := EditServidor.Text;
    ExecSQL;
  end;


  TabControl.GotoVisibleTab(0,TTabTransition.Slide);
  lblTitulo.Text := 'Acesso';
end;

end.
