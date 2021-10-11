unit UMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, SMTPMess, SMTPClient, StdCtrls;

type
  TMain = class(TForm)
    Subject_Lb: TLabel;
    Message_Lb: TLabel;
    HTML_Mess_Lb: TLabel;
    Ident_Gb: TGroupBox;
    SMTP_Lb: TLabel;
    Login_Lb: TLabel;
    Password_Lb: TLabel;
    Port_Lb: TLabel;
    Ident_Rb: TRadioButton;
    Anonym_Rb: TRadioButton;
    SMTP_Ed: TEdit;
    Login_Ed: TEdit;
    Password_Ed: TEdit;
    Port_Ed: TEdit;
    Address_Gb: TGroupBox;
    Shipper_Lb: TLabel;
    Shipper_Addr_Lb: TLabel;
    Recipient_Addr_Lb: TLabel;
    Shipper_Ed: TEdit;
    Shipper_Addr_Ed: TEdit;
    Recipient_Addr_Ed: TEdit;
    Message_Memo: TMemo;
    Subject_Ed: TEdit;
    Send_Bt: TButton;
    File_Bt: TButton;
    File_Ed: TEdit;
    HTML_Mess_Memo: TMemo;
    SMTPClient: TSMTPClient;
    OpenDialog: TOpenDialog;
    SMTPMess: TSMTPMess;
    procedure File_BtClick(Sender: TObject);
    procedure Send_BtClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Main: TMain;

implementation

{$R *.dfm}

procedure TMain.File_BtClick(Sender: TObject);
begin
  if not OpenDialog.Execute then
    Exit;
  File_Ed.Text := OpenDialog.FileName;
end;

procedure TMain.Send_BtClick(Sender: TObject);
begin
  with SMTPMess do
  begin
    ShipperName := Shipper_Ed.Text;
    ShipperAddress := Shipper_Addr_Ed.Text;
    RecipientsAddresses.Text := Recipient_Addr_Ed.Text;
    RecipientsNames.Text := 'A toi public';
    Subject     := Subject_Ed.Text;
    Priority    := 1;
    ContentType := mixed;
    with Bodies.Add do
    begin
      EncodageText := QP;
      Charset      := ISO1;
      TextContentType := Plain;
      EncodedText.Text :=StringToEncodeQPString(Message_Memo.Text);
    end;
   With Bodies.Add Do
    Begin
    EncodageText:=QP;
    Charset:=ISO1;
    TextContentType:=Html;
    EncodedText.Text:=StringToEncodeQPString(HTML_Mess_Memo.Text);
    End;
  if File_Ed.Text <> '' then
    begin
      if not FileExists(File_Ed.Text) then
        Exit;
      with Attachments.Add do
      begin
        EncodageFile := QP;
        FileContentType := Bmp;
        FileName := ExtractFileName(File_Ed.Text);
        FileEncoded.Text:=FileToEncodeQPString(File_Ed.Text);
      end;
    end;
  end;
  with SMTPClient do
  begin
    SMTPAddress := SMTP_Ed.Text;
    UserName := Login_Ed.Text;
    Password := Password_Ed.Text;
    port := StrToInt(Port_Ed.Text);
    if Ident_Rb.Checked then
      Identification := AtLogin
    else
      Identification := AtNone;
    Connect;
    if not connected then
    begin
      ShowMessage('Connection Error: ' + Error);
      Exit;
    end;
    try
      if SendMessage(SMTPMess) = True then
        ShowMessage('Messsage sended!');
    finally
      Disconnect;
    end;
  end;
end;
end.
