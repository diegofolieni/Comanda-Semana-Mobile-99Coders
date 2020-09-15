unit UnitDM;

interface

uses
  System.SysUtils, System.Classes, uDWDataModule, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.FMXUI.Wait, Data.DB,
  FireDAC.Comp.Client, uDWJSONObject, uDWAbout, uRESTDWServerEvents,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, System.JSON, FireDAC.VCLUI.Wait;
type
  TDM = class(TServerMethodDataModule)
    Conn: TFDConnection;
    DWEvents: TDWServerEvents;
    QryLogin: TFDQuery;
    procedure DWEventsEventsValidarLoginReplyEvent(var Params: TDWParams;
      var Result: string);
    procedure DWEventsEventsListarComandasReplyEvent(var Params: TDWParams;
      var Result: string);
    procedure DWEventsEventsListarCategoriasReplyEvent(var Params: TDWParams;
      var Result: string);
    procedure DWEventsEventsListarProdutosReplyEvent(var Params: TDWParams;
      var Result: string);
    procedure DWEventsEventsAdicionarProdutoComandaReplyEvent(
      var Params: TDWParams; var Result: string);
    procedure DWEventsEventsListarProdutosComandaReplyEvent(
      var Params: TDWParams; var Result: string);
    procedure DWEventsEventsExcluirProdutoComandaReplyEvent(
      var Params: TDWParams; var Result: string);
    procedure DWEventsEventsEncerrarComandaReplyEvent(var Params: TDWParams;
      var Result: string);
    procedure DWEventsEventsListarOpcionalReplyEvent(var Params: TDWParams;
      var Result: string);
  private
    { Private declarations }
  public

  end;

var
  DM: TDM;

implementation

uses
  uDWConsts;

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TDM.DWEventsEventsAdicionarProdutoComandaReplyEvent(
  var Params: TDWParams; var Result: string);
var
  Qry : TFDQuery;
  Json : TJSONObject;
begin
  Qry  := TFDQuery.Create(nil);
  Json := TJSONObject.Create;
  try
    Qry.Connection := Conn;
    if(Params.ItemsString['id_comanda'].AsString='')or
      (Params.ItemsString['id_produto'].AsString='')or
      (Params.ItemsString['qtd'       ].AsString='')or
      (Params.ItemsString['vlr_total' ].AsString='')then
    begin
      Json.AddPair('retorno','Parametros não informados');
      Result := Json.ToString;
      exit;
    end;

    try
      //Atualiza a Comanda como Aberta;
      Qry.Active := False;
      Qry.SQL.Clear;
      Qry.SQL.Add('UPDATE TAB_COMANDA SET STATUS = ''A'',');
      Qry.SQL.Add('DT_ABERTURA = COALESCE(DT_ABERTURA, current_timestamp)');
      Qry.SQL.Add('WHERE ID_COMANDA = :ID_COMANDA');
      Qry.ParamByName('ID_COMANDA').AsString := Params.ItemsString['id_comanda'].AsString;
      Qry.ExecSQL;

      Qry.Active := False;
      Qry.SQL.Clear;
      Qry.SQL.Add('INSERT INTO TAB_COMANDA_CONSUMO(ID_COMANDA,ID_PRODUTO,QTD,VALOR_TOTAL)');
      Qry.SQL.Add('VALUES(:ID_COMANDA,:ID_PRODUTO,:QTD,:VALOR_TOTAL)');
      Qry.ParamByName('ID_COMANDA' ).AsString  := Params.ItemsString['id_comanda'].AsString;
      Qry.ParamByName('ID_PRODUTO' ).AsInteger := Params.ItemsString['id_produto'].AsInteger;
      Qry.ParamByName('QTD'        ).AsInteger := Params.ItemsString['qtd'       ].AsInteger;
      Qry.ParamByName('VALOR_TOTAL').AsFloat   := Params.ItemsString['vlr_total' ].AsFloat;
      Qry.ExecSQL;

      Json.AddPair('retorno','OK');
    except
      on E:Exception do
        Json.AddPair('retorno','Ocorreu um erro ao Inserir: ' + E.Message);
    end;

    Result := Json.ToString;
  finally
    Qry.DisposeOf;
    Json.DisposeOf;
  end;
end;

procedure TDM.DWEventsEventsEncerrarComandaReplyEvent(var Params: TDWParams;
  var Result: string);
var
  Qry  : TFDQuery;
  Json : TJSONObject;
