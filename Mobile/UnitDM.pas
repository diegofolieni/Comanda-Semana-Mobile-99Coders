unit UnitDM;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.FMXUI.Wait, Data.DB,
  FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Comp.DataSet, REST.Types, REST.Client,
  Data.Bind.Components, Data.Bind.ObjectScope, System.JSON, System.NetEncoding, System.IOUtils;

type
  TDM = class(TDataModule)
    Conn: TFDConnection;
    QryConfig: TFDQuery;
    RESTClient: TRESTClient;
    RequestLogin: TRESTRequest;
    RequestListarComandas: TRESTRequest;
    RequestListarCategorias: TRESTRequest;
    RequestListarProdutos: TRESTRequest;
    RequestListarProdutosComanda: TRESTRequest;
    RequestAdicionarProduto: TRESTRequest;
    RequestExcluirProduto: TRESTRequest;
    RequestEncerrarComanda: TRESTRequest;
    RequestListarOpcional: TRESTRequest;
    procedure DataModuleCreate(Sender: TObject);
  private

  public
    function ValidaLogin(usuario:String; out Erro:String):Boolean;
    function ListarComandas(out JsArray: TJSONArray;out Erro: String): boolean;
    function ListarCategorias(out JsArray: TJSONArray; out Erro: String):Boolean;
    function ListarProdutos(IdCategoria: Integer;TermoBusca:String;Pagina:Integer;out JsArray:TJSONArray;out Erro:String):Boolean;
    function ListarProdutosComanda(IdComanda:String;out JSArray:TJSONArray;out Erro:String):Boolean;
    function AdicionarProdutoComanda(IdComanda: String; IdProduto,Qtd: Integer; VlrTotal: Double;Obs, ObsOpcional:String;VlOpcional:Double; out Erro:String): Boolean;
    function ExcluirProdutoComanda(IdComanda:String;IdConsumo:integer;out Erro:String):Boolean;
    function EncerrarComanda(IdComanda: String; out Erro: String):Boolean;
    function ListarOpcional(IdProduto: Integer;out JsArray:TJSONArray;out Erro: String): Boolean;
  end;

var
  DM: TDM;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

function TDM.AdicionarProdutoComanda(IdComanda: String; IdProduto,Qtd: Integer; VlrTotal: Double;Obs, ObsOpcional:String;VlOpcional:Double; out Erro:String): Boolean;
var
  JsonObj : TJSONObject;
  Json : String;
  ts: String;
begin
  VlrTotal := VlrTotal / 100;
  with RequestAdicionarProduto do
  begin
    Params.Clear;
    AddParameter('id_comanda',IdComanda,TRESTRequestParameterKind.pkGETorPOST);
    AddParameter('id_produto',IdProduto.ToString,TRESTRequestParameterKind.pkGETorPOST);
    AddParameter('qtd'       ,Qtd.ToString      ,TRESTRequestParameterKind.pkGETorPOST);
    AddParameter('vlr_total' ,FormatFloat('0.00',VlrTotal).Replace(',','').Replace('.','')
                                       ,TRESTRequestParameterKind.pkGETorPOST);
    AddParameter('obs' , Obs , TRESTRequestParameterKind.pkGETorPOST);
    AddParameter('obs_opcional', ObsOpcional, TRESTRequestParameterKind.pkGETorPOST);
    AddParameter('vl_opcional',FormatFloat('0.00',VlOpcional).Replace(',','').Replace('.','')
                                       ,TRESTRequestParameterKind.pkGETorPOST);
    Execute;

    if(Response.StatusCode<>200)then
    begin
      Result := False;
      Erro := 'Erro do Servidor ' + Response.StatusCode.ToString;
    end else
    begin
      Json := Response.JSONValue.ToString;
      JsonObj := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(Json),0) as TJSONObject;
      if(JsonObj.GetValue('retorno').Value = 'OK')then
      begin
        Result := True;
        Erro := '';
      end else
      begin
        Result := False;
        Erro := 'Erro ao inserir Item ' + JsonObj.GetValue('retorno').Value;
      end;
      JsonObj.DisposeOf;
    end;
  end;
