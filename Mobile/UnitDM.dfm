object DM: TDM
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 275
  Width = 448
  object Conn: TFDConnection
    Params.Strings = (
      'LockingMode=Normal'
      'DriverID=SQLite')
    LoginPrompt = False
    Left = 40
    Top = 24
  end
  object QryConfig: TFDQuery
    Connection = Conn
    Left = 104
    Top = 24
  end
  object RESTClient: TRESTClient
    Accept = 'application/json, text/plain; q=0.9, text/html;q=0.8,'
    AcceptCharset = 'utf-8, *;q=0.8'
    Params = <>
    RaiseExceptionOn500 = False
    Left = 32
    Top = 112
  end
  object RequestLogin: TRESTRequest
    Client = RESTClient
    Method = rmPOST
    Params = <
      item
        Name = 'usuario'
        Value = 'Diego'
      end>
    Resource = 'ValidarLogin'
    SynchronizedEvents = False
    Left = 104
    Top = 104
  end
  object RequestListarComandas: TRESTRequest
    Client = RESTClient
    Method = rmPOST
    Params = <
      item
        Name = 'usuario'
        Value = 'Diego'
      end>
    Resource = 'ListarComandas'
    SynchronizedEvents = False
    Left = 188
    Top = 112
  end
  object RequestListarCategorias: TRESTRequest
    Client = RESTClient
    Method = rmPOST
    Params = <
      item
        Name = 'usuario'
        Value = 'Diego'
      end>
    Resource = 'ListarCategorias'
    SynchronizedEvents = False
    Left = 28
    Top = 176
  end
  object RequestListarProdutos: TRESTRequest
    Client = RESTClient
    Method = rmPOST
    Params = <
      item
        Name = 'usuario'
        Value = 'Diego'
      end>
    Resource = 'ListarProdutos'
    SynchronizedEvents = False
    Left = 160
    Top = 176
  end
  object RequestListarProdutosComanda: TRESTRequest
    Client = RESTClient
    Method = rmPOST
    Params = <
      item
        Name = 'usuario'
        Value = 'Diego'
      end>
    Resource = 'ListarProdutosComanda'
    SynchronizedEvents = False
    Left = 304
    Top = 176
  end
  object RequestAdicionarProduto: TRESTRequest
    Client = RESTClient
    Method = rmPOST
    Params = <
      item
        Name = 'usuario'
        Value = 'Diego'
      end>
    Resource = 'AdicionarProdutoComanda'
    SynchronizedEvents = False
    Left = 316
    Top = 112
  end
  object RequestExcluirProduto: TRESTRequest
    AutoCreateParams = False
    Client = RESTClient
    Method = rmPOST
    Params = <
      item
        Name = 'usuario'
        Value = 'Diego'
      end>
    Resource = 'ExcluirProdutoComanda'
    SynchronizedEvents = False
    Left = 196
    Top = 40
  end
  object RequestEncerrarComanda: TRESTRequest
    AutoCreateParams = False
    Client = RESTClient
    Method = rmPOST
    Params = <
      item
        Name = 'usuario'
        Value = 'Diego'
      end>
    Resource = 'EncerrarComanda'
    SynchronizedEvents = False
    Left = 316
    Top = 40
  end
  object RequestListarOpcional: TRESTRequest
    Client = RESTClient
    Method = rmPOST
    Params = <
      item
        Name = 'usuario'
        Value = 'Diego'
      end>
    Resource = 'ListarOpcional'
    SynchronizedEvents = False
    Left = 120
    Top = 216
  end
end