begin
  Qry  := TFDQuery.Create(nil);
  Json := TJSONObject.Create;
  try
    if(Params.ItemsString['id_comanda'].AsString='')then
    begin
      Json.AddPair('retorno','Parametro id_comanda não informado');
      Result := Json.ToString;
      exit;
    end;
    Qry.Connection := Conn;

    try
      //Aqui cadastraria a comanda na tabela de vendas do ERP do restaurante
      Qry.Active := False;
      Qry.SQL.Clear;
      Qry.SQL.Add('UPDATE TAB_COMANDA SET STATUS = ''F'', DT_ABERTURA = NULL ');
      Qry.SQL.Add('WHERE ID_COMANDA = :ID_COMANDA');
      Qry.ParamByName('ID_COMANDA').AsString := Params.ItemsString['id_comanda'].AsString;
      Qry.ExecSQL;

      Qry.Active := False;
      Qry.SQL.Clear;
      Qry.SQL.Add('DELETE FROM TAB_COMANDA_CONSUMO ');
      Qry.SQL.Add('WHERE ID_COMANDA = :ID_COMANDA');
      Qry.ParamByName('ID_COMANDA').AsString := Params.ItemsString['id_comanda'].AsString;
      Qry.ExecSQL;

      Json.AddPair('retorno','OK');

    except
      on E:Exception do
        Json.AddPair('retorno','Erro ao finalizar comanda ' + E.Message);
    end;
    Result := Json.ToString;
  finally
    Qry.DisposeOf;
    Json.DisposeOf;
  end;
end;

procedure TDM.DWEventsEventsExcluirProdutoComandaReplyEvent(
  var Params: TDWParams; var Result: string);
var
  Qry: TFDQuery;
  Json : TJSONObject;
begin
  Qry  := TFDQuery.Create(nil);
  Json := TJSONObject.Create;
  try
    Qry.Connection := Conn;
    Qry.Active := False;
    if(Params.ItemsString['id_comanda'].AsString = '')or
      (Params.ItemsString['id_consumo'].AsString = '')then
    begin
      Json.AddPair('retorno','Parametros não informados');
      Result := Json.ToString;
      exit;
    end;

    try
      Qry.Active := False;
      Qry.SQL.Clear;
      Qry.SQL.Add('DELETE FROM TAB_COMANDA_CONSUMO ');
      Qry.SQL.Add('WHERE ID_CONSUMO = :ID_CONSUMO AND ID_COMANDA = :ID_COMANDA');
      Qry.ParamByName('ID_COMANDA').AsString  := Params.ItemsString['id_comanda'].AsString;
      Qry.ParamByName('ID_CONSUMO').AsInteger := Params.ItemsString['id_consumo'].AsInteger;
      Qry.ExecSQL;
      Json.AddPair('retorno','OK');
    except
      on E:Exception do
        Json.AddPair('retorno','Ocorreu um Erro ' +E.Message);
    end;
    Result := Json.ToString;
  finally
    Qry.DisposeOf;
    Json.DisposeOf;
  end;
end;

procedure TDM.DWEventsEventsListarCategoriasReplyEvent(var Params: TDWParams;
  var Result: string);
var
  Qry : TFDQuery;
  Json : uDWJSONObject.TJSONValue;
begin
  Qry  := TFDQuery.Create(nil);
  Json := uDWJSONObject.TJSONValue.Create;
  try
    Qry.Connection := Conn;

    Qry.Active := False;
    Qry.SQL.Clear;
    Qry.SQL.Add('SELECT C.*');
    Qry.SQL.Add('FROM TAB_PRODUTO_CATEGORIA C');
    Qry.SQL.Add('ORDER BY C.DESCRICAO');
    Qry.Active := True;

    Json.LoadFromDataSet('',Qry,False, jmPureJSON);

    Result := Json.ToJSON;
  finally
    Json.DisposeOf;
    Qry.DisposeOf;
  end;
end;

procedure TDM.DWEventsEventsListarComandasReplyEvent(var Params: TDWParams;var Result: string);
var
  Qry: TFDQuery;
  Json : uDWJSONObject.TJSONValue;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := Conn;
    Json := uDWJSONObject.TJSONValue.Create;
    try
      Qry.Active := False;
      Qry.SQL.Clear;
      Qry.SQL.Add('SELECT C.ID_COMANDA, C.STATUS, COALESCE(SUM(O.VALOR_TOTAL),0) AS VALOR_TOTAL');
      Qry.SQL.Add('FROM TAB_COMANDA C');
      Qry.SQL.Add('LEFT JOIN TAB_COMANDA_CONSUMO O ON (C.ID_COMANDA = O.ID_COMANDA)');
      Qry.SQL.Add('GROUP BY C.ID_COMANDA,C.STATUS');
      Qry.SQL.Add('ORDER BY C.ID_COMANDA');
      Qry.Active := True;

      Json.LoadFromDataset('',Qry,False,jmPureJSON);

      Result := Json.ToJSON;
    finally
      Json.DisposeOf;
    end;
  finally
    Qry.DisposeOf;
  end;
end;

procedure TDM.DWEventsEventsListarOpcionalReplyEvent(var Params: TDWParams;
  var Result: string);
var
  Qry: TFDQuery;
  Json : uDWJSONObject.TJSONValue;
