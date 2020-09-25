object DM: TDM
  OldCreateOrder = False
  Encoding = esUtf8
  Height = 425
  Width = 343
  object Conn: TFDConnection
    Params.Strings = (
      
        'Database=C:\Users\Prog-3\Documents\Embarcadero\Studio\Projects\S' +
        'emana Mobile - Comandas\Servidor\DB\BANCO.FDB'
      'User_Name=SYSDBA'
      'Password=masterkey'
      'DriverID=FB')
    LoginPrompt = False
    Left = 168
    Top = 184
  end
  object DWEvents: TDWServerEvents
    IgnoreInvalidParams = False
    Events = <
      item
        Routes = [crAll]
        DWParams = <
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'usuario'
            Encoded = False
          end>
        JsonMode = jmPureJSON
        Name = 'ValidarLogin'
        OnReplyEvent = DWEventsEventsValidarLoginReplyEvent
      end
      item
        Routes = [crAll]
        DWParams = <>
        JsonMode = jmPureJSON
        Name = 'ListarComandas'
        OnReplyEvent = DWEventsEventsListarComandasReplyEvent
      end
      item
        Routes = [crAll]
        DWParams = <>
        JsonMode = jmPureJSON
        Name = 'ListarCategorias'
        OnReplyEvent = DWEventsEventsListarCategoriasReplyEvent
      end
      item
        Routes = [crAll]
        DWParams = <
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'id_categoria'
            Encoded = False
          end
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'termo_busca'
            Encoded = False
          end
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'pagina'
            Encoded = True
          end>
        JsonMode = jmPureJSON
        Name = 'ListarProdutos'
        OnReplyEvent = DWEventsEventsListarProdutosReplyEvent
      end
      item
        Routes = [crAll]
        DWParams = <
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'id_comanda'
            Encoded = False
          end
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'id_produto'
            Encoded = False
          end
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'qtd'
            Encoded = False
          end
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'vlr_total'
            Encoded = True
          end
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'obs_opcional'
            Encoded = False
          end
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'vl_opcional'
            Encoded = False
          end
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'obs'
            Encoded = False
          end>
        JsonMode = jmPureJSON
        Name = 'AdicionarProdutoComanda'
        OnReplyEvent = DWEventsEventsAdicionarProdutoComandaReplyEvent
      end
      item
        Routes = [crAll]
        DWParams = <
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'id_comanda'
            Encoded = False
          end>
        JsonMode = jmPureJSON
        Name = 'ListarProdutosComanda'
        OnReplyEvent = DWEventsEventsListarProdutosComandaReplyEvent
      end
      item
        Routes = [crAll]
        DWParams = <
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'id_comanda'
            Encoded = False
          end
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'id_consumo'
            Encoded = False
          end>
        JsonMode = jmPureJSON
        Name = 'ExcluirProdutoComanda'
        OnReplyEvent = DWEventsEventsExcluirProdutoComandaReplyEvent
      end
      item
        Routes = [crAll]
        DWParams = <
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'id_comanda'
            Encoded = False
          end>
        JsonMode = jmPureJSON
        Name = 'EncerrarComanda'
        OnReplyEvent = DWEventsEventsEncerrarComandaReplyEvent
      end
      item
        Routes = [crAll]
        DWParams = <
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'id_produto'
            Encoded = False
          end>
        JsonMode = jmPureJSON
        Name = 'ListarOpcional'
        OnReplyEvent = DWEventsEventsListarOpcionalReplyEvent
      end>
    Left = 120
    Top = 248
  end
  object QryLogin: TFDQuery
    Connection = Conn
    Left = 224
    Top = 136
  end
end
