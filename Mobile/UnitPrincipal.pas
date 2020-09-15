unit UnitPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.TabControl,
  FMX.Edit, FMX.Layouts, FMX.ListBox, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView, FMX.Types,
  System.JSON;

type
  TFormPrincipal = class(TForm)
    RecToolbar: TRectangle;
    Label1: TLabel;
    TabControl: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    TabItem3: TTabItem;
    RecMenu: TRectangle;
    Rectangle1: TRectangle;
    Label2: TLabel;
    Rectangle2: TRectangle;
    Label3: TLabel;
    LayoutComanda: TLayout;
    Label4: TLabel;
    EditComanda: TEdit;
    RecAddItem: TRectangle;
    Label5: TLabel;
    RecDetalhes: TRectangle;
    Label6: TLabel;
    lbMapaMesas: TListBox;
    Rectangle4: TRectangle;
    lvProdutos: TListView;
    EditBuscaProduto: TEdit;
    RecBuscaProduto: TRectangle;
    Label7: TLabel;
    ImageAba1: TImage;
    ImageAba2: TImage;
    ImageAba3: TImage;
    procedure ImageAba1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RecDetalhesClick(Sender: TObject);
    procedure RecAddItemClick(Sender: TObject);
    procedure lbMapaMesasItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
    procedure FormResize(Sender: TObject);
    procedure RecBuscaProdutoClick(Sender: TObject);
    procedure lvProdutosPaint(Sender: TObject; Canvas: TCanvas;
      const ARect: TRectF);
    procedure ThreadEnd(Sender: TObject);
  private
    procedure MudarAba(Img: TImage);
    procedure DetalhesComanda(NmroComanda: String);
    procedure AddMapa(Comanda:String; Status:String;VlrTotal:Double);
    procedure CarregarComanda;
    procedure AddProdutoLv(Id:Integer;Descricao:String;Preco:Double);
    procedure ListarProduto(IndClear: Boolean; Busca: String);

  public
    procedure AddItem(Comanda: String);
  end;

var
  FormPrincipal: TFormPrincipal;

implementation

{$R *.fmx}

uses UnitAddItem, UnitResumo, UnitDM;

procedure TFormPrincipal.AddItem(Comanda: String);
begin
  if not(Assigned(FormAddItem))then
    Application.CreateForm(TFormAddItem,FormAddItem);
  FormAddItem.TabControl.ActiveTab := FormAddItem.TabCategoria;
  FormAddItem.Comanda := Comanda;
  FormAddItem.Show;
end;

procedure TFormPrincipal.AddMapa(Comanda:String; Status:String;VlrTotal:Double);
var
  Item : TListBoxItem;
  RecItem: TRectangle;
  Lbl: TLabel;
begin
//Usou a ListBox porque a ListView não tem propriedade Columns;

  Item                  := TListBoxItem.Create(lbMapaMesas);
  Item.Text             := '';
  Item.Height           := 110;
  Item.TagString        := Comanda;
  Item.Selectable := False;
  //Retangulo de fundo....
  RecItem                := TRectangle.Create(Item);
  RecItem.Name           := 'Comanda_'+Comanda;
  RecItem.Parent         := Item;
  RecItem.Align          := TAlignLayout.Client;
  RecItem.Margins.Top    := 10;
  RecItem.Margins.Bottom := 10;
  RecItem.Margins.Left   := 10;
  RecItem.Margins.Right  := 10;
  RecItem.Fill.Kind      := TBrushKind.Solid;
  if(Status='F')then
    RecItem.Fill.Color   := $FF4A70F7 //Azul...
  else
    RecItem.Fill.Color   := $FFEC6E73; //Vermelho...

  RecItem.XRadius        := 10;
  RecItem.YRadius        := 10;
  RecItem.Stroke.Kind    := TBrushKind.None;
  RecItem.HitTest        := False; //Se deixar True ele Captura o Click ao invés do Item;
  //Label Status.........
  Lbl                := TLabel.Create(RecItem);
  Lbl.Parent         := RecItem;
  Lbl.Align          := TAlignLayout.Top;
  if(Status='F')then
    Lbl.Text         := 'Livre'
  else
    Lbl.Text         := 'Ocupada';
  Lbl.Margins.Left   := 5;
  Lbl.Margins.Top    := 5;
  Lbl.Height         := 15;
  Lbl.FontColor      := $FFFFFFFF;
  Lbl.StyledSettings := Lbl.StyledSettings - [TStyledSetting.FontColor];
  //Label Valor..........
  Lbl                := TLabel.Create(RecItem);
  Lbl.Parent         := RecItem;
  Lbl.Align          := TAlignLayout.Bottom;
  if(Status='F')then
    Lbl.Text         := ''
  else
    Lbl.Text         := FormatFloat('##0.00',VlrTotal);
  Lbl.Margins.Right  := 5;
  Lbl.Margins.Bottom := 5;
  Lbl.Height         := 15;
  Lbl.FontColor      := $FFFFFFFF;
  Lbl.StyledSettings := Lbl.StyledSettings - [TStyledSetting.FontColor];
  Lbl.TextAlign      := TTextAlign.Trailing;
  //Label Comanda.....
  Lbl                := TLabel.Create(RecItem);
  Lbl.Parent         := RecItem;
  Lbl.Align          := TAlignLayout.Client;
  Lbl.Text           := Comanda;
  Lbl.FontColor      := $FFFFFFFF;
  Lbl.StyledSettings := Lbl.StyledSettings - [TStyledSetting.FontColor, TStyledSetting.Size];
  Lbl.TextAlign      := TTextAlign.Center;
  Lbl.VertTextAlign  := TTextAlign.Center;
  Lbl.Font.Size      := 30;

  lbMapaMesas.AddObject(Item);
end;