begin
  Qry  := TFDQuery.Create(nil);
  Json := uDWJSONObject.TJSONValue.Create;
  try
    Qry.Connection := Conn;
    Qry.Active := False;
    Qry.SQL.Clear;
    if(Params.ItemsString['id_produto'].AsString='')then
    begin
      Result := '{"retorno":"É preciso passar um IdProduto"}';
    end else
    begin
      Qry.SQL.Add('SELECT * ');
      Qry.SQL.Add('FROM TAB_PRODUTO_OPCIONAL ');
      Qry.SQL.Add('WHERE ID_PRODUTO = :ID_PRODUTO');
      Qry.ParamByName('ID_PRODUTO').AsInteger := Params.ItemsString['id_produto'].AsInteger;
      Qry.SQL.Add('ORDER BY DESCRICAO');

      Qry.Active := True;

      Json.LoadFromDataSet('',Qry,False,jmPureJSON);

      Result := Json.ToJSON;
    end;
  finally
    Qry.DisposeOf;
    Json.DisposeOf;
  end;
end;

procedure TDM.DWEventsEventsListarProdutosComandaReplyEvent(
  var Params: TDWParams; var Result: string);
var
  Qry : TFDQuery;
  Json : uDWJSONObject.TJSONValue;
begin
  Qry  := TFDQuery.Create(nil);
  Json := uDWJSONObject.TJSONValue.Create;
  try
    Qry.Connection := Conn;
    Qry.Active := False;
    Qry.SQL.Clear;
    Qry.SQL.Add('SELECT C.ID_CONSUMO, P.ID_PRODUTO, P.DESCRICAO, C.QTD, C.VALOR_TOTAL');
    Qry.SQL.Add('FROM TAB_COMANDA_CONSUMO C');
    Qry.SQL.Add('JOIN TAB_PRODUTO P ON (P.ID_PRODUTO = C.ID_PRODUTO)');
    Qry.SQL.Add('WHERE C.ID_COMANDA = :ID_COMANDA');
    Qry.SQL.Add('ORDER BY P.DESCRICAO');
    Qry.ParamByName('ID_COMANDA').AsString := Params.ItemsString['id_comanda'].AsString;
    Qry.Active := True;

    Json.LoadFromDataset('',Qry,False,jmPureJSON);

    Result := Json.ToJSON;
  finally
    Qry.DisposeOf;
    Json.DisposeOf;
  end;
end;

procedure TDM.DWEventsEventsListarProdutosReplyEvent(var Params: TDWParams;
  var Result: string);
var
  Qry: TFDQuery;
  Json : uDWJSONObject.TJSONValue;
  pg_inicio,pg_fim : Integer;
begin
  Qry  := TFDQuery.Create(nil);
  Json := uDWJSONObject.TJSONValue.Create;
  try
    Qry.Connection := Conn;
    Qry.Active := False;
    Qry.SQL.Clear;
    Qry.SQL.Add('SELECT * ');
    Qry.SQL.Add('FROM TAB_PRODUTO P');
    Qry.SQL.Add('WHERE P.ID_PRODUTO > 0');
    if(Params.ItemsString['id_categoria'].AsString<>'0')then
    begin
      Qry.SQL.Add('AND P.ID_CATEGORIA = :ID_CATEGORIA');
      Qry.ParamByName('ID_CATEGORIA').AsInteger := Params.ItemsString['id_categoria'].AsInteger;
    end;
    if(Params.ItemsString['termo_busca'].AsString<>'')then
    begin
      Qry.SQL.Add('AND P.DESCRICAO LIKE :TERMO_BUSCA');
      Qry.ParamByName('TERMO_BUSCA').Value := '%'+Params.ItemsString['termo_busca'].AsString+'%';
    end;
    Qry.SQL.Add('ORDER BY P.DESCRICAO');
    if(Params.ItemsString['pagina'].AsString<>'0')then
    begin
      pg_inicio := (Params.ItemsString['pagina'].AsInteger - 1) * 10  +1;
      pg_fim    := Params.ItemsString['pagina'].AsInteger * 10;
      Qry.SQL.Add('ROWS ' + pg_inicio.ToString + ' TO ' + pg_fim.ToString);
    end;
    Qry.Active := True;

    Json.LoadFromDataSet('',Qry,False,jmPureJSON);

    Result := Json.ToJSON;
  finally
    Qry.DisposeOf;
    Json.DisposeOf;
  end;
end;

procedure TDM.DWEventsEventsValidarLoginReplyEvent(var Params: TDWParams;
  var Result: string);
var
  Json : TJsonObject;
begin
  Json := TJsonObject.Create;
  try
    if(Params.ItemsString['usuario'].AsString = '')then
    begin
      Json.AddPair('retorno','Usuário não informado');
      Result := Json.ToString;
      exit;
    end;

    try
      QryLogin.Active := False;
      QryLogin.SQL.Clear;
      QryLogin.SQL.Add('SELECT * FROM TAB_USUARIO WHERE COD_USUARIO = :Usuario');
      QryLogin.ParamByName('Usuario').AsString := Params.ItemsString['usuario'].AsString;
      QryLogin.Active := True;

      if(QryLogin.RecordCount>0)then
        Json.AddPair('retorno','OK')
      else
        Json.AddPair('retorno','Usuário não informado');
    except
      on E:Exception do
        Json.AddPair('retorno','Erro ao Logar: ' + E.Message);
    end;
    Result := Json.ToString;
  finally
    Json.DisposeOf;
  end;
end;

end.