end;

procedure TDM.DataModuleCreate(Sender: TObject);
begin
  with Conn do
  begin
    Params.Values['DriverID'] := 'SQLite';

    {$IFDEF MSWINDOWS}
      Params.Values['Database'] := System.SysUtils.GetCurrentDir + '\DB\Comanda_Mobile.db';
    {$ELSE}
      Params.Values['Database'] := TPath.Combine(TPath.GetDocumentsPath, 'Comanda_Mobile.db');
    {$ENDIF}
    try
      Connected := True;
    except
      on E:Exception do
        raise Exception.Create('Ocorreu um erro ao conectar no banco: ' + E.Message);
    end;
  end;
end;

function TDM.EncerrarComanda(IdComanda: String; out Erro: String): Boolean;
var
  Json : String;
  JsonObject: TJSONObject;
begin
  with RequestEncerrarComanda do
  begin
    Params.Clear;
    AddParameter('id_comanda',IdComanda, TRESTRequestParameterKind.pkGETorPOST);
    Execute;

    if(Response.StatusCode<>200)then
    begin
      Erro   := 'Erro do Servidor ' + Response.StatusCode.ToString;
      Result := False;
    end else
    begin
      Json := Response.JSONValue.ToString;
      JsonObject := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(Json),0) as TJSONObject;

      if(JsonObject.GetValue('retorno').Value = 'OK')then
      begin
        Result := True;
        Erro   := '';
      end else
      begin
        Result := False;
        Erro   := 'Erro ao Encerrar Comanda ' + JsonObject.GetValue('retorno').Value;
      end;
    end;

  end;
end;

function TDM.ExcluirProdutoComanda(IdComanda: String; IdConsumo: integer;
  out Erro: String): Boolean;
var
  Json : String;
  JSONObj: TJSONObject;
begin
  with RequestExcluirProduto do
  begin
    Params.Clear;
    AddParameter('id_comanda',IdComanda, TRESTRequestParameterKind.pkGETorPOST);
    AddParameter('id_consumo',IdConsumo.ToString, TRESTRequestParameterKind.pkGETorPOST);
    Execute;

    if(Response.StatusCode <> 200)then
    begin
      Result := False;
      Erro := 'Erro do Servidor ' + Response.StatusCode.ToString;
    end else
    begin
      Json := Response.JSONValue.ToString;
      JSONObj := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(Json),0) as TJSONObject;
      if(JSONObj.GetValue('retorno').Value='OK')then
      begin
        Result := True;
        Erro   := '';
      end else
      begin
        Result := False;
        Erro := 'Erro ao Excluir Produto ' + JSONObj.GetValue('retorno').Value;
      end;
    end;
  end;
end;

function TDM.ListarCategorias(out JsArray: TJSONArray;
  out Erro: String): Boolean;
var
  Json : String;
begin
  RequestListarCategorias.Params.Clear;
  RequestListarCategorias.Execute;
  if(RequestListarCategorias.Response.StatusCode <> 200)then
  begin
    Result := False;
    Erro := 'Erro de Servidor ' + RequestListarCategorias.Response.StatusCode.ToString;
    exit;
  end;
  Json := RequestListarCategorias.Response.JSONValue.ToString;
  JsArray := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(Json),0) as TJSONArray;
  Result := True;
end;

function TDM.ListarComandas(out JsArray: TJSONArray;out Erro: String): boolean;
var
  JSon: String;
begin
  RequestListarComandas.Params.Clear;
  RequestListarComandas.Execute;
  if(RequestListarComandas.Response.StatusCode<>200)then
  begin
    Result  := False;
    Erro    := 'Erro ao Listar Comandas ' + RequestListarComandas.Response.StatusCode.ToString;
  end else
  begin
    Json    := RequestListarComandas.Response.JSONValue.ToString;
    JsArray := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(Json),0) as TJSONArray;
    Result  := True;
  end;
