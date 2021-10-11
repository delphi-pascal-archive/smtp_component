unit SMTPMess;

interface

uses
  SysUtils, Classes, Controls, ComCtrls, Math, StrUtils;

type

  TSMTPMess = class;

  {TBody}
  TEncodage = (Base64, QP, Bits8, Bits7, Binary);
  TTextContentType = (Plain, RichText, Html,Css,Javascript);
  TCharset  = (ASCII, ISO1, ISO2, ISO3, ISO4, ISO5, ISO6, ISO7, ISO8,
    ISO9, UTF8, Unicode);

  TBody = class(TCollectionItem)
  protected
    FEncodedText: TStringList;
    FName:    string;
    FEncodageText: TEncodage;
    FTextContentType: TTextContentType;
    FCharset: TCharset;
    procedure SetName(const AValue: string);
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
  published
    property Name: string Read FName Write SetName;
    property EncodedText: TStringList Read FEncodedText Write FEncodedText;
    property EncodageText: TEncodage Read FEncodageText Write FEncodageText;
    property TextContentType: TTextContentType
      Read FTextContentType Write FTextContentType;
    property Charset: TCharset Read FCharset Write FCharset;
  end;

  {TBodies}
  TBodies = class(TOwnedCollection)
  protected
    function GetAccount(const AIndex: integer): TBody;
    procedure SetAccount(const AIndex: integer; AAccountValue: TBody);
  public
    constructor Create(AOwner: TSMTPMess);
    function Add: TBody;
    property Items[const AIndex: integer]: TBody Read GetAccount Write SetAccount;
  end;

  {TAttachment}
  TFileContentType = (Pdf, Rtf, PostScript, Tar, Zip, GZip, MP3,WMA,RealAudio, Wav, Bmp, Gif, Jpeg, Png, Tiff,
    Mpeg, QuickTime,WMV,Flash, Avi, Octet_stream,Ogg,XHTML);

  TAttachment = class(TCollectionItem)
  protected
    FFileName: string;
    FFileEncoded: TStringList;
    FName: string;
    FEncodageFile: TEncodage;
    FFileContentType: TFileContentType;
    procedure SetName(const AValue: string);
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
  published
    property Name: string Read FName Write SetName;
    property FileEncoded: TStringList Read FFileEncoded Write FFileEncoded;
    property FileName: string Read FFileName Write FFileName;
    property EncodageFile: TEncodage Read FEncodageFile Write FEncodageFile;
    property FileContentType: TFileContentType
      Read FFileContentType Write FFileContentType;
  end;

  {TAttachments}
  TAttachments = class(TOwnedCollection)
  protected
    function GetAccount(const AIndex: integer): TAttachment;
    procedure SetAccount(const AIndex: integer; AAccountValue: TAttachment);
  public
    constructor Create(AOwner: TSMTPMess);
    function Add: TAttachment;
    property Items[const AIndex: integer]: TAttachment Read GetAccount Write SetAccount;
  end;

  {TSMTPMess}
  TContentType = (any, mixed, alternative, Digest, Related, Report,
    Signed, Encrypted, Form_Data);
  TPriority    = 1..5;

  TSMTPMess = class(TComponent)
  private
    { Private declarations }
  protected
  Fanswer:boolean;
    FAttachments: TAttachments;
    FBodies:  TBodies;
    FBCCList: TStringList;
    FCCList:  TStringList;
    FContentType: TContentType;
    FShipperName: string;
    FShipperAddress: string;
    FRecipientsNames: TStringList;
    FRecipientsAddresses: TStringList;
    FReplyAddress: string;
    FRCPT_To: string;
    FPriority: TPriority;
    FDate:    TDate;
    FSubject: string;
    { Protected declarations }
  public
    Function StringToEnCode64String(Source:string):string;
    Function FileToEnCode64String(Source:string):string;
    Function StringToEnCodeQPString(Source:string):string;
    Function FileToEnCodeQPString(Source:string):string;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property RCPT_To: string Read FRCPT_To Write FRCPT_To;
    procedure Written(Mess: TStringList);
    { Public declarations }
  published
    property Attachments: TAttachments Read FAttachments Write FAttachments;
    property Bodies: TBodies Read FBodies Write FBodies;
    property BCCList: TStringList Read FBCCList Write FBCCList;
    property CCList: TStringList Read FCCList Write FCCList;
    property Priority: TPriority Read FPriority Write FPriority default 3;
    property ShipperName: string Read FShipperName Write FShipperName nodefault;
    property ShipperAddress: string Read FShipperAddress Write FShipperAddress nodefault;
    property RecipientsNames: TStringList Read FRecipientsNames Write FRecipientsNames;
    property RecipientsAddresses: TStringList
      Read FRecipientsAddresses Write FRecipientsAddresses;
    property ReplyAddress: string Read FReplyAddress Write FReplyAddress nodefault;
    property Subject: string Read FSubject Write FSubject nodefault;
    property ContentType: TContentType
      Read FContentType Write FContentType default mixed;
    { Published declarations }
  end;