procedure TFormPrincipal.AddProdutoLv(Id: Integer; Descricao: String;
  Preco: Double);
begin
  with lvProdutos.Items.Add do
  begin
    Tag := Id;
    TListItemText(Objects.FindDrawable('TxtDescricao')).Text := Descricao;
    TListItemText(Objects.FindDrawable('TxtPreco')).Text     := FormatFloat('##0.00',Preco);
  end;
end;

procedure TFormPrincipal.CarregarComanda;
var
  JSONArray: TJSONArray;
  Erro : String;
  i : Integer;
begin
  lbMapaMesas.Items.Clear;
  if(DM.ListarComandas(JSONArray,Erro))then
  begin
    for i:= 0 to Pred(JSONArray.Size)do
    begin
      AddMapa(JSONArray.Get(i).GetValue<string>('ID_COMANDA'),
              JSONArray.Get(i).GetValue<string>('STATUS'),
              JSONArray.Get(i).GetValue<double>('VALOR_TOTAL'));
    end;
    JSONArray.DisposeOf;
  end else
  begin
    ShowMessage('Erro ao Listar Comandas: ' + Erro);
  end;
end;

procedure TFormPrincipal.DetalhesComanda(NmroComanda: String);
begin
  if not(Assigned(FormResumo))then
    Application.CreateForm(TFormResumo,FormResumo);
  FormResumo.lblComanda.TagString := NmroComanda;
  FormResumo.lblComanda.Text := NmroComanda;
  FormResumo.ShowModal(
                      procedure(ModalResult: TModalResult)
                      begin
                        CarregarComanda;
                      end);
end;

procedure TFormPrincipal.FormResize(Sender: TObject);
begin
  lbMapaMesas.Columns := Trunc(lbMapaMesas.Width/110);
end;

procedure TFormPrincipal.FormShow(Sender: TObject);
begin
  MudarAba(ImageAba1);
end;

procedure TFormPrincipal.ImageAba1Click(Sender: TObject);
begin
  MudarAba(TImage(Sender));
end;

procedure TFormPrincipal.lbMapaMesasItemClick(const Sender: TCustomListBox;
  const Item: TListBoxItem);
begin
  DetalhesComanda(Item.TagString);
end;

procedure TFormPrincipal.ListarProduto(IndClear: Boolean; Busca: String);
var
  MyThread : TThread;
begin
  //Em processamento...
  if(lvProdutos.TagString = 'Processando')then
    exit;
  //--------------------
  lvProdutos.TagString := 'Processando';
  if(IndClear)then
  begin
    lvProdutos.ScrollTo(0);//Move para o Inicio;
    lvProdutos.Tag := 0;
    lvProdutos.Items.Clear;
  end;
  lvProdutos.BeginUpdate;
  MyThread := TThread.CreateAnonymousThread(
  procedure
  var
    i: Integer;
    Erro: String;
    JSONArray: TJSONArray;
  begin
    if(lvProdutos.Tag>=0)then
      lvProdutos.Tag := lvProdutos.Tag + 1;
    if not(DM.ListarProdutos(0,EditBuscaProduto.Text,lvProdutos.Tag,JSONArray,Erro))then
    begin
      TThread.Synchronize(nil,
      procedure
      begin
        ShowMessage('Erro ao Carregar Produtos ' + Erro);
      end);
      Exit;
    end;
    for i:= 0 to Pred(JSONArray.Size)do
    begin
      TThread.Synchronize(
      nil,
      procedure
      begin
        AddProdutoLv(JSONArray.Get(i).GetValue<Integer>('ID_PRODUTO'),
        JSONArray.Get(i).GetValue<String>('DESCRICAO'),
        JSONArray.Get(i).GetValue<Double>('PRECO'));
      end);
    end;
    if(JSONArray.Size = 0)then
      lvProdutos.Tag := -1;

    TThread.Synchronize(nil,
    procedure
    begin
      lvProdutos.EndUpdate;
    end);

    lvProdutos.TagString := '';

    JSONArray.DisposeOf;
  end);
  MyThread.OnTerminate := ThreadEnd;
  MyThread.Start;
end;

procedure TFormPrincipal.lvProdutosPaint(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);
begin
  if(lvProdutos.Items.Count>0) and (lvProdutos.Tag>=0)then
  begin
    if(lvProdutos.GetItemRect(lvProdutos.Items.Count - 3).Bottom <= lvProdutos.Height)then
    begin
      ListarProduto(False,EditBuscaProduto.Text);
    end;
  end;
end;

procedure TFormPrincipal.MudarAba(Img: TImage);
begin
  ImageAba1.Opacity := 0.6;
  ImageAba2.Opacity := 0.6;
  ImageAba3.Opacity := 0.6;
  Img.Opacity := 1;
  TabControl.GotoVisibleTab(Img.Tag, TTabTransition.Slide);

  if(Img.Tag = 1)then
      CarregarComanda;
end;

procedure TFormPrincipal.RecAddItemClick(Sender: TObject);
begin
  if(Trim(EditComanda.Text)<>'')then
    AddItem(EditComanda.Text);
end;

procedure TFormPrincipal.RecBuscaProdutoClick(Sender: TObject);
begin
  ListarProduto(True,EditBuscaProduto.Text);
end;

procedure TFormPrincipal.RecDetalhesClick(Sender: TObject);
begin
  if(Trim(EditComanda.Text)<>'')then
    DetalhesComanda(EditComanda.Text);
end;

procedure TFormPrincipal.ThreadEnd(Sender: TObject);
begin
  lvProdutos.EndUpdate;
  if(Assigned(TThread(Sender).FatalException))then
  begin
    ShowMessage('Erro ao Carregar os Produtos ' + Exception(TThread(Sender).FatalException).Message);
  end;
end;

end.