end;

function TDM.ListarOpcional(IdProduto: Integer;out JsArray:TJSONArray;out Erro: String): Boolean;
var
  Json: String;
begin
  Erro := '';

  try
    with RequestListarOpcional do
    begin
      Params.Clear;
      AddParameter('id_produto',IdProduto.ToString,TRESTRequestParameterKind.pkGETorPOST);
      Execute;
    end;
  except
    on E:Exception do
    begin
      Result := False;
      Erro:= 'Erro ao Listar Opcionais: ' + E.Message;
    end;
  end;

  if(RequestListarOpcional.Response.StatusCode<>200)then
  begin
    Result := False;
    Erro := 'Erro do Servidor ' + RequestListarOpcional.Response.StatusCode.ToString;
  end else
  begin
    Json    := RequestListarOpcional.Response.JSONValue.ToString;
    JsArray := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(Json),0) as TJSONArray;
    Result  := True;
  end;
end;

function TDM.ListarProdutos(IdCategoria: Integer; TermoBusca: String; Pagina: Integer; out JsArray: TJSONArray; out Erro: String): Boolean;
var
  Json: String;
begin
  Erro := '';

  try
    with RequestListarProdutos do
    begin
      Params.Clear;
      AddParameter('id_categoria',IdCategoria.ToString,TRESTRequestParameterKind.pkGETorPOST);
      AddParameter('termo_busca' ,TermoBusca          ,TRESTRequestParameterKind.pkGETorPOST);
      AddParameter('pagina'      ,Pagina.ToString     ,TRESTRequestParameterKind.pkGETorPOST);
      Execute;
    end;
  except
    on E:Exception do
    begin
      Result := False;
      Erro:= 'Erro ao Listar Produtos: ' + E.Message;
    end;
  end;

  if(RequestListarProdutos.Response.StatusCode<>200)then
  begin
    Result := False;
    Erro := 'Erro do Servidor ' + RequestListarProdutos.Response.StatusCode.ToString;
  end else
  begin
    Json    := RequestListarProdutos.Response.JSONValue.ToString;
    JsArray := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(Json),0) as TJSONArray;
    Result  := True;
  end;
end;

function TDM.ListarProdutosComanda(IdComanda: String; out JSArray: TJSONArray;
  out Erro: String): Boolean;
var
  Json : String;
begin
  with RequestListarProdutosComanda do
  begin
    Params.Clear;
    AddParameter('id_comanda', IdComanda,TRESTRequestParameterKind.pkGETorPOST);
    Execute;

    if(Response.StatusCode<>200)then
    begin
      Result := False;
      Erro := 'Erro do Servidor ' + Response.StatusCode.ToString;
      exit;
    end;

    Json := Response.JSONValue.ToString;

    JSArray := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(Json),0) as TJSONArray;
    Result := True;
  end;
end;

function TDM.ValidaLogin(usuario:String; out Erro:String): Boolean;
var
  Json : String;
  JsonObj: TJSONObject;
begin
  try
    RequestLogin.Params.Clear;
    RequestLogin.AddParameter('usuario',usuario,TRESTRequestParameterKind.pkGETorPOST);
    RequestLogin.Execute;
    if(RequestLogin.Response.StatusCode<>200)then
    begin
      Result := False;
      Erro := 'Erro ao Validar Login: ' + RequestLogin.Response.StatusCode.ToString;
    end else
    begin
      Json := RequestLogin.Response.JSONValue.ToString;
      JsonObj := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(Json),0) as TJSONObject;

      if(JsonObj.GetValue('retorno').Value ='OK')then
      begin
        Erro:='';
        Result := True;
      end
      else
      begin
        Result := False;
        Erro := JsonObj.GetValue('retorno').Value;
      end;
    end;
  except
    on E:Exception do
      raise Exception.Create('Ocorreu um Erro ao tentar Logar: ' + E.Message);
  end;
end;

end.
