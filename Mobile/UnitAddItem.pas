unit UnitAddItem;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.Edit, FMX.TabControl, FMX.ListView, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, System.JSON,
  System.NetEncoding;

type
  TFormAddItem = class(TForm)
    RecToolbar: TRectangle;
    Label1: TLabel;
    ImgFechar: TImage;
    lvCategoria: TListView;
    TabControl: TTabControl;
    TabCategoria: TTabItem;
    TabProduto: TTabItem;
    RecBusca: TRectangle;
    EditBusca: TEdit;
    RecBuscarProduto: TRectangle;
    Label7: TLabel;
    RecToolBarProduto: TRectangle;
    lblTitulo: TLabel;
    ImgVoltar: TImage;
    RecComanda: TRectangle;
    lblComanda: TLabel;
    lvProdutos: TListView;
    ImgAdd: TImage;
    LayoutQtde: TLayout;
    RecDialog: TRectangle;
    RecPlanoFundo: TRectangle;
    lblProdutoDialog: TLabel;
    RecAdicionar: TRectangle;
    Label4: TLabel;
    lblQtde: TLabel;
    ImgDel: TImage;
    ImgAddQtde: TImage;
    ImgCloseDialog: TImage;
    EditObsAdicional: TEdit;
    lvOpcional: TListView;
    ImageChecked: TImage;
    ImageUnChecked: TImage;
    Rectangle1: TRectangle;
    procedure ImgFecharClick(Sender: TObject);
    procedure ImgVoltarClick(Sender: TObject);
    procedure lvCategoriaItemClick(const Sender: TObject;
      const AItem: TListViewItem);
    procedure FormShow(Sender: TObject);
    procedure lvProdutosItemClick(const Sender: TObject;
      const AItem: TListViewItem);
    procedure ImgAddQtdeClick(Sender: TObject);
    procedure ImgCloseDialogClick(Sender: TObject);
    procedure RecAdicionarClick(Sender: TObject);
    procedure lvOpcionalItemClickEx(const Sender: TObject; ItemIndex: Integer;
      const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
  private
    procedure AddCategoria(Id:Integer;Descricao, Icone:String);
    procedure ListarCategorias;
    procedure AddProduto(IdOpcao: Integer; Descricao: String; Vlr: Double);
    procedure AddOpcional(IdOpcao:Integer; Descricao:String;Valor:Double);
    procedure ListarProdutos(IdCategoria: Integer;Busca:String);
    procedure ListarOpcional(IdProduto:Integer);
    function ConverteValor(Vlr: String): Double;
    function BitmapFromBase64(const base64: String): TBitmap;
  public
    Comanda: String;
  end;

var
  FormAddItem: TFormAddItem;

implementation

{$R *.fmx}

uses UnitDM;

procedure TFormAddItem.AddCategoria(Id:Integer;Descricao, Icone:String);
var
  img : TBitmap;
begin
  with lvCategoria.Items.Add do
  begin
    Tag := Id;
    TListItemText(Objects.FindDrawable('TxtDescricao')).Text := Descricao;
    //Icone....
//    TIdDecoderMIME.DecodeStream(JSONArray.Get(i).GetValue<String>('ICONE'),Icone);
    if(Trim(Icone)<>'')then
    begin
      img := TBitmap.Create; //A própria rotina de limpar os items da um Free, não precisa se preocupar com MemoryLeak
      img := BitmapFromBase64(Icone);
      TListItemImage(Objects.FindDrawable('ImgIcone')).OwnsBitmap := True; //Precisa setar como True se não pode aparecer no Android;
      TListItemImage(Objects.FindDrawable('ImgIcone')).Bitmap  := img;
    end;
  end;
end;

procedure TFormAddItem.AddOpcional(IdOpcao: Integer; Descricao: String;
  Valor: Double);
begin
  with lvOpcional.Items.Add do
  begin
    Tag      := IdOpcao;
    TListItemText(Objects.FindDrawable('TxtDescricao')).Text := Descricao;
    TListItemText(Objects.FindDrawable('TxtValor'    )).Text := FormatFloat('#,##0.00', Valor);
    TListItemImage(Objects.FindDrawable('ImgCheck')).Bitmap  := ImageUnChecked.Bitmap;
    TListItemImage(Objects.FindDrawable('ImgCheck')).TagString := 'F';
    TListItemImage(Objects.FindDrawable('ImgCheck')).TagFloat  := Valor;
  end;
end;

procedure TFormAddItem.AddProduto(IdOpcao: Integer; Descricao: String; Vlr: Double);
begin
  with lvProdutos.Items.Add do
  begin
    Tag := IdOpcao;
    TListItemText(Objects.FindDrawable('TxtDescricao')).Text := Descricao;
    TListItemText(Objects.FindDrawable('TxtPreco')).Text     := FormatFloat('##0.00',Vlr);
    TListItemImage(Objects.FindDrawable('ImgAdd')).Bitmap    := ImgAdd.Bitmap;
  end;
end;

function TFormAddItem.BitmapFromBase64(const base64: String): TBitmap;
var
  Input    : TStringStream;
  Output   : TBytesStream;
  Encoding : TBase64Encoding;
begin
  Input := TStringStream.Create(base64,TEncoding.ASCII);
  try
    Output := TBytesStream.Create;
    try
      Encoding := TBase64Encoding.Create(0);
      Encoding.Decode(Input,Output);

      Output.Position := 0;

      Result := TBitMap.Create;
      try
        Result.LoadFromStream(Output);
      except
        on E:Exception do
        begin
          Result.Free;
          raise Exception.Create('Erro ao carregar imagens: ' + E.Message);
        end;
      end;

    finally
      Output.Free;
      Encoding.DisposeOf;
    end;
  finally
    Input.Free;
  end;
end;

function TFormAddItem.ConverteValor(Vlr: String):Double;
begin
  try
    Vlr := Vlr.Replace(',','').Replace('.','');
    Result := Vlr.ToDouble;
    Result := Result / 100;
  except
    Result := 0;
  end;
end;

procedure TFormAddItem.FormShow(Sender: TObject);
begin
  LayoutQtde.Visible := False;
  ListarCategorias;
end;

procedure TFormAddItem.ImgAddQtdeClick(Sender: TObject);
begin
  try
    lblQtde.Text := FormatFloat('00', lblQtde.Text.ToInteger + TImage(Sender).Tag);
  except
    lblQtde.Text := '01';
  end;
  if(lblQtde.Text.ToInteger<1)then
    lblQtde.Text := '01';
end;

procedure TFormAddItem.ImgCloseDialogClick(Sender: TObject);
begin
  LayoutQtde.Visible := False;
end;

procedure TFormAddItem.ImgFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TFormAddItem.ImgVoltarClick(Sender: TObject);
begin
  TabControl.GotoVisibleTab(0,TTabTransition.Slide);
end;

procedure TFormAddItem.ListarCategorias;
var
  JSONArray: TJSONArray;
  Erro : String;
  i: integer;
begin
  lvCategoria.Items.Clear;
  if(DM.ListarCategorias(JSONArray,Erro))then
  begin
    for i:= 0 to Pred(JSONArray.Size) do
    begin
      AddCategoria(JSONArray.Get(i).GetValue<integer>('ID_CATEGORIA'),
      JSONArray.Get(i).GetValue<String>('DESCRICAO'),
      JSONArray.Get(i).GetValue<String>('ICONE'));
    end;
  end else
  begin
    ShowMessage('Erro ao Listar as Categorias ' + Erro);
  end;
end;

procedure TFormAddItem.ListarOpcional(IdProduto: Integer);
var
  i: integer;
  Erro: String;
  JSONArray: TJSONArray;
begin
  lvOpcional.Items.Clear;
  if(IdProduto<=0)then
  begin
    lvOpcional.Visible := False;
    exit;
  end;
  if(DM.ListarOpcional(IdProduto,JSONArray,Erro))then
  begin
    for i:=0 to Pred(JSONArray.Size) do
    begin
      AddOpcional(JSONArray.Get(i).GetValue<Integer>('ID_OPCAO'),
                 JSONArray.Get(i).GetValue<String>('DESCRICAO'),
                 JSONArray.Get(i).GetValue<Double>('VALOR'));
    end;
    lvOpcional.Visible := JSONArray.Size > 0;
    JSONArray.DisposeOf;
  end else
  begin
    ShowMessage('Ocorreu um Erro ao Listar os Opcionais: ' + Erro);
  end;
end;

procedure TFormAddItem.ListarProdutos(IdCategoria: Integer;Busca:String);
var
  i: integer;
  Erro: String;
  JSONArray: TJSONArray;
begin
  lvProdutos.Items.Clear;
  if(DM.ListarProdutos(IdCategoria,'',0,JSONArray,Erro))then
  begin
    for i:=0 to Pred(JSONArray.Size) do
    begin
      AddProduto(JSONArray.Get(i).GetValue<Integer>('ID_PRODUTO'),
      JSONArray.Get(i).GetValue<String>('DESCRICAO'),
      JSONArray.Get(i).GetValue<Double>('PRECO'));
    end;
  end else
  begin
    ShowMessage('Ocorreu um Erro ao Listar os Produtos: ' + Erro);
  end;
end;

procedure TFormAddItem.lvCategoriaItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
  lblTitulo.Text  := TListItemText(AItem.Objects.FindDrawable('TxtDescricao')).Text;
  lblComanda.Text := 'Comanda/Mesa ' + Comanda;
  ListarProdutos(AItem.Tag,'');
  TabControl.GoToVisibleTab(1,TTabTransition.Slide);
end;

procedure TFormAddItem.lvOpcionalItemClickEx(const Sender: TObject;
  ItemIndex: Integer; const LocalClickPos: TPointF;
  const ItemObject: TListItemDrawable);
begin
  if(TListView(Sender).Selected<>nil)then
  begin
    if(ItemObject is TListItemImage)then
    begin
      if(TListItemImage(ItemObject).TagString='F')then
      begin
        TListItemImage(ItemObject).Bitmap := ImageChecked.Bitmap;
        TListItemImage(ItemObject).TagString := 'V';
      end else
      begin
        TListItemImage(ItemObject).Bitmap := ImageUnChecked.Bitmap;
        TListItemImage(ItemObject).TagString := 'F';
      end;
    end;
  end;
end;

procedure TFormAddItem.lvProdutosItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
  //Exibir a Confirmação + Qtde
  lblQtde.Text          := '01';
  lblProdutoDialog.Text := TListItemText(AItem.Objects.FindDrawable('TxtDescricao')).Text;
  lblProdutoDialog.Tag  := AItem.Tag;
  lblQtde.TagFloat      := ConverteValor(TListItemText(AItem.Objects.FindDrawable('TxtPreco')).Text);

  //Verificar Opcionais....
  ListarOpcional(AItem.Tag);

  EditObsAdicional.Text.Empty;
  LayoutQtde.Visible := True;
end;

procedure TFormAddItem.RecAdicionarClick(Sender: TObject);
var
  Erro, ObsOpcional: String;
  VlOpcional: Double;
  i: integer;
begin
//Verificar Adicionais-------
  VlOpcional := 0;
  ObsOpcional   := '';
  for i := 0 to Pred(lvOpcional.Items.Count)do
  begin
    if(TListItemImage(lvOpcional.Items[i].Objects.FindDrawable('ImgCheck')).TagString='V')then
    begin
      VlOpcional := VlOpcional + (TListItemImage(lvOpcional.Items[i].Objects.FindDrawable('ImgCheck')).TagFloat * lblQtde.Text.ToInteger);
      if(Trim(ObsOpcional)<>'')then
        ObsOpcional := ObsOpcional + ' + ';
      ObsOpcional   := ObsOpcional + TListItemText(lvOpcional.Items[i].Objects.FindDrawable('TxtDescricao')).Text;
    end;
  end;

  if(Trim(ObsOpcional)<>'')then
    ObsOpcional := ObsOpcional + ' = ' + FormatFloat('#,##0.00', VlOpcional);


//Adiciona Produto-----------
  if(DM.AdicionarProdutoComanda(Comanda,
                                lblProdutoDialog.Tag,
                                lblQtde.Text.ToInteger,
                                lblQtde.Text.ToInteger * lblQtde.TagFloat,
                                EditObsAdicional.Text,
                                ObsOpcional,
                                VlOpcional,
                                Erro))then
  begin
    ShowMessage('Produto inserido');
    LayoutQtde.Visible := False;
  end else
  begin
    ShowMessage(Erro);
  end;
end;

end.