Function QuotedEncode(S1: TStream) : string;  
Function Base64Encode(S1: TStream) : string;
function CtToStr(AContentType: TContentType): string;
function TctToStr(ATextContentType: TTextContentType): string;
function CharsetToStr(ACharset: TCharset): string;
function FctToStr(AFileContentType: TFileContentType): string;
function EncToStr(AEncodage: TEncodage): string;
procedure FormatRecipientsAddresses(RA: TStringList);
procedure DeleteDuplicatedItems(List1, List2: TStringList);

procedure Register;

const
  CRLF = #13#10;

implementation

procedure Register;
begin
  RegisterComponents('Sdk', [TSMTPMess]);
end;

Function Base64Encode(S1: TStream) : string;
const
Code64: string[64]=('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/');
var
  Sg,Str: string;
  N, J: Integer;
  B: array[1..3] of Byte;
const
  LinLen = SizeOf(B)* 20;
begin
while S1.Position < S1.Size do
  begin
    N:= 0;
    Sg:= '';
      while (N < LinLen) and (S1.Position < S1.Size) do
        begin
          J:= S1.Size-S1.Position;
          if J > SizeOf(B) then
          J:= SizeOf(B);
          Inc(N, J);
          S1.ReadBuffer(B, J);
          Sg:= Sg+ Code64[(B[1] shr 2)+1];
          Sg:= Sg+ Code64[(B[1] and $03) shl 4 + (B[2] shr 4)+1];
          if J > 1 then Sg:= Sg+ Code64[(B[2] and $0F) shl 2 + (B[3] shr 6)+1]
                   else Sg:= Sg+ '=';
          if J > 2 then Sg:= Sg+ Code64[(B[3] and $3F)+1]
                   else Sg:= Sg+ '=';
        end;
    Str:=Str+Sg;
    end;
Result:=Str;
end;

Function TSMTPMess.StringToEnCode64String(Source:string):string;
Var
S1: TMemoryStream;
Begin
S1:=TMemoryStream.create;
s1.write(Source[1],length(Source));
s1.position:=0;
Result:=Base64Encode(s1);
s1.Free;
End;

Function TSMTPMess.FileToEnCode64String(Source:string):string;
Var
S1: TFileStream;
Begin
If not FileExists(Source) then
Begin
Result:='';
Exit;
End;
S1:=TFileStream.create(Source,fmOpenRead);
Result:=Base64Encode(s1);
s1.Free;
End;

Function QuotedEncode(S1: TStream) : string;
var

  Sg: string;
  C: Char;
const
  LinLen = 70;
