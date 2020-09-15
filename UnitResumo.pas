unit UnitResumo;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  FMX.Layouts,FMX.DialogService, System.JSON;

type
  TFormResumo = class(TForm)
    RecToolbar: TRectangle;
    Label1: TLabel;
    ImgFechar: TImage;
    ImgAddItem: TImage;
    RecComanda: TRectangle;
    Label2: TLabel;
    Layout1: TLayout;
    lblComanda: TLabel;
    RecAcessar: TRectangle;
    Label4: TLabel;
    RecTotal: TRectangle;
    lblTotal: TLabel;
    lvProdutos: TListView;
    ImgDel: TImage;
    procedure ImgFecharClick(Sender: TObject);
    procedure ImgAddItemClick(Sender: TObject);
    procedure RecAcessarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lvProdutosItemClickEx(const Sender: TObject; ItemIndex: Integer;
      const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
  private
    TotalComanda : Double;
    procedure AddProdutoResumo(IdConsumo,IdProduto: Integer; Descricao: String; Qtd: Integer;Preco: Double);
    procedure ListarProdutos;
  public
  end;

var
  FormResumo: TFormResumo;

implementation

{$R *.fmx}

uses UnitPrincipal, UnitDM, UnitAddItem;

procedure TFormResumo.AddProdutoResumo(IdConsumo,IdProduto: Integer; Descricao: String; Qtd: Integer;Preco: Double);
begin
  with lvProdutos.Items.Add do
  begin
    Tag := IdConsumo;
    TagString := IdProduto.ToString;
    TListItemText(Objects.FindDrawable('TxtDescricao')).Text := Qtd.ToString + ' x ' + Descricao;
    TListItemText(Objects.FindDrawable('TxtPreco')).Text     := FormatFloat('##0.00',Preco);
    TListItemImage(Objects.FindDrawable('ImgDel')).Bitmap    := ImgDel.Bitmap;
  end;
end;

procedure TFormResumo.FormShow(Sender: TObject);
begin
  ListarProdutos;
end;

procedure TFormResumo.ImgAddItemClick(Sender: TObject);
begin
  if not(Assigned(FormAddItem))then
    Application.CreateForm(TFormAddItem,FormAddItem);
  FormAddItem.TabControl.ActiveTab := FormAddItem.TabCategoria;
  FormAddItem.Comanda := lblComanda.Text;
  FormAddItem.ShowModal(
                        procedure(ModalResult: TModalResult)
                        begin
                          ListarProdutos;
                        end);
end;

procedure TFormResumo.ImgFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TFormResumo.ListarProdutos;
var
  i: Integer;
  Erro: String;
  JSONArray: TJSONArray;
begin
  TotalComanda := 0;
  lvProdutos.Items.Clear;
  if(DM.ListarProdutosComanda(lblComanda.Text,JSONArray,Erro))then
  begin
    for i:= 0 to Pred(JSONArray.Size)do
    begin
      AddProdutoResumo(JSONArray.Get(i).GetValue<Integer>('ID_CONSUMO'),
      JSONArray.Get(i).GetValue<Integer>('ID_PRODUTO'),
      JSONArray.Get(i).GetValue<String>('DESCRICAO'),
      JSONArray.Get(i).GetValue<Integer>('QTD'),
      JSONArray.Get(i).GetValue<Double>('VALOR_TOTAL'));
      TotalComanda := TotalComanda + JSONArray.Get(i).GetValue<Double>('VALOR_TOTAL');
    end;
    LblTotal.Text := FormatFloat('##0.00',TotalComanda);
  end else
  begin
    ShowMessage('Erro ao Listar Produtos da Comanda ' + Erro);
  end;
//  AddProdutoResumo(i,'Produto ' + i.ToString,i);
end;

procedure TFormResumo.lvProdutosItemClickEx(const Sender: TObject;
  ItemIndex: Integer; const LocalClickPos: TPointF;
  const ItemObject: TListItemDrawable);
begin
  if(Assigned(TListView(Sender).Selected))then
  begin
    if(ItemObject is TListItemImage)then
    begin
      TDialogService.MessageDialog('Deseja excluir o item da comanda?',
                                   TMsgDlgType.mtConfirmation,
                                   [TMsgDlgBtn.mbYes,TMsgDlgBtn.mbNo],
                                   TMsgDlgBtn.mbNo,
                                   0,
                                   procedure(const AResult: TModalResult)
                                   var
                                     Erro : String;
                                   begin
                                     if(AResult = mrYes)then
                                     begin
                                       if(Dm.ExcluirProdutoComanda(lblComanda.Text,
                                          lvProdutos.Selected.Tag,
                                          Erro))then
                                       begin
                                         ShowMessage('Item excluído');
                                         ListarProdutos;
                                       end else
                                       begin
                                         ShowMessage('Erro ao excluir item ' + Erro);
                                       end;
                                     end;
                                   end);
    end;
  end;
end;

procedure TFormResumo.RecAcessarClick(Sender: TObject);
begin
  TDialogService.MessageDialog('Confirma encerramento?',
                               TMsgDlgType.mtConfirmation,
                               [TMsgDlgBtn.mbYes,TMsgDlgBtn.mbNo],
                               TMsgDlgBtn.mbNo,
                               0,
                               procedure(const AResult: TModalResult)
                               var
                                Erro: String;
                               begin
                                 if(AResult = mrYes)then
                                 begin
                                   if(DM.EncerrarComanda(lblComanda.Text,Erro))then
                                     ShowMessage('Comanda Encerrada')
                                   else
                                    ShowMessage('Erro ao Encerrar Comanda ' + Erro);
                                 end;
                               end);
end;

end.