begin
     while S1.Position < S1.Size do
      begin
        Sg:= '';
        while (Length(Sg) <= LinLen) and (S1.Position < S1.Size) do
        begin
          S1.ReadBuffer(C, SizeOf(C));
          if C in [#0..#32, '=', #128..#255] then
            Sg:= Format('%s=%.2x', [Sg, Byte(C)])
          else
            Sg:= Sg+C;
        end;
        if S1.Position = S1.Size then
     Sg:=Sg+#0;
    end;
Result:=Sg;
end;


Function TSMTPMess.StringToEncodeQPString(Source:string):string;
Var
S1: TMemoryStream;
Begin
S1:=TMemoryStream.create;
s1.write(Source[1],length(Source));
s1.position:=0;
Result:=QuotedEncode(s1);
s1.Free;
End;

Function TSMTPMess.FileToEnCodeQPString(Source:string):string;
Var
S1: TFileStream;
Begin
If not FileExists(Source) then 
Begin
Result:='';
Exit;
End;
S1:=TFileStream.create(Source,fmOpenRead);
Result:=QuotedEncode(s1);
s1.Free;
End;

function CtToStr(AContentType: TContentType): string;
const
  CtToStr: array[TContentType] of string =
    ('any', 'mixed', 'alternative', 'Digest', 'Related', 'Report', 'Signed',
    'Encrypted', 'Form_Data');
begin
  Result := CtToStr[AContentType];
end;

function TctToStr(ATextContentType: TTextContentType): string;
const
  TctToStr: array[TTextContentType] of string = ('Plain', 'RichText', 'Html','Css','Javascript');
begin
  Result := TctToStr[ATextContentType];
end;

function CharsetToStr(ACharset: TCharset): string;
const
  CharsetToStr: array[TCharset] of string =
    ('US-ASCII', 'ISO-8859-1', 'ISO-8859-2', 'ISO-8859-3', 'ISO-8859-4',
    'ISO-8859-5', 'ISO-8859-6', 'ISO-8859-7', 'ISO-8859-8',
    'ISO-8859-9', 'UTF-8', 'Unicode');
begin
  Result := CharsetToStr[ACharset];
end;

function FctToStr(AFileContentType: TFileContentType): string;
const
  FctToStr: array[TFileContentType] of
    string = ('application/pdf', 'application/rtf', 'application/postScript',
    'application/x-tar', 'application/zip', 'application/x-gZip','audio/mpeg ','audio/x-ms-wma','audio/x-realaudio ', 'audio/x-wav',
    'image/x-xbitmap', 'image/gif', 'image/jpeg', 'image/tiff','image/png','video/mpeg', 'video/quicktime','video/x-ms-wmv','video/x-shockwave-flash',
    'video/msvideo', 'application/octet-stream','application/ogg','application/xhtml+xml');
begin
  Result := FctToStr[AFileContentType];
end;

function EncToStr(AEncodage: TEncodage): string;
const
  EncToStr: array[TEncodage] of string =
    ('Base64', 'Quoted-Printable', '8Bit', '7Bit', 'Binary');
begin
  Result := EncToStr[AEncodage];
end;

{TAttachment}
constructor TAttachment.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FFileEncoded := TStringList.Create;
end;

destructor TAttachment.Destroy;
begin
  FreeAndNil(FFileEncoded);
  inherited Destroy;
end;

procedure TAttachment.SetName(const AValue: string);
begin
  FName := AValue;
end;

{TAttachments}
constructor TAttachments.Create(AOwner: TSMTPMess);
begin
  inherited Create(AOwner, TAttachment);
end;

function TAttachments.Add: TAttachment;
begin
  Result := inherited Add as TAttachment;
end;

function TAttachments.GetAccount(const AIndex: integer): TAttachment;
begin
  Result := TAttachment(inherited Items[AIndex]);
end;

procedure TAttachments.SetAccount(const AIndex: integer; AAccountValue: TAttachment);
begin
  inherited SetItem(AIndex, AAccountValue);
end;

{TBody}
constructor Tbody.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FEncodedText := TStringList.Create;
end;

destructor TBody.Destroy;
begin
  FreeAndNil(FEncodedText);
  inherited Destroy;
end;

procedure TBody.SetName(const AValue: string);
begin
  FName := AValue;
end;

{TBodies}
constructor TBodies.Create(AOwner: TSMTPMess);
begin
  inherited Create(AOwner, TBody);
end;

function TBodies.Add: TBody;
begin
  Result := inherited Add as TBody;
end;

function TBodies.GetAccount(const AIndex: integer): TBody;
begin
  Result := TBody(inherited Items[AIndex]);
end;

procedure TBodies.SetAccount(const AIndex: integer; AAccountValue: TBody);
begin
  inherited SetItem(AIndex, AAccountValue);
end;

{TSMTPMess}
constructor TSMTPMess.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBCCList := TStringList.Create;
  FCCList := TStringList.Create;
  FRecipientsNames := TStringList.Create;
  FRecipientsAddresses := TStringList.Create;
  FAttachments := TAttachments.Create(Self);
  FBodies := TBodies.Create(Self);
  FDate := Now;
end;

destructor TSMTPMess.Destroy;
begin
  FreeAndNil(FBCCList);
  FreeAndNil(FCCList);
  FreeAndNil(FRecipientsNames);
  FreeAndNil(FRecipientsAddresses);
  FreeAndNil(FAttachments);
  FreeAndNil(FBodies);
  inherited Destroy;
end;

procedure FormatRecipientsAddresses(RA: TStringList);
var
  Index:   cardinal;
  Pref, Suf, Ref: string;
  Deleted: boolean;
begin
  Deleted := True;
  for Index := (RA.Count - 1) downto 0 do
  begin
    Pref := Copy(RA.Strings[Index], 0, Pos('@', RA.Strings[Index]) - 1);
    Suf  := Copy(RA.Strings[Index], Pos('@', RA.Strings[Index]),
      length(RA.Strings[Index]));
    if Pref = '' then
      Pref := Ref
    else
    begin
      Ref     := Pref;
      Deleted := False;
    end;
    if Deleted = True then
      RA.Delete(Index)
    else
      RA.Strings[Index] := Pref + Suf;
  end;
end;

procedure DeleteDuplicatedItems(List1, List2: TStringList);
var
  Index: cardinal;
begin
  for Index := 0 to (List2.Count - 1) do
    if List1.IndexOf(List2.Strings[Index]) > -1 then
      List2.Delete(Index);
end;

procedure TSMTPMess.Written(Mess: TStringList);
var
  Index: integer;
  CcStr, BccStr, ToStr,Boundary: string;
begin
  if FRecipientsAddresses.Count <= 0 then
    Exit;
  //Initialisation des variables
  Mess.Clear;
  ToStr  := '';
  CcStr  := '';
  BccStr := '';
  Boundary:='-----=1b6b670268fcbcaedb0449becff4f435';
  //Trie et suppression de doublons dans les adresses
  FormatRecipientsAddresses(FRecipientsAddresses);
  if FCcList.Count > 0 then
    DeleteDuplicatedItems(FRecipientsAddresses, FCcList);
  if FCcList.Count > 0 then
    DeleteDuplicatedItems(FRecipientsAddresses, FBccList);
  if (FCcList.Count > 0) and (FBCcList.Count > 0) then
    DeleteDuplicatedItems(FCcList, FBccList);
  //Création des listes d'adresses
  for Index := 0 to (FRecipientsAddresses.Count - 1) do
    ToStr := ToStr + FRecipientsNames.Strings[Index] + '<' +
      FRecipientsAddresses.Strings[Index] + '>;';
  ToStr := Copy(ToStr, 0, Length(ToStr) - 1);
  if FCcList.Count > 0 then
  begin
    for Index := 0 to (FCcList.Count - 1) do
      CcStr := CcStr + '<' + FCcList.Strings[Index] + '>;';
    CcStr := Copy(CcStr, 0, Length(CcStr) - 1);
  end;
  if FBCcList.Count > 0 then
  begin
    for Index := 0 to (FBccList.Count - 1) do
      BccStr := BccStr + '<' + FBccList.Strings[Index] + '>;';
    BccStr := Copy(BccStr, 0, Length(BccStr) - 1);
  end;
  //Création du message
  with Mess do
  begin
    add('From: "' + FShipperName + '" <' + FShipperAddress + '>' + CRLF);
    if FReplyAddress <> '' then
    begin
      add('Reply-To : ' + FReplyAddress + CRLF);
      add('Return-Path : <' + FReplyAddress + '>' + CRLF);
    end;
    add('To: ' + ToStr + CRLF);
    if CcStr <> '' then
      add('Cc: ' + CcStr + CRLF);
    if BccStr <> '' then
      add('Bcc: ' + BccStr + CRLF);
    if FSubject <> '' then
      add('Subject: ' + FSubject + CRLF);
    add('Date: ' + DateToStr(FDate) + CRLF);
    if (FContentType) <> any then
    begin
      add('MIME-Version: 1.0' + CRLF);
      add('Content-Type: multipart/' + CtToStr(FContentType) +
        '; boundary="' + Boundary + '"' + CRLF+CRLF);
    end;
    if FBodies.Count > 0 then
      for Index := 0 to (FBodies.Count - 1) do
      begin
        add('--'+Boundary + CRLF);
        add('Content-Type: text/' + TctToStr(FBodies.Items[Index].TextContentType) +
          '; charset:' + CharsetToStr(FBodies.Items[Index].Charset) + CRLF);
        add('Content-Transfer-Encoding: ' +
          EncToStr(FBodies.Items[Index].EncodageText) + CRLF+CRLF );
        add(FBodies.Items[Index].EncodedText.Text + CRLF+CRLF);
      end;
    if FAttachments.Count > 0 then
      for Index := 0 to (FAttachments.Count - 1) do
      begin
        add('--'+Boundary + CRLF);
        add('Content-Type: ' +
          FctToStr(FAttachments.Items[Index].FileContentType) +
          '; name="' + FAttachments.Items[Index].FileName + '"' + CRLF);
        add('Content-Transfer-Encoding: ' +
          EncToStr(FAttachments.Items[Index].EncodageFile) + CRLF);
        add('Content-Disposition: inline; filename="' +
          FAttachments.Items[Index].FileName + '"' + CRLF+CRLF );
        add(FAttachments.Items[Index].FileEncoded.Text + CRLF + CRLF + CRLF);
      end;
    if (FContentType) <> any then add('--'+Boundary+'--'+ CRLF);
  end;
end;    

end.